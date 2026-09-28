"""Test doubles and helpers for the image pipeline tests (no network).

``FakeImageGateway`` stands in for ``GeminiGateway.image``: it renders tiny JPEGs and
records every call (stage, prompt, references, aspect ratio), so tests can check exactly
which pictures were sent as references and in which order. Each render gets a distinct
color, so two renders of the same key produce different files and an overwrite is
observable.
"""

from __future__ import annotations

import asyncio
import io
import json
import re
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from PIL import Image

from app.ai.gemini import GeneratedImage
from app.core.tutorials import tutorial_id_for
from app.images.framing import SUPPORTED_ASPECT_RATIOS
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial

FIXTURES_DIR = Path(__file__).resolve().parents[3] / "contracts" / "fixtures"
_STEP_OF = re.compile(r"This picture is step (\d+) of (\d+)")


def load_fixture(name: str) -> Any:
    return json.loads((FIXTURES_DIR / f"{name}.json").read_text(encoding="utf-8"))


def make_jpeg(width: int, height: int, color: tuple[int, int, int] = (200, 190, 170)) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (width, height), color).save(buf, "JPEG", quality=90)
    return buf.getvalue()


def jpeg_size(data: bytes) -> tuple[int, int]:
    with Image.open(io.BytesIO(data)) as img:
        return img.size


@dataclass
class ImageCall:
    stage: str
    prompt: str
    references: list[bytes]
    aspect_ratio: str | None

    @property
    def kind(self) -> str:
        return self.stage.removeprefix("image_")

    @property
    def step(self) -> int | None:
        match = _STEP_OF.search(self.prompt)
        return int(match.group(1)) if match else None

    @property
    def label(self) -> str:
        """'step3', 'after', 'reference', 'bin': compact labels for order assertions."""
        return f"step{self.step}" if self.kind == "step" else self.kind


@dataclass
class FakeImageGateway:
    """Stands in for ``GeminiGateway.image``."""

    calls: list[ImageCall] = field(default_factory=list)
    delay: float = 0.0
    fail: Callable[[ImageCall], BaseException | None] | None = None
    output: bytes | None = None
    active: int = 0
    max_active: int = 0

    async def image(
        self,
        *,
        stage: str,
        prompt: str,
        references: Any = (),
        aspect_ratio: str | None = None,
        image_size: str | None = None,
        timeout: float | None = None,
    ) -> GeneratedImage:
        call = ImageCall(stage, prompt, list(references), aspect_ratio)
        self.calls.append(call)
        self.active += 1
        self.max_active = max(self.max_active, self.active)
        try:
            if self.delay:
                await asyncio.sleep(self.delay)
            error = self.fail(call) if self.fail else None
            if error is not None:
                raise error
            if self.output is not None:
                return GeneratedImage(data=self.output, mime_type="image/png", model="fake-image")
            ratio = SUPPORTED_ASPECT_RATIOS.get(aspect_ratio or "4:3", 4 / 3)
            width = 120
            shade = (len(self.calls) * 37) % 256
            data = make_jpeg(width, round(width / ratio), (shade, 255 - shade, 128))
            return GeneratedImage(data=data, mime_type="image/jpeg", model="fake-image")
        finally:
            self.active -= 1

    @property
    def labels(self) -> list[str]:
        return [c.label for c in self.calls]

    def only(self, label: str) -> ImageCall:
        matches = [c for c in self.calls if c.label == label]
        assert len(matches) == 1, f"expected one '{label}' render, got {self.labels}"
        return matches[0]


def make_tutorial(image_id: str, idea: UpcycleIdea, skill: str = "beginner") -> Tutorial:
    base = Tutorial.model_validate(load_fixture("tutorial_jar_lantern")["tutorial"])
    tools = [t.tool_id for t in base.tools if t.have]
    return base.model_copy(
        update={
            "tutorial_id": tutorial_id_for(image_id, idea.id, skill, tools, "en"),
            "image_id": image_id,
            "idea_id": idea.id,
            "skill": skill,
        }
    )
