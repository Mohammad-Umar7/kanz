"""Material -> drop-off category routing, driven by backend/config/facility_categories.json."""

import pytest

from app.places.categories import catalog, categories_for_items, keys_for_item
from app.places.config import get_config
from tests.places.factories import make_item


@pytest.mark.parametrize(
    ("item", "expected_first"),
    [
        (make_item("i1", "Wooden crate", "wood", quality=4, reuse="high"), "wood"),
        (make_item("i1", "Cotton shirt", "textile", quality=4), "textile_donation"),
        (make_item("i1", "Torn rag", "textile", quality=1, state=("torn",)), "textile_recycling"),
        (make_item("i1", "AA batteries", "hazardous", hazards=("battery",)), "battery"),
        (make_item("i1", "Old phone", "electronics", hazards=("e_waste", "battery")), "e_waste"),
        (make_item("i1", "Aerosol can", "metal", hazards=("aerosol",)), "hazardous"),
        (make_item("i1", "Glass jar", "glass", quality=4, reuse="high"), "glass"),
        (make_item("i1", "Broken bottle", "glass", hazards=("broken_glass",)), "hazardous"),
        (make_item("i1", "Mixed packaging", "other", quality=2), "general_recycling"),
    ],
)
def test_primary_route(item, expected_first):
    assert keys_for_item(item)[0] == expected_first


def test_wearable_textile_also_offers_recycling():
    assert keys_for_item(make_item("i1", "Jeans", "textile", quality=3)) == ["textile_donation", "textile_recycling"]


def test_textile_with_hazard_is_not_donated():
    moldy = make_item("i1", "Damp towel", "textile", quality=4, hazards=("mold",))
    assert keys_for_item(moldy) == ["textile_recycling"]


def test_hazardous_item_never_goes_to_general_bins_or_donation():
    phone = make_item("i1", "Old phone", "electronics", quality=5, reuse="high", hazards=("battery", "e_waste"))
    assert keys_for_item(phone) == ["e_waste", "battery"]


def test_reusable_wood_in_good_condition_is_also_donatable():
    assert keys_for_item(make_item("i1", "Wooden crate", "wood", quality=4, reuse="high")) == ["wood", "donation"]
    assert keys_for_item(make_item("i1", "Split crate", "wood", quality=2, reuse="high")) == ["wood"]
    assert keys_for_item(make_item("i1", "Offcuts", "wood", quality=5, reuse="high", raw=True)) == ["wood"]


def test_organic_items_need_no_drop_off():
    assert keys_for_item(make_item("i1", "Banana peel", "organic")) == []


def test_categories_are_deduplicated_and_collect_item_ids():
    items = [
        make_item("item_1", "Glass jar", "glass"),
        make_item("item_2", "Metal lid", "metal"),
        make_item("item_3", "Glass bottle", "glass"),
    ]
    cats = categories_for_items(items, "en")
    assert [c.key for c in cats] == ["glass", "metal"]
    assert cats[0].item_ids == ["item_1", "item_3"]
    assert cats[1].item_ids == ["item_2"]
    assert cats[0].label == "Glass recycling"
    assert cats[0].material_categories == ["glass"]


def test_primary_routes_come_before_secondary_ones():
    items = [
        make_item("item_1", "T-shirt", "textile", quality=4),
        make_item("item_2", "Batteries", "hazardous", hazards=("battery",)),
    ]
    assert [c.key for c in categories_for_items(items, "en")] == ["textile_donation", "battery", "textile_recycling"]


def test_labels_are_localized():
    cats = categories_for_items([make_item("item_1", "Glass jar", "glass")], "ar")
    assert cats[0].label == "إعادة تدوير الزجاج"


def test_catalog_lists_every_category_without_items():
    cats = catalog("en")
    keys = [c.key for c in cats]
    assert keys == list(get_config().categories)
    for required in (
        "glass",
        "textile_donation",
        "textile_recycling",
        "battery",
        "e_waste",
        "hazardous",
        "general_recycling",
    ):
        assert required in keys
    assert all(c.item_ids == [] for c in cats)
