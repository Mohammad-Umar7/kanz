"""The Swap Advisor graph end to end, with a fake retriever and a fake Gemini gateway."""

import pytest

from app.core.errors import AiInvalidOutput, AiUnavailable
from app.schemas.swaps import HistorySummary, SwapsRequest
from app.swaps import service
from tests.swaps.fakes import FakeGateway, FakeRetriever, card, card_ar

TABLE = {
    "plastic bags": ["swap_plastic_bag_tote", "swap_produce_bags_mesh", "swap_bin_liners_fewer"],
    "cling film": ["swap_cling_film_beeswax", "swap_zip_bags_silicone", "swap_foil_reusable_lids"],
    "plastic bottle": ["swap_bottled_water_filter", "swap_water_bottle_reusable"],
    "single-use": ["swap_plastic_bag_tote", "swap_straws_reusable", "swap_disposable_cups_reusable"],
}
HISTORY = HistorySummary(
    period_days=30, counts={"plastic": 6, "glass": 2}, top_items=["plastic bottle"], top_item_counts=[6]
)


def english_answer() -> dict:
    return {
        "swaps": [
            card("swap_bottled_water_filter", None, from_item="Bottled water", to_item="A filter jug"),
            card("swap_cling_film_beeswax", "cling film", from_item="Cling film", to_item="Beeswax wraps"),
            card("swap_plastic_bag_tote", "plastic bags"),
        ]
    }


async def test_english_flow_builds_grounded_cards():
    retriever = FakeRetriever(TABLE)
    gateway = FakeGateway([english_answer()])
    req = SwapsRequest(materials=["plastic_bags", "cling_film"], history=HISTORY, lang="en")
    res = await service.suggest(req, gateway=gateway, retriever=retriever)

    assert [c["query"] for c in retriever.calls] == ["plastic bags", "cling film", "plastic bottle plastic glass"]
    assert all(c["kinds"] == ["swap"] for c in retriever.calls)

    # Input cards first, in the user's order; the history card last.
    assert [s.id for s in res.swaps] == [
        "swap_plastic_bag_tote",
        "swap_cling_film_beeswax",
        "swap_bottled_water_filter",
    ]
    tote, wrap, water = res.swaps
    assert tote.matched_input == "plastic bags"
    assert tote.from_history is False
    assert water.matched_input is None and water.from_history is True
    # Facts come from the knowledge base, not the model.
    assert (tote.effort, tote.cost, tote.category) == ("low", "low", "plastic")
    assert (wrap.effort, wrap.cost) == ("low", "medium")
    assert tote.sources[0].model_dump() == {
        "id": "swap_plastic_bag_tote",
        "title": "Reusable shopping bags",
        "kind": "swap",
    }
    assert res.history_insight == "You scanned 6 plastic bottles this month."
    assert {"retrieval", "swap_advisor", "total"} <= set(res.timings_ms)

    call = gateway.calls[0]
    assert call["stage"] == "swap_advisor"
    assert "English" in call["system"]
    assert "[swap_plastic_bag_tote]" in call["contents"][0]


async def test_documents_are_interleaved_so_every_input_is_represented():
    retriever = FakeRetriever(TABLE)
    gateway = FakeGateway([english_answer()])
    await service.suggest(
        SwapsRequest(materials=["plastic bags", "cling film"], history=HISTORY), gateway=gateway, retriever=retriever
    )
    ids = list(gateway.calls[0]["schema"].model_json_schema()["$defs"]["SwapCard"]["properties"]["source_id"]["enum"])
    assert ids[:3] == ["swap_plastic_bag_tote", "swap_cling_film_beeswax", "swap_bottled_water_filter"]
    assert len(ids) == len(set(ids))


async def test_arabic_flow():
    retriever = FakeRetriever(TABLE)
    answer = {
        "swaps": [
            card_ar("swap_plastic_bag_tote", "أكياس بلاستيكية"),
            card_ar("swap_cling_film_beeswax", "غلاف بلاستيكي للطعام", from_item="غلاف الطعام البلاستيكي"),
            card_ar("swap_produce_bags_mesh", "أكياس بلاستيكية", from_item="أكياس الخضار الرقيقة"),
        ]
    }
    gateway = FakeGateway([answer])
    res = await service.suggest(
        SwapsRequest(materials=["plastic_bags", "cling_film"], lang="ar"), gateway=gateway, retriever=retriever
    )
    assert [c["query"] for c in retriever.calls] == ["plastic bags", "cling film"]  # English retrieval queries
    assert [s.matched_input for s in res.swaps] == ["أكياس بلاستيكية", "أكياس بلاستيكية", "غلاف بلاستيكي للطعام"]
    assert res.swaps[0].sources[0].title == "أكياس تسوّق قابلة لإعادة الاستخدام"
    assert all(not s.from_history for s in res.swaps)
    assert res.history_insight is None
    assert "Modern Standard Arabic" in gateway.calls[0]["system"]


async def test_a_bad_first_answer_is_repaired():
    bad = english_answer()
    bad["swaps"][0]["why"] = "Filters save 1,500 bottles a year."
    gateway = FakeGateway([bad, english_answer()])
    res = await service.suggest(
        SwapsRequest(materials=["plastic bags", "cling film"], history=HISTORY),
        gateway=gateway,
        retriever=FakeRetriever(TABLE),
    )
    assert len(res.swaps) == 3
    assert any("states a number" in p for p in gateway.problems_seen[0])


async def test_advice_that_stays_invalid_raises():
    bad = english_answer()
    bad["swaps"][0]["why"] = "Filters save 1,500 bottles a year."
    gateway = FakeGateway([bad, bad])
    with pytest.raises(AiInvalidOutput):
        await service.suggest(
            SwapsRequest(materials=["plastic bags", "cling film"], history=HISTORY),
            gateway=gateway,
            retriever=FakeRetriever(TABLE),
        )
    assert all(any("states a number" in p for p in problems) for problems in gateway.problems_seen)


async def test_no_documents_means_no_model_call():
    gateway = FakeGateway([])
    res = await service.suggest(
        SwapsRequest(materials=["jet engines"], history=None), gateway=gateway, retriever=FakeRetriever(TABLE)
    )
    assert res.swaps == []
    assert gateway.calls == []


async def test_no_inputs_and_no_history_asks_for_general_swaps():
    retriever = FakeRetriever(TABLE)
    answer = {
        "swaps": [
            card("swap_plastic_bag_tote", None),
            card("swap_straws_reusable", None, from_item="Plastic straws"),
            card("swap_disposable_cups_reusable", None, from_item="Paper cups"),
        ]
    }
    res = await service.suggest(SwapsRequest(), gateway=FakeGateway([answer]), retriever=retriever)
    assert retriever.calls[0]["query"] == service.GENERAL_QUERY
    assert len(res.swaps) == 3
    assert all(s.from_history is False and s.matched_input is None for s in res.swaps)


async def test_retrieval_failure_is_reported_as_ai_unavailable():
    async def broken(query, **kwargs):
        raise RuntimeError("index missing")

    with pytest.raises(AiUnavailable):
        await service.suggest(SwapsRequest(materials=["plastic bags"]), gateway=FakeGateway([]), retriever=broken)
