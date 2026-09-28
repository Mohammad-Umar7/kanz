"""Deterministic conversion of model output into API models."""

import math
import re

import pytest

from app.ai.convert import (
    bbox_from_box2d,
    choose_primary,
    idea_id,
    quantity_display,
    split_tools,
    to_analysis,
    to_item,
)
from app.ai.llm_schemas import LlmAnalysis, LlmItem

from .conftest import fixture_analysis, llm_analysis, llm_item


class TestBoundingBoxes:
    def test_box_2d_is_converted_to_xywh_fractions(self):
        box = bbox_from_box2d([100, 200, 500, 600])
        assert (box.x, box.y, box.w, box.h) == (0.2, 0.1, 0.4, 0.4)

    def test_values_outside_the_grid_are_clamped(self):
        box = bbox_from_box2d([-50, 900, 1200, 1100])
        assert (box.x, box.y, box.w, box.h) == (0.9, 0.0, 0.1, 1.0)
        assert box.x + box.w <= 1 and box.y + box.h <= 1

    def test_fractional_boxes_are_read_as_fractions(self):
        assert bbox_from_box2d([0.1, 0.2, 0.5, 0.6]) == bbox_from_box2d([100, 200, 500, 600])

    def test_reversed_corners_are_swapped(self):
        assert bbox_from_box2d([500, 600, 100, 200]) == bbox_from_box2d([100, 200, 500, 600])

    @pytest.mark.parametrize(
        "box", [None, [], [1, 2, 3], [0, 0, 0, 0], [100, 100, 104, 900], [math.nan, 0, 100, 100], ["a", 0, 1, 1]]
    )
    def test_malformed_or_degenerate_boxes_become_none(self, box):
        assert bbox_from_box2d(box) is None


class TestQuantityAndQuality:
    @pytest.mark.parametrize(
        ("value", "unit", "estimate", "lang", "expected"),
        [
            (1, "pcs", False, "en", "1 pc"),
            (1, "bag", True, "en", "~1 bag"),
            (3, "pcs", False, "en", "3 pcs"),
            (30, "pcs", True, "en", "~30 pcs"),
            (0.5, "kg", True, "en", "~0.5 kg"),
            (2, "handful", False, "en", "2 handfuls"),
            (1, "pcs", False, "ar", "قطعة واحدة"),
            (2, "pcs", False, "ar", "قطعتان"),
            (4, "pcs", False, "ar", "4 قطع"),
            (30, "pcs", True, "ar", "حوالي 30 قطعة"),
            (0.5, "kg", True, "ar", "حوالي 0.5 كغ"),
        ],
    )
    def test_quantity_display_is_localized(self, value, unit, estimate, lang, expected):
        assert quantity_display(value, unit, estimate, lang) == expected

    @pytest.mark.parametrize(("score", "lang", "label"), [(4, "en", "Good"), (4, "ar", "جيد"), (1, "en", "Poor")])
    def test_quality_label_comes_from_the_vocabulary(self, score, lang, label):
        item = to_item(LlmItem.model_validate(llm_item(quality_score=score)), 0, lang)
        assert item.quality.label == label

    def test_out_of_range_numbers_are_clamped_not_rejected(self):
        item = to_item(LlmItem.model_validate(llm_item(quality_score=9, confidence=1.4, quantity_value=-2)), 2, "en")
        assert item.id == "item_3"
        assert item.quality.score == 5 and item.quality.label == "Like new"
        assert item.confidence == 1.0
        assert item.quantity.value == 1  # a counted item is at least one piece

    def test_resin_code_is_kept_only_for_plastics(self):
        glass = to_item(LlmItem.model_validate(llm_item(resin_code=1)), 0, "en")
        pet = to_item(LlmItem.model_validate(llm_item(category="plastic", resin_code=1)), 0, "en")
        assert glass.resin_code is None and pet.resin_code == 1

    def test_text_input_never_gets_boxes(self):
        raw = LlmAnalysis.model_validate(llm_analysis(llm_item()))
        assert to_analysis(raw, "en", source="text").items[0].bbox is None
        assert to_analysis(raw, "en", source="image").items[0].bbox is not None


class TestPhotoCheck:
    def test_unusable_photo_gets_a_localized_default_tip(self):
        raw = LlmAnalysis.model_validate(llm_analysis(usable=False, issue="too_dark"))
        photo = to_analysis(raw, "ar", source="image").photo
        assert not photo.usable and photo.issue == "too_dark"
        assert photo.retake_tip and re.search("[؀-ۿ]", photo.retake_tip)

    def test_usable_photo_without_items_asks_for_a_retake(self):
        photo = to_analysis(LlmAnalysis.model_validate(llm_analysis()), "en", source="image").photo
        assert (photo.usable, photo.issue) == (False, "no_items")
        assert photo.retake_tip

    def test_model_tip_is_kept(self):
        raw = LlmAnalysis.model_validate(llm_analysis(usable=False, issue="blurry", tip="Hold still."))
        assert to_analysis(raw, "en", source="image").photo.retake_tip == "Hold still."

    def test_empty_description_asks_for_a_better_description_not_a_photo(self):
        raw = LlmAnalysis.model_validate(llm_analysis(usable=False, issue="blurry"))
        photo = to_analysis(raw, "en", source="text").photo
        assert (photo.usable, photo.issue) == (False, "no_items")
        assert "made of" in photo.retake_tip

    def test_description_with_items_is_usable(self):
        raw = LlmAnalysis.model_validate(llm_analysis(llm_item(), usable=False, issue="too_dark"))
        assert to_analysis(raw, "en", source="text").photo.usable


class TestIdsAndTools:
    def test_idea_ids_are_stable_and_well_formed(self):
        a = idea_id("img_1", "Hanging jar lantern")
        assert a == idea_id("img_1", "Hanging jar lantern")
        assert re.fullmatch(r"idea_[0-9a-f]{8}", a)
        assert a != idea_id("img_2", "Hanging jar lantern")
        assert a != idea_id("img_1", "Herb jar")

    def test_split_tools_excludes_safety_gear_and_dedupes(self):
        needed, have, missing = split_tools(
            ["drill", "gloves", "scissors", "drill", "dust_mask", "twine"], ["scissors", "gloves"]
        )
        assert needed == ["drill", "scissors", "twine"]
        assert have == ["scissors"]
        assert missing == ["drill", "twine"]


class TestPrimaryItem:
    def test_most_confident_non_hazardous_item_is_primary(self):
        analysis = fixture_analysis("analyze_glass_jar.json")
        assert choose_primary(analysis.items) == "item_1"

    def test_hazardous_items_are_skipped(self):
        jar = fixture_analysis("analyze_glass_jar.json").items[0]
        battery = fixture_analysis("analyze_battery.json").items[0].model_copy(update={"id": "item_2"})
        confident_battery = battery.model_copy(update={"confidence": 0.99})
        assert choose_primary([confident_battery, jar]) == jar.id

    def test_all_hazardous_falls_back_to_the_first_item(self):
        battery = fixture_analysis("analyze_battery.json").items[0]
        assert choose_primary([battery]) == battery.id
        assert choose_primary([]) is None
