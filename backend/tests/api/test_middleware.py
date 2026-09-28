"""Request ids, access log, rate limiting and CORS."""

from __future__ import annotations

import logging
import re
from collections.abc import Callable

import httpx
import pytest
from fastapi import FastAPI

from app.config import Settings
from app.core.ratelimit import SlidingWindowLimiter
from app.core.request_id import request_id_var
from app.main import create_app
from tests.api.helpers import Seams, assert_error

GENERATED_ID = re.compile(r"^req_[0-9a-f]{8}$")


# ------------------------------------------------------------------------------ request id
async def test_request_id_is_generated(client: httpx.AsyncClient) -> None:
    response = await client.get("/health")
    assert GENERATED_ID.match(response.headers["X-Request-ID"])


async def test_request_ids_are_unique(client: httpx.AsyncClient) -> None:
    ids = {(await client.get("/health")).headers["X-Request-ID"] for _ in range(5)}
    assert len(ids) == 5


async def test_valid_client_request_id_is_echoed(client: httpx.AsyncClient) -> None:
    response = await client.get("/health", headers={"X-Request-ID": "app-7f3a9c21"})
    assert response.headers["X-Request-ID"] == "app-7f3a9c21"


@pytest.mark.parametrize("incoming", ["abc", "has spaces in it", "x" * 65, "semi;colon", "slash/slash"])
async def test_unsafe_client_request_id_is_replaced(client: httpx.AsyncClient, incoming: str) -> None:
    response = await client.get("/health", headers={"X-Request-ID": incoming})
    assert GENERATED_ID.match(response.headers["X-Request-ID"])


async def test_error_body_repeats_the_client_request_id(client: httpx.AsyncClient) -> None:
    response = await client.get("/v1/unknown", headers={"X-Request-ID": "trace_0042"})
    assert assert_error(response, 404, "not_found")["request_id"] == "trace_0042"


async def test_access_log_line(client: httpx.AsyncClient, caplog: pytest.LogCaptureFixture) -> None:
    caplog.set_level(logging.INFO, logger="kanz.access")
    await client.get("/health", headers={"X-Request-ID": "trace_0043"})
    record = next(r for r in caplog.records if r.name == "kanz.access")
    assert re.fullmatch(r"method=GET path=/health status=200 ms=\d+", record.getMessage())


async def test_request_id_is_visible_inside_routes(client: httpx.AsyncClient, monkeypatch: pytest.MonkeyPatch) -> None:
    """Route code (and its log lines) sees the id of the request it is serving."""
    seen: list[str | None] = []

    def catalog(lang: str) -> list[object]:
        seen.append(request_id_var.get())
        return []

    monkeypatch.setattr("app.places.categories.catalog", catalog, raising=False)
    await client.get("/v1/facilities/categories", headers={"X-Request-ID": "trace_0044"})
    assert seen == ["trace_0044"]
    assert request_id_var.get() is None


# ------------------------------------------------------------------------------ rate limit
@pytest.fixture
def limited_app(settings: Settings, seams: Seams) -> FastAPI:
    seams.returns("app.places.categories.catalog", [], sync=True)
    return create_app(settings.model_copy(update={"rate_limit_per_minute": 2}))


async def test_rate_limit_returns_429_with_retry_after(
    limited_app: FastAPI, make_client: Callable[[FastAPI], httpx.AsyncClient]
) -> None:
    async with make_client(limited_app) as client:
        for _ in range(2):
            assert (await client.get("/v1/facilities/categories")).status_code == 200
        response = await client.get("/v1/facilities/categories")

    assert_error(response, 429, "rate_limited", retryable=True)
    assert 1 <= int(response.headers["Retry-After"]) <= 60


async def test_health_and_static_are_not_rate_limited(
    limited_app: FastAPI, make_client: Callable[[FastAPI], httpx.AsyncClient]
) -> None:
    async with make_client(limited_app) as client:
        for _ in range(5):
            assert (await client.get("/health")).status_code == 200
            assert (await client.get("/static/uploads/missing.jpg")).status_code == 404
        assert (await client.get("/v1/facilities/categories")).status_code == 200


async def test_rate_limit_can_be_disabled(
    settings: Settings, seams: Seams, make_client: Callable[[FastAPI], httpx.AsyncClient]
) -> None:
    seams.returns("app.places.categories.catalog", [], sync=True)
    async with make_client(create_app(settings.model_copy(update={"rate_limit_per_minute": 0}))) as client:
        statuses = {(await client.get("/v1/facilities/categories")).status_code for _ in range(5)}
    assert statuses == {200}


class FakeClock:
    def __init__(self) -> None:
        self.now = 1000.0

    def __call__(self) -> float:
        return self.now


def test_limiter_slides_instead_of_resetting_per_minute() -> None:
    clock = FakeClock()
    limiter = SlidingWindowLimiter(3, clock=clock)
    for offset in (0, 20, 40):
        clock.now = 1000.0 + offset
        assert limiter.hit("10.0.0.2") == 0
    clock.now = 1050.0
    assert limiter.hit("10.0.0.2") == pytest.approx(10.0)  # the first hit leaves the window at 1060
    clock.now = 1060.5
    assert limiter.hit("10.0.0.2") == 0
    assert limiter.hit("10.0.0.3") == 0  # other clients are counted separately


def test_limiter_forgets_idle_clients() -> None:
    clock = FakeClock()
    limiter = SlidingWindowLimiter(1, clock=clock, max_keys=2)
    limiter.hit("a")
    limiter.hit("b")
    clock.now += 61
    limiter.hit("c")
    assert set(limiter._hits) == {"c"}


# ------------------------------------------------------------------------------------ CORS
async def test_cors_headers_on_simple_request(client: httpx.AsyncClient) -> None:
    response = await client.get("/health", headers={"Origin": "http://localhost:5173"})
    assert response.headers["access-control-allow-origin"] == "*"
    assert "x-request-id" in response.headers["access-control-expose-headers"].lower()


async def test_cors_preflight(client: httpx.AsyncClient) -> None:
    response = await client.options(
        "/v1/analyze",
        headers={
            "Origin": "http://localhost:5173",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "content-type,x-request-id",
        },
    )
    assert response.status_code == 200
    assert "POST" in response.headers["access-control-allow-methods"]
