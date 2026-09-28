"""Fixtures for the image pipeline tests: isolated storage, a fake image model, a photo, ideas and a tutorial."""

from __future__ import annotations

from pathlib import Path

import pytest

from app.config import Settings
from app.core.storage import ImageStore
from app.core.tutorials import TutorialStore
from app.images.service import ImageService
from app.schemas.analysis import Item
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial
from tests.images.fakes import FakeImageGateway, load_fixture, make_jpeg, make_tutorial


@pytest.fixture
def image_settings(tmp_path: Path) -> Settings:
    """Settings rooted in ``tmp_path``; no API keys, so nothing can reach Gemini."""
    return Settings(
        data_dir=tmp_path / "data",
        gemini_api_key="",
        google_maps_api_key="",
        step_images_autostart=True,
    )


@pytest.fixture
def store(image_settings: Settings) -> ImageStore:
    return ImageStore(image_settings)


@pytest.fixture
def tutorial_store(image_settings: Settings) -> TutorialStore:
    return TutorialStore(image_settings)


@pytest.fixture
def gateway() -> FakeImageGateway:
    return FakeImageGateway()


@pytest.fixture
def service(
    gateway: FakeImageGateway, store: ImageStore, tutorial_store: TutorialStore, image_settings: Settings
) -> ImageService:
    return ImageService(gateway=gateway, store=store, tutorials=tutorial_store, settings=image_settings)


@pytest.fixture
def photo_id(store: ImageStore) -> str:
    """A landscape 800x600 'photo' stored as an upload."""
    return store.save_upload(make_jpeg(800, 600)).image_id


@pytest.fixture
def ideas() -> list[UpcycleIdea]:
    return [UpcycleIdea.model_validate(i) for i in load_fixture("recommend_glass_jar")["upcycle"]]


@pytest.fixture
def idea(ideas: list[UpcycleIdea]) -> UpcycleIdea:
    """The jar lantern idea; the tutorial fixture belongs to it."""
    return ideas[0]


@pytest.fixture
def jar_item() -> Item:
    return Item.model_validate(load_fixture("analyze_glass_jar")["analysis"]["items"][0])


@pytest.fixture
def tutorial(photo_id: str, idea: UpcycleIdea, tutorial_store: TutorialStore) -> Tutorial:
    """The 5-step jar lantern tutorial for ``photo_id``, saved in the tutorial store."""
    tut = make_tutorial(photo_id, idea)
    tutorial_store.save(tut)
    return tut
