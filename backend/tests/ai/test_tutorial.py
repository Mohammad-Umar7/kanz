"""The tutorial graph: adaptation, ids, caching, safety backstops and the step-image hand-off."""

import pytest

from app.ai import pipeline
from app.ai.llm_schemas import LlmTutorial
from app.core.errors import AiInvalidOutput, BadRequest
from app.core.tutorials import get_tutorial_store, tutorial_id_for
from app.schemas.common import Profile
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import TutorialRequest

from .conftest import FakeGateway, fixture_analysis, fixture_json, llm_tutorial

BEGINNER = Profile(skill="beginner", tools=["scissors", "twine", "pliers"], lang="en")


def lantern_idea() -> UpcycleIdea:
    return UpcycleIdea.model_validate(fixture_json("recommend_glass_jar.json")["upcycle"][0])


def request(profile: Profile = BEGINNER, items=None) -> TutorialRequest:
    jar = fixture_analysis("analyze_glass_jar.json").items[0]
    return TutorialRequest(image_id="img_jar", idea=lantern_idea(), items=items or [jar], profile=profile)


async def test_tutorial_is_built_saved_and_starts_the_step_chain(step_chain):
    gateway = FakeGateway({LlmTutorial: llm_tutorial(6)})
    res = await pipeline.tutorial(request(), gateway=gateway)
    t = res.tutorial

    assert t.tutorial_id == tutorial_id_for("img_jar", t.idea_id, "beginner", BEGINNER.tools, "en")
    assert [s.number for s in t.steps] == [1, 2, 3, 4, 5, 6]
    assert t.total_minutes == 30
    assert {tool.tool_id: tool.have for tool in t.tools} == {"pliers": True, "twine": True, "craft_wire": False}
    assert next(tool for tool in t.tools if tool.tool_id == "craft_wire").alternative
    assert t.materials[0].from_scan and t.materials[0].item_id == "item_1"
    assert [s.id for s in t.sources][:2] == ["proj_glass_jar_lantern", "safety_glass_handling"]
    assert {"retrieval", "tutorial_writer", "finalize", "total"} <= set(res.timings_ms)

    assert get_tutorial_store().get(t.tutorial_id) == t
    assert len(step_chain) == 1 and step_chain[0][0] == t and step_chain[0][1].id == t.idea_id


async def test_same_request_is_served_from_the_store(step_chain):
    gateway = FakeGateway({LlmTutorial: llm_tutorial()})
    first = await pipeline.tutorial(request(), gateway=gateway)
    second = await pipeline.tutorial(request(), gateway=gateway)
    assert second.tutorial == first.tutorial
    assert len(gateway.calls) == 1
    assert "cache" in second.timings_ms
    assert len(step_chain) == 2  # handed off again, so a restarted server resumes the chain


async def test_changing_skill_or_tools_gives_a_new_adapted_tutorial(step_chain):
    gateway = FakeGateway({LlmTutorial: llm_tutorial()})
    base = await pipeline.tutorial(request(), gateway=gateway)
    fewer_tools = await pipeline.tutorial(request(BEGINNER.model_copy(update={"tools": ["scissors"]})), gateway=gateway)
    advanced = await pipeline.tutorial(request(BEGINNER.model_copy(update={"skill": "advanced"})), gateway=gateway)
    ids = {base.tutorial.tutorial_id, fewer_tools.tutorial.tutorial_id, advanced.tutorial.tutorial_id}
    assert len(ids) == 3
    user = gateway.calls[1]["contents"][0]
    assert "Tools they do NOT have" in user
    assert fewer_tools.tutorial.tools[0].have is False  # pliers are now missing


async def test_missing_tools_are_recomputed_for_the_current_profile(step_chain):
    # The idea says only craft_wire is missing; this user has since lost the pliers too.
    gateway = FakeGateway({LlmTutorial: llm_tutorial()})
    await pipeline.tutorial(request(BEGINNER.model_copy(update={"tools": ["scissors", "twine"]})), gateway=gateway)
    lines = gateway.calls[0]["contents"][0].splitlines()
    missing_line = next(line for line in lines if line.startswith("Tools they do NOT"))
    assert "pliers" in missing_line and "craft_wire" in missing_line


