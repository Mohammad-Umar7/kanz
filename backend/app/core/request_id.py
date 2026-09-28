"""Request ids: one per HTTP request, returned in ``X-Request-ID`` and written on every log line.

The app sends its own id with each call so a failed request on the phone can be matched
to the server log. An incoming id is kept only if it looks like a safe token; anything
else (too long, spaces, control characters) is replaced so it can't pollute the logs.
"""

import re
import secrets
from contextvars import ContextVar

HEADER = "X-Request-ID"

_VALID = re.compile(r"^[A-Za-z0-9_-]{6,64}$")

# Set by RequestContextMiddleware for the lifetime of one request; read by the log filter
# and by the error handlers so the id in an error body always matches the header.
request_id_var: ContextVar[str | None] = ContextVar("request_id", default=None)


def new_request_id() -> str:
    """A short random id such as ``req_5f3c2a1b``."""
    return "req_" + secrets.token_hex(4)


def accept_or_new(incoming: str | None) -> str:
    """Keep a well-formed client id, otherwise generate one."""
    if incoming and _VALID.match(incoming):
        return incoming
    return new_request_id()


def current_request_id() -> str:
    """The id of the request being handled (a fresh one outside a request)."""
    return request_id_var.get() or new_request_id()
