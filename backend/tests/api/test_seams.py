"""The module seams accept exactly the calls the routers make (PLAN.md section 4).

The API tests stub every seam, so a renamed parameter or a sync/async mix-up in a real
implementation would only show up as a 500 at runtime. These checks bind the router's
call against each real signature instead. A seam whose workstream has not landed yet is
skipped, with the owner named in the reason.
"""

from __future__ import annotations

import importlib
import inspect
from typing import Any

import pytest

# (module, function, is_async, how the router calls it, owner)
SEAM_CALLS: list[tuple[str, str, bool, tuple[tuple[Any, ...], dict[str, Any]], str]] = [
    ("app.ai.pipeline", "analyze", True, ((), {"image": b"", "text": None, "lang": "en"}), "AI Pipeline"),
    ("app.ai.pipeline", "recommend", True, ((object(),), {}), "AI Pipeline"),
    ("app.ai.pipeline", "tutorial", True, ((object(),), {}), "AI Pipeline"),
    ("app.images.service", "after_image", True, ((object(),), {}), "Image Generation"),
    ("app.images.service", "step_image", True, ((object(),), {}), "Image Generation"),
    ("app.images.service", "bin_image", True, ((object(),), {}), "Image Generation"),
    ("app.places.service", "search", True, ((object(),), {}), "Places & Swaps"),
    ("app.places.categories", "catalog", False, (("en",), {}), "Places & Swaps"),
    ("app.swaps.service", "suggest", True, ((object(),), {}), "Places & Swaps"),
    ("app.ai.rag", "seed_knowledge", True, ((), {}), "AI Pipeline"),
    ("app.ai.rag", "status", False, ((), {}), "AI Pipeline"),
]


@pytest.mark.parametrize(
    ("module_name", "name", "is_async", "call", "owner"),
    SEAM_CALLS,
    ids=[f"{module}.{name}" for module, name, *_ in SEAM_CALLS],
)
def test_seam_accepts_the_router_call(
    module_name: str, name: str, is_async: bool, call: tuple[tuple[Any, ...], dict[str, Any]], owner: str
) -> None:
    seam = getattr(importlib.import_module(module_name), name, None)
    if seam is None:
        pytest.skip(f"{module_name}.{name} has not landed yet ({owner})")
    assert inspect.iscoroutinefunction(seam) is is_async, f"{name} must be {'async' if is_async else 'sync'}"
    args, kwargs = call
    inspect.signature(seam).bind(*args, **kwargs)
