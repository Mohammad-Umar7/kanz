"""Pure ASGI middleware: request context and request-body size limit.

Pure ASGI (rather than ``BaseHTTPMiddleware``) keeps the request-id context variable
visible to route code and background work, and adds no buffering to responses.
"""

from __future__ import annotations

import logging
import time

from starlette.datastructures import Headers, MutableHeaders
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.core.error_handlers import KanzHTTPException, internal_error_response, kanz_error_response
from app.core.errors import BadRequest, ImageTooLarge, KanzError
from app.core.request_id import HEADER, accept_or_new, request_id_var

access_log = logging.getLogger("kanz.access")
error_log = logging.getLogger("kanz.errors")


class PayloadTooLarge(BadRequest):
    """A non-upload request body over the size limit: code ``bad_request``, HTTP 413."""

    status = 413
    default_message = "That request is too large."


class RequestContextMiddleware:
    """Assign a request id, echo it in ``X-Request-ID`` and write one access-log line.

    It also converts unhandled exceptions into the 500 ``internal`` envelope itself.
    Starlette would otherwise handle them in ``ServerErrorMiddleware``, which sits outside
    every user middleware: that response would miss the request id header and the access
    log, and the traceback would be logged twice.
    """

    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request_id = accept_or_new(Headers(scope=scope).get(HEADER))
        token = request_id_var.set(request_id)
        start = time.perf_counter()
        status = 500
        response_started = False

        async def send_with_id(message: Message) -> None:
            nonlocal status, response_started
            if message["type"] == "http.response.start":
                response_started = True
                status = message["status"]
                MutableHeaders(scope=message)[HEADER] = request_id
            await send(message)

        try:
            await self.app(scope, receive, send_with_id)
        except Exception as exc:
            error_log.error("error code=internal status=500 path=%s", scope.get("path", ""), exc_info=exc)
            if response_started:
                raise
            await internal_error_response()(scope, receive, send_with_id)
        finally:
            ms = int((time.perf_counter() - start) * 1000)
            path = scope.get("path", "")
            # Image fetches are frequent and uninteresting; keep them out of the INFO stream.
            level = logging.DEBUG if path.startswith("/static/") else logging.INFO
            access_log.log(level, "method=%s path=%s status=%d ms=%d", scope.get("method", "-"), path, status, ms)
            request_id_var.reset(token)


class BodySizeLimitMiddleware:
    """Reject request bodies larger than ``max_bytes`` before they are parsed or spooled.

    A declared ``Content-Length`` over the limit is answered immediately; a chunked body is
    counted as it streams and cut off once it passes the limit. Multipart requests (photo
    uploads) get ``image_too_large``; anything else gets a 413 ``bad_request``. The exact
    per-file limit is enforced again in the analyze route.
    """

    def __init__(self, app: ASGIApp, *, max_bytes: int) -> None:
        self.app = app
        self.max_bytes = max_bytes

    def _error(self, scope: Scope) -> KanzError:
        content_type = Headers(scope=scope).get("content-type", "")
        return ImageTooLarge() if content_type.startswith("multipart/") else PayloadTooLarge()

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or scope.get("method") in ("GET", "HEAD", "OPTIONS"):
            await self.app(scope, receive, send)
            return

        declared = Headers(scope=scope).get("content-length")
        if declared is not None and declared.isdigit() and int(declared) > self.max_bytes:
            await kanz_error_response(self._error(scope))(scope, receive, send)
            return

        received = 0

        async def limited_receive() -> Message:
            nonlocal received
            message = await receive()
            if message["type"] == "http.request":
                received += len(message.get("body", b""))
                if received > self.max_bytes:
                    raise KanzHTTPException(self._error(scope))
            return message

        await self.app(scope, limited_receive, send)
