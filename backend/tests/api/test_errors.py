"""Error mapping: KanzError codes, validation messages, framework errors and crashes."""

from __future__ import annotations

import logging

import httpx
import pytest

from app.core.error_handlers import describe_validation_error
from app.core.errors import (
    AiInvalidOutput,
    AiQuotaExhausted,
    AiTimeout,
    AiUnavailable,
    ImageInvalid,
    KanzError,
    NotFound,
    PlacesUnavailable,
)
from app.schemas.analysis import AnalyzeResponse
from tests.api.helpers import Seams, assert_error
from tests.conftest import load_fixture

SWAPS = "app.swaps.service.suggest"


@pytest.mark.parametrize(
    ("error", "expected"),
    [
        (AiUnavailable(detail="503 UNAVAILABLE upstream"), (503, "ai_unavailable", True)),
        (AiTimeout(detail="stage swap_advisor exceeded 30s"), (504, "ai_timeout", True)),
        (AiInvalidOutput(detail="validation failed twice"), (502, "ai_invalid_output", True)),
        (AiQuotaExhausted(detail="429 RESOURCE_EXHAUSTED limit: 0"), (503, "ai_quota_exhausted", False)),
        (NotFound(detail="tutorial tut_x missing"), (404, "not_found", False)),
        (ImageInvalid(detail="cannot identify image file"), (400, "image_invalid", False)),
    ],
    ids=lambda value: value.code if isinstance(value, KanzError) else "",
)
async def test_kanz_errors_keep_status_code_and_retryable(
    client: httpx.AsyncClient, seams: Seams, error: KanzError, expected: tuple[int, str, bool]
) -> None:
    status, code, retryable = expected
    seams.raises(SWAPS, error)
    response = await client.post("/v1/swaps", json={"materials": ["plastic bags"]})
    body = assert_error(response, status, code, retryable=retryable)
    assert body["message"] == error.message
    assert error.detail is not None
    assert error.detail not in response.text  # details are logged, never sent


async def test_places_unavailable(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.raises("app.places.service.search", PlacesUnavailable(detail="overpass 504"))
    response = await client.post("/v1/facilities", json={"categories": ["glass"], "lat": 24.45, "lng": 54.38})
    assert_error(response, 503, "places_unavailable", retryable=True)


async def test_custom_message_is_sent(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.raises(SWAPS, AiUnavailable("AI is not configured on this server."))
    body = assert_error(await client.post("/v1/swaps", json={}), 503, "ai_unavailable")
    assert body["message"] == "AI is not configured on this server."


async def test_unexpected_exception_is_500_without_details(
    client: httpx.AsyncClient, seams: Seams, caplog: pytest.LogCaptureFixture
) -> None:
    seams.raises(SWAPS, RuntimeError("database password is hunter2"))
    response = await client.post("/v1/swaps", json={})
    assert_error(response, 500, "internal", retryable=False)
    assert "hunter2" not in response.text
    assert "Traceback" in caplog.text
    assert "RuntimeError" in caplog.text


async def test_a_seam_returning_the_wrong_shape_is_500(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns(SWAPS, AnalyzeResponse.model_validate(load_fixture("analyze_glass_jar")))
    assert_error(await client.post("/v1/swaps", json={}), 500, "internal")


async def test_missing_seam_is_500(client: httpx.AsyncClient, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delattr(SWAPS, raising=False)
    assert_error(await client.post("/v1/swaps", json={}), 500, "internal")


# ------------------------------------------------------------------------------ validation
async def test_missing_field_names_it(client: httpx.AsyncClient) -> None:
    response = await client.post("/v1/recommend", json={"image_id": "img_3f9a1c2b7d4e5f60"})
    assert assert_error(response, 422, "bad_request")["message"] == "'analysis' is required."


async def test_nested_field_is_named_with_its_path(client: httpx.AsyncClient) -> None:
    request = load_fixture("recommend_request_glass_jar")
    request["analysis"]["items"][0]["category"] = "unobtainium"
    message = assert_error(await client.post("/v1/recommend", json=request), 422, "bad_request")["message"]
    assert message.startswith("'analysis.items[0].category' is invalid: Input should be 'glass'")


async def test_unknown_field_is_rejected(client: httpx.AsyncClient) -> None:
    response = await client.post("/v1/swaps", json={"materials": [], "colour": "green"})
    assert assert_error(response, 422, "bad_request")["message"] == "'colour' is not a known field."


async def test_malformed_json(client: httpx.AsyncClient) -> None:
    response = await client.post("/v1/swaps", content=b"{not json", headers={"Content-Type": "application/json"})
    assert assert_error(response, 422, "bad_request")["message"] == "The request body is not valid JSON."


def test_long_validation_messages_are_shortened() -> None:
    message = describe_validation_error(
        [{"type": "literal_error", "loc": ("body", "profile", "tools", 3), "msg": "Input should be " + "x" * 400}]
    )
    assert message.startswith("'profile.tools[3]' is invalid: Input should be")
    assert message.endswith("...")
    assert len(message) < 240


def test_model_level_validation_message() -> None:
    errors = [{"type": "value_error", "loc": ("body",), "msg": "Value error, Provide lat and lng, or a city."}]
    assert describe_validation_error(errors) == "Provide lat and lng, or a city."
    assert describe_validation_error([]) == "Some fields are missing or invalid."


# ------------------------------------------------------------------------ framework errors
async def test_unknown_route_is_404(client: httpx.AsyncClient) -> None:
    assert_error(await client.get("/v1/nothing-here"), 404, "not_found")


async def test_wrong_method_is_405(client: httpx.AsyncClient) -> None:
    response = await client.get("/v1/recommend")
    assert_error(response, 405, "bad_request")
    assert "POST" in response.headers["allow"]


async def test_client_errors_are_logged_quietly(
    client: httpx.AsyncClient, seams: Seams, caplog: pytest.LogCaptureFixture
) -> None:
    caplog.set_level(logging.INFO, logger="kanz.errors")
    seams.raises(SWAPS, NotFound(detail="swap card swap_x missing"))
    await client.post("/v1/swaps", json={})
    record = next(r for r in caplog.records if r.name == "kanz.errors")
    assert record.levelno == logging.INFO
    assert "code=not_found status=404" in record.getMessage()
    assert "swap card swap_x missing" in record.getMessage()
