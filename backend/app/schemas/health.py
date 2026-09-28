"""GET /health: liveness plus what is configured (shown on the app's Settings > Backend status)."""

from typing import Literal

from pydantic import Field

from app.schemas.common import ApiModel


class HealthResponse(ApiModel):
    status: Literal["ok", "degraded"]
    app_name: str
    version: str
    models: dict[str, str] = Field(description="Role -> model id, e.g. {'vision': 'gemini-3.6-flash'}.")
    ai_configured: bool
    knowledge_docs: int
    rag_ready: bool
    places_google: bool
    places_osm: bool
    uptime_s: int
