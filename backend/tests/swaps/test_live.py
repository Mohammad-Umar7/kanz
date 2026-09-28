"""One real Swap Advisor call per language (excluded by default; run with ``-m live``).

    .venv/Scripts/python -m pytest tests/swaps/test_live.py -m live -s

Each test makes one Gemini call through the real gateway (plus the repair round if the
validator objects). Retrieval uses the knowledge index as it is: the vector index when it
has been seeded, the BM25 keyword fallback otherwise.
"""

import time

import pytest

from app.ai.gemini import GeminiGateway
from app.config import Settings
from app.schemas.swaps import SwapsRequest
from app.swaps.service import suggest


@pytest.mark.live
@pytest.mark.parametrize(
    ("materials", "lang"), [(["plastic bags, cling film"], "en"), (["plastic_bags", "cling_film"], "ar")]
)
async def test_live_swaps(materials: list[str], lang: str) -> None:
    settings = Settings(llm_retries=0)  # one attempt per model: a busy model falls back instead of looping
    if not settings.ai_configured:
        pytest.skip("GEMINI_API_KEY is not set")
    start = time.perf_counter()
    res = await suggest(SwapsRequest(materials=materials, lang=lang), gateway=GeminiGateway(settings))
    elapsed = int((time.perf_counter() - start) * 1000)

    print(f"\n{lang}: {len(res.swaps)} cards in {elapsed} ms, timings={res.timings_ms}")
    for swap in res.swaps:
        print(f"  [{swap.id}] {swap.from_item} -> {swap.to_item} (for {swap.matched_input})")
    assert 3 <= len(res.swaps) <= 6
    assert {s.matched_input for s in res.swaps} >= {"plastic bags" if lang == "en" else "أكياس بلاستيكية"}
    assert all(s.sources and s.sources[0].id == s.id for s in res.swaps)
