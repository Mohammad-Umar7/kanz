"""Shared fixtures for the places tests (all offline)."""

import json
from pathlib import Path

import pytest

from app.config import Settings
from app.places import service

DATA = Path(__file__).parent / "data"


@pytest.fixture(autouse=True)
def _fresh_cache():
    service.clear_cache()
    yield
    service.clear_cache()


@pytest.fixture
def overpass_sample() -> dict:
    return json.loads((DATA / "overpass_sample.json").read_text(encoding="utf-8"))


@pytest.fixture
def google_sample() -> dict:
    return json.loads((DATA / "google_sample.json").read_text(encoding="utf-8"))


@pytest.fixture
def osm_only_settings() -> Settings:
    return Settings(_env_file=None, google_maps_api_key="", places_timeout_s=5)


@pytest.fixture
def google_settings() -> Settings:
    return Settings(_env_file=None, google_maps_api_key="test-key", places_timeout_s=5)
