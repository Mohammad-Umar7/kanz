"""Recycling Advisor node: per-item streams, prep steps, do's and don'ts, grounded in material guides."""

from __future__ import annotations

from langgraph.runtime import Runtime

from app.ai import fallbacks, safety
from app.ai.labels import lang_name
from app.ai.llm_schemas import LlmRecycle
from app.ai.nodes.common import cite, item_line, knowledge_block, language_problems, log, recyclability_line, timed
from app.ai.prompts import load_prompt
from app.ai.state import PipelineContext, RecommendState
from app.schemas.recommend import RecycleInstruction, RecyclePath


def _texts(out: LlmRecycle) -> list[str | None]:
    return [t for i in out.instructions for t in (i.stream, i.note, *i.prep_steps, *i.dos, *i.donts)]


@timed("recycle")
async def recycling_advisor(state: RecommendState, runtime: Runtime[PipelineContext]) -> dict:
    ctx = runtime.context
    lang = state["lang"]
    items = state["diy_items"]
    guides = state.get("guides", [])
    if not items:
        return {"recycle": RecyclePath(instructions=[], sources=[])}
    prompt = load_prompt("recycling_advisor", ctx.settings.prompts_dir)
    user = "\n".join(
        [
            "## Scanned items",
            *(f"{item_line(it)}\n{recyclability_line(it)}" for it in items),
            "",
            "## Knowledge (cite only these ids)",
            knowledge_block(guides),
            "",
            "Write one instruction per item.",
        ]
    )
    try:
        out = await ctx.gateway.structured(
            stage=prompt.tag,
            system=prompt.render(lang_name=lang_name(lang)),
            contents=[user],
            schema=LlmRecycle,
            model=prompt.model(ctx.settings),
            examples=prompt.examples,
            validator=safety.TwoTierValidator(
                hard=lambda o: safety.check_plastic_heat(_texts(o), where="The recycling advice "),
                soft=lambda o: language_problems(_texts(o), lang, what="streams, steps and tips"),
            ),
            temperature=prompt.temperature,
            thinking_level=prompt.thinking_level,
        )
    except Exception as exc:
        log.warning("recycling_advisor failed, using the analyst's recyclability: %r", exc)
        return {"recycle": fallbacks.recycle_path(items, lang, guides), "errors": {"recycle": exc}}

    by_id = {i.item_id: i for i in out.instructions}
    instructions = []
    for it in items:
        raw = by_id.get(it.id)
        if raw is None:
            instructions.append(fallbacks.recycle_instruction(it, lang))
            continue
        instructions.append(
            RecycleInstruction(
                item_id=it.id,
                status=raw.status,
                stream=raw.stream.strip() or it.recyclability.stream,
                prep_steps=[s.strip() for s in raw.prep_steps if s.strip()][:4] or list(it.recyclability.prep_steps),
                dos=[s.strip() for s in raw.dos if s.strip()][:2],
                donts=[s.strip() for s in raw.donts if s.strip()][:3],
                note=(raw.note or "").strip() or None,
            )
        )
    # The guides were retrieved for exactly these materials; cite them if the model cited none.
    sources = cite(out.source_ids, guides, lang) or cite((g.id for g in guides), guides, lang)
    return {"recycle": RecyclePath(instructions=instructions, sources=sources)}
