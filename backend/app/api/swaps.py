"""POST /v1/swaps: things the user often throws away -> eco-friendly swap cards."""

from fastapi import APIRouter

from app.api.responses import AI, COMMON, error_responses
from app.schemas.swaps import SwapsRequest, SwapsResponse
from app.swaps import service

router = APIRouter(tags=["swaps"])


@router.post(
    "/swaps",
    response_model=SwapsResponse,
    summary="Suggest eco-friendly swaps",
    responses=error_responses(*COMMON, *AI),
)
async def suggest(req: SwapsRequest) -> SwapsResponse:
    """Swap Advisor over the swaps knowledge base. ``materials`` takes chip ids and free
    text; ``history`` (counted on the device) lets it point at what the user throws away most.
    """
    return await service.suggest(req)
