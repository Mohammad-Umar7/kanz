"""The swap documents in ``backend/knowledge/swaps.json``, as a strict typed catalog.

The RAG index embeds these documents together with the rest of the knowledge base and
decides *which* swaps fit a request. This catalog supplies the *facts* of each chosen
document (effort, cost, material, whether a number may be quoted), so those fields on a
swap card always come from reviewed writing, never from the model.
"""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, TypeAdapter

from app.config import get_settings
from app.schemas.vocab import Level, MaterialCategory

SWAPS_FILE = "swaps.json"


class SwapEntry(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    id: str = Field(pattern=r"^swap_[a-z0-9_]+$")
    kind: Literal["swap"] = "swap"
    title: str = Field(min_length=3)
    title_ar: str = Field(min_length=2)
    materials: list[MaterialCategory] = Field(min_length=1)
    from_item: str
    to_item: str
    replaces_category: MaterialCategory
    keywords: list[str] = Field(min_length=1)
    why: str
    tip: str
    effort: Level
    cost: Level
    impact_note: str | None = None
    impact_source: str | None = Field(
        default=None, description="A checkable citation. Only then may a card quote a number for this swap."
    )

    def title_for(self, lang: str) -> str:
        return self.title_ar if lang == "ar" else self.title


_ADAPTER = TypeAdapter(list[SwapEntry])


def load_swaps(path: Path) -> list[SwapEntry]:
    """Parse and validate the swaps file (raises on any invalid or duplicate entry)."""
    entries = _ADAPTER.validate_python(json.loads(path.read_text(encoding="utf-8")))
    ids = [e.id for e in entries]
    duplicates = sorted({i for i in ids if ids.count(i) > 1})
    if duplicates:
        raise ValueError(f"duplicate swap ids: {', '.join(duplicates)}")
    return entries


@lru_cache
def swap_catalog() -> dict[str, SwapEntry]:
    """``{id: SwapEntry}`` for the shipped knowledge file, loaded once."""
    return {e.id: e for e in load_swaps(get_settings().knowledge_dir / SWAPS_FILE)}
