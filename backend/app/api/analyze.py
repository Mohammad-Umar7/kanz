"""POST /v1/analyze: a photo and/or a short description -> structured material analysis."""

from typing import Annotated

from fastapi import APIRouter, File, Form, UploadFile

from app.ai import pipeline
from app.api.deps import SettingsDep
from app.api.responses import AI, COMMON, error_responses
from app.core.errors import BadRequest
from app.core.uploads import MIB, read_image_upload
from app.schemas.analysis import AnalyzeResponse
from app.schemas.vocab import Lang

router = APIRouter(tags=["analysis"])

MAX_TEXT_CHARS = 2000


@router.post(
    "/analyze",
    response_model=AnalyzeResponse,
    summary="Identify the materials in a photo or a description",
    responses=error_responses(400, 413, *COMMON, *AI),
)
async def analyze(
    settings: SettingsDep,
    image: Annotated[
        UploadFile | None,
        File(description="JPEG, PNG or WebP photo. The app sends ~1600 px on the long edge, JPEG q85."),
    ] = None,
    text: Annotated[
        str | None,
        Form(max_length=MAX_TEXT_CHARS, description="Optional if a photo is sent: 'a pile of old denim jeans'."),
    ] = None,
    lang: Annotated[Lang, Form(description="Language for all free text in the answer.")] = "en",
) -> AnalyzeResponse:
    """Send a photo, a description, or both (the text then acts as a hint for the photo).

    Items come back with material, quantity, quality, state tags, recyclability, reuse
    potential, hazards, confidence and a bounding box. When ``analysis.photo.usable`` is
    false the app asks for a retake and shows ``retake_tip``.
    """
    photo = await read_image_upload(image, max_bytes=settings.max_upload_mb * MIB) if image is not None else None
    description = (text or "").strip() or None
    if photo is None and description is None:
        raise BadRequest("Add a photo or describe the item in a few words.")
    return await pipeline.analyze(image=photo, text=description, lang=lang)
