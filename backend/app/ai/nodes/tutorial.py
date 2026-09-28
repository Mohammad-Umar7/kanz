"""Tutorial Writer and finalize nodes: an adapted, safe, step-by-step tutorial with step image prompts."""

from __future__ import annotations

from collections.abc import Sequence

from langgraph.runtime import Runtime

from app.ai import labels, rag, safety
from app.ai.labels import lang_name
from app.ai.llm_schemas import LlmTutorial
from app.ai.nodes.common import cite, items_block, knowledge_block, language_problems, log, profile_block, timed
from app.ai.prompts import load_prompt
from app.ai.state import PipelineContext, TutorialState
from app.core.tutorials import get_tutorial_store
from app.schemas.analysis import Item
from app.schemas.common import Profile, SourceRef
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial, TutorialMaterial, TutorialStep, TutorialTool
from app.schemas.vocab import SAFETY_GEAR

# Tools whose absence really changes the method. Consumables (twine, glue, paint) are
# covered by the alternatives check alone: naming them in a step is not an error.
TOOLS_THAT_CHANGE_THE_METHOD = frozenset(
    {
        "drill",
        "hot_glue_gun",
        "craft_knife",
        "handsaw",
        "sewing_machine",
        "staple_gun",
        "iron",
        "wire_cutter",
        "clamps",
        "pliers",
        "screwdriver",
        "hammer",
    }
)
BORROW: dict[str, str] = {
    "en": "No {tool}? Borrow one from a neighbour or ask at a local makerspace.",
    "ar": "لا يتوفر لديك {tool}؟ استعره من أحد الجيران أو اسأل في ورشة قريبة.",
}
SKILL_NAMES = {
    "en": {"beginner": "Beginner", "intermediate": "Intermediate", "advanced": "Advanced"},
    "ar": {"beginner": "مبتدئ", "intermediate": "متوسط", "advanced": "متقدم"},
}


def _missing(out: LlmTutorial, profile: Profile) -> list[str]:
    owned = set(profile.tools)
    return [t.tool_id for t in out.tools if t.tool_id not in owned and t.tool_id not in SAFETY_GEAR]


def _all_texts(out: LlmTutorial) -> list[str | None]:
    return [
        out.title,
        out.adapted_note,
        *out.safety,
        *out.finishing,
        *out.care,
        *(m.name for m in out.materials),
        *(t.alternative for t in out.tools),
        *(x for s in out.steps for x in (s.title, s.instruction, s.tip, s.warning)),
    ]


def hard_rules(items: Sequence[Item]):
    def check(out: LlmTutorial) -> list[str]:
        problems: list[str] = []
        for n, step in enumerate(out.steps, 1):
            problems += safety.check_english(step.image_prompt, field=f"Step {n} image_prompt")
        problems += safety.check_text_rules(_all_texts(out), items=items, where="The tutorial ")
        return problems

    return check


def soft_rules(profile: Profile):
    def check(out: LlmTutorial) -> list[str]:
        missing = _missing(out, profile)
        problems = safety.check_alternatives({t.tool_id: t.alternative for t in out.tools}, missing)
        problems += safety.check_missing_tools_used(
            [(n, f"{s.instruction} {s.tip or ''}") for n, s in enumerate(out.steps, 1)],
            [t for t in missing if t in TOOLS_THAT_CHANGE_THE_METHOD],
        )
        step_texts = [x for s in out.steps for x in (s.title, s.instruction)]
        problems += safety.check_protective_gear(
            step_texts,
            [t.tool_id for t in out.tools],
            [*out.safety, *(s.warning for s in out.steps)],
            where="The tutorial ",
        )
        problems += language_problems(
            [s.instruction for s in out.steps] + [out.adapted_note], profile.lang, what="the tutorial text"
        )
        return problems

    return check


def _user_message(state: TutorialState) -> str:
    req = state["request"]
    idea = req.idea
    return "\n".join(
        [
            "## Idea",
            f"Title: {idea.title}",
            f"Pitch: {idea.pitch}",
            f"Difficulty: {idea.difficulty}; about {idea.time_minutes} min",
            f"Tools the idea lists: {', '.join(idea.tools_needed) or 'none'}",
            f"Extra materials: {', '.join(idea.extra_materials) or 'none'}",
            f"Finished object (after_visual): {idea.after_visual}",
            f"Safety note: {idea.safety_note or 'none'}",
            "",
            "## Scanned items used",
            items_block(req.items) or "(none: the idea was described in text)",
            "",
            "## Person",
            # Recomputed: the user may have changed their tools since the idea was generated.
            profile_block(req.profile, missing=[t for t in idea.tools_needed if t not in req.profile.tools]),
            "",
            "## Knowledge (cite only these ids)",
            knowledge_block(state.get("knowledge", [])),
            "",
            "Write the tutorial.",
        ]
    )


@timed("tutorial_writer")
async def tutorial_writer(state: TutorialState, runtime: Runtime[PipelineContext]) -> dict:
    ctx = runtime.context
    req = state["request"]
    prompt = load_prompt("tutorial_writer", ctx.settings.prompts_dir)
    out = await ctx.gateway.structured(
        stage=prompt.tag,
        system=prompt.render(lang_name=lang_name(req.profile.lang), gear_rules=safety.gear_rules_text()),
        contents=[_user_message(state)],
        schema=LlmTutorial,
        model=prompt.model(ctx.settings),
        examples=prompt.examples,
        validator=safety.TwoTierValidator(hard=hard_rules(req.items), soft=soft_rules(req.profile)),
        temperature=prompt.temperature,
        thinking_level=prompt.thinking_level,
    )
    return {"tutorial": build_tutorial(out, state)}


