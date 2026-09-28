"""Localized labels from the shared vocabulary (``contracts/vocab.json``).

The models return closed English ids (``"glass"``, ``"craft_knife"``, quality score ``4``);
everything a person reads is localized deterministically from this one file, so the app,
the backend and the prompts always agree on wording.
"""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Any

from app.config import BACKEND_DIR

LANG_NAMES = {"en": "English", "ar": "Modern Standard Arabic"}

# The source of truth is contracts/vocab.json, next to backend/ in the repo. The container
# image is built from backend/ alone, so an exact copy ships in this package;
# tests/ai/test_labels.py fails if the two drift apart.
CONTRACT_VOCAB = BACKEND_DIR.parent / "contracts" / "vocab.json"
BUNDLED_VOCAB = Path(__file__).with_name("vocab.json")


def vocab_path() -> Path:
    return CONTRACT_VOCAB if CONTRACT_VOCAB.exists() else BUNDLED_VOCAB


@lru_cache
def vocab() -> dict[str, Any]:
    return json.loads(vocab_path().read_text(encoding="utf-8"))


def _pick(entry: dict[str, Any], lang: str) -> str:
    return str(entry.get(lang) or entry["en"])


@lru_cache
def _table(section: str) -> dict[str, dict[str, Any]]:
    return {str(e["id"]): e for e in vocab()[section]}


def material_label(category: str, lang: str) -> str:
    entry = _table("materials").get(category)
    return _pick(entry, lang) if entry else category


def tool_label(tool_id: str, lang: str) -> str:
    entry = _table("tools").get(tool_id)
    return _pick(entry, lang) if entry else tool_id.replace("_", " ")


def hazard_label(hazard: str, lang: str) -> str:
    entry = _table("hazards").get(hazard)
    return _pick(entry, lang) if entry else hazard.replace("_", " ")


def state_label(tag: str, lang: str) -> str:
    entry = _table("state_tags").get(tag)
    return _pick(entry, lang) if entry else tag.replace("_", " ")


def quality_label(score: int, lang: str) -> str:
    score = min(5, max(1, int(score)))
    for entry in vocab()["quality_labels"]:
        if int(entry["score"]) == score:
            return _pick(entry, lang)
    return str(score)


def lang_name(lang: str) -> str:
    return LANG_NAMES.get(lang, "English")
