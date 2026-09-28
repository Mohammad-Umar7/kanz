"""The recommend graph: routing modes, parallel fan-out, grounding and branch-failure fallbacks."""

import asyncio

import pytest

from app.ai import pipeline
from app.ai.llm_schemas import LlmDisposalPlan, LlmDonate, LlmIdeas, LlmRecycle
from app.core.errors import AiInvalidOutput, AiTimeout, AiUnavailable, BadRequest
from app.schemas.analysis import Analysis
from app.schemas.common import Profile
from app.schemas.recommend import RecommendRequest

from .conftest import (
    FakeGateway,
    fixture_analysis,
    llm_disposal,
    llm_donate,
    llm_ideas,
    llm_recycle,
)

BEGINNER = Profile(skill="beginner", tools=["scissors", "twine", "pliers", "gloves"], lang="en")


def jar_request(profile: Profile = BEGINNER) -> RecommendRequest:
    return RecommendRequest(image_id="img_jar", analysis=fixture_analysis("analyze_glass_jar.json"), profile=profile)


def battery_request() -> RecommendRequest:
    return RecommendRequest(image_id="img_bat", analysis=fixture_analysis("analyze_battery.json"), profile=BEGINNER)


def mixed_request() -> RecommendRequest:
    jar = fixture_analysis("analyze_glass_jar.json")
    battery = fixture_analysis("analyze_battery.json").items[0].model_copy(update={"id": "item_3"})
    analysis = jar.model_copy(update={"items": [*jar.items, battery]})
    return RecommendRequest(image_id="img_mix", analysis=analysis, profile=BEGINNER)


def diy_gateway(overrides: dict | None = None) -> FakeGateway:
    answers = {
        LlmIdeas: llm_ideas(),
        LlmRecycle: llm_recycle("item_1", "item_2"),
        LlmDonate: llm_donate("item_1", "item_2"),
        LlmDisposalPlan: llm_disposal("item_3"),
    }
    answers.update(overrides or {})
    return FakeGateway(answers)


async def test_glass_jar_gets_three_grounded_ideas_and_every_path():
    gateway = diy_gateway()
    res = await pipeline.recommend(jar_request(), gateway=gateway)

    assert res.routing.mode == "diy"
    assert len(res.upcycle) == 3
    lantern = res.upcycle[0]
    assert lantern.id.startswith("idea_") and len(lantern.id) == 13
    assert lantern.tools_needed == ["craft_wire", "pliers", "twine", "scissors"]  # gloves are not a tool
    assert lantern.tools_have == ["pliers", "twine", "scissors"]
    assert lantern.tools_missing == ["craft_wire"]
    assert [s.id for s in lantern.sources] == ["proj_glass_jar_lantern"]  # the invented id is dropped
    assert [i.item_id for i in res.recycle.instructions] == ["item_1", "item_2"]
    assert res.recycle.sources[0].id == "mat_glass"
    assert res.donate.available is True
    assert res.disposal == []
    assert {c.key for c in res.facility_categories} == {"glass", "metal"}
    assert {"safety_router", "retrieval", "upcycle", "recycle", "donate", "dropoff", "total"} <= set(res.timings_ms)
    assert sorted(gateway.schemas_called()) == ["LlmDonate", "LlmIdeas", "LlmRecycle"]


async def test_prompts_carry_the_items_profile_and_retrieved_projects():
    gateway = diy_gateway()
    await pipeline.recommend(jar_request(), gateway=gateway)
    designer = next(c for c in gateway.calls if c["schema"] is LlmIdeas)
    user = designer["contents"][0]
    assert "item_1 (focus): Glass jam jar" in user
    assert "Skill: beginner" in user and "twine (Twine or string)" in user
    assert "[proj_glass_jar_lantern]" in user  # retrieved (keyword fallback in tests)
    assert "spray painting: a dust mask" in designer["system"]


