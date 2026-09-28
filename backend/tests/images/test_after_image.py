"""After images: edit of the original photo, cached per (image_id, idea), de-duplicated, bounded."""

import asyncio

import pytest

from app.core.errors import AiInvalidOutput, BadRequest, NotFound
from app.core.storage import ImageStore
from app.images.service import ImageService
from app.schemas.images import AfterImageRequest
from app.schemas.recommend import UpcycleIdea
from tests.images.fakes import FakeImageGateway, jpeg_size, make_jpeg, until


def request(image_id: str, idea: UpcycleIdea, *, regenerate: bool = False) -> AfterImageRequest:
    return AfterImageRequest(image_id=image_id, idea=idea, regenerate=regenerate)


async def test_first_request_edits_the_original_photo(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, photo_id: str, idea: UpcycleIdea
) -> None:
    resp = await service.after_image(request(photo_id, idea))

    call = gateway.only("after")
    assert call.references == [store.load_upload(photo_id)]
    assert call.aspect_ratio == "4:3"
    assert idea.after_visual in call.prompt

    path = store.generated_path(photo_id, f"after_{idea.id}")
    assert path.exists()
    assert resp.kind == "after"
    assert resp.cached is False
    assert resp.url == f"/static/generated/{photo_id}/after_{idea.id}.jpg"
    assert resp.key == f"{photo_id}:after:{idea.id}"
    assert (resp.width, resp.height) == jpeg_size(path.read_bytes())
    assert resp.step is None and resp.skill is None
    assert "image_after" in resp.timings_ms and "render_after" in resp.timings_ms


async def test_idea_is_saved_next_to_the_after_image(
    service: ImageService, store: ImageStore, photo_id: str, idea: UpcycleIdea
) -> None:
    await service.after_image(request(photo_id, idea))
    assert store.generated_path(photo_id, f"idea_{idea.id}").with_suffix(".json").exists()
    assert service.load_idea(photo_id, idea.id) == idea


async def test_second_request_is_a_cache_hit(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, idea: UpcycleIdea
) -> None:
    first = await service.after_image(request(photo_id, idea))
    second = await service.after_image(request(photo_id, idea))
    assert len(gateway.calls) == 1
    assert second.cached is True
    assert (second.url, second.key, second.width, second.height) == (first.url, first.key, first.width, first.height)
    assert "image_after" in second.timings_ms and "render_after" not in second.timings_ms


async def test_an_unreadable_cached_file_is_rendered_again(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, photo_id: str, idea: UpcycleIdea
) -> None:
    path = store.generated_path(photo_id, f"after_{idea.id}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"")  # what a write cut short by a crash leaves behind

    resp = await service.after_image(request(photo_id, idea))

    assert resp.cached is False
    assert len(gateway.calls) == 1
    assert jpeg_size(path.read_bytes()) == (resp.width, resp.height)


async def test_regenerate_bypasses_the_cache_and_overwrites(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, photo_id: str, idea: UpcycleIdea
) -> None:
    await service.after_image(request(photo_id, idea))
    path = store.generated_path(photo_id, f"after_{idea.id}")
    before = path.read_bytes()

    resp = await service.after_image(request(photo_id, idea, regenerate=True))
    assert len(gateway.calls) == 2
    assert resp.cached is False
    assert path.read_bytes() != before


async def test_portrait_photo_gets_a_portrait_after_image(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, idea: UpcycleIdea
) -> None:
    portrait = store.save_upload(make_jpeg(600, 800, (90, 120, 150))).image_id
    resp = await service.after_image(request(portrait, idea))
    assert gateway.only("after").aspect_ratio == "3:4"
    assert resp.height > resp.width


async def test_concurrent_requests_for_one_key_render_once(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, idea: UpcycleIdea
) -> None:
    gateway.delay = 0.05
    results = await asyncio.gather(*(service.after_image(request(photo_id, idea)) for _ in range(4)))
    assert len(gateway.calls) == 1
    assert len({r.url for r in results}) == 1


async def test_renders_are_capped_by_the_semaphore(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, idea: UpcycleIdea
) -> None:
    gateway.gate = asyncio.Event()
    variants = [idea.model_copy(update={"id": f"idea_{n:08x}"}) for n in range(6)]
    batch = asyncio.gather(*(service.after_image(request(photo_id, v)) for v in variants))
    await until(lambda: gateway.active == 3)
    await asyncio.sleep(0.01)
    assert len(gateway.calls) == 3  # the other three wait for a free slot
    gateway.gate.set()
    await batch
    assert len(gateway.calls) == 6
    assert gateway.max_active == 3


async def test_unknown_photo_is_not_found_and_writes_nothing(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, idea: UpcycleIdea
) -> None:
    with pytest.raises(NotFound):
        await service.after_image(request("img_00000000deadbeef", idea))
    with pytest.raises(NotFound):
        await service.after_image(request("../etc/passwd", idea))
    assert gateway.calls == []
    assert not (store.s.generated_dir / "img_00000000deadbeef").exists()


async def test_unsafe_idea_id_is_a_bad_request(service: ImageService, photo_id: str, idea: UpcycleIdea) -> None:
    with pytest.raises(BadRequest):
        await service.after_image(request(photo_id, idea.model_copy(update={"id": "idea/../../x"})))


async def test_unreadable_model_output_is_an_invalid_output_error(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, photo_id: str, idea: UpcycleIdea
) -> None:
    gateway.output = b"not an image"
    with pytest.raises(AiInvalidOutput) as err:
        await service.after_image(request(photo_id, idea))
    assert err.value.retryable is True
    assert not store.generated_path(photo_id, f"after_{idea.id}").exists()
