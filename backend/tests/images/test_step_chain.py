"""Background step chain: renders every step in order, shares renders with requests, never raises."""

import asyncio
import logging

import pytest

from app.core.errors import AiUnavailable
from app.core.storage import ImageStore
from app.images import service as image_service
from app.images.service import ImageService
from app.schemas.images import StepImageRequest
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial
from tests.images.fakes import FakeImageGateway, ImageCall


def step_exists(store: ImageStore, tutorial: Tutorial, n: int) -> bool:
    return store.generated_path(tutorial.image_id, f"step_{tutorial.idea_id}_{tutorial.skill}_{n}").exists()


async def test_chain_renders_every_step_in_order(
    service: ImageService, gateway: FakeImageGateway, store: ImageStore, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    service.start_step_chain(tutorial, idea)
    await service.wait_for_chains()

    assert gateway.labels == ["step1", "step2", "step3", "step4", "after", "step5"]
    assert all(step_exists(store, tutorial, n) for n in range(1, 6))
    assert service.load_idea(tutorial.image_id, idea.id) == idea


async def test_requests_join_the_running_chain_instead_of_rendering_twice(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    gateway.delay = 0.02
    service.start_step_chain(tutorial, idea)
    await asyncio.sleep(0)  # let the chain start on step 1
    req = StepImageRequest(image_id=tutorial.image_id, tutorial_id=tutorial.tutorial_id, step=3)
    first, second = await asyncio.gather(service.step_image(req), service.step_image(req))
    await service.wait_for_chains()

    assert first.url == second.url
    assert sorted(gateway.labels) == ["after", "step1", "step2", "step3", "step4", "step5"]


async def test_one_chain_per_tutorial(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    gateway.delay = 0.01
    service.start_step_chain(tutorial, idea)
    service.start_step_chain(tutorial, idea)
    assert len(service._chains) == 1
    await service.wait_for_chains()
    assert len(gateway.calls) == 6
    assert service._chains == {}


async def test_chain_stops_on_a_failure_logs_it_and_can_resume(
    service: ImageService,
    gateway: FakeImageGateway,
    tutorial: Tutorial,
    idea: UpcycleIdea,
    caplog: pytest.LogCaptureFixture,
) -> None:
    def fail_step_two(call: ImageCall) -> Exception | None:
        return AiUnavailable(detail="model overloaded") if call.step == 2 else None

    gateway.fail = fail_step_two
    with caplog.at_level(logging.WARNING, logger="kanz.images"):
        service.start_step_chain(tutorial, idea)
        await service.wait_for_chains()  # must not raise

    assert gateway.labels == ["step1", "step2"]
    assert step_exists(service.store, tutorial, 1) and not step_exists(service.store, tutorial, 2)
    assert "stopped at step 2/5" in caplog.text and "ai_unavailable" in caplog.text
    assert service._chains == {}

    # Once the model recovers, a new chain picks up where the old one stopped.
    gateway.fail = None
    service.start_step_chain(tutorial, idea)
    await service.wait_for_chains()
    assert gateway.labels == ["step1", "step2", "step2", "step3", "step4", "after", "step5"]


async def test_unexpected_errors_are_logged_not_raised(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, caplog: pytest.LogCaptureFixture
) -> None:
    gateway.fail = lambda call: RuntimeError("bug in a dependency")
    with caplog.at_level(logging.ERROR, logger="kanz.images"):
        service.start_step_chain(tutorial)
        await service.wait_for_chains()
    assert "failed at step 1/5" in caplog.text


async def test_chain_uses_an_idea_saved_earlier(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    service.save_idea(tutorial.image_id, idea)
    service.start_step_chain(tutorial)  # no idea passed: the saved one is used
    await service.wait_for_chains()
    assert len(gateway.only("step5").references) == 3


async def test_autostart_off_only_saves_the_idea(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    service.settings.step_images_autostart = False
    service.start_step_chain(tutorial, idea)
    await service.wait_for_chains()
    assert gateway.calls == []
    assert service.load_idea(tutorial.image_id, idea.id) == idea


def test_start_without_an_event_loop_does_not_raise(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    service.start_step_chain(tutorial, idea)
    assert gateway.calls == []
    assert service._chains == {}


async def test_module_seam_uses_the_process_service(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial, idea: UpcycleIdea
) -> None:
    image_service.set_image_service(service)
    try:
        assert image_service.get_image_service() is service
        image_service.start_step_chain(tutorial, idea)
        await service.wait_for_chains()
        resp = await image_service.step_image(
            StepImageRequest(image_id=tutorial.image_id, tutorial_id=tutorial.tutorial_id, step=5)
        )
    finally:
        image_service.set_image_service(None)
    assert resp.cached is True
    assert len(gateway.calls) == 6
