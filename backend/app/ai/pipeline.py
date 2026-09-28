"""LangGraph pipelines behind /v1/analyze, /v1/recommend and /v1/tutorial. Owned by AI Pipeline.

Public seam (keep these signatures):

    async def analyze(*, image: bytes | None, text: str | None, lang: str) -> AnalyzeResponse
    async def recommend(req: RecommendRequest) -> RecommendResponse
    async def tutorial(req: TutorialRequest) -> TutorialResponse

Each function accepts an optional ``gateway`` keyword (tests and the eval script pass one)
and returns ``timings_ms`` with one entry per stage plus ``total``.
"""

from __future__ import annotations

import time

from app.ai import safety
from app.ai.gemini import GeminiGateway, get_gateway
from app.ai.graph import analyze_graph, recommend_graph, tutorial_graph
from app.ai.nodes.tutorial import start_step_images
from app.ai.state import PipelineContext
from app.config import get_settings
from app.core.errors import BadRequest, NotFound
from app.core.storage import get_store
from app.core.timing import stage_timer
from app.core.tutorials import get_tutorial_store, tutorial_id_for
from app.schemas.analysis import AnalyzeResponse
from app.schemas.recommend import RecommendRequest, RecommendResponse
from app.schemas.tutorial import TutorialRequest, TutorialResponse


def _context(gateway: GeminiGateway | None) -> PipelineContext:
    return PipelineContext(gateway=gateway or get_gateway(), settings=get_settings(), tutorials=get_tutorial_store())


def _ms(start: float) -> int:
    return int((time.perf_counter() - start) * 1000)


async def analyze(
    *, image: bytes | None, text: str | None, lang: str, gateway: GeminiGateway | None = None
) -> AnalyzeResponse:
    """Photo (or description) -> stored upload -> Material Analyst -> safety-normalised analysis."""
    start = time.perf_counter()
    lang = "ar" if lang == "ar" else "en"
    timings: dict[str, int] = {}
    store = get_store()
    image_url = width = height = None
    jpeg: bytes | None = None
    if image:
        with stage_timer(timings, "upload"):
            stored = store.save_upload(image)
        image_id, image_url, width, height = stored.image_id, stored.url, stored.width, stored.height
        jpeg = stored.path.read_bytes()  # the re-encoded, downscaled JPEG is what the model sees
    elif text and text.strip():
        image_id = store.save_text_scan(text)
    else:
        raise BadRequest("Send a photo or a short description of the item.")

    state = await analyze_graph().ainvoke(
        {"image": jpeg, "text": None if jpeg else text, "lang": lang}, context=_context(gateway)
    )
    timings.update(state.get("timings", {}))
    timings["total"] = _ms(start)
    return AnalyzeResponse(
        image_id=image_id,
        image_url=image_url,
        image_width=width,
        image_height=height,
        analysis=state["analysis"],
        lang=lang,
        timings_ms=timings,
    )


async def recommend(req: RecommendRequest, *, gateway: GeminiGateway | None = None) -> RecommendResponse:
    """Safety routing, then grounded upcycle / recycle / donate / disposal advice and drop-off categories."""
    start = time.perf_counter()
    if not req.analysis.items:
        raise BadRequest("Nothing was identified in this scan yet. Retake the photo, then try again.")
    _require_scan(req.image_id)
    lang = req.profile.lang
    state = await recommend_graph().ainvoke({"request": req, "lang": lang}, context=_context(gateway))
    timings = dict(state.get("timings", {}))
    timings["total"] = _ms(start)
    return state["response"].model_copy(update={"timings_ms": timings})


def _require_scan_impl(image_id: str) -> None:
    """Fail fast (404) for an unknown photo or text scan instead of spending model calls on it."""
    store = get_store()
    try:
        exists = store.upload_exists(image_id) if image_id.startswith("img_") else bool(store.load_text_scan(image_id))
    except NotFound:
        exists = False
    if not exists:
        raise NotFound("We couldn't find that scan. It may have expired; please scan the item again.")


_require_scan = _require_scan_impl


async def tutorial(req: TutorialRequest, *, gateway: GeminiGateway | None = None) -> TutorialResponse:
    """Adapted tutorial for one idea. Cached by (image, idea, skill, tools, lang); starts step images."""
    start = time.perf_counter()
    items = safety.normalise_items(req.items, req.profile.lang)
    used = set(req.idea.uses_item_ids)
    if any(safety.disposal_hazards(it) for it in items if it.id in used):
        raise BadRequest("This item needs safe disposal, so there is no DIY tutorial for it.")
    # Hazardous items the idea does not use are dropped rather than shown to the writer.
    req = req.model_copy(update={"items": [it for it in items if not safety.disposal_hazards(it)]})
    profile = req.profile
    tutorial_id = tutorial_id_for(req.image_id, req.idea.id, profile.skill, list(profile.tools), profile.lang)

    cached = get_tutorial_store().get(tutorial_id)
    if cached is not None:
        start_step_images(cached, req.idea)  # resumes the chain after a restart; deduplicated otherwise
        return TutorialResponse(tutorial=cached, timings_ms={"cache": _ms(start), "total": _ms(start)})

    state = await tutorial_graph().ainvoke({"request": req, "tutorial_id": tutorial_id}, context=_context(gateway))
    timings = dict(state.get("timings", {}))
    timings["total"] = _ms(start)
    return TutorialResponse(tutorial=state["tutorial"], timings_ms=timings)
