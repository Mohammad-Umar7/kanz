"""Typed loader for ``backend/config/facility_categories.json``.

That one JSON file decides where every scanned item can be dropped off and how each
kind of drop-off point is searched on Google Places and OpenStreetMap. It is parsed
into the models below at first use; ``extra="forbid"`` and the cross-checks in
``FacilityConfig`` make a typo (an unknown key, a rule that points at a missing
category) fail at startup and in the tests instead of silently returning no places.
"""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Literal, get_args

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.config import get_settings
from app.schemas.vocab import FacilityType, HazardFlag, MaterialCategory

CONFIG_FILE = "facility_categories.json"

# Filter value syntax shared by the Overpass query builder and the local matcher:
#   "yes"          exact value
#   "*"            the key exists with any value
#   "~pattern"     case-insensitive regular expression
TagValue = str


class _Model(BaseModel):
    model_config = ConfigDict(extra="forbid", populate_by_name=True, frozen=True)


class Labels(_Model):
    en: str
    ar: str

    def get(self, lang: str) -> str:
        return self.ar if lang == "ar" else self.en


class LocalizedQueries(_Model):
    en: list[str] = Field(min_length=1)
    ar: list[str] = Field(min_length=1)

    def get(self, lang: str) -> list[str]:
        return self.ar if lang == "ar" else self.en


class OsmFilter(_Model):
    """One Overpass selector: every tag must match. ``facility_type`` is what a match makes the place."""

    tags: dict[str, TagValue] = Field(min_length=1)
    facility_type: FacilityType | None = None


class OsmCategory(_Model):
    filters: list[OsmFilter] = Field(min_length=1)
    include_unlisted: bool = Field(
        default=False,
        description="Also offer recycling points that list no accepted materials at all (flagged as unlisted).",
    )


class CategoryConfig(_Model):
    labels: Labels
    facility_types: list[FacilityType] = Field(min_length=1)
    material_categories: list[MaterialCategory] = Field(min_length=1)
    empty_hint: Labels | None = Field(
        default=None, description="Shown with the 'nothing found' notice, e.g. where else batteries are taken."
    )
    google_queries: LocalizedQueries
    osm: OsmCategory


class Condition(_Model):
    """All given fields must hold for the rule to match an item."""

    category: list[MaterialCategory] | None = None
    min_quality: int | None = Field(default=None, ge=1, le=5)
    no_hazards: bool = False
    reuse_level: list[Literal["high", "medium", "low"]] | None = None
    is_raw_material: bool | None = None


class RoutingRule(_Model):
    id: str
    when: Condition
    keys: list[str] = Field(min_length=1)


class RoutingConfig(_Model):
    comment: str | None = Field(default=None, alias="_comment")
    by_hazard: dict[HazardFlag, list[str]]
    by_condition: list[RoutingRule]
    by_material: dict[MaterialCategory, list[str]]
    extras: list[RoutingRule]


class KnownOperator(_Model):
    id: str
    comment: str | None = Field(default=None, alias="_comment")
    pattern: str = Field(description="Case-insensitive regex matched against the name and operator tags.")
    implies: dict[str, str] = Field(min_length=1)


class OsmSettings(_Model):
    comment: str | None = Field(default=None, alias="_comment")
    material_tags: dict[MaterialCategory, list[str]]
    known_operators: list[KnownOperator] = Field(default_factory=list)


class FacilityConfig(_Model):
    comment: str | None = Field(default=None, alias="_comment")
    version: int
    categories: dict[str, CategoryConfig] = Field(min_length=1)
    routing: RoutingConfig
    osm: OsmSettings

    @model_validator(mode="after")
    def _cross_check(self) -> FacilityConfig:
        known = set(self.categories)
        referenced: list[tuple[str, str]] = []
        for hazard, keys in self.routing.by_hazard.items():
            referenced += [(f"routing.by_hazard.{hazard}", k) for k in keys]
        for material, keys in self.routing.by_material.items():
            referenced += [(f"routing.by_material.{material}", k) for k in keys]
        for rule in [*self.routing.by_condition, *self.routing.extras]:
            referenced += [(f"routing rule {rule.id}", k) for k in rule.keys]
        unknown = [f"{where} -> {key}" for where, key in referenced if key not in known]
        if unknown:
            raise ValueError(f"Routing points at unknown categories: {', '.join(unknown)}")
        missing = [m for m in get_args(MaterialCategory) if m not in self.routing.by_material]
        if missing:
            raise ValueError(f"routing.by_material has no entry for: {', '.join(missing)}")
        return self

    # ------------------------------------------------------------------ helpers
    def material_for_osm_suffix(self) -> dict[str, MaterialCategory]:
        """``{"glass_bottles": "glass", "cans": "metal", ...}`` for reading recycling:* tags."""
        return {suffix: material for material, suffixes in self.osm.material_tags.items() for suffix in suffixes}


def config_path() -> Path:
    return get_settings().config_dir / CONFIG_FILE


def load_config(path: Path) -> FacilityConfig:
    """Parse and validate a facility config file (raises ``ValueError`` with the reason)."""
    return FacilityConfig.model_validate(json.loads(path.read_text(encoding="utf-8")))


@lru_cache
def get_config() -> FacilityConfig:
    """The shipped config, loaded once per process."""
    return load_config(config_path())
