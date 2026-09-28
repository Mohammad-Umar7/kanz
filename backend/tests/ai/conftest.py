"""Fixtures for the AI pipeline tests: a scripted Gemini stand-in and isolated storage.

No test in this package touches the network (except ``test_live.py``, marked ``live``).
``FakeGateway`` mimics ``GeminiGateway.structured``: it returns canned model outputs per
schema, runs the node's validator, and performs the same single repair round, so the tests
exercise the real validators and fallbacks.
"""

from __future__ import annotations

import hashlib
import io
import json
import math
import re
from collections.abc import Callable
from pathlib import Path
from typing import Any

import pytest
from PIL import Image
from pydantic import BaseModel, ValidationError

from app.ai.rag import index as rag_index
from app.ai.rag.index import KnowledgeIndex
from app.config import BACKEND_DIR, Settings
from app.core import storage, tutorials
from app.core.errors import AiInvalidOutput
from app.schemas.analysis import Analysis
from app.schemas.recommend import FacilityCategory

FIXTURES = BACKEND_DIR.parent / "contracts" / "fixtures"

Answer = dict | BaseModel | Exception | Callable[[list], Any]


class FakeGateway:
    """Scripted replacement for ``GeminiGateway`` (structured + embed)."""

    def __init__(
        self, answers: dict[type, Answer | list[Answer]] | None = None, *, embed_error: Exception | None = None
    ):
        self.answers = dict(answers or {})
        self.embed_error = embed_error
        self.calls: list[dict[str, Any]] = []
        self.problems: list[list[str]] = []
        self.embedded: list[str] = []

    def _next(self, schema: type, attempt: int, contents: list) -> Any:
        script = self.answers.get(schema)
        if script is None:
            raise AssertionError(f"no scripted answer for {schema.__name__}")
        answer = script[min(attempt, len(script) - 1)] if isinstance(script, list) else script
        if isinstance(answer, Exception):
            raise answer
        if callable(answer) and not isinstance(answer, BaseModel):
            answer = answer(contents)
        return schema.model_validate(answer.model_dump() if isinstance(answer, BaseModel) else answer)

    async def structured(self, *, stage: str, system: str, contents: list, schema: type, validator=None, **kwargs):
        """Like the real gateway: validate the schema and the node's rules, repair once, then give up."""
        self.calls.append({"stage": stage, "system": system, "contents": contents, "schema": schema, **kwargs})
        for attempt in (0, 1):
            if attempt == 1 and callable(getattr(validator, "begin_repair", None)):
                validator.begin_repair()
            try:
                obj = self._next(schema, attempt, contents)
            except ValidationError as err:
                problems = [f"{'.'.join(map(str, e['loc']))}: {e['msg']}" for e in err.errors()]
            else:
                problems = validator(obj) if validator else []
                if not problems:
                    return obj
            self.problems.append(problems)
        raise AiInvalidOutput(detail="; ".join(problems))

    def schemas_called(self) -> list[str]:
        return [c["schema"].__name__ for c in self.calls]

    async def embed(self, texts, *, task_type: str = "RETRIEVAL_DOCUMENT") -> list[list[float]]:
        if self.embed_error:
            raise self.embed_error
        self.embedded.extend(texts)
        return [hash_vector(t) for t in texts]


def hash_vector(text: str, dim: int = 64) -> list[float]:
    """Deterministic bag-of-words embedding: texts sharing words point the same way."""
    vec = [0.0] * dim
    for word in re.findall(r"\w+", text.lower()):
        vec[int(hashlib.md5(word.encode()).hexdigest(), 16) % dim] += 1.0
    norm = math.sqrt(sum(v * v for v in vec)) or 1.0
    return [v / norm for v in vec]


# ------------------------------------------------------------------------ environment
@pytest.fixture
def settings(tmp_path: Path) -> Settings:
    return Settings(
        _env_file=None,
        gemini_api_key="test-key",
        data_dir=tmp_path / "data",
        step_images_autostart=True,
    )