async def test_writer_prompt_carries_idea_items_profile_and_knowledge(step_chain):
    gateway = FakeGateway({LlmTutorial: llm_tutorial()})
    await pipeline.tutorial(request(), gateway=gateway)
    call = gateway.calls[0]
    user = call["contents"][0]
    assert "Finished object (after_visual): the same clear glass jar" in user
    assert "- item_1: Glass jam jar" in user
    assert "[proj_glass_jar_lantern]" in user
    assert "drilling: safety glasses" in call["system"]
    assert call["stage"].startswith("tutorial_writer@v")


async def test_missing_gear_is_requested_once_then_added(step_chain):
    knife_steps = llm_tutorial(safety=["Work on a stable table"])
    knife_steps["steps"][1]["instruction"] = "Cut the cardboard base with a craft knife."
    gateway = FakeGateway({LlmTutorial: [knife_steps, knife_steps]})
    t = (await pipeline.tutorial(request(), gateway=gateway)).tutorial
    assert gateway.problems and "gloves" in gateway.problems[0][0]
    assert "gloves" in t.safety[0]


async def test_missing_alternative_gets_a_safe_default(step_chain):
    no_alt = llm_tutorial()
    no_alt["tools"][2]["alternative"] = None
    t = (await pipeline.tutorial(request(), gateway=FakeGateway({LlmTutorial: [no_alt, no_alt]}))).tutorial
    wire = next(tool for tool in t.tools if tool.tool_id == "craft_wire")
    assert wire.alternative and "Borrow" in wire.alternative


async def test_arabic_image_prompts_are_hard_errors():
    bad = llm_tutorial()
    bad["steps"][0]["image_prompt"] = "نفس البرطمان بعد الخطوة الأولى"
    with pytest.raises(AiInvalidOutput):
        await pipeline.tutorial(request(), gateway=FakeGateway({LlmTutorial: [bad, bad]}))


async def test_too_few_steps_are_repaired(step_chain):
    gateway = FakeGateway({LlmTutorial: [llm_tutorial(3), llm_tutorial(5)]})
    t = (await pipeline.tutorial(request(), gateway=gateway)).tutorial
    assert len(t.steps) == 5
    assert "steps" in gateway.problems[0][0]


async def test_a_repair_after_too_few_steps_is_not_failed_by_soft_rules(step_chain):
    # The first answer breaks the schema, so the repair round is the last attempt: a missing
    # gear line there is added by the backend instead of failing the tutorial.
    knife = llm_tutorial(safety=["Work on a stable table"])
    knife["steps"][1]["instruction"] = "Cut the cardboard base with a craft knife."
    gateway = FakeGateway({LlmTutorial: [llm_tutorial(3), knife]})
    t = (await pipeline.tutorial(request(), gateway=gateway)).tutorial
    assert len(t.steps) == 5
    assert "gloves" in t.safety[0]


async def test_hazardous_items_never_get_a_tutorial():
    battery = fixture_analysis("analyze_battery.json").items[0]
    idea = lantern_idea().model_copy(update={"uses_item_ids": [battery.id]})
    req = TutorialRequest(image_id="img_b", idea=idea, items=[battery], profile=BEGINNER)
    with pytest.raises(BadRequest):
        await pipeline.tutorial(req, gateway=FakeGateway())


async def test_unused_hazardous_items_are_dropped_not_rejected(step_chain):
    jar = fixture_analysis("analyze_glass_jar.json").items[0]
    battery = fixture_analysis("analyze_battery.json").items[0].model_copy(update={"id": "item_9"})
    gateway = FakeGateway({LlmTutorial: llm_tutorial()})
    await pipeline.tutorial(request(items=[jar, battery]), gateway=gateway)
    assert "item_9" not in gateway.calls[0]["contents"][0]


async def test_step_images_never_break_a_tutorial(monkeypatch):
    def broken(tutorial, idea=None):
        raise RuntimeError("image quota exhausted")

    monkeypatch.setattr("app.images.service.start_step_chain", broken, raising=False)
    res = await pipeline.tutorial(request(), gateway=FakeGateway({LlmTutorial: llm_tutorial()}))
    assert len(res.tutorial.steps) == 5


async def test_the_idea_is_handed_off_even_with_autostart_off(step_chain, isolated):
    # The image service stores the idea and itself decides whether to start rendering.
    isolated.step_images_autostart = False
    await pipeline.tutorial(request(), gateway=FakeGateway({LlmTutorial: llm_tutorial()}))
    assert len(step_chain) == 1
