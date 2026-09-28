"""API test fixtures: an app built on temporary settings, an async client, and seam stubs.

Nothing here reaches Gemini, Places or the file system outside ``tmp_path``: seams are
replaced per test (see ``helpers.Seams``) and settings come from the root ``settings``
fixture.
"""

from __future__ import annotations

from collections.abc import AsyncIterator, Callable

import httpx
import pytest
from fastapi import FastAPI

from app.config import Settings
from app.main import create_app
from tests.api.helpers import Seams


@pytest.fixture
def seams(monkeypatch: pytest.MonkeyPatch) -> Seams:
    return Seams(monkeypatch)


@pytest.fixture
def app(settings: Settings) -> FastAPI:
    return create_app(settings)


@pytest.fixture
def make_client() -> Callable[[FastAPI], httpx.AsyncClient]:
    def build(app: FastAPI) -> httpx.AsyncClient:
        transport = httpx.ASGITransport(app=app, raise_app_exceptions=False)
        return httpx.AsyncClient(transport=transport, base_url="http://testserver")

    return build


@pytest.fixture
async def client(app: FastAPI, make_client: Callable[[FastAPI], httpx.AsyncClient]) -> AsyncIterator[httpx.AsyncClient]:
    async with make_client(app) as c:
        yield c
