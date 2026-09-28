"""The facility config is validated at load, so typos fail here instead of returning no places."""

import copy
import json

import pytest

from app.places.config import config_path, get_config, load_config
from app.schemas.vocab import FACILITY_TYPES, MATERIAL_CATEGORIES


@pytest.fixture
def raw_config() -> dict:
    return json.loads(config_path().read_text(encoding="utf-8"))


def write(tmp_path, data) -> object:
    path = tmp_path / "facility_categories.json"
    path.write_text(json.dumps(data), encoding="utf-8")
    return path


def test_shipped_config_is_valid():
    cfg = get_config()
    assert cfg.version >= 1
    for key, cat in cfg.categories.items():
        assert cat.labels.en and cat.labels.ar, key
        assert set(cat.facility_types) <= set(FACILITY_TYPES)
        assert cat.google_queries.en and cat.google_queries.ar


def test_every_material_has_a_route():
    routing = get_config().routing
    assert set(routing.by_material) == set(MATERIAL_CATEGORIES)


def test_rule_pointing_at_unknown_category_is_rejected(tmp_path, raw_config):
    bad = copy.deepcopy(raw_config)
    bad["routing"]["by_material"]["glass"] = ["glas"]
    with pytest.raises(ValueError, match="glas"):
        load_config(write(tmp_path, bad))


def test_misspelled_field_is_rejected(tmp_path, raw_config):
    bad = copy.deepcopy(raw_config)
    bad["categories"]["glass"]["facilty_types"] = bad["categories"]["glass"].pop("facility_types")
    with pytest.raises(ValueError):
        load_config(write(tmp_path, bad))


def test_unknown_facility_type_is_rejected(tmp_path, raw_config):
    bad = copy.deepcopy(raw_config)
    bad["categories"]["glass"]["facility_types"] = ["bottle_bank"]
    with pytest.raises(ValueError):
        load_config(write(tmp_path, bad))


def test_osm_suffix_lookup_maps_tags_to_materials():
    lookup = get_config().material_for_osm_suffix()
    assert lookup["glass_bottles"] == "glass"
    assert lookup["cans"] == "metal"
    assert lookup["clothes"] == "textile"
    assert lookup["batteries"] == "hazardous"
