"""Shared building blocks of the public API (contract v1).

Conventions for every schema in ``app.schemas``:
* JSON keys are snake_case English. Free-text values (names, steps, tips) are in the
  request language (``lang``); enum values stay English and are localized by the app.
* Every response carries ``timings_ms`` so the app and the eval script can show and
  log per-stage latency.
* The Dart mirror lives in ``app/lib/core/data/models/`` and is tested against the
  JSON fixtures in ``contracts/fixtures/``.
"""

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.vocab import Lang, SkillLevel, ToolId


class ApiModel(BaseModel):
    """Base for all API models: forbid unknown fields so contract drift fails loudly."""

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class Profile(ApiModel):
    """What the user told us in onboarding; used to tailor ideas and tutorials."""

    skill: SkillLevel = "beginner"
    tools: list[ToolId] = Field(default_factory=list, description="Tools the user has at home.")
    lang: Lang = "en"


class SourceRef(ApiModel):
    """A knowledge-base document that grounded a recommendation (shown as a source chip)."""

    id: str = Field(description="Knowledge-base document id, e.g. 'proj_glass_jar_lantern'.")
    title: str = Field(description="Title in the request language.")
    kind: Literal["project", "material_guide", "safety", "swap"]


class LatLng(ApiModel):
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)


ErrorCode = Literal[
    "bad_request",
    "image_invalid",
    "image_too_large",
    "not_found",
    "rate_limited",
    "ai_unavailable",
    "ai_timeout",
    "ai_invalid_output",
    "ai_quota_exhausted",
    "places_unavailable",
    "internal",
]


class ErrorBody(ApiModel):
    code: ErrorCode
    message: str = Field(description="Short, friendly, human message safe to show in the app.")
    retryable: bool
    request_id: str


class ErrorResponse(ApiModel):
    """Body of every non-2xx response. HTTP status mirrors the code (400/404/413/422/429/502/503/504/500)."""

    error: ErrorBody


Timings = dict[str, int]
