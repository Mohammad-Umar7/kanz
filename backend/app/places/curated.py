"""Team-verified drop-off points from ``backend/config/curated_facilities.json``.

The file ships empty. Team members add places they have checked in person or with the
operator; see ``backend/config/README.md``. Every entry is validated at load against
``CuratedFacility`` (kept in sync with ``curated_facilities.schema.json`` by a test):
an invalid entry is rejected and logged, and the rest still load, so one typo cannot
take the drop-off finder down during a demo.

Check the file before committing:

    cd backend && .venv/Scripts/python -m app.places.curated
"""

from __future__ import annotations

import json
import logging
import sys
from dataclasses import dataclass, field
from datetime import date
from functools import lru_cache
from pathlib import Path

from pydantic import BaseModel, ConfigDict, Field, ValidationError, field_validator

from app.config import get_settings
from app.places.config import FacilityConfig, get_config
from app.places.geo import maps_search_url
from app.places.models import Candidate
from app.schemas.vocab import CityId, FacilityType, MaterialCategory

log = logging.getLogger("kanz.places.curated")

CURATED_FILE = "curated_facilities.json"


class CuratedFacility(BaseModel):
    """One verified drop-off point. Mirrors ``curated_facilities.schema.json``."""

    model_config = ConfigDict(extra="forbid")

    id: str = Field(pattern=r"^[a-z0-9][a-z0-9_-]{1,63}$")
    name: str = Field(min_length=2, max_length=120)
    name_ar: str | None = Field(default=None, min_length=2, max_length=120)
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
    address: str | None = None
    city: CityId | None = None
    facility_types: list[FacilityType] = Field(min_length=1)
    category_keys: list[str] = Field(min_length=1)
    accepted_materials: list[MaterialCategory] | None = None
    phone: str | None = Field(default=None, pattern=r"^[+]?[0-9 ()-]{6,20}$")
    website: str | None = Field(default=None, pattern=r"^https?://")
    verified_by: str = Field(min_length=2, max_length=80)
    verified_on: date

    @field_validator("category_keys")
    @classmethod
    def _known_categories(cls, keys: list[str]) -> list[str]:
        unknown = [k for k in keys if k not in get_config().categories]
        if unknown:
            raise ValueError(f"unknown category keys: {', '.join(unknown)}")
        return keys

    @field_validator("verified_on")
    @classmethod
    def _not_in_future(cls, value: date) -> date:
        if value > date.today():
            raise ValueError("verified_on is in the future")
        return value


@dataclass
class CuratedLoad:
    entries: list[CuratedFacility] = field(default_factory=list)
    problems: list[str] = field(default_factory=list)


def load_curated(path: Path) -> CuratedLoad:
    """Validate every entry; keep the good ones and describe the rejected ones."""
    result = CuratedLoad()
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return result
    except json.JSONDecodeError as exc:
        result.problems.append(f"{path.name} is not valid JSON: {exc}")
        return result
    if not isinstance(raw, list):
        result.problems.append(f"{path.name} must be a JSON list of entries")
        return result

    seen: set[str] = set()
    for index, entry in enumerate(raw):
        label = entry.get("id", f"#{index}") if isinstance(entry, dict) else f"#{index}"
        try:
            facility = CuratedFacility.model_validate(entry)
        except ValidationError as err:
            reasons = "; ".join(f"{'.'.join(map(str, e['loc'])) or 'entry'}: {e['msg']}" for e in err.errors())
            result.problems.append(f"entry {label} rejected: {reasons}")
            continue
        if facility.id in seen:
            result.problems.append(f"entry {label} rejected: duplicate id")
            continue
        seen.add(facility.id)
        result.entries.append(facility)
    for problem in result.problems:
        log.error("curated facilities: %s", problem)
    return result


@lru_cache
def get_curated() -> CuratedLoad:
    return load_curated(get_settings().config_dir / CURATED_FILE)


def candidates(keys: list[str], lang: str, entries: list[CuratedFacility] | None = None) -> list[Candidate]:
    """Curated entries serving any requested category (distance is applied by the service)."""
    cfg: FacilityConfig = get_config()
    wanted = set(keys)
    out: list[Candidate] = []
    for f in get_curated().entries if entries is None else entries:
        matched = [k for k in f.category_keys if k in wanted and k in cfg.categories]
        if not matched:
            continue
        out.append(
            Candidate(
                id=f"cur:{f.id}",
                source="curated",
                name=(f.name_ar if lang == "ar" and f.name_ar else f.name),
                lat=f.lat,
                lng=f.lng,
                category_keys=matched,
                facility_types=list(f.facility_types),
                address=f.address,
                phone=f.phone,
                website=f.website,
                maps_url=maps_search_url(f.lat, f.lng),
                accepted_materials=list(f.accepted_materials) if f.accepted_materials else None,
                verified_by=f.verified_by,
                verified_on=f.verified_on,
            )
        )
    return out


def main() -> int:
    """CLI: validate the curated file and print a short report."""
    path = get_settings().config_dir / CURATED_FILE
    loaded = load_curated(path)
    for problem in loaded.problems:
        print(f"REJECTED  {problem}")
    print(f"{len(loaded.entries)} valid entr{'y' if len(loaded.entries) == 1 else 'ies'} in {path.name}")
    return 1 if loaded.problems else 0


if __name__ == "__main__":
    sys.exit(main())
