"""POST /v1/recommend: analysis + profile -> safety routing, upcycle ideas, recycle, donate, drop-off."""

from fastapi import APIRouter

from app.ai import pipeline
from app.api.responses import AI, COMMON, error_responses
from app.core.errors import BadRequest
from app.schemas.recommend import RecommendRequest, RecommendResponse

router = APIRouter(tags=["recommendations"])


@router.post(
    "/recommend",
    response_model=RecommendResponse,
    summary="Recommend upcycle, recycle and donate paths",
    responses=error_responses(400, *COMMON, *AI),
)
async def recommend(req: RecommendRequest) -> RecommendResponse:
    """Runs the agent graph: Safety Router, Knowledge Retriever, then the Upcycle Designer,
    Recycling Advisor, Donation Advisor and Drop-off Locator.

    Hazardous items (batteries, e-waste, chemicals, ...) switch ``routing.mode`` to
    ``disposal_only``: no DIY ideas, only safe disposal guidance and matching drop-off points.
    """
    item_ids = {item.id for item in req.analysis.items}
    if not item_ids:
        raise BadRequest("This scan has no items to recommend for. Try another photo.")
    if req.focus_item_id is not None and req.focus_item_id not in item_ids:
        raise BadRequest(f"'focus_item_id' {req.focus_item_id!r} is not an item in this scan.")
    return await pipeline.recommend(req)
