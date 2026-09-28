"""Persistent tutorial store.

The Tutorial Writer saves every tutorial here; the image pipeline reads it back by
``tutorial_id`` to get each step's ``image_prompt`` when it builds the step-image chain.
"""

from __future__ import annotations

import hashlib
import json

from app.config import Settings, get_settings
from app.schemas.tutorial import Tutorial


def tutorial_id_for(image_id: str, idea_id: str, skill: str, tools: list[str], lang: str) -> str:
    """Deterministic id: the same photo, idea, skill, tools and language give the same tutorial."""
    raw = json.dumps([image_id, idea_id, skill, sorted(set(tools)), lang], separators=(",", ":"))
    return "tut_" + hashlib.sha256(raw.encode()).hexdigest()[:16]


class TutorialStore:
    def __init__(self, settings: Settings | None = None) -> None:
        self.s = settings or get_settings()
        self.s.tutorials_dir.mkdir(parents=True, exist_ok=True)
        self._cache: dict[str, Tutorial] = {}

    def save(self, tutorial: Tutorial) -> None:
        self._cache[tutorial.tutorial_id] = tutorial
        path = self.s.tutorials_dir / f"{tutorial.tutorial_id}.json"
        path.write_text(tutorial.model_dump_json(indent=1), encoding="utf-8")

    def get(self, tutorial_id: str) -> Tutorial | None:
        if tutorial_id in self._cache:
            return self._cache[tutorial_id]
        if not tutorial_id.startswith("tut_") or not tutorial_id[4:].isalnum():
            return None
        path = self.s.tutorials_dir / f"{tutorial_id}.json"
        if not path.exists():
            return None
        tutorial = Tutorial.model_validate_json(path.read_text(encoding="utf-8"))
        self._cache[tutorial_id] = tutorial
        return tutorial


_store: TutorialStore | None = None


def get_tutorial_store() -> TutorialStore:
    global _store
    if _store is None:
        _store = TutorialStore()
    return _store