async def test_idea_ids_are_stable_across_requests():
    first = await pipeline.recommend(jar_request(), gateway=diy_gateway())
    second = await pipeline.recommend(jar_request(), gateway=diy_gateway())
    assert [i.id for i in first.upcycle] == [i.id for i in second.upcycle]


async def test_battery_is_disposal_only_with_no_ideas_and_no_design_call():
    gateway = FakeGateway({LlmDisposalPlan: llm_disposal("item_1")})
    res = await pipeline.recommend(battery_request(), gateway=gateway)
    assert res.routing.mode == "disposal_only"
    assert res.upcycle == []
    assert gateway.schemas_called() == ["LlmDisposalPlan"]
    assert res.disposal[0].hazard == "battery" and res.disposal[0].never
    assert res.recycle.instructions[0].stream == "Battery collection point"
    assert res.recycle.instructions[0].status == "conditional"
    assert res.donate.available is False
    assert [c.key for c in res.facility_categories] == ["battery"]
    assert res.recycle.sources[0].id == "safety_batteries"


async def test_jar_and_battery_is_mixed_and_ideas_skip_the_battery():
    gateway = diy_gateway()
    res = await pipeline.recommend(mixed_request(), gateway=gateway)
    assert res.routing.mode == "mixed" and res.routing.hazardous_item_ids == ["item_3"]
    assert all("item_3" not in i.uses_item_ids for i in res.upcycle)
    assert [d.item_id for d in res.disposal] == ["item_3"]
    assert [i.item_id for i in res.recycle.instructions] == ["item_1", "item_2", "item_3"]
    designer = next(c for c in gateway.calls if c["schema"] is LlmIdeas)
    assert "item_3" not in designer["contents"][0]  # the designer never sees the battery


async def test_idea_using_a_hazardous_item_is_rejected_then_repaired():
    unsafe = llm_ideas(uses_item_ids=["item_1", "item_3"])
    gateway = diy_gateway({LlmIdeas: [unsafe, llm_ideas()]})
    res = await pipeline.recommend(mixed_request(), gateway=gateway)
    assert "item_3" in gateway.problems[0][0]
    assert all("item_3" not in i.uses_item_ids for i in res.upcycle)


async def test_one_failed_branch_falls_back_and_the_rest_still_arrive():
    gateway = diy_gateway({LlmRecycle: AiTimeout()})
    res = await pipeline.recommend(jar_request(), gateway=gateway)
    assert len(res.upcycle) == 3 and res.donate.available
    first = res.recycle.instructions[0]
    assert first.stream == "Glass bottle bank" and first.prep_steps  # the analyst's own fields
    assert first.dos and first.donts


async def test_upcycle_failure_falls_back_to_retrieved_projects():
    gateway = diy_gateway({LlmIdeas: AiUnavailable()})
    res = await pipeline.recommend(jar_request(), gateway=gateway)
    assert len(res.upcycle) == 3
    assert all(i.sources and i.sources[0].id.startswith("proj_glass_") for i in res.upcycle)
    assert all(i.after_visual.startswith("the same glass item") for i in res.upcycle)
    assert [i.difficulty for i in res.upcycle].count("easy") >= 2  # beginner ordering


async def test_unsafe_ideas_twice_fall_back_instead_of_reaching_the_user():
    melt = llm_ideas(pitch="Melt the plastic caps in the oven into a coaster.")
    gateway = diy_gateway({LlmIdeas: [melt, melt]})
    res = await pipeline.recommend(jar_request(), gateway=gateway)
    assert all("Melt" not in i.pitch for i in res.upcycle)
    assert len(gateway.problems) == 2


async def test_every_generating_branch_failing_fails_the_request():
    gateway = diy_gateway({LlmIdeas: AiUnavailable(), LlmRecycle: AiUnavailable(), LlmDonate: AiUnavailable()})
    with pytest.raises(AiUnavailable):
        await pipeline.recommend(jar_request(), gateway=gateway)


