"""The Swap Advisor's schema and validator: what the model may cite and say."""

from types import SimpleNamespace

import pytest
from pydantic import ValidationError

from app.schemas.swaps import HistorySummary
from app.swaps.advisor import AdviceContext, advice_problems, advice_schema, render_request
from app.swaps.inputs import normalize_inputs
from app.swaps.knowledge import swap_catalog
from tests.swaps.fakes import card, card_ar

IDS = ["swap_plastic_bag_tote", "swap_cling_film_beeswax", "swap_bottled_water_filter", "swap_straws_reusable"]


def context(lang="en", materials=("plastic bags", "cling film"), has_history=False, docs=None) -> AdviceContext:
    catalog = swap_catalog()
    chosen = {i: catalog[i] for i in IDS} if docs is None else docs
    return AdviceContext(
        docs=chosen, inputs=normalize_inputs(list(materials), lang), has_history=has_history, lang=lang
    )


def advice(ctx: AdviceContext, cards: list[dict]):
    schema = advice_schema(list(ctx.docs), [i.label for i in ctx.inputs])
    return schema.model_validate({"swaps": cards})


def good_cards() -> list[dict]:
    return [
        card("swap_plastic_bag_tote", "plastic bags"),
        card("swap_cling_film_beeswax", "cling film", from_item="Cling film", to_item="Beeswax wraps"),
        card("swap_straws_reusable", "plastic bags", from_item="Plastic straws", to_item="A steel straw"),
    ]


def test_valid_advice_has_no_problems():
    ctx = context()
    assert advice_problems(advice(ctx, good_cards()), ctx) == []


def test_schema_only_allows_provided_ids_and_inputs():
    ctx = context()
    with pytest.raises(ValidationError):
        advice(ctx, [*good_cards()[:2], card("swap_invented_by_model", "plastic bags")])
    with pytest.raises(ValidationError):
        advice(ctx, [*good_cards()[:2], card("swap_straws_reusable", "paper cups")])
    schema = advice_schema(IDS, ["plastic bags"]).model_json_schema()
    card_schema = schema["$defs"]["SwapCard"]
    assert card_schema["properties"]["source_id"]["enum"] == IDS
    assert list(card_schema["properties"])[:2] == ["source_id", "matched_input"]


def test_numbers_without_a_source_are_rejected():
    ctx = context()
    cards = good_cards()
    cards[0]["why"] = "A tote replaces about 500 plastic bags a year."
    cards[1]["impact_note"] = "Cuts kitchen plastic by 80%."
    problems = advice_problems(advice(ctx, cards), ctx)
    assert any("swaps[0].why states a number" in p for p in problems)
    assert any("swaps[1].impact_note states a number" in p for p in problems)


def test_numbers_are_allowed_when_the_document_cites_a_source():
    catalog = swap_catalog()
    sourced = catalog["swap_plastic_bag_tote"].model_copy(update={"impact_source": "Checkable report, page ref"})
    docs = {i: catalog[i] for i in IDS} | {"swap_plastic_bag_tote": sourced}
    ctx = context(docs=docs)
    cards = good_cards()
    cards[0]["why"] = "A tote replaces about 500 plastic bags a year."
    assert advice_problems(advice(ctx, cards), ctx) == []


def test_count_and_duplicate_documents():
    ctx = context()
    # The schema already enforces the count; the validator re-checks it as a second guard.
    too_few = advice_problems(SimpleNamespace(swaps=advice(ctx, good_cards()).swaps[:2]), ctx)
    assert any("between 3 and 4" in p for p in too_few)
    dup = good_cards()
    dup[2]["source_id"] = "swap_plastic_bag_tote"
    assert any("reuses document" in p for p in advice_problems(advice(ctx, dup), ctx))


def test_history_cards_need_history():
    cards = good_cards()
    cards[2]["matched_input"] = None
    without = context(has_history=False)
    assert any("must answer one of the user's inputs" in p for p in advice_problems(advice(without, cards), without))
    with_history = context(has_history=True)
    assert advice_problems(advice(with_history, cards), with_history) == []


def test_output_must_be_in_the_request_language():
    ctx_ar = context(lang="ar", materials=("plastic_bags", "cling_film"))
    english_in_ar = [card("swap_plastic_bag_tote", "أكياس بلاستيكية")] + [
        card_ar(i, None if n else "غلاف بلاستيكي للطعام") for n, i in enumerate(IDS[1:3])
    ]
    ctx_ar_hist = AdviceContext(docs=ctx_ar.docs, inputs=ctx_ar.inputs, has_history=True, lang="ar")
    problems = advice_problems(advice(ctx_ar_hist, english_in_ar), ctx_ar_hist)
    assert any("swaps[0].why must be written in Modern Standard Arabic" in p for p in problems)
    assert not any(p.startswith("swaps[1]") or p.startswith("swaps[2]") for p in problems)

    ctx_en = context()
    arabic_in_en = good_cards()
    arabic_in_en[1]["tip"] = "احتفظ بواحدة في السيارة دائمًا."
    assert any(
        "swaps[1].tip must be written in English" in p for p in advice_problems(advice(ctx_en, arabic_in_en), ctx_en)
    )


def test_short_latin_terms_are_fine_in_arabic():
    ctx = AdviceContext(docs=context().docs, inputs=[], has_history=False, lang="ar")
    cards = [card_ar(i, None, to_item="مصابيح LED موفرة للطاقة") for i in IDS[:3]]
    assert advice_problems(advice(ctx, cards), ctx) == []


def test_request_lists_inputs_history_and_documents_with_their_rules():
    ctx = context()
    history = HistorySummary(counts={"plastic": 6}, top_items=["plastic bottle"], top_item_counts=[6])
    text = render_request(ctx.inputs, history, list(ctx.docs.values()), "en")
    assert '- "plastic bags"' in text
    assert "plastic bottle x6" in text
    assert "[swap_plastic_bag_tote] Reusable shopping bags" in text
    assert "Numbers allowed: no" in text
    no_history = render_request(ctx.inputs, None, list(ctx.docs.values()), "ar")
    assert "Output language: Modern Standard Arabic." in no_history
    assert "No scan history was shared" in no_history