@pytest.fixture(autouse=True)
def isolated(monkeypatch: pytest.MonkeyPatch, settings: Settings):
    """Stores and the knowledge index live in a temp dir; the pipeline sees the test settings."""
    monkeypatch.setattr(storage, "_store", storage.ImageStore(settings))
    monkeypatch.setattr(tutorials, "_store", tutorials.TutorialStore(settings))
    monkeypatch.setattr(rag_index, "_index", KnowledgeIndex(settings, gateway=FakeGateway()))
    monkeypatch.setattr("app.ai.pipeline.get_settings", lambda: settings)
    # Most tests use fixture image ids with no stored upload; test_scan_lookup.py covers the check.
    monkeypatch.setattr("app.ai.pipeline._require_scan", lambda image_id: None)
    return settings


@pytest.fixture
def step_chain(monkeypatch: pytest.MonkeyPatch) -> list[tuple]:
    """Record calls to the image pipeline's ``start_step_chain`` instead of generating images."""
    calls: list[tuple] = []
    monkeypatch.setattr(
        "app.images.service.start_step_chain", lambda tutorial, idea=None: calls.append((tutorial, idea)), raising=False
    )
    return calls


@pytest.fixture(autouse=True)
def facility_categories(monkeypatch: pytest.MonkeyPatch) -> None:
    """Stand-in for the Places workstream's ``categories_for_items``: one category per material."""

    def categories_for_items(items, lang):
        out: dict[str, FacilityCategory] = {}
        for it in items:
            key = "battery" if "battery" in it.hazards else it.category
            cat = out.setdefault(
                key,
                FacilityCategory(
                    key=key,
                    label=key.title(),
                    facility_types=["hazardous_waste"] if key == "battery" else ["recycling_center"],
                    material_categories=[it.category],
                    item_ids=[],
                ),
            )
            cat.item_ids.append(it.id)
        return list(out.values())

    monkeypatch.setattr("app.places.categories.categories_for_items", categories_for_items, raising=False)


# ------------------------------------------------------------------------ test data
def jpeg_bytes(width: int = 640, height: int = 480, color: tuple[int, int, int] = (180, 200, 210)) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (width, height), color).save(buf, "JPEG")
    return buf.getvalue()


def fixture_json(name: str) -> dict:
    return json.loads((FIXTURES / name).read_text(encoding="utf-8"))


def fixture_analysis(name: str) -> Analysis:
    return Analysis.model_validate(fixture_json(name)["analysis"])


def llm_item(**overrides: Any) -> dict:
    item = {
        "name": "Glass jam jar",
        "category": "glass",
        "material": "Clear soda-lime glass",
        "resin_code": None,
        "is_raw_material": False,
        "quantity_value": 1,
        "quantity_unit": "pcs",
        "quantity_is_estimate": False,
        "quality_score": 4,
        "quality_notes": "No chips or cracks",
        "state": ["empty", "label_on", "intact"],
        "recyclability_status": "yes",
        "recycling_stream": "Glass bottle bank",
        "prep_steps": ["Rinse out food", "Remove the lid"],
        "recyclability_reason": None,
        "reuse_level": "high",
        "reuse_note": "Thick clear glass with a screw thread.",
        "hazards": [],
        "confidence": 0.93,
        "box_2d": [180, 310, 800, 670],
    }
    item.update(overrides)
    return item


def llm_analysis(
    *items: dict, usable: bool = True, issue: str = "ok", tip: str | None = None, summary: str = "An empty jar."
) -> dict:
    return {"photo": {"usable": usable, "issue": issue, "retake_tip": tip}, "items": list(items), "summary": summary}


