"""Typed application errors. Each maps to one ``ErrorCode`` and HTTP status.

Raise these anywhere in the backend; the exception handlers in ``app.main`` turn
them into ``ErrorResponse`` bodies with a friendly message and a request id.
"""

from app.schemas.common import ErrorCode


class KanzError(Exception):
    code: ErrorCode = "internal"
    status: int = 500
    retryable: bool = False
    default_message: str = "Something went wrong on our side. Please try again."

    def __init__(self, message: str | None = None, *, detail: str | None = None) -> None:
        self.message = message or self.default_message
        self.detail = detail  # logged, never sent to the client
        super().__init__(self.message)


class BadRequest(KanzError):
    code: ErrorCode = "bad_request"
    status = 400
    default_message = "That request was missing something. Please try again."


class ImageInvalid(KanzError):
    code: ErrorCode = "image_invalid"
    status = 400
    default_message = "We couldn't read that image. Try a JPEG or PNG photo."


class ImageTooLarge(KanzError):
    code: ErrorCode = "image_too_large"
    status = 413
    default_message = "That photo is too large. Try again with a smaller one."


class NotFound(KanzError):
    code: ErrorCode = "not_found"
    status = 404
    default_message = "We couldn't find that. It may have expired; try scanning again."


class RateLimited(KanzError):
    code: ErrorCode = "rate_limited"
    status = 429
    retryable = True
    default_message = "Too many requests at once. Wait a few seconds and try again."


class AiUnavailable(KanzError):
    code: ErrorCode = "ai_unavailable"
    status = 503
    retryable = True
    default_message = "The AI service is busy right now. Please try again in a moment."


class AiTimeout(KanzError):
    code: ErrorCode = "ai_timeout"
    status = 504
    retryable = True
    default_message = "This is taking longer than usual. Please try again."


class AiInvalidOutput(KanzError):
    code: ErrorCode = "ai_invalid_output"
    status = 502
    retryable = True
    default_message = "The AI gave an answer we couldn't use. Please try again."


class AiQuotaExhausted(KanzError):
    code: ErrorCode = "ai_quota_exhausted"
    status = 503
    retryable = False
    default_message = "The AI quota for this server is used up. Try again later."


class PlacesUnavailable(KanzError):
    code: ErrorCode = "places_unavailable"
    status = 503
    retryable = True
    default_message = "We couldn't load drop-off points right now. Please try again."
