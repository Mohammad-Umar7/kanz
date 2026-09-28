"""POST /v1/images/after, /step, /bin: generated images, returned as static URLs."""

from fastapi import APIRouter

from app.api.responses import AI, COMMON, error_responses
from app.images import service
from app.schemas.images import AfterImageRequest, BinImageRequest, ImageResponse, StepImageRequest

router = APIRouter(prefix="/images", tags=["images"])

_ERRORS = error_responses(404, *COMMON, *AI)


@router.post("/after", response_model=ImageResponse, summary="Render the finished project", responses=_ERRORS)
async def after_image(req: AfterImageRequest) -> ImageResponse:
    """Edits the user's photo into the finished upcycled object, keeping its identity,
    lighting and camera angle. Cached per (photo, idea) unless ``regenerate`` is set.
    """
    return await service.after_image(req)


@router.post("/step", response_model=ImageResponse, summary="Render one tutorial step", responses=_ERRORS)
async def step_image(req: StepImageRequest) -> ImageResponse:
    """Step N edits step N-1's image, so the same object visibly progresses through the
    tutorial. Missing earlier steps are generated first.
    """
    return await service.step_image(req)


@router.post("/bin", response_model=ImageResponse, summary="Show the item prepared for its bin", responses=_ERRORS)
async def bin_image(req: BinImageRequest) -> ImageResponse:
    """The scanned item shown ready for recycling (rinsed, cap off, flattened)."""
    return await service.bin_image(req)
