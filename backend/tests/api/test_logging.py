"""The key=value log format and logging setup."""

from __future__ import annotations

import logging
import re
import sys

import pytest

from app.core.logging import KanzLogHandler, KeyValueFormatter, RequestIdFilter, configure_logging
from app.core.request_id import request_id_var


def render(message: str, *args: object, exc_info: bool = False) -> str:
    record = logging.LogRecord("kanz.test", logging.INFO, __file__, 1, message, args, None)
    if exc_info:
        try:
            raise ValueError("boom")
        except ValueError:
            record.exc_info = sys.exc_info()
    RequestIdFilter().filter(record)
    return KeyValueFormatter().format(record)


def test_key_value_messages_are_kept() -> None:
    token = request_id_var.set("req_5f3c2a1b")
    try:
        line = render("stage=%s ms=%d ok=%s", "analysis", 4120, True)
    finally:
        request_id_var.reset(token)
    assert re.fullmatch(
        r"ts=\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z level=info logger=kanz\.test "
        r"request_id=req_5f3c2a1b stage=analysis ms=4120 ok=True",
        line,
    )


def test_event_names_are_kept() -> None:
    assert render("error code=%s status=%d", "not_found", 404).endswith("request_id=- error code=not_found status=404")
    assert render("knowledge_seed_failed").endswith("request_id=- knowledge_seed_failed")


def test_free_text_is_quoted_and_escaped() -> None:
    line = render('Waiting for "application" startup.\nsecond line')
    assert line.endswith('request_id=- msg="Waiting for \\"application\\" startup.\\nsecond line"')


def test_arabic_text_is_kept() -> None:
    assert render("item=%s", "برطمان زجاجي").endswith("item=برطمان زجاجي")


def test_tracebacks_follow_the_line() -> None:
    first, *rest = render("error code=internal", exc_info=True).split("\n")
    assert first.endswith("error code=internal")
    assert rest[0] == "Traceback (most recent call last):"
    assert rest[-1] == "ValueError: boom"


def test_configure_logging_is_idempotent_and_quiets_libraries() -> None:
    root = logging.getLogger()
    configure_logging("DEBUG")
    configure_logging("INFO")
    assert sum(isinstance(h, KanzLogHandler) for h in root.handlers) == 1
    assert root.level == logging.INFO
    assert logging.getLogger("httpx").level == logging.WARNING
    assert logging.getLogger("google_genai").level == logging.WARNING
    assert logging.getLogger("uvicorn.access").propagate is False


def test_uvicorn_logs_use_our_handler(monkeypatch: pytest.MonkeyPatch) -> None:
    uvicorn_error = logging.getLogger("uvicorn.error")
    monkeypatch.setattr(uvicorn_error, "handlers", [logging.StreamHandler()])
    configure_logging("INFO")
    assert uvicorn_error.handlers == []
    assert uvicorn_error.propagate is True
