"""Input normalization (chip ids, free text) and the deterministic history insight."""

import pytest

from app.schemas.swaps import HistorySummary
from app.swaps.inputs import MAX_INPUTS, normalize_inputs
from app.swaps.insight import history_insight, history_query


def test_chip_ids_become_readable_text_in_the_request_language():
    en = normalize_inputs(["plastic_bags", "cling_film", "batteries"], "en")
    assert [i.label for i in en] == ["plastic bags", "cling film", "batteries"]
    ar = normalize_inputs(["plastic_bags", "wet_wipes"], "ar")
    assert [i.label for i in ar] == ["أكياس بلاستيكية", "مناديل مبللة"]
    assert [i.query for i in ar] == ["plastic bags", "wet wipes"]  # retrieval stays in English


def test_unknown_chip_ids_and_free_text():
    inputs = normalize_inputs(["egg_cartons", "  old   phone chargers ", "أكياس الخبز"], "en")
    assert [i.label for i in inputs] == ["egg cartons", "old phone chargers", "أكياس الخبز"]


def test_typed_lists_are_split_into_separate_inputs():
    assert [i.label for i in normalize_inputs(["plastic bags, cling film"], "en")] == ["plastic bags", "cling film"]
    assert [i.label for i in normalize_inputs(["أكياس الخبز، علب العصير"], "ar")] == ["أكياس الخبز", "علب العصير"]


def test_empty_and_duplicate_inputs_are_dropped_and_the_list_is_capped():
    inputs = normalize_inputs(["plastic_bags", "", "Plastic Bags", "   ", *[f"item {c}" for c in "abcdefgh"]], "en")
    assert inputs[0].label == "plastic bags"
    assert len(inputs) == MAX_INPUTS
    assert len({i.label.casefold() for i in inputs}) == len(inputs)


@pytest.mark.parametrize(
    ("days", "lang", "expected"),
    [
        (30, "en", "You scanned 6 plastic bottles this month."),
        (7, "en", "You scanned 6 plastic bottles this week."),
        (14, "en", "You scanned 6 plastic bottles in the last 14 days."),
        (30, "ar", "مسحت «plastic bottle» 6 مرات هذا الشهر."),
        (14, "ar", "مسحت «plastic bottle» 6 مرات خلال آخر 14 يومًا."),
    ],
)
def test_history_insight_names_the_top_item(days, lang, expected):
    history = HistorySummary(
        period_days=days, counts={"plastic": 6, "glass": 2}, top_items=["plastic bottle"], top_item_counts=[6]
    )
    assert history_insight(history, lang) == expected


def test_english_plurals_and_capitalization():
    def line(item: str, n: int) -> str:
        return history_insight(HistorySummary(top_items=[item], top_item_counts=[n]), "en")

    assert line("Glass jar", 3) == "You scanned 3 glass jars this month."
    assert line("cardboard box", 2) == "You scanned 2 cardboard boxes this month."
    assert line("PET bottle", 1) == "You scanned 1 PET bottle this month."
    assert line("denim jeans", 4) == "You scanned 4 denim jeans this month."


def test_arabic_count_agreement():
    def line(n: int) -> str:
        return history_insight(HistorySummary(top_items=["علبة"], top_item_counts=[n]), "ar")

    assert "مرة واحدة" in line(1)
    assert "مرتين" in line(2)
    assert "12 مرة" in line(12)


def test_insight_from_material_counts_only():
    history = HistorySummary(counts={"plastic": 6, "glass": 2})
    assert history_insight(history, "en") == "Plastic made up 6 of the 8 items you scanned this month."
    assert history_insight(history, "ar") == "الأكثر بين ما مسحته هذا الشهر: البلاستيك (6 من 8)."
    only = HistorySummary(counts={"paper": 3})
    assert history_insight(only, "en") == "Everything you scanned this month was paper and cardboard (3 items)."


def test_no_history_means_no_insight():
    assert history_insight(None, "en") is None
    assert history_insight(HistorySummary(), "en") is None


def test_history_query_uses_items_then_materials():
    history = HistorySummary(
        counts={"plastic": 6, "glass": 2, "paper": 1},
        top_items=["plastic bottle", "glass jar"],
        top_item_counts=[6, 2],
    )
    assert history_query(history) == "plastic bottle glass jar plastic glass"
    assert history_query(None) is None
