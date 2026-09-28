"""GET /health: liveness plus what is configured (shown in the app under Settings > Backend)."""

import logging
import time

from fastapi import APIRouter, Request

from app.api.deps import SettingsDep
from app.schemas.health import HealthResponse

router = APIRouter(tags=["system"])
log = logging.getLogger("kanz.api")


def knowledge_status() -> tuple[int, bool]:
    """``(documents indexed, ready)`` from the RAG store, or ``(0, False)`` if it can't say.

    Health must answer even while the knowledge base is still seeding, failed to load, or
    its dependencies are missing, so every failure here degrades to "not ready".
    """
    try:
        from app.ai import rag  # noqa: PLC0415  # optional subsystem; imported lazily on purpose

        docs, ready = rag.status()
        return int(docs), bool(ready)
    except Exception as exc:
        log.debug("rag_status unavailable error=%r", exc)
        return 0, False


@router.get("/health", response_model=HealthResponse, summary="Warm-up and configuration status")
async def health(request: Request, settings: SettingsDep) -> HealthResponse:
    """Cheap and always available: the app calls it on launch to wake the server up."""
    docs, ready = knowledge_status()
    return HealthResponse(
        status="ok" if settings.ai_configured else "degraded",
        app_name=settings.app_name,
        version=settings.version,
        models={
            "vision": settings.model_vision,
            "text": settings.model_text,
            "image": settings.model_image,
            "embed": settings.model_embed,
        },
        ai_configured=settings.ai_configured,
        knowledge_docs=docs,
        rag_ready=ready,
        places_google=settings.places_google_configured,
        places_osm=True,
        uptime_s=int(time.monotonic() - request.app.state.started_at),
    )
