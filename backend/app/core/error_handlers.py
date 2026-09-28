"""Turn every failure into the ``ErrorResponse`` envelope from docs/API.md.

* ``KanzError`` (raised anywhere in the backend) keeps its status, code and retryable flag.
  Its ``detail`` goes to the log only; the client gets the friendly ``message``.
* ``RequestValidationError`` becomes 422 ``bad_request`` with a message naming the first
  bad field, e.g. ``'profile.skill' is invalid: Input should be 'beginner', ...``.
* ``HTTPException`` (unknown route, wrong method, unparsable body) maps to the nearest code.
* Anything else is a 500 ``internal``: the traceback is logged, nothing leaks to the client.

Every body carries the request id so a message on the phone can be matched to the log.
"""

from __future__ import annotations

import logging
from collections.abc import Mapping, Sequence
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException

from app.core.errors import BadRequest, ImageTooLarge, KanzError, RateLimited
from app.core.request_id import current_request_id
from app.schemas.common import ErrorBody, ErrorCode, ErrorResponse

log = logging.getLogger("kanz.errors")

_LOCATIONS = {"body", "query", "path", "header", "cookie"}
_MAX_DETAIL_CHARS = 180

# HTTP status -> (code, message) for framework-raised HTTPExceptions.
_HTTP_ERRORS: dict[int, tuple[ErrorCode, str]] = {
    400: ("bad_request", "We couldn't read that request. Please try again."),
    404: ("not_found", "We couldn't find that."),
    405: ("bad_request", "That method isn't supported here."),
    413: ("image_too_large", ImageTooLarge.default_message),
    429: ("rate_limited", RateLimited.default_message),
}


class KanzHTTPException(HTTPException):
    """Carries a ``KanzError`` through code that only lets ``HTTPException`` pass.

    FastAPI re-raises ``HTTPException`` from request-body parsing unchanged but wraps any
    other exception into a generic 400. Middleware that must fail inside that phase (the
    streaming body-size limit) raises this instead, and the handler unwraps the real error.
    """

    def __init__(self, error: KanzError) -> None:
        super().__init__(status_code=error.status, detail=error.message)
        self.error = error


def error_response(
    status: int,
    code: ErrorCode,
    message: str,
    *,
    retryable: bool = False,
    headers: Mapping[str, str] | None = None,
) -> JSONResponse:
    """Build an ``ErrorResponse`` JSON response stamped with the current request id."""
    body = ErrorResponse(
        error=ErrorBody(code=code, message=message, retryable=retryable, request_id=current_request_id())
    )
    return JSONResponse(body.model_dump(mode="json"), status_code=status, headers=dict(headers or {}))


def kanz_error_response(exc: KanzError, headers: Mapping[str, str] | None = None) -> JSONResponse:
    return error_response(exc.status, exc.code, exc.message, retryable=exc.retryable, headers=headers)


def describe_validation_error(errors: Sequence[Mapping[str, Any]]) -> str:
    """One short sentence naming the first invalid field, safe to show in the app."""
    if not errors:
        return "Some fields are missing or invalid."
    first = errors[0]
    kind = str(first.get("type", ""))
    if kind == "json_invalid":
        return "The request body is not valid JSON."

    loc = list(first.get("loc", ()))
    if loc and loc[0] in _LOCATIONS:
        loc = loc[1:]
    field = ""
    for part in loc:
        field += f"[{part}]" if isinstance(part, int) else (f".{part}" if field else str(part))

    msg = str(first.get("msg", "invalid value")).removeprefix("Value error, ")
    if len(msg) > _MAX_DETAIL_CHARS:
        msg = msg[: _MAX_DETAIL_CHARS - 3].rstrip() + "..."

    if not field:
        return msg if msg.endswith(".") else msg + "."
    if kind == "missing":
        return f"'{field}' is required."
    if kind == "extra_forbidden":
        return f"'{field}' is not a known field."
    return f"'{field}' is invalid: {msg}" + ("" if msg.endswith(".") else ".")


async def handle_kanz_error(request: Request, exc: KanzError) -> JSONResponse:
    level = logging.WARNING if exc.status >= 500 else logging.INFO
    log.log(
        level,
        "error code=%s status=%d path=%s detail=%r",
        exc.code,
        exc.status,
        request.url.path,
        exc.detail or exc.message,
    )
    return kanz_error_response(exc)


async def handle_validation_error(request: Request, exc: RequestValidationError) -> JSONResponse:
    errors = exc.errors()
    message = describe_validation_error(errors)
    log.info("error code=bad_request status=422 path=%s problems=%d first=%r", request.url.path, len(errors), message)
    return error_response(422, "bad_request", message)


async def handle_http_exception(request: Request, exc: HTTPException) -> JSONResponse:
    if isinstance(exc, KanzHTTPException):
        return await handle_kanz_error(request, exc.error)
    if exc.status_code in _HTTP_ERRORS:
        code, message = _HTTP_ERRORS[exc.status_code]
    elif exc.status_code < 500:
        code, message = "bad_request", BadRequest.default_message
    else:
        code, message = "internal", KanzError.default_message
    log.info("error code=%s status=%d path=%s", code, exc.status_code, request.url.path)
    return error_response(
        exc.status_code,
        code,
        message,
        retryable=exc.status_code == 429,
        headers=exc.headers,
    )


def internal_error_response() -> JSONResponse:
    return error_response(500, "internal", KanzError.default_message)


async def handle_unexpected(request: Request, exc: Exception) -> JSONResponse:
    """Last resort. RequestContextMiddleware normally catches these first (see its docstring)."""
    log.error("error code=internal status=500 path=%s", request.url.path, exc_info=exc)
    return internal_error_response()


def install_error_handlers(app: FastAPI) -> None:
    # Handlers are typed with their specific exception; Starlette dispatches on the MRO.
    app.add_exception_handler(KanzError, handle_kanz_error)  # type: ignore[arg-type]
    app.add_exception_handler(RequestValidationError, handle_validation_error)  # type: ignore[arg-type]
    app.add_exception_handler(HTTPException, handle_http_exception)  # type: ignore[arg-type]
    app.add_exception_handler(Exception, handle_unexpected)
