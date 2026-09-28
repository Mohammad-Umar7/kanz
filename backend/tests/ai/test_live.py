"""Live end-to-end checks against Gemini on real photos. Run with: pytest -m live tests/ai/test_live.py

Each test spends a handful of model calls; free-tier keys have small daily quotas, so these
are excluded from the default run. Storage, tutorials and the step-image hand-off are
isolated by the package fixtures; only the model calls are real.
"""

import pytest

from app.ai import pipeline
from app.ai.gemini import GeminiGateway
from app.config import BACKEND_DIR, get_settings
from app.schemas.common import Profile
from app.schemas.recommend import RecommendRequest
from app.schemas.tutorial import TutorialRequest

PHOTOS = BACKEND_DIR / "eval" / "photos"
PROFILE = Profile(skill="beginner", tools=["scissors", "twine", "pliers", "acrylic_paint", "paintbrush"], lang="en")

pytestmark = [
    pytest.mark.live,
    pytest.mark.skipif(not get_settings().ai_configured, reason="GEMINI_API_KEY is not set"),
    pytest.mark.skipif(not (PHOTOS / "glass_jar.jpg").exists(), reason="eval photos are not downloaded"),
]


@pytest.fixture
def gateway() -> GeminiGateway:
    return GeminiGateway(get_settings())


async def analyze(name: str, gateway: GeminiGateway):
    return await pipeline.analyze(image=(PHOTOS / name).read_bytes(), text=None, lang="en", gateway=gateway)


async def test_glass_jar_analysis_ideas_and_tutorial(gateway, step_chain):
    scan = await analyze("glass_jar.jpg", gateway)
    jar = next(it for it in scan.analysis.items if it.id == scan.analysis.primary_item_id)
    assert scan.analysis.photo.usable
    assert jar.category == "glass" and jar.bbox is not None and not jar.hazards

    rec = await pipeline.recommend(
        RecommendRequest(image_id=scan.image_id, analysis=scan.analysis, profile=PROFILE), gateway=gateway
    )
    assert rec.routing.mode == "diy"
    assert len(rec.upcycle) == 3 and len({i.title for i in rec.upcycle}) == 3
    assert all(i.sources for i in rec.upcycle)

    idea = rec.upcycle[0]
    items = [it for it in scan.analysis.items if it.id in idea.uses_item_ids]
    tut = await pipeline.tutorial(
        TutorialRequest(image_id=scan.image_id, idea=idea, items=items, profile=PROFILE), gateway=gateway
    )
    assert 5 <= len(tut.tutorial.steps) <= 8
    assert all(s.image_prompt and s.image_prompt.isascii() for s in tut.tutorial.steps)
    assert step_chain and step_chain[0][0].tutorial_id == tut.tutorial.tutorial_id
    print("latency ms", {"analyze": scan.timings_ms, "recommend": rec.timings_ms, "tutorial": tut.timings_ms})


async def test_batteries_are_disposal_only(gateway):
    scan = await analyze("aa_batteries.jpg", gateway)
    assert any("battery" in it.hazards for it in scan.analysis.items)
    rec = await pipeline.recommend(
        RecommendRequest(image_id=scan.image_id, analysis=scan.analysis, profile=PROFILE), gateway=gateway
    )
    assert rec.routing.mode == "disposal_only" and rec.upcycle == []
    assert rec.disposal and rec.disposal[0].hazard == "battery"


async def test_tshirt_can_be_donated(gateway):
    scan = await analyze("old_tshirt.jpg", gateway)
    assert scan.analysis.items[0].category == "textile"
    rec = await pipeline.recommend(
        RecommendRequest(image_id=scan.image_id, analysis=scan.analysis, profile=PROFILE), gateway=gateway
    )
    assert rec.donate.available
    assert len(rec.upcycle) == 3
