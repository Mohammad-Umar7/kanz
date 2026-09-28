"""POST /v1/tutorial: an upcycle idea -> a step-by-step tutorial adapted to skill and tools."""

from fastapi import APIRouter

from app.ai import pipeline
from app.api.responses import AI, COMMON, error_responses
from app.schemas.tutorial import TutorialRequest, TutorialResponse

router = APIRouter(tags=["tutorials"])


@router.post(
    "/tutorial",
    response_model=TutorialResponse,
    summary="Write a DIY tutorial for an idea",
    responses=error_responses(*COMMON, *AI),
)
async def tutorial(req: TutorialRequest) -> TutorialResponse:
    """Retriever + Tutorial Writer. ``tutorial_id`` is deterministic for (photo, idea, skill,
    tools, language): changing the skill or tools yields a new, re-adapted tutorial.

    Step images are not in this response. When ``STEP_IMAGES_AUTOSTART`` is on, the image
    chain starts in the background; the app fetches each one from ``/v1/images/step``.
    """
    return await pipeline.tutorial(req)
