"""Shared test fixtures: isolated settings and access to the contract fixtures.

Workstream-specific fixtures live in each test folder's own conftest.py.
"""

from __future__ import annotations

import json
from collections.abc import Callable, Iterator
from pathlib import Path
from typing import Any

import pytest

from app.ai.gemini import get_gateway
from app.config import Settings, get_settings
from app.core import storage, tutorials

REPO_ROOT = Path(__file__).resolve().parents[2]
CONTRACTS_DIR = REPO_ROOT / "contracts"
FIXTURES_DIR = CONTRACTS_DIR / "fixtures"


def load_fixture(name: str) -> Any:
    """Parsed JSON of ``contracts/fixtures/<name>.json``."""
    return json.loads((FIXTURES_DIR / f"{name}.json").read_text(encoding="utf-8"))


@pytest.fixture
def contract_fixture() -> Callable[[str], Any]:
    return load_fixture


@pytest.fixture
def settings(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Iterator[Settings]:
    """Settings rooted in ``tmp_path`` with no API keys.

    ``get_settings()`` returns this object for the whole test, and the storage singletons
    are reset, so nothing touches ``backend/data`` and no live API can be called.
    """
    monkeypatch.setenv("DATA_DIR", str(tmp_path / "data"))
    monkeypatch.setenv("GEMINI_API_KEY", "")
    monkeypatch.setenv("GOOGLE_MAPS_API_KEY", "")
    get_settings.cache_clear()
    get_gateway.cache_clear()
    monkeypatch.setattr(storage, "_store", None)
    monkeypatch.setattr(tutorials, "_store", None)
    yield get_settings()
    get_settings.cache_clear()
    get_gateway.cache_clear()
