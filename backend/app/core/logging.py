"""Logging setup: one ``key=value`` line per event, tagged with the current request id.

Example::

    ts=2026-09-28T10:15:02.114Z level=info logger=kanz.timing request_id=req_5f3c2a1b stage=analysis ms=4120 ok=True
    ts=2026-09-28T10:15:02.120Z level=info logger=kanz.access request_id=req_5f3c2a1b method=POST path=/v1/analyze status=200 ms=4133

Kanz messages are written as ``event key=value ...`` and kept as they are; free-text
messages (mostly from libraries) are wrapped as ``msg="..."`` so every line stays parsable.
"""

from __future__ import annotations

import contextlib
import logging
import re
import sys
from datetime import UTC, datetime

from app.core.request_id import request_id_var

# "stage=analysis ms=4120", "error code=not_found status=404" (an event name, then pairs)
# or a bare event name such as "knowledge_seed_failed". Anything else is free text.
_KV_MESSAGE = re.compile(r"^[a-z_][a-z0-9_.]*(?:=|\s+[a-z_][a-z0-9_.]*=|$)")

# Libraries that are chatty at INFO. The Gemini SDK logs an "AFC is enabled" notice on
# every call, httpx logs every request line, and Chroma logs telemetry setup.
_QUIET_LOGGERS = {
    "httpx": logging.WARNING,
    "httpcore": logging.WARNING,
    "google_genai": logging.WARNING,
    "chromadb": logging.WARNING,
    "chromadb.telemetry": logging.ERROR,
    "posthog": logging.ERROR,
    "urllib3": logging.WARNING,
    "multipart": logging.WARNING,
    "python_multipart": logging.WARNING,
    "watchfiles": logging.WARNING,
    "asyncio": logging.WARNING,
}


class KanzLogHandler(logging.StreamHandler):
    """The stderr handler this module installs (a distinct type so re-configuring replaces it)."""


class RequestIdFilter(logging.Filter):
    """Attach ``record.request_id`` from the request context ("-" outside a request)."""

    def filter(self, record: logging.LogRecord) -> bool:
        record.request_id = request_id_var.get() or "-"
        return True


class KeyValueFormatter(logging.Formatter):
    """Render records as ``ts=... level=... logger=... request_id=... <message>``."""

    def format(self, record: logging.LogRecord) -> str:
        ts = datetime.fromtimestamp(record.created, UTC).isoformat(timespec="milliseconds").replace("+00:00", "Z")
        message = record.getMessage()
        if not _KV_MESSAGE.match(message):
            escaped = message.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
            message = f'msg="{escaped}"'
        request_id = getattr(record, "request_id", None) or request_id_var.get() or "-"
        line = f"ts={ts} level={record.levelname.lower()} logger={record.name} request_id={request_id} {message}"
        if record.exc_info:
            line += "\n" + self.formatException(record.exc_info)
        if record.stack_info:
            line += "\n" + self.formatStack(record.stack_info)
        return line


def configure_logging(level: str = "INFO") -> None:
    """Install the key=value handler on the root logger. Safe to call more than once."""
    root = logging.getLogger()
    for existing in list(root.handlers):
        if isinstance(existing, KanzLogHandler):
            root.removeHandler(existing)

    # A redirected stderr on Windows may use a legacy code page; never let an Arabic item
    # name in a log line raise UnicodeEncodeError inside the logging machinery.
    reconfigure = getattr(sys.stderr, "reconfigure", None)
    if callable(reconfigure):
        with contextlib.suppress(ValueError, OSError):
            reconfigure(errors="backslashreplace")

    handler = KanzLogHandler(sys.stderr)
    handler.setFormatter(KeyValueFormatter())
    handler.addFilter(RequestIdFilter())
    root.addHandler(handler)
    root.setLevel(level.upper())

    # Uvicorn installs its own handlers before importing the app. Route its server logs
    # through ours, and silence its access log: RequestContextMiddleware writes a richer one.
    for name in ("uvicorn", "uvicorn.error"):
        uv = logging.getLogger(name)
        uv.handlers.clear()
        uv.propagate = True
    access = logging.getLogger("uvicorn.access")
    access.handlers.clear()
    access.propagate = False
    access.setLevel(logging.WARNING)

    for name, quiet_level in _QUIET_LOGGERS.items():
        logging.getLogger(name).setLevel(quiet_level)
