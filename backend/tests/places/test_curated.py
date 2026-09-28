"""The curated facilities file: schema, validation at load and conversion to candidates."""

import json
from datetime import date, timedelta

from app.config import get_settings
from app.places import curated
from app.places.curated import CuratedFacility, load_curated


def entry(**overrides) -> dict:
    base = {
        "id": "test_clothes_bin",
        "name": "Synthetic clothes bin",
        "name_ar": "حاوية ملابس تجريبية",
        "lat": 24.46,
        "lng": 54.38,
        "address": "Test car park",
        "city": "abu_dhabi",
        "facility_types": ["donation", "collection_point"],
        "category_keys": ["textile_donation"],
        "accepted_materials": ["textile"],
        "phone": "+971 2 000 0000",
        "website": "https://example.org",
        "verified_by": "QA",
        "verified_on": "2026-09-01",
    }
    base.update(overrides)
    return base


def write(tmp_path, data) -> object:
    path = tmp_path / "curated_facilities.json"
    path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    return path


def test_shipped_file_is_an_empty_valid_list():
    loaded = load_curated(get_settings().config_dir / curated.CURATED_FILE)
    assert loaded.entries == []
    assert loaded.problems == []


def test_schema_file_matches_the_model():
    schema = json.loads((get_settings().config_dir / "curated_facilities.schema.json").read_text(encoding="utf-8"))
    items = schema["items"]
    model = CuratedFacility.model_json_schema()
    assert set(items["properties"]) == set(model["properties"])
    assert set(items["required"]) == set(model["required"])
    assert items["additionalProperties"] is False


def test_valid_entry_loads(tmp_path):
    loaded = load_curated(write(tmp_path, [entry()]))
    assert loaded.problems == []
    [facility] = loaded.entries
    assert facility.verified_on == date(2026, 9, 1)


def test_bad_entries_are_rejected_and_the_rest_still_load(tmp_path):
    data = [
        entry(id="good_one"),
        entry(id="bad_category", category_keys=["glas"]),
        entry(id="bad_lat", lat=124.0),
        entry(id="extra_field", opening_hours="24/7"),
        entry(id="future", verified_on=(date.today() + timedelta(days=3)).isoformat()),
        entry(id="good_one"),
    ]
    loaded = load_curated(write(tmp_path, data))
    assert [f.id for f in loaded.entries] == ["good_one"]
    assert len(loaded.problems) == 5
    joined = " ".join(loaded.problems)
    for rejected in ("bad_category", "bad_lat", "extra_field", "future", "duplicate id"):
        assert rejected in joined


def test_a_file_that_is_not_a_list_is_reported(tmp_path):
    loaded = load_curated(write(tmp_path, {"id": "x"}))
    assert loaded.entries == []
    assert loaded.problems


def test_candidates_filter_by_category_and_localize(tmp_path):
    entries = load_curated(write(tmp_path, [entry(), entry(id="glass_bank", category_keys=["glass"])])).entries
    ar = curated.candidates(["textile_donation"], "ar", entries)
    assert [c.id for c in ar] == ["cur:test_clothes_bin"]
    assert ar[0].name == "حاوية ملابس تجريبية"
    assert ar[0].source == "curated"
    assert ar[0].verified_by == "QA"
    assert ar[0].accepted_materials == ["textile"]
    en = curated.candidates(["glass", "textile_donation"], "en", entries)
    assert [c.name for c in en] == ["Synthetic clothes bin", "Synthetic clothes bin"]
    assert en[1].category_keys == ["glass"]
