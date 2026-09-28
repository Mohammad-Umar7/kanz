"""Disposal Advisor node: safe disposal guidance for hazardous items (never DIY)."""

from __future__ import annotations

import asyncio

from langgraph.runtime import Runtime

from app.ai import fallbacks, safety
from app.ai.labels import lang_name
from app.ai.llm_schemas import LlmDisposalPlan
from app.ai.nodes.common import (
    ADVISOR_BUDGET_S,
    cite,
    items_block,
    knowledge_block,
    language_problems,
    log,
    timed,
    unexpected,
)
from app.ai.prompts import load_prompt
from app.ai.rag.index import get_index
from app.ai.state import PipelineContext, RecommendState
from app.schemas.recommend import DisposalGuidance


def _texts(out: LlmDisposalPlan) -> list[str | None]:
    return [t for g in out.guidance for t in (g.headline, g.stream, *g.steps, *g.never)]


@timed("disposal")
async def disposal_advisor(state: RecommendState, runtime: Runtime[PipelineContext]) -> dict:
    ctx = runtime.context
    lang = state["lang"]
    items = state["hazardous_items"]
    if not items:
        return {"disposal": [], "disposal_recycle": [], "disposal_sources": []}
    # Safety documents are looked up by hazard, not by similarity: the right rules are always present.
    docs = get_index().safety_for(hazards={h for it in items for h in safety.disposal_hazards(it)})
    prompt = load_prompt("disposal_advisor", ctx.settings.prompts_dir)
    user = "\n".join(
        [
            "## Hazardous items",
            items_block(items),
            "",
            "## Knowledge (cite only these ids)",
            knowledge_block(docs),
            "",
            "Write the guidance for every item.",
        ]
    )
    plan = None
    try:
        plan = await asyncio.wait_for(
            ctx.gateway.structured(
                stage=prompt.tag,
                system=prompt.render(lang_name=lang_name(lang)),
                contents=[user],
                schema=LlmDisposalPlan,
                model=prompt.model(ctx.settings),
                examples=prompt.examples,
                validator=safety.TwoTierValidator(
                    hard=lambda o: safety.check_text_rules(_texts(o), items=items, where="The disposal advice "),
                    soft=lambda o: language_problems(_texts(o), lang, what="headlines, steps and warnings"),
                ),
                temperature=prompt.temperature,
                thinking_level=prompt.thinking_level,
            ),
            timeout=ADVISOR_BUDGET_S,
        )
        error: dict = {}
    except Exception as exc:
        log.warning("disposal_advisor failed, using reviewed disposal copy: %r", exc, exc_info=unexpected(exc))
        error = {"errors": {"disposal": exc}}

    by_id = {g.item_id: g for g in plan.guidance} if plan else {}
    guidance: list[DisposalGuidance] = []
    recycle = []
    for it in items:
        raw = by_id.get(it.id)
        allowed = safety.disposal_hazards(it)
        if raw is None or not raw.steps or not raw.never:
            entry = fallbacks.disposal_guidance(it, lang)
            stream = str(fallbacks.disposal_copy(entry.hazard, lang)["stream"])
        else:
            hazard = raw.hazard if raw.hazard in allowed else safety.primary_hazard(it) or allowed[0]
            entry = DisposalGuidance(
                item_id=it.id,
                hazard=hazard,
                headline=raw.headline.strip(),
                steps=[s.strip() for s in raw.steps if s.strip()][:4],
                never=[s.strip() for s in raw.never if s.strip()][:3],
            )
            stream = raw.stream.strip() or str(fallbacks.disposal_copy(hazard, lang)["stream"])
        guidance.append(entry)
        recycle.append(fallbacks.disposal_recycle_instruction(it, entry, stream, lang))
    sources = (cite(plan.source_ids, docs, lang) if plan else []) or cite((d.id for d in docs), docs, lang)
    return {"disposal": guidance, "disposal_recycle": recycle, "disposal_sources": sources, **error}
