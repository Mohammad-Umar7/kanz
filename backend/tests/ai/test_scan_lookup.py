"""Recommend fails fast with 404 for a scan the server does not know, before any model call."""

import pytest

from app.ai import pipeline
from app.core.errors import NotFound
from app.core.storage import get_store
from app.schemas.recommend import RecommendRequest

from .conftest import fixture_analysis, jpeg_bytes


@pytest.fixture
def real_lookup(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr("app.ai.pipeline._require_scan", pipeline.__dict__["_require_scan_impl"])


def test_known_photo_and_text_scans_pass():
    store = get_store()
    photo = store.save_upload(jpeg_bytes())
    text_id = store.save_text_scan("an old denim jacket")
    pipeline._require_scan_impl(photo.image_id)
    pipeline._require_scan_impl(text_id)


@pytest.mark.parametrize("image_id", ["img_0000000000000000", "txt_0000000000000000", "../etc"])
def test_unknown_scan_is_not_found(image_id: str):
    with pytest.raises(NotFound):
        pipeline._require_scan_impl(image_id)


async def test_recommend_rejects_unknown_scan_without_calling_the_model(real_lookup, monkeypatch):
    def boom(*args, **kwargs):
        raise AssertionError("the graph must not run for an unknown scan")

    monkeypatch.setattr(pipeline, "recommend_graph", boom)
    req = RecommendRequest(image_id="img_ffffffffffffffff", analysis=fixture_analysis("analyze_glass_jar.json"))
    with pytest.raises(NotFound):
        await pipeline.recommend(req)
