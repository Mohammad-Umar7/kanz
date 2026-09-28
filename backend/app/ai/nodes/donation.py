"""Donation Advisor node: condition-based donation decisions with where and how."""

from __future__ import annotations

import asyncio

from langgraph.runtime import Runtime

from app.ai import fallbacks, safety
from app.ai.labels import lang_name
from app.ai.llm_schemas import LlmDonate
from app.ai.nodes.common import (
    ADVISOR_BUDGET_S,
    items_block,
    knowledge_block,
    language_problems,
    log,
    timed,
    unexpected,
)
from app.ai.prompts import load_prompt
from app.ai.state import PipelineContext, RecommendState
from app.schemas.recommend import DonateOption, DonatePath


def _texts(out: LlmDonate) -> list[str | None]:
    return [out.summary, *(t for o in out.options for t in (o.reason, *o.where, *o.prep_steps))]


@timed("donate")
async def donation_advisor(state: RecommendState, runtime: Runtime[PipelineContext]) -> dict:
    ctx = runtime.context
    lang = state["lang"]
    items = state["diy_items"]
    if not items:
        return {"donate": fallbacks.donate_unavailable(lang)}
    guides = [g for g in state.get("guides", []) if g.id.startswith("mat_")]
    prompt = load_prompt("donation_advisor", ctx.settings.prompts_dir)
    user = "\n".join(
        [
            "## Scanned items",
            items_block(items),
            "",
            "## Knowledge",
            knowledge_block(guides),
            "",
            "Decide for every item.",
        ]
    )
    try:
        out = await asyncio.wait_for(
            ctx.gateway.structured(
                stage=prompt.tag,
                system=prompt.render(lang_name=lang_name(lang)),
                contents=[user],
                schema=LlmDonate,
                model=prompt.model(ctx.settings),
                examples=prompt.examples,
                validator=safety.TwoTierValidator(
                    hard=lambda o: safety.check_text_rules(_texts(o), where="The donation advice "),
                    soft=lambda o: language_problems(_texts(o), lang, what="reasons, places and steps"),
                ),
                temperature=prompt.temperature,
                thinking_level=prompt.thinking_level,
            ),
            timeout=ADVISOR_BUDGET_S,
        )
    except Exception as exc:
        log.warning("donation_advisor failed, using condition rules: %r", exc, exc_info=unexpected(exc))
        return {"donate": fallbacks.donate_path(items, lang), "errors": {"donate": exc}}

    by_id = {o.item_id: o for o in out.options}
    options: list[DonateOption] = []
    overridden = False
    for it in items:
        raw = by_id.get(it.id)
        if raw is None:
            options.append(fallbacks.donate_option(it, lang))
            continue
        if raw.suitable and fallbacks.donation_blocker(it):
            # Hazards, mold or breakage rule donation out whatever the model concluded.
            options.append(fallbacks.donate_option(it, lang))
            overridden = True
            continue
        options.append(
            DonateOption(
                item_id=it.id,
                suitable=raw.suitable,
                reason=raw.reason.strip(),
                where=[w.strip() for w in raw.where if w.strip()][:4] if raw.suitable else [],
                prep_steps=[p.strip() for p in raw.prep_steps if p.strip()][:3] if raw.suitable else [],
            )
        )
    available = any(o.suitable for o in options)
    summary = out.summary.strip()
    if not summary or (overridden and not available):
        summary = fallbacks.donate_summary(available, lang)
    return {"donate": DonatePath(available=available, summary=summary, options=options)}
