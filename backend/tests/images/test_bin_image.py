"""Bin image: the item prepared for its stream, edited from a crop around the item."""

import pytest

from app.core.errors import BadRequest
from app.core.storage import ImageStore
from app.images.service import ImageService, item_variant
from app.schemas.analysis import Item
from app.schemas.images import BinImageRequest
from tests.images.fakes import FakeImageGateway, jpeg_size, load_fixture


async def test_bin_image_edits_a_crop_around_the_item(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, photo_id: str, jar_item: Item
) -> None:
    resp = await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item))

    call = gateway.only("bin")
    (reference,) = call.references
    width, height = jpeg_size(reference)
    assert width < 800 and height < 600  # cropped to the jar's box
    for step in jar_item.recyclability.prep_steps:  # the item's own steps are the fallback
        assert step in call.prompt

    variant = item_variant(jar_item)
    assert resp.kind == "bin"
    assert resp.key == f"{photo_id}:bin:{jar_item.id}:{variant}"
    assert resp.url == f"/static/generated/{photo_id}/bin_{jar_item.id}_{variant}.jpg"
    assert resp.cached is False
    assert "image_bin" in resp.timings_ms and "render_bin" in resp.timings_ms


async def test_a_corrected_item_gets_a_new_picture(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, jar_item: Item
) -> None:
    # The user told us the "glass" jar is really a PET tub: same id, different item.
    first = await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item))
    corrected = jar_item.model_copy(update={"category": "plastic", "resin_code": 1, "user_corrected": True})
    resp = await service.bin_image(BinImageRequest(image_id=photo_id, item=corrected))
    assert resp.cached is False
    assert resp.url != first.url
    assert len(gateway.calls) == 2


async def test_the_same_item_in_arabic_shares_the_picture(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, jar_item: Item
) -> None:
    arabic = Item.model_validate(load_fixture("analyze_glass_jar_ar")["analysis"]["items"][0])
    assert arabic.name != jar_item.name
    first = await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item))
    resp = await service.bin_image(BinImageRequest(image_id=photo_id, item=arabic))
    assert resp.cached is True
    assert resp.url == first.url
    assert len(gateway.calls) == 1


async def test_request_prep_steps_take_priority(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, jar_item: Item
) -> None:
    await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item, prep_steps=["Unscrew the lid"]))
    prompt = gateway.only("bin").prompt
    assert "- Unscrew the lid" in prompt
    assert jar_item.recyclability.prep_steps[0] not in prompt


async def test_bin_image_is_cached_and_regenerable(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, jar_item: Item
) -> None:
    await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item))
    hit = await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item))
    fresh = await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item, regenerate=True))
    assert hit.cached is True and fresh.cached is False
    assert len(gateway.calls) == 2


async def test_item_without_a_box_uses_the_whole_photo(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, photo_id: str, jar_item: Item
) -> None:
    item = jar_item.model_copy(update={"bbox": None})
    await service.bin_image(BinImageRequest(image_id=photo_id, item=item))
    assert gateway.only("bin").references == [store.load_upload(photo_id)]
    assert gateway.only("bin").aspect_ratio == "4:3"


async def test_unsafe_item_id_is_a_bad_request(service: ImageService, photo_id: str, jar_item: Item) -> None:
    with pytest.raises(BadRequest):
        await service.bin_image(BinImageRequest(image_id=photo_id, item=jar_item.model_copy(update={"id": "a b"})))
