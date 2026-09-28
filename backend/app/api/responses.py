"""OpenAPI entries for the error envelope, so /docs shows every route's failure modes.

Each route lists the statuses it can return; the schema is ``ErrorResponse`` and the
example is built from the real error class, so the docs can't drift from the handlers.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import Any

from app.core.errors import (
    AiInvalidOutput,
    AiTimeout,
    AiUnavailable,
    BadRequest,
    ImageTooLarge,
    KanzError,
    NotFound,
    RateLimited,
)
from app.schemas.common import ErrorResponse

_DEFAULTS: dict[int, tuple[str, KanzError]] = {
    400: ("`bad_request` or `image_invalid`.", BadRequest()),
    404: ("`not_found`: unknown or expired id.", NotFound()),
    413: ("`image_too_large`: upload over `MAX_UPLOAD_MB`.", ImageTooLarge()),
    422: (
        "`bad_request`: a field failed validation; the message names it.",
        BadRequest("'lang' is invalid: Input should be 'en' or 'ar'."),
    ),
    429: ("`rate_limited`: too many requests from this client. See `Retry-After`.", RateLimited()),
    500: ("`internal`: unexpected error (logged with the request id).", KanzError()),
    502: ("`ai_invalid_output`: the model's answer failed validation after the repair round.", AiInvalidOutput()),
    503: ("`ai_unavailable` (retry) or `ai_quota_exhausted` (do not retry).", AiUnavailable()),
    504: ("`ai_timeout`: a stage exceeded its time budget.", AiTimeout()),
}

COMMON = (422, 429, 500)
"""Every /v1 route: validation, rate limit, unexpected errors."""

AI = (502, 503, 504)
"""Routes that call Gemini."""


def error_responses(
    *statuses: int, overrides: Mapping[int, tuple[str, KanzError]] | None = None
) -> dict[int | str, dict[str, Any]]:
    """``responses=`` value documenting ``statuses``; ``overrides`` swaps a description and example."""
    docs: dict[int | str, dict[str, Any]] = {}
    for status in sorted(set(statuses) | set(overrides or {})):
        description, example = (overrides or {}).get(status) or _DEFAULTS[status]
        docs[status] = {
            "model": ErrorResponse,
            "description": description,
            "content": {
                "application/json": {
                    "example": {
                        "error": {
                            "code": example.code,
                            "message": example.message,
                            "retryable": example.retryable,
                            "request_id": "req_5f3c2a1b",
                        }
                    }
                }
            },
        }
    return docs
