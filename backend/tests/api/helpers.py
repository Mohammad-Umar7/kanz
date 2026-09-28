"""Helpers shared by the API tests: seam stubs and the error-envelope assertion.

The routers call module seams (``app.ai.pipeline.analyze`` ...). ``Seams`` swaps a seam
for a stub that records its arguments and returns a contract fixture or raises, so the
API tests exercise the HTTP layer only.
"""

from __future__ import annotations

import importlib
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

import httpx
import pytest


@dataclass
class Call:
    args: tuple[Any, ...]
    kwargs: dict[str, Any]


@dataclass
class Seams:
    monkeypatch: pytest.MonkeyPatch

    def _install(self, target: str, stub: Callable[..., Any]) -> None:
        module_name, attr = target.rsplit(".", 1)
        module = importlib.import_module(module_name)
        self.monkeypatch.setattr(module, attr, stub, raising=False)

    def returns(self, target: str, value: Any, *, sync: bool = False) -> list[Call]:
        """Replace ``target`` (e.g. ``"app.ai.pipeline.analyze"``) with a stub returning ``value``."""
        calls: list[Call] = []

        def record(*args: Any, **kwargs: Any) -> Any:
            calls.append(Call(args, kwargs))
            return value

        async def record_async(*args: Any, **kwargs: Any) -> Any:
            return record(*args, **kwargs)

        self._install(target, record if sync else record_async)
        return calls

    def raises(self, target: str, exc: BaseException, *, sync: bool = False) -> None:
        """Replace ``target`` with a stub that raises ``exc``."""

        def fail(*_args: Any, **_kwargs: Any) -> Any:
            raise exc

        async def fail_async(*args: Any, **kwargs: Any) -> Any:
            return fail(*args, **kwargs)

        self._install(target, fail if sync else fail_async)


def assert_error(response: httpx.Response, status: int, code: str, *, retryable: bool | None = None) -> dict[str, Any]:
    """Check the ErrorResponse envelope and that its request id matches the header."""
    assert response.status_code == status, response.text
    body = response.json()
    assert set(body) == {"error"}
    error = body["error"]
    assert error["code"] == code
    assert error["message"]
    assert error["request_id"] == response.headers["X-Request-ID"]
    if retryable is not None:
        assert error["retryable"] is retryable
    return error
