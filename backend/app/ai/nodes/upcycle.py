"""Upcycle Designer node: exactly three grounded ideas for the non-hazardous items."""

from __future__ import annotations

import asyncio
from collections.abc import Sequence

from langgraph.runtime import Runtime

from app.ai import fallbacks, safety
from app.ai.convert import idea_id, split_tools
from app.ai.labels import lang_name
from app.ai.llm_schemas import LlmIdea, LlmIdeas
from app.ai.nodes.common import (
    DESIGNER_BUDGET_S,
    cite,
    items_block,
    knowledge_block,
    language_problems,
    log,
    profile_block,
    timed,
)
from app.ai.prompts import load_prompt
from app.ai.rag import KnowledgeHit
from app.ai.state import PipelineContext, RecommendState
from app.schemas.analysis import Item
from app.schemas.common import Profile
from app.schemas.recommend import UpcycleIdea


def _where(n: int, idea: LlmIdea) -> str:
    return f"Idea {n} ('{idea.title}') "


def hard_rules(items: Sequence[Item], hazardous_ids: Sequence[str]):
    """Rules that must hold or the output is rejected: safety, distinctness, English after_visual."""
    names = [it.name for it in items]

    def check(out: LlmIdeas) -> list[str]:
        problems: list[str] = []
        titles = {i.title.strip().lower() for i in out.ideas}
        if len(titles) < len(out.ideas):
            problems.append("The three ideas must be different objects; two titles repeat.")
        for n, idea in enumerate(out.ideas, 1):
            where = _where(n, idea)
            problems += safety.check_english(idea.after_visual, field=f"Idea {n} after_visual")
            texts = [idea.title, idea.pitch, idea.after_visual, idea.safety_note, *idea.extra_materials]
            problems += safety.check_text_rules(texts, item_names=names, where=where)
            problems += safety.check_no_hazardous_diy(idea.uses_item_ids, hazardous_ids, where=where)
        return problems

    return check


def soft_rules(profile: Profile):
    """Rules the model gets one chance to fix; the node repairs whatever is left deterministically."""

    def check(out: LlmIdeas) -> list[str]:
        problems: list[str] = []
        for n, idea in enumerate(out.ideas, 1):
            problems += safety.check_protective_gear(
                [idea.title, idea.pitch],
                idea.tools_needed,
                [idea.safety_note],
                where=_where(n, idea),
                include_painting=False,
            )
        if profile.skill == "beginner":
            levels = [i.difficulty for i in out.ideas]
            if levels.count("easy") < 2 or "hard" in levels:
                problems.append("The user is a beginner: make at least two ideas 'easy' and none 'hard'.")
        problems += language_problems(
            [t for i in out.ideas for t in (i.title, i.pitch)], profile.lang, what="titles and pitches"
        )
        return problems

    return check


def to_ideas(
    out: LlmIdeas,
    *,
    image_id: str,
    profile: Profile,
    items: Sequence[Item],
    focus_id: str | None,
    projects: Sequence[KnowledgeHit],
) -> list[UpcycleIdea]:
    """Model ideas -> API ideas: stable ids, tool split, valid item ids, citations and gear backstop."""
    lang = profile.lang
    valid_ids = [it.id for it in items]
    ideas: list[UpcycleIdea] = []
    for raw in out.ideas[:3]:
        needed, have, missing = split_tools(raw.tools_needed, profile.tools)
        uses = [i for i in dict.fromkeys(raw.uses_item_ids) if i in valid_ids] or [focus_id or valid_ids[0]]
        note = (raw.safety_note or "").strip() or None
        lacking = safety.missing_gear([raw.title, raw.pitch], needed, [note], include_painting=False)
        if lacking:
            note = " ".join([*([note] if note else []), *safety.gear_lines(lacking, lang)])
        ideas.append(
            UpcycleIdea(
                id=idea_id(image_id, raw.title),
                title=raw.title.strip(),
                pitch=raw.pitch.strip(),
                difficulty=raw.difficulty,
                time_minutes=min(600, max(5, int(raw.time_minutes))),
                tools_needed=needed,
                tools_have=have,
                tools_missing=missing,
                uses_item_ids=uses,
                extra_materials=[m.strip() for m in raw.extra_materials if m.strip()],
                after_visual=raw.after_visual.strip(),
                safety_note=note,
                sources=cite(raw.source_ids, projects, lang),
            )
        )
    return ideas


@timed("upcycle")
async def upcycle_designer(state: RecommendState, runtime: Runtime[PipelineContext]) -> dict:
    ctx = runtime.context
    req = state["request"]
    profile = req.profile
    items = state["diy_items"]
    focus_id = state.get("focus_id")
    projects = state.get("projects", [])
    prompt = load_prompt("upcycle_designer", ctx.settings.prompts_dir)
    system = prompt.render(lang_name=lang_name(profile.lang), gear_rules=safety.gear_rules_text())
    user = "\n".join(
        [
            "## Scanned items",
            items_block(items, focus_id=focus_id),
            f"Focus item: {focus_id}",
            "",
            "## Person",
            profile_block(profile),
            "",
            "## Knowledge (cite only these ids)",
            knowledge_block(projects),
            "",
            "Propose the three ideas.",
        ]
    )
    try:
        out = await asyncio.wait_for(
            ctx.gateway.structured(
                stage=prompt.tag,
                system=system,
                contents=[user],
                schema=LlmIdeas,
                model=prompt.model(ctx.settings),
                examples=prompt.examples,
                validator=safety.TwoTierValidator(
                    hard=hard_rules(items, state["routing"].hazardous_item_ids), soft=soft_rules(profile)
                ),
                temperature=prompt.temperature,
                thinking_level=prompt.thinking_level,
            ),
            timeout=DESIGNER_BUDGET_S,
        )
        ideas = to_ideas(out, image_id=req.image_id, profile=profile, items=items, focus_id=focus_id, projects=projects)
        return {"upcycle": ideas}
    except Exception as exc:
        # Fall back to the three best retrieved projects so the Upcycle tab still has content.
        log.warning("upcycle_designer failed, using project fallback: %r", exc)
        focus = next((it for it in items if it.id == focus_id), items[0])
        ideas = fallbacks.upcycle_from_projects(req.image_id, focus, projects, profile)
        return {"upcycle": ideas if len(ideas) == 3 else [], "errors": {"upcycle": exc}}
