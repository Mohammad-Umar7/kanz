"""Contract guards: vocabularies, the app's copy of them, and the JSON fixtures.

The backend, the Flutter app and the fixtures all describe the same API. These tests fail
as soon as one of them drifts: a tool id added to the Literals but not to vocab.json, an
app asset that is no longer an exact copy, or a fixture the schemas no longer accept.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import pytest
from pydantic import BaseModel

from app.schemas import vocab
from app.schemas.analysis import AnalyzeResponse
from app.schemas.common import ErrorResponse
from app.schemas.facilities import FacilitiesResponse, FacilityCategoriesResponse
from app.schemas.health import HealthResponse
from app.schemas.images import ImageResponse
from app.schemas.recommend import RecommendRequest, RecommendResponse
from app.schemas.swaps import SwapsRequest, SwapsResponse
from app.schemas.tutorial import TutorialRequest, TutorialResponse

REPO_ROOT = Path(__file__).resolve().parents[2]
CONTRACTS_DIR = REPO_ROOT / "contracts"
FIXTURES_DIR = CONTRACTS_DIR / "fixtures"
VOCAB_PATH = CONTRACTS_DIR / "vocab.json"
APP_VOCAB_PATH = REPO_ROOT / "app" / "assets" / "config" / "vocab.json"

# Fixture file name prefix -> schema. Order matters: the first matching prefix wins, so
# the request prefixes come before the response prefixes they start with.
FIXTURE_SCHEMAS: list[tuple[str, type[BaseModel]]] = [
    ("analyze_", AnalyzeResponse),
    ("recommend_request_", RecommendRequest),
    ("recommend_", RecommendResponse),
    ("tutorial_request_", TutorialRequest),
    ("tutorial_", TutorialResponse),
    ("image_", ImageResponse),
    ("facilities_", FacilitiesResponse),
    ("facility_categories", FacilityCategoriesResponse),
    ("swaps_request", SwapsRequest),
    ("swaps_", SwapsResponse),
    ("health", HealthResponse),
    ("error_", ErrorResponse),
]

FIXTURE_PATHS = sorted(FIXTURES_DIR.glob("*.json"))


def _vocab() -> dict[str, Any]:
    return json.loads(VOCAB_PATH.read_text(encoding="utf-8"))


def _ids(section: str) -> list[str]:
    return [entry["id"] for entry in _vocab()[section]]


def schema_for(path: Path) -> type[BaseModel]:
    for prefix, model in FIXTURE_SCHEMAS:
        if path.stem.startswith(prefix):
            return model
    raise LookupError(f"no schema mapped for fixture {path.name}")


# ---------------------------------------------------------------------------- vocabularies
@pytest.mark.parametrize(
    ("section", "literal_ids"),
    [
        ("materials", vocab.MATERIAL_CATEGORIES),
        ("tools", vocab.TOOL_IDS),
        ("state_tags", vocab.STATE_TAGS),
        ("hazards", vocab.HAZARD_FLAGS),
        ("facility_types", vocab.FACILITY_TYPES),
        ("cities", vocab.CITY_IDS),
    ],
)
def test_vocab_ids_match_literals(section: str, literal_ids: tuple[str, ...]) -> None:
    assert tuple(_ids(section)) == literal_ids


def test_disposal_only_hazards_match() -> None:
    assert set(_vocab()["disposal_only_hazards"]) == vocab.DISPOSAL_ONLY_HAZARDS
    assert vocab.DISPOSAL_ONLY_HAZARDS.issubset(vocab.HAZARD_FLAGS)


def test_safety_tools_match_safety_gear() -> None:
    tools = _vocab()["tools"]
    assert {tool["kind"] for tool in tools} == {"tool", "safety"}
    assert {tool["id"] for tool in tools if tool["kind"] == "safety"} == vocab.SAFETY_GEAR


def test_every_vocab_entry_has_both_languages() -> None:
    data = _vocab()
    for section in ("materials", "tools", "state_tags", "hazards", "facility_types", "cities", "quality_labels"):
        for entry in data[section]:
            assert entry["en"].strip(), (section, entry)
            assert entry["ar"].strip(), (section, entry)
    assert [label["score"] for label in data["quality_labels"]] == [1, 2, 3, 4, 5]


def test_app_vocab_is_an_exact_copy() -> None:
    assert APP_VOCAB_PATH.read_bytes() == VOCAB_PATH.read_bytes(), (
        "app/assets/config/vocab.json must be a byte-for-byte copy of contracts/vocab.json"
    )


# -------------------------------------------------------------------------------- fixtures
def test_fixtures_exist() -> None:
    assert len(FIXTURE_PATHS) >= 12


@pytest.mark.parametrize("path", FIXTURE_PATHS, ids=lambda p: p.stem)
def test_fixture_matches_its_schema(path: Path) -> None:
    model = schema_for(path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    parsed = model.model_validate(raw)
    # Round trip: the fixture holds every field explicitly, exactly as the API serializes it.
    assert parsed.model_dump(mode="json") == raw
