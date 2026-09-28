"""Kanz API: the FastAPI application.

Run it with ``uvicorn app.main:app`` (see ``run.ps1`` / ``run.sh``). ``create_app`` builds a
fresh app from a ``Settings`` object, which the tests use with a temporary data folder.

Request path, outermost first::

    CORS -> request id + access log -> rate limit (/v1) -> body size limit -> routes
                                                                 |-> /static (uploads, generated images)
"""

from __future__ import annotations

import asyncio
import contextlib
import logging
import time
from collections.abc import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from app.api import analyze, facilities, health, images, recommend, swaps, tutorial
from app.config import Settings, get_settings
from app.core.error_handlers import install_error_handlers
from app.core.logging import configure_logging
from app.core.middleware import BodySizeLimitMiddleware, RequestContextMiddleware
from app.core.ratelimit import RateLimitMiddleware, SlidingWindowLimiter
from app.core.request_id import HEADER as REQUEST_ID_HEADER
from app.core.static import IMMUTABLE, REVALIDATE_DAILY, CachedStaticFiles
from app.core.timing import stage_timer
from app.core.uploads import MIB

log = logging.getLogger("kanz.app")

# Room for the multipart envelope and the text/lang fields around the photo itself.
FORM_OVERHEAD_BYTES = 256 * 1024

DESCRIPTION = """
Kanz identifies the materials in a photo of something you would throw away, recommends
how to upcycle, recycle or donate it, writes a tutorial adapted to your tools and skill
with generated step images, and finds drop-off points nearby.

Every non-2xx response is an `ErrorResponse`; every response has an `X-Request-ID` header.
Full contract: `docs/API.md`.
"""

TAGS = [
    {"name": "analysis", "description": "Material recognition from a photo or a description."},
    {"name": "recommendations", "description": "Safety routing and the upcycle, recycle and donate paths."},
    {"name": "tutorials", "description": "Step-by-step DIY tutorials."},
    {"name": "images", "description": "Generated after, step and bin images."},
    {"name": "drop-off", "description": "Nearby recycling, donation and hazardous-waste points."},
    {"name": "swaps", "description": "Eco-friendly alternatives."},
    {"name": "system", "description": "Health and configuration."},
]


def ensure_data_dirs(settings: Settings) -> None:
    for folder in (settings.uploads_dir, settings.generated_dir, settings.tutorials_dir):
        folder.mkdir(parents=True, exist_ok=True)


def log_config_summary(settings: Settings) -> None:
    """One line describing the running configuration. Keys are reported as booleans only."""
    log.info(
        "config environment=%s version=%s model_vision=%s model_text=%s model_image=%s model_embed=%s "
        "fallbacks=%s gemini_key=%s maps_key=%s rate_limit_per_minute=%d max_upload_mb=%d "
        "step_images_autostart=%s data_dir=%s",
        settings.environment,
        settings.version,
        settings.model_vision,
        settings.model_text,
        settings.model_image,
        settings.model_embed,
        ",".join(settings.model_fallbacks),
        settings.ai_configured,
        settings.places_google_configured,
        settings.rate_limit_per_minute,
        settings.max_upload_mb,
        settings.step_images_autostart,
        settings.data_dir,
    )


async def seed_knowledge_in_background() -> None:
    """Index the knowledge base without holding up startup.

    Seeding embeds every document on a fresh install, which can take a while on a free-tier
    key. The API serves immediately; until seeding finishes, ``/health`` reports
    ``rag_ready: false``. A failure is logged and never takes the server down.
    """
    try:
        from app.ai import rag  # noqa: PLC0415  # imported here so a RAG problem can't block startup

        with stage_timer(None, "seed_knowledge"):
            docs = await rag.seed_knowledge()
        log.info("knowledge_seeded docs=%d", docs)
    except Exception:
        log.exception("knowledge_seed_failed")


@contextlib.asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings: Settings = app.state.settings
    ensure_data_dirs(settings)
    app.state.started_at = time.monotonic()
    log_config_summary(settings)
    seeding = asyncio.create_task(seed_knowledge_in_background(), name="seed-knowledge")
    app.state.seed_task = seeding
    try:
        yield
    finally:
        if not seeding.done():
            seeding.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await seeding


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or get_settings()
    configure_logging(settings.log_level)
    ensure_data_dirs(settings)  # StaticFiles checks its folders when mounted

    app = FastAPI(
        title="Kanz API",
        version=settings.version,
        description=DESCRIPTION,
        openapi_tags=TAGS,
        lifespan=lifespan,
    )
    app.state.settings = settings
    app.state.started_at = time.monotonic()
    install_error_handlers(app)

    # add_middleware wraps the app built so far, so the last one added runs first.
    app.add_middleware(BodySizeLimitMiddleware, max_bytes=settings.max_upload_mb * MIB + FORM_OVERHEAD_BYTES)
    if settings.rate_limit_per_minute > 0:
        app.add_middleware(RateLimitMiddleware, limiter=SlidingWindowLimiter(settings.rate_limit_per_minute))
    app.add_middleware(RequestContextMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=["*"],
        expose_headers=[REQUEST_ID_HEADER, "Retry-After"],
    )

    app.include_router(health.router)
    for module in (analyze, recommend, tutorial, images, facilities, swaps):
        app.include_router(module.router, prefix="/v1")

    app.mount(
        "/static/uploads",
        CachedStaticFiles(directory=settings.uploads_dir, cache_control=IMMUTABLE),
        name="uploads",
    )
    app.mount(
        "/static/generated",
        CachedStaticFiles(directory=settings.generated_dir, cache_control=REVALIDATE_DAILY),
        name="generated",
    )

    @app.get("/", include_in_schema=False)
    async def root() -> RedirectResponse:
        return RedirectResponse("/docs")

    return app


app = create_app()
