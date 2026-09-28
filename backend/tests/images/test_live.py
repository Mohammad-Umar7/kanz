"""One real after-image render on an eval photo (excluded by default; run with ``-m live``).

    .venv/Scripts/python -m pytest tests/images/test_live.py -m live -s

It makes a single request through the real ``GeminiGateway`` (the gateway's own bounded
retries and one fallback model apply; nothing here loops). On a free-tier key the image
models have a quota of 0, and the expected outcome is a clean ``AiQuotaExhausted``: the
API answers 503 ``ai_quota_exhausted`` and the app shows its fallback visual. With billing
enabled the test checks the stored picture instead and prints where it is.
"""

import time
from pathlib import Path

import pytest

from app.ai.gemini import GeminiGateway
from app.config import Settings
from app.core.errors import AiQuotaExhausted
from app.core.storage import ImageStore
from app.core.tutorials import TutorialStore
from app.images.service import ImageService
from app.schemas.images import AfterImageRequest
from app.schemas.recommend import UpcycleIdea
from tests.images.fakes import jpeg_size, load_fixture

PHOTO = Path(__file__).resolve().parents[2] / "eval" / "photos" / "glass_jar.jpg"


@pytest.mark.live
async def test_live_after_image_for_the_glass_jar(tmp_path: Path) -> None:
    settings = Settings(data_dir=tmp_path / "data")
    if not settings.ai_configured:
        pytest.skip("GEMINI_API_KEY is not set")
    if not PHOTO.exists():
        pytest.skip(f"{PHOTO.name} is not downloaded (eval photos are git-ignored)")

    store = ImageStore(settings)
    service = ImageService(
        gateway=GeminiGateway(settings), store=store, tutorials=TutorialStore(settings), settings=settings
    )
    image_id = store.save_upload(PHOTO.read_bytes()).image_id
    idea = UpcycleIdea.model_validate(load_fixture("recommend_glass_jar")["upcycle"][0])

    start = time.perf_counter()
    try:
        resp = await service.after_image(AfterImageRequest(image_id=image_id, idea=idea))
    except AiQuotaExhausted as exc:
        ms = int((time.perf_counter() - start) * 1000)
        print(f"\nimage quota exhausted after {ms} ms: code={exc.code} status={exc.status} message={exc.message!r}")
        assert (exc.code, exc.status, exc.retryable) == ("ai_quota_exhausted", 503, False)
        assert not store.generated_path(image_id, f"after_{idea.id}").exists()
        return

    path = store.generated_path(image_id, f"after_{idea.id}")
    print(f"\nafter image {resp.width}x{resp.height} in {resp.timings_ms} -> {path}")
    assert path.exists()
    assert (resp.width, resp.height) == jpeg_size(path.read_bytes())
    assert resp.cached is False
