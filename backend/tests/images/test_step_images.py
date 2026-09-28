"""Step chain on request: each step edits the previous one; the last one also sees the after image."""

import asyncio

import pytest

from app.core.errors import BadRequest, NotFound
from app.core.storage import ImageStore
from app.core.tutorials import TutorialStore
from app.images.service import ImageService
from app.schemas.images import AfterImageRequest, StepImageRequest
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial
from tests.images.fakes import FakeImageGateway, make_tutorial


def request(tutorial: Tutorial, step: int, *, regenerate: bool = False) -> StepImageRequest:
    return StepImageRequest(
        image_id=tutorial.image_id, tutorial_id=tutorial.tutorial_id, step=step, regenerate=regenerate
    )


def step_file(store: ImageStore, tutorial: Tutorial, n: int) -> bytes:
    return store.generated_path(tutorial.image_id, f"step_{tutorial.idea_id}_{tutorial.skill}_{n}").read_bytes()


async def test_step_one_edits_the_original_photo(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, tutorial: Tutorial
) -> None:
    resp = await service.step_image(request(tutorial, 1))

    assert gateway.labels == ["step1"]
    assert gateway.calls[0].references == [store.load_upload(tutorial.image_id)]
    assert resp.kind == "step" and resp.step == 1 and resp.skill == "beginner"
    assert resp.key == f"{tutorial.image_id}:step:{tutorial.idea_id}:beginner:1"
    assert resp.url.endswith(f"/{tutorial.image_id}/step_{tutorial.idea_id}_beginner_1.jpg")
    assert resp.cached is False
    assert "image_step" in resp.timings_ms


async def test_missing_earlier_steps_render_first_in_order(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, tutorial: Tutorial
) -> None:
    resp = await service.step_image(request(tutorial, 3))

    assert gateway.labels == ["step1", "step2", "step3"]
    original = store.load_upload(tutorial.image_id)
    assert gateway.calls[1].references == [step_file(store, tutorial, 1), original]
    assert gateway.calls[2].references == [step_file(store, tutorial, 2), original]
    assert {"render_step_1", "render_step_2", "render_step_3", "image_step"} <= resp.timings_ms.keys()


async def test_last_step_references_previous_original_and_after(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    service.save_idea(tutorial.image_id, idea)  # as after_image / start_step_chain would
    await service.step_image(request(tutorial, 5))

    # The after image is missing, so it is rendered (from the original) before the final step.
    assert gateway.labels == ["step1", "step2", "step3", "step4", "after", "step5"]
    after = store.generated_path(tutorial.image_id, f"after_{idea.id}").read_bytes()
    final = gateway.only("step5")
    assert final.references == [step_file(store, tutorial, 4), store.load_upload(tutorial.image_id), after]
    assert "Image 3 shows the finished project" in final.prompt


async def test_last_step_reuses_an_existing_after_image(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    await service.after_image(AfterImageRequest(image_id=tutorial.image_id, idea=idea))
    await service.step_image(request(tutorial, 5))
    assert gateway.labels.count("after") == 1


async def test_last_step_without_a_known_idea_uses_two_references(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial
) -> None:
    await service.step_image(request(tutorial, 5))
    final = gateway.only("step5")
    assert "after" not in gateway.labels
    assert len(final.references) == 2
    assert "Image 3" not in final.prompt


async def test_rendered_steps_are_cache_hits(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial
) -> None:
    await service.step_image(request(tutorial, 2))
    again = await service.step_image(request(tutorial, 2))
    earlier = await service.step_image(request(tutorial, 1))
    assert gateway.labels == ["step1", "step2"]
    assert again.cached is True and earlier.cached is True


async def test_regenerate_rerenders_only_that_step(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, tutorial: Tutorial
) -> None:
    await service.step_image(request(tutorial, 3))
    old_step2 = step_file(store, tutorial, 2)

    resp = await service.step_image(request(tutorial, 2, regenerate=True))
    assert gateway.labels == ["step1", "step2", "step3", "step2"]
    assert gateway.calls[-1].references[0] == step_file(store, tutorial, 1)
    assert resp.cached is False
    assert step_file(store, tutorial, 2) != old_step2


async def test_concurrent_step_requests_render_each_step_once(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial
) -> None:
    gateway.delay = 0.02
    await asyncio.gather(
        service.step_image(request(tutorial, 3)),
        service.step_image(request(tutorial, 3)),
        service.step_image(request(tutorial, 2)),
        service.step_image(request(tutorial, 1)),
    )
    assert sorted(gateway.labels) == ["step1", "step2", "step3"]


async def test_skill_levels_have_separate_chains(
    service: ImageService,
    gateway: FakeImageGateway,
    tutorial_store: TutorialStore,
    tutorial: Tutorial,
    idea: UpcycleIdea,
) -> None:
    advanced = make_tutorial(tutorial.image_id, idea, skill="advanced")
    tutorial_store.save(advanced)
    await service.step_image(request(tutorial, 1))
    resp = await service.step_image(request(advanced, 1))
    assert gateway.labels == ["step1", "step1"]
    assert resp.url.endswith("_advanced_1.jpg")


async def test_unknown_tutorial_is_not_found(service: ImageService, photo_id: str) -> None:
    with pytest.raises(NotFound):
        await service.step_image(StepImageRequest(image_id=photo_id, tutorial_id="tut_0000000000000000", step=1))
    with pytest.raises(NotFound):
        await service.step_image(StepImageRequest(image_id=photo_id, tutorial_id="not-a-tutorial", step=1))


async def test_tutorial_for_another_photo_is_a_bad_request(service: ImageService, tutorial: Tutorial) -> None:
    other = StepImageRequest(image_id="img_1111111111111111", tutorial_id=tutorial.tutorial_id, step=1)
    with pytest.raises(BadRequest, match="different photo"):
        await service.step_image(other)


async def test_step_beyond_the_tutorial_is_a_bad_request(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial
) -> None:
    with pytest.raises(BadRequest, match="5 steps"):
        await service.step_image(request(tutorial, 6))
    assert gateway.calls == []
