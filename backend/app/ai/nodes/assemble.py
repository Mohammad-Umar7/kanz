"""Assemble node: joins the parallel branches into one ``RecommendResponse``.

Failure policy: a failed branch has already been replaced by its deterministic fallback,
so the response is still complete. The request only fails when the Upcycle Designer and
every other generating branch failed together (the AI service is effectively down), or
when three ideas could not be produced at all.
"""

from __future__ import annotations

from app.ai import fallbacks
from app.ai.state import RecommendState
from app.core.errors import AiTimeout, AiUnavailable, KanzError
from app.schemas.common import SourceRef
from app.schemas.recommend import RecommendResponse, RecyclePath

GENERATING_BRANCHES = ("upcycle", "recycle", "donate")


def as_api_error(exc: Exception | None) -> KanzError:
    """Branch errors are stored raw; the API needs a typed error with the right code and status."""
    if isinstance(exc, KanzError):
        return exc
    if isinstance(exc, TimeoutError):
        return AiTimeout(detail="recommendation branches exceeded their time budget")
    return AiUnavailable(detail=repr(exc) if exc else "upcycle designer returned no usable ideas")


def _dedupe_sources(sources: list[SourceRef]) -> list[SourceRef]:
    seen: dict[str, SourceRef] = {}
    for s in sources:
        seen.setdefault(s.id, s)
    return list(seen.values())


async def assemble(state: RecommendState) -> dict:
    routing = state["routing"]
    lang = state["lang"]
    errors = state.get("errors", {})
    disposal_only = routing.mode == "disposal_only"

    ideas = [] if disposal_only else state.get("upcycle", [])
    all_failed = all(branch in errors for branch in GENERATING_BRANCHES)
    if not disposal_only and (all_failed or len(ideas) != 3):
        raise as_api_error(errors.get("upcycle"))

    advisor = state.get("recycle") or RecyclePath(instructions=[], sources=[])
    by_item = {i.item_id: i for i in [*advisor.instructions, *state.get("disposal_recycle", [])]}
    instructions = [by_item[it.id] for it in state["items"] if it.id in by_item]
    recycle = RecyclePath(
        instructions=instructions,
        sources=_dedupe_sources([*advisor.sources, *state.get("disposal_sources", [])]),
    )
    donate = fallbacks.donate_unavailable(lang) if disposal_only else state["donate"]

    response = RecommendResponse(
        routing=routing,
        upcycle=ideas,
        recycle=recycle,
        donate=donate,
        disposal=state.get("disposal", []),
        facility_categories=state.get("facility_categories", []),
        lang=lang,
        timings_ms={},
    )
    return {"response": response}
