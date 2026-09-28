"""GET /health, the root redirect, the OpenAPI error docs and the startup lifespan."""

from __future__ import annotations

import asyncio
import logging
from collections.abc import Callable

import httpx
import pytest
from fastapi import FastAPI

from app.config import Settings
from app.main import create_app
from app.schemas.health import HealthResponse
from tests.api.helpers import Seams


async def test_health_reports_configuration(
    settings: Settings, seams: Seams, make_client: Callable[[FastAPI], httpx.AsyncClient]
) -> None:
    seams.returns("app.ai.rag.status", (96, True), sync=True)
    configured = settings.model_copy(update={"gemini_api_key": "test-key", "google_maps_api_key": "test-maps-key"})
    async with make_client(create_app(configured)) as client:
        response = await client.get("/health")

    assert response.status_code == 200
    health = HealthResponse.model_validate(response.json())
    assert health.status == "ok"
    assert health.ai_configured is True
    assert health.knowledge_docs == 96
    assert health.rag_ready is True
    assert health.places_google is True
    assert health.places_osm is True
    assert health.models == {
        "vision": settings.model_vision,
        "text": settings.model_text,
        "image": settings.model_image,
        "embed": settings.model_embed,
    }
    assert health.version == settings.version
    assert health.uptime_s >= 0
    assert "test-key" not in response.text


async def test_health_is_degraded_without_gemini_key(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns("app.ai.rag.status", (0, False), sync=True)
    body = (await client.get("/health")).json()
    assert body["status"] == "degraded"
    assert body["ai_configured"] is False
    assert body["places_google"] is False


async def test_health_survives_a_broken_knowledge_base(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.raises("app.ai.rag.status", RuntimeError("chroma is down"), sync=True)
    response = await client.get("/health")
    assert response.status_code == 200
    assert response.json()["knowledge_docs"] == 0
    assert response.json()["rag_ready"] is False


async def test_health_survives_a_missing_knowledge_base(
    client: httpx.AsyncClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.delattr("app.ai.rag.status", raising=False)
    response = await client.get("/health")
    assert response.status_code == 200
    assert (response.json()["knowledge_docs"], response.json()["rag_ready"]) == (0, False)


async def test_root_redirects_to_docs(client: httpx.AsyncClient) -> None:
    response = await client.get("/")
    assert response.status_code == 307
    assert response.headers["location"] == "/docs"


def test_openapi_documents_error_envelope(app: FastAPI) -> None:
    spec = app.openapi()
    analyze = spec["paths"]["/v1/analyze"]["post"]["responses"]
    assert {"400", "413", "422", "429", "500", "502", "503", "504"} <= set(analyze)
    too_large = analyze["413"]["content"]["application/json"]
    assert too_large["schema"]["$ref"].endswith("/ErrorResponse")
    assert too_large["example"]["error"]["code"] == "image_too_large"
    places = spec["paths"]["/v1/facilities"]["post"]["responses"]["503"]["content"]["application/json"]
    assert places["example"]["error"]["code"] == "places_unavailable"


async def test_lifespan_seeds_knowledge_in_background(
    app: FastAPI, seams: Seams, caplog: pytest.LogCaptureFixture
) -> None:
    calls = seams.returns("app.ai.rag.seed_knowledge", 42)
    caplog.set_level(logging.INFO)
    async with app.router.lifespan_context(app):
        await app.state.seed_task
    assert len(calls) == 1
    assert "knowledge_seeded docs=42" in caplog.text
    assert "config environment=" in caplog.text


async def test_lifespan_survives_seeding_failure(
    app: FastAPI, seams: Seams, caplog: pytest.LogCaptureFixture, make_client: Callable[[FastAPI], httpx.AsyncClient]
) -> None:
    seams.raises("app.ai.rag.seed_knowledge", RuntimeError("embedding quota"))
    seams.returns("app.ai.rag.status", (0, False), sync=True)
    async with app.router.lifespan_context(app):
        await app.state.seed_task
        async with make_client(app) as client:
            assert (await client.get("/health")).status_code == 200
    assert "knowledge_seed_failed" in caplog.text


async def test_lifespan_cancels_unfinished_seeding_on_shutdown(app: FastAPI, monkeypatch: pytest.MonkeyPatch) -> None:
    async def never_finishes() -> int:
        await asyncio.Event().wait()
        return 0

    monkeypatch.setattr("app.ai.rag.seed_knowledge", never_finishes, raising=False)
    async with app.router.lifespan_context(app):
        task = app.state.seed_task
        await asyncio.sleep(0)
    assert task.cancelled()


def test_config_summary_never_logs_secrets(settings: Settings, caplog: pytest.LogCaptureFixture) -> None:
    from app.main import log_config_summary  # noqa: PLC0415

    caplog.set_level(logging.INFO)
    log_config_summary(settings.model_copy(update={"gemini_api_key": "AIza-secret", "google_maps_api_key": "maps"}))
    assert "gemini_key=True maps_key=True" in caplog.text
    assert "AIza-secret" not in caplog.text
