"""Failures reach the API as clean KanzErrors; an exhausted quota is not hammered."""

import pytest

from app.core.errors import AiQuotaExhausted, AiTimeout, AiUnavailable
from app.images.service import ImageService
from app.schemas.images import AfterImageRequest, StepImageRequest
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial
from tests.images.fakes import FakeImageGateway


def quota(_call: object) -> Exception:
    return AiQuotaExhausted(detail="429 RESOURCE_EXHAUSTED limit: 0")


async def test_quota_exhaustion_propagates_as_a_clean_error(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, idea: UpcycleIdea
) -> None:
    gateway.fail = quota
    with pytest.raises(AiQuotaExhausted) as err:
        await service.after_image(AfterImageRequest(image_id=photo_id, idea=idea))
    assert (err.value.code, err.value.status, err.value.retryable) == ("ai_quota_exhausted", 503, False)


async def test_after_a_quota_error_renders_fail_fast_during_the_cooldown(
    service: ImageService,
    gateway: FakeImageGateway,
    ideas: list[UpcycleIdea],
    tutorial: Tutorial,
) -> None:
    photo_id = tutorial.image_id
    gateway.fail = quota
    with pytest.raises(AiQuotaExhausted):
        await service.after_image(AfterImageRequest(image_id=photo_id, idea=ideas[0]))
    with pytest.raises(AiQuotaExhausted):
        await service.after_image(AfterImageRequest(image_id=photo_id, idea=ideas[1]))
    with pytest.raises(AiQuotaExhausted):
        await service.step_image(StepImageRequest(image_id=photo_id, tutorial_id=tutorial.tutorial_id, step=1))
    assert len(gateway.calls) == 1

    # Once the cool-down has passed, the model is tried again.
    service._quota_blocked_until = 0.0
    gateway.fail = None
    resp = await service.after_image(AfterImageRequest(image_id=photo_id, idea=ideas[1]))
    assert resp.cached is False
    assert len(gateway.calls) == 2


@pytest.mark.parametrize("error", [AiUnavailable(detail="503"), AiTimeout(detail="slow")])
async def test_transient_errors_propagate_without_a_cooldown(
    service: ImageService, gateway: FakeImageGateway, photo_id: str, idea: UpcycleIdea, error: Exception
) -> None:
    gateway.fail = lambda call: error
    for _ in range(2):
        with pytest.raises(type(error)) as err:
            await service.after_image(AfterImageRequest(image_id=photo_id, idea=idea))
        assert err.value.retryable is True
    assert len(gateway.calls) == 2


async def test_quota_error_in_a_step_request_leaves_no_partial_files(
    service: ImageService, gateway: FakeImageGateway, tutorial: Tutorial
) -> None:
    gateway.fail = quota
    with pytest.raises(AiQuotaExhausted):
        await service.step_image(StepImageRequest(image_id=tutorial.image_id, tutorial_id=tutorial.tutorial_id, step=3))
    assert gateway.labels == ["step1"]
    folder = service.store.s.generated_dir / tutorial.image_id
    assert not folder.exists() or not list(folder.glob("step_*.jpg"))
