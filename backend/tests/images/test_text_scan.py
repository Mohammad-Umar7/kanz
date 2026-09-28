"""Text scans: a reference photo is rendered once from the description, then edited like an upload."""

import asyncio

import pytest

from app.core.errors import BadRequest, NotFound
from app.core.storage import ImageStore
from app.core.tutorials import TutorialStore
from app.images.service import ImageService
from app.schemas.images import AfterImageRequest, StepImageRequest
from app.schemas.recommend import UpcycleIdea
from tests.images.fakes import FakeImageGateway, make_tutorial


@pytest.fixture
def text_id(store: ImageStore) -> str:
    return store.save_text_scan("a pile of old denim jeans, faded at the knees")


async def test_reference_photo_is_rendered_before_the_first_edit(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, text_id: str, idea: UpcycleIdea
) -> None:
    resp = await service.after_image(AfterImageRequest(image_id=text_id, idea=idea))

    assert gateway.labels == ["reference", "after"]
    reference = gateway.only("reference")
    assert reference.references == []
    assert reference.aspect_ratio == "4:3"
    assert "a pile of old denim jeans, faded at the knees" in reference.prompt

    ref_path = store.generated_path(text_id, "reference")
    assert ref_path.exists()
    assert gateway.only("after").references == [ref_path.read_bytes()]
    assert resp.url == f"/static/generated/{text_id}/after_{idea.id}.jpg"
    assert "render_reference" in resp.timings_ms


async def test_reference_is_rendered_once_for_concurrent_ideas(
    service: ImageService, gateway: FakeImageGateway, text_id: str, ideas: list[UpcycleIdea]
) -> None:
    gateway.delay = 0.02
    await asyncio.gather(*(service.after_image(AfterImageRequest(image_id=text_id, idea=i)) for i in ideas))
    assert gateway.labels.count("reference") == 1
    assert gateway.labels.count("after") == 3


async def test_step_chain_reuses_the_reference(
    service: ImageService,
    gateway: FakeImageGateway,
    tutorial_store: TutorialStore,
    text_id: str,
    idea: UpcycleIdea,
) -> None:
    await service.after_image(AfterImageRequest(image_id=text_id, idea=idea))
    tutorial = make_tutorial(text_id, idea)
    tutorial_store.save(tutorial)
    await service.step_image(StepImageRequest(image_id=text_id, tutorial_id=tutorial.tutorial_id, step=2))
    assert gateway.labels == ["reference", "after", "step1", "step2"]


async def test_unknown_text_scan_is_not_found(
    service: ImageService, gateway: FakeImageGateway, idea: UpcycleIdea
) -> None:
    with pytest.raises(NotFound):
        await service.after_image(AfterImageRequest(image_id="txt_0000000000000000", idea=idea))
    assert gateway.calls == []


async def test_reference_image_gives_text_scans_a_before_picture(
    service: ImageService, gateway: FakeImageGateway, text_id: str, photo_id: str
) -> None:
    first = await service.reference_image(text_id)
    again = await service.reference_image(text_id)
    assert first.kind == "reference" and first.key == f"{text_id}:reference"
    assert first.url == f"/static/generated/{text_id}/reference.jpg"
    assert (first.cached, again.cached) == (False, True)
    assert "image_reference" in again.timings_ms
    assert gateway.labels == ["reference"]

    with pytest.raises(BadRequest):
        await service.reference_image(photo_id)