async def test_disposal_failure_uses_reviewed_copy():
    gateway = FakeGateway({LlmDisposalPlan: AiInvalidOutput()})
    res = await pipeline.recommend(battery_request(), gateway=gateway)
    assert res.disposal[0].headline == "Take the batteries to a battery collection point."
    assert res.recycle.instructions[0].donts


async def test_moldy_items_are_never_donated_whatever_the_model_says():
    analysis = fixture_analysis("analyze_glass_jar.json")
    moldy = analysis.items[0].model_copy(update={"state": ["moldy"]})
    req = RecommendRequest(image_id="img_m", analysis=analysis.model_copy(update={"items": [moldy]}), profile=BEGINNER)
    gateway = diy_gateway({LlmRecycle: llm_recycle("item_1"), LlmDonate: llm_donate("item_1", suitable=True)})
    res = await pipeline.recommend(req, gateway=gateway)
    assert res.donate.available is False
    assert res.donate.options[0].suitable is False


async def test_gear_missing_from_a_safety_note_is_added():
    knife = llm_ideas(tools_needed=["craft_knife", "scissors"], safety_note=None)
    gateway = diy_gateway({LlmIdeas: [knife, knife]})
    res = await pipeline.recommend(jar_request(), gateway=gateway)
    assert "gloves" in res.upcycle[0].safety_note
    assert gateway.problems  # the model was asked first


async def test_user_edits_cannot_remove_a_battery_hazard():
    analysis = fixture_analysis("analyze_battery.json")
    edited = analysis.items[0].model_copy(update={"hazards": [], "category": "other", "user_corrected": True})
    req = RecommendRequest(
        image_id="img_b",
        analysis=Analysis.model_validate(analysis.model_copy(update={"items": [edited]}).model_dump()),
        profile=BEGINNER,
    )
    res = await pipeline.recommend(req, gateway=FakeGateway({LlmDisposalPlan: llm_disposal("item_1")}))
    assert res.routing.mode == "disposal_only"


async def test_focus_item_leads_the_designer_prompt():
    req = jar_request().model_copy(update={"focus_item_id": "item_2"})
    gateway = diy_gateway()
    await pipeline.recommend(req, gateway=gateway)
    designer = next(c for c in gateway.calls if c["schema"] is LlmIdeas)
    assert "item_2 (focus): Metal jar lid" in designer["contents"][0]


async def test_empty_analysis_is_a_bad_request():
    analysis = fixture_analysis("analyze_unclear.json")
    with pytest.raises(BadRequest):
        await pipeline.recommend(RecommendRequest(image_id="img_u", analysis=analysis), gateway=FakeGateway())


async def test_arabic_sources_use_arabic_titles():
    profile = Profile(skill="beginner", tools=["scissors"], lang="ar")
    arabic_ideas = llm_ideas()
    for idea in arabic_ideas["ideas"]:
        idea["title"], idea["pitch"] = "فانوس " + idea["title"][:3], "فكرة بسيطة ومفيدة للمنزل."
    gateway = diy_gateway({LlmIdeas: arabic_ideas})
    res = await pipeline.recommend(jar_request(profile), gateway=gateway)
    assert res.lang == "ar"
    assert res.upcycle[0].sources[0].title == "فانوس برطمان معلّق"


async def test_slow_branch_is_cut_off_by_its_time_budget(monkeypatch):
    class SlowRecycling(FakeGateway):
        async def structured(self, *, schema, **kwargs):
            if schema is LlmRecycle:
                await asyncio.sleep(5)
            return await super().structured(schema=schema, **kwargs)

    monkeypatch.setattr("app.ai.nodes.recycling.ADVISOR_BUDGET_S", 0.05)
    gateway = SlowRecycling(
        {LlmIdeas: llm_ideas(), LlmRecycle: llm_recycle("item_1", "item_2"), LlmDonate: llm_donate("item_1", "item_2")}
    )
    res = await pipeline.recommend(jar_request(), gateway=gateway)
    assert res.timings_ms["recycle"] < 1000
    assert res.recycle.instructions[0].note  # the deterministic fallback, not the slow model
