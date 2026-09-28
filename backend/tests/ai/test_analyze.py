"""The analyze graph end to end with a scripted model: photo and text input, safety, photo check."""

import re

import pytest

from app.ai import pipeline
from app.ai.classifier import ClassifierHint, NoOpClassifier, get_classifier
from app.ai.llm_schemas import LlmAnalysis
from app.core.errors import BadRequest

from .conftest import FakeGateway, jpeg_bytes, llm_analysis, llm_item


def jar_and_lid() -> dict:
    lid = llm_item(
        name="Metal jar lid",
        category="metal",
        material="Tin-plated steel",
        confidence=0.81,
        box_2d=[150, 330, 230, 650],
        reuse_level="medium",
    )
    return llm_analysis(llm_item(), lid, summary="An empty glass jam jar with its metal lid.")


async def test_photo_analysis_converts_everything_deterministically():
    gateway = FakeGateway({LlmAnalysis: jar_and_lid()})
    res = await pipeline.analyze(image=jpeg_bytes(), text=None, lang="en", gateway=gateway)

    assert res.image_id.startswith("img_") and res.image_url.endswith(f"{res.image_id}.jpg")
    assert (res.image_width, res.image_height) == (640, 480)
    items = res.analysis.items
    assert [it.id for it in items] == ["item_1", "item_2"]
    assert items[0].bbox.x == 0.31 and items[0].bbox.h == 0.62
    assert items[0].quality.label == "Good" and items[0].quantity.display == "1 pc"
    assert res.analysis.primary_item_id == "item_1"
    assert res.analysis.source == "image"
    assert {"upload", "analysis", "safety", "total"} <= set(res.timings_ms)

    call = gateway.calls[0]
    assert call["stage"].startswith("material_analyst@v")
    assert call["media_resolution"] == "medium"
    assert any(getattr(part, "inline_data", None) for part in call["contents"])  # the photo is sent
    assert "English" in call["system"]


async def test_text_input_has_no_boxes_and_a_text_id():
    gateway = FakeGateway({LlmAnalysis: llm_analysis(llm_item(name="Plastic bottle caps", category="plastic"))})
    res = await pipeline.analyze(image=None, text="about thirty bottle caps", lang="en", gateway=gateway)
    assert res.image_id.startswith("txt_") and res.image_url is None
    assert res.analysis.source == "text"
    assert res.analysis.items[0].bbox is None
    assert '"about thirty bottle caps"' in gateway.calls[0]["contents"][0]
    assert gateway.calls[0]["media_resolution"] is None


async def test_under_reported_battery_is_flagged_and_not_primary():
    cells = llm_item(name="AA batteries", category="other", material="Alkaline cells", hazards=[], confidence=0.97)
    jar = llm_item(confidence=0.6)
    res = await pipeline.analyze(
        image=jpeg_bytes(), text=None, lang="en", gateway=FakeGateway({LlmAnalysis: llm_analysis(cells, jar)})
    )
    battery = res.analysis.items[0]
    assert battery.hazards == ["battery"] and battery.category == "hazardous"
    assert res.analysis.primary_item_id == "item_2"


async def test_unclear_photo_asks_for_one_specific_retake():
    blurry = llm_analysis(usable=False, issue="blurry", tip=None, summary="Too blurred to tell.")
    res = await pipeline.analyze(image=jpeg_bytes(), text=None, lang="en", gateway=FakeGateway({LlmAnalysis: blurry}))
    assert res.analysis.photo.usable is False
    assert res.analysis.photo.issue == "blurry"
    assert res.analysis.photo.retake_tip
    assert res.analysis.items == [] and res.analysis.primary_item_id is None


async def test_arabic_labels_and_language_prompt():
    arabic = llm_analysis(
        llm_item(name="برطمان زجاجي", material="زجاج شفاف", reuse_note="زجاج سميك"), summary="برطمان زجاجي فارغ."
    )
    gateway = FakeGateway({LlmAnalysis: arabic})
    res = await pipeline.analyze(image=jpeg_bytes(), text=None, lang="ar", gateway=gateway)
    item = res.analysis.items[0]
    assert item.quality.label == "جيد" and item.quantity.display == "قطعة واحدة"
    assert "Modern Standard Arabic" in gateway.calls[0]["system"]
    assert gateway.problems == []


async def test_wrong_language_gets_one_repair_round():
    english = llm_analysis(llm_item(), summary="An empty jar.")
    arabic = llm_analysis(llm_item(name="برطمان", reuse_note="زجاج سميك"), summary="برطمان فارغ.")
    gateway = FakeGateway({LlmAnalysis: [english, arabic]})
    res = await pipeline.analyze(image=jpeg_bytes(), text=None, lang="ar", gateway=gateway)
    assert res.analysis.items[0].name == "برطمان"
    assert gateway.problems and "Arabic" in gateway.problems[0][0]


async def test_language_problems_never_fail_the_scan():
    english = llm_analysis(llm_item(), summary="An empty jar.")
    res = await pipeline.analyze(
        image=jpeg_bytes(), text=None, lang="ar", gateway=FakeGateway({LlmAnalysis: [english, english]})
    )
    assert res.analysis.items  # soft rules are not re-checked on the repair round


async def test_classifier_hint_reaches_the_prompt_and_the_response(monkeypatch):
    class Stub:
        name = "stub"

        def classify(self, image: bytes):
            return ClassifierHint(label="glass jar", category="glass", confidence=0.91, source="stub")

    monkeypatch.setattr("app.ai.nodes.analyst.get_classifier", Stub)
    gateway = FakeGateway({LlmAnalysis: jar_and_lid()})
    res = await pipeline.analyze(image=jpeg_bytes(), text=None, lang="en", gateway=gateway)
    assert res.analysis.classifier_hint == "glass jar (0.91, stub)"
    assert "glass jar (0.91, stub)" in gateway.calls[0]["system"]


def test_default_classifier_is_the_no_op():
    assert isinstance(get_classifier(), NoOpClassifier)
    assert NoOpClassifier().classify(b"") is None


async def test_nothing_to_analyze_is_a_bad_request():
    with pytest.raises(BadRequest):
        await pipeline.analyze(image=None, text="   ", lang="en", gateway=FakeGateway())


async def test_prompt_placeholders_are_all_filled():
    gateway = FakeGateway({LlmAnalysis: jar_and_lid()})
    await pipeline.analyze(image=jpeg_bytes(), text=None, lang="en", gateway=gateway)
    assert not re.search(r"\{[a-z_]+\}", gateway.calls[0]["system"])