def llm_ideas(item_id: str = "item_1", **first: Any) -> dict:
    ideas = [
        {
            "title": "Hanging jar lantern",
            "pitch": "A tea-light lantern with a twine handle for the balcony.",
            "difficulty": "easy",
            "time_minutes": 35,
            "tools_needed": ["craft_wire", "pliers", "twine", "scissors", "gloves"],
            "uses_item_ids": [item_id],
            "extra_materials": ["LED tea light"],
            "after_visual": "the same clear glass jar with a wire handle and a glowing tea light inside",
            "safety_note": "Use an LED tea light indoors.",
            "source_ids": ["proj_glass_jar_lantern", "proj_invented_by_model"],
        },
        {
            "title": "Windowsill herb jar",
            "pitch": "Grow basil on a sunny sill with a pebble drainage layer.",
            "difficulty": "easy",
            "time_minutes": 25,
            "tools_needed": ["scissors"],
            "uses_item_ids": [item_id],
            "extra_materials": ["Pebbles", "Potting mix", "Basil seedling"],
            "after_visual": "the same glass jar filled with pebbles, soil and a small basil plant",
            "safety_note": None,
            "source_ids": ["proj_glass_jar_herb_garden"],
        },
        {
            "title": "Painted desk organizer",
            "pitch": "Paint the outside and keep pens and brushes in it.",
            "difficulty": "medium",
            "time_minutes": 60,
            "tools_needed": ["acrylic_paint", "paintbrush", "masking_tape"],
            "uses_item_ids": [item_id],
            "extra_materials": [],
            "after_visual": "the same jar painted matte white on the outside, holding pens",
            "safety_note": "Paint the outside only.",
            "source_ids": ["proj_glass_painted_jar"],
        },
    ]
    ideas[0].update(first)
    return {"ideas": ideas}


def llm_recycle(*item_ids: str) -> dict:
    return {
        "instructions": [
            {
                "item_id": i,
                "status": "yes",
                "stream": "Glass bottle bank",
                "prep_steps": ["Rinse it", "Remove the lid"],
                "dos": ["Sort by color"],
                "donts": ["Don't bag the glass"],
                "note": None,
            }
            for i in item_ids
        ],
        "source_ids": ["mat_glass"],
    }


def llm_donate(*item_ids: str, suitable: bool = True) -> dict:
    return {
        "summary": "Clean jars are welcome at refill shops.",
        "options": [
            {
                "item_id": i,
                "suitable": suitable,
                "reason": "Intact and clean.",
                "where": ["Refill shops"],
                "prep_steps": ["Wash and dry it"],
            }
            for i in item_ids
        ],
    }


def llm_disposal(item_id: str = "item_1", hazard: str = "battery") -> dict:
    return {
        "guidance": [
            {
                "item_id": item_id,
                "hazard": hazard,
                "headline": "Take the batteries to a battery collection point.",
                "stream": "Battery collection point",
                "steps": ["Tape both terminals", "Keep them dry in a jar"],
                "never": ["Never put them in the bin", "Never burn them"],
            }
        ],
        "source_ids": ["safety_batteries"],
    }


def llm_tutorial(n_steps: int = 5, **overrides: Any) -> dict:
    steps = [
        {
            "title": f"Step {n}",
            "instruction": f"Do part {n} of the lantern carefully.",
            "tip": None,
            "warning": None,
            "duration_minutes": 5,
            "image_prompt": f"the same clear glass jar after step {n}",
        }
        for n in range(1, n_steps + 1)
    ]
    out = {
        "title": "Hanging jar lantern",
        "adapted_note": "Adapted for Beginner: pliers instead of a drill.",
        "materials": [
            {"name": "Glass jam jar", "quantity": "1", "from_scan": True, "item_id": "item_1"},
            {"name": "Tea light", "quantity": "1", "from_scan": False, "item_id": None},
        ],
        "tools": [
            {"tool_id": "pliers", "alternative": None},
            {"tool_id": "twine", "alternative": None},
            {"tool_id": "craft_wire", "alternative": "A straightened metal coat hanger"},
        ],
        "safety": ["Wear work gloves when bending wire"],
        "steps": steps,
        "finishing": ["Hang it from a hook"],
        "care": ["Wipe soot off with a damp cloth"],
        "source_ids": ["proj_glass_jar_lantern"],
    }
    out.update(overrides)
    return out