def _adapted_note(skill: str, missing: Sequence[str], lang: str) -> str:
    key = "ar" if lang == "ar" else "en"
    skill_name = SKILL_NAMES[key].get(skill, skill)
    names = (
        "، ".join(labels.tool_label(t, key) for t in missing)
        if key == "ar"
        else ", ".join(labels.tool_label(t, key).lower() for t in missing)
    )
    if key == "ar":
        return f"مُكيَّف لمستوى {skill_name}" + (
            f"، مع بدائل لـ: {names}." if missing else "، بالأدوات المتوفرة لديك فقط."
        )
    return f"Adapted for {skill_name}" + (
        f", with alternatives for: {names}." if missing else ", using only tools you have."
    )


def build_tutorial(out: LlmTutorial, state: TutorialState) -> Tutorial:
    """Model tutorial -> API ``Tutorial``: id, tool availability, materials, steps, gear backstop, sources."""
    req = state["request"]
    profile, idea = req.profile, req.idea
    lang = profile.lang
    owned = set(profile.tools)

    tools: list[TutorialTool] = []
    for raw in out.tools:
        if raw.tool_id in SAFETY_GEAR or any(t.tool_id == raw.tool_id for t in tools):
            continue
        have = raw.tool_id in owned
        alternative = None if have else (raw.alternative or "").strip() or None
        if not have and alternative is None:
            alternative = BORROW[lang if lang == "ar" else "en"].format(tool=labels.tool_label(raw.tool_id, lang))
        tools.append(TutorialTool(tool_id=raw.tool_id, have=have, alternative=alternative))

    item_ids = [it.id for it in req.items]
    materials: list[TutorialMaterial] = []
    for m in out.materials:
        item_id = m.item_id if m.item_id in item_ids else None
        from_scan = bool(item_id) or (m.from_scan and bool(item_ids))
        if from_scan and item_id is None:
            item_id = item_ids[0]
        materials.append(
            TutorialMaterial(name=m.name.strip(), quantity=m.quantity, from_scan=from_scan, item_id=item_id)
        )
    listed = {m.item_id for m in materials if m.from_scan}
    for it in reversed(req.items):
        if it.id in idea.uses_item_ids and it.id not in listed:
            materials.insert(
                0, TutorialMaterial(name=it.name, quantity=it.quantity.display, from_scan=True, item_id=it.id)
            )

    steps = [
        TutorialStep(
            number=n,
            title=s.title.strip(),
            instruction=s.instruction.strip(),
            tip=(s.tip or "").strip() or None,
            warning=(s.warning or "").strip() or None,
            duration_minutes=min(240, max(1, int(s.duration_minutes))),
            image_prompt=s.image_prompt.strip(),
        )
        for n, s in enumerate(out.steps[:8], 1)
    ]

    safety_lines = [s.strip() for s in out.safety if s.strip()]
    lacking = safety.missing_gear(
        [x for s in steps for x in (s.title, s.instruction)],
        [t.tool_id for t in tools],
        [*safety_lines, *(s.warning for s in steps)],
    )
    safety_lines = safety.gear_lines(lacking, lang) + safety_lines

    knowledge = state.get("knowledge", [])
    sources: list[SourceRef] = list(idea.sources)
    for ref in cite(out.source_ids, knowledge, lang):
        if all(ref.id != s.id for s in sources):
            sources.append(ref)
    if not sources:
        sources = [rag.source_ref(h, lang) for h in knowledge[:1]]

    missing = [t.tool_id for t in tools if not t.have]
    return Tutorial(
        tutorial_id=state["tutorial_id"],
        idea_id=idea.id,
        image_id=req.image_id,
        title=out.title.strip() or idea.title,
        adapted_note=out.adapted_note.strip() or _adapted_note(profile.skill, missing, lang),
        skill=profile.skill,
        total_minutes=sum(s.duration_minutes for s in steps),
        materials=materials,
        tools=tools,
        safety=safety_lines,
        steps=steps,
        finishing=[f.strip() for f in out.finishing if f.strip()][:3],
        care=[c.strip() for c in out.care if c.strip()][:3],
        sources=sources,
        lang=lang,
    )


@timed("finalize")
async def finalize(state: TutorialState, runtime: Runtime[PipelineContext]) -> dict:
    """Persist the tutorial, then hand it to the image pipeline (never blocking or failing)."""
    tutorial = state["tutorial"]
    store = runtime.context.tutorials or get_tutorial_store()
    store.save(tutorial)
    start_step_images(tutorial, state["request"].idea)
    return {}


def start_step_images(tutorial: Tutorial, idea: UpcycleIdea) -> None:
    """Hand the tutorial and its idea to the image pipeline.

    The image service always stores the idea (later ``/images/step`` calls need it for the
    final step) and starts rendering in the background only when ``STEP_IMAGES_AUTOSTART``
    is on. It deduplicates chains, so calling it again for a cached tutorial is safe.
    """
    try:
        # Lazy import: the image pipeline is a separate workstream and must never break tutorials.
        from app.images.service import start_step_chain  # noqa: PLC0415

        start_step_chain(tutorial, idea)
    except Exception as exc:
        log.warning("step image chain did not start for %s: %r", tutorial.tutorial_id, exc)
