"""Safety Router node: decides, deterministically, what the recommend graph may generate."""

from __future__ import annotations

from app.ai.convert import choose_primary
from app.ai.nodes.common import timed
from app.ai.safety import disposal_hazards, normalise_items, route
from app.ai.state import RecommendState


@timed("safety_router")
async def safety_router(state: RecommendState) -> dict:
    """Re-normalise hazards (the analysis may have been edited in the app), route, and pick the focus item.

    Hazards are only ever added here, never removed, so a user correction cannot turn a
    battery into a craft project.
    """
    req = state["request"]
    lang = state["lang"]
    items = normalise_items(req.analysis.items, lang)
    routing = route(items, lang)
    diy = [it for it in items if not disposal_hazards(it)]
    hazardous = [it for it in items if disposal_hazards(it)]
    diy_ids = {it.id for it in diy}
    wanted = req.focus_item_id or req.analysis.primary_item_id
    focus = wanted if wanted in diy_ids else choose_primary(diy)
    return {
        "items": items,
        "diy_items": diy,
        "hazardous_items": hazardous,
        "routing": routing,
        "focus_id": focus,
    }


def branch_after_router(state: RecommendState) -> list[str]:
    """disposal_only skips retrieval and design entirely; everything else is grounded first."""
    if state["routing"].mode == "disposal_only":
        return ["disposal_advisor", "dropoff_locator"]
    return ["knowledge_retriever"]


def branch_after_retrieval(state: RecommendState) -> list[str]:
    """Parallel fan-out. In mixed mode the Disposal Advisor also runs, for the hazardous items."""
    branches = ["upcycle_designer", "recycling_advisor", "donation_advisor", "dropoff_locator"]
    if state["routing"].mode == "mixed":
        branches.append("disposal_advisor")
    return branches
