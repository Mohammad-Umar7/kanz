"""Internal shape of a drop-off point while providers' results are merged.

Each provider (Google Places, OpenStreetMap, the curated file) turns its own format
into ``Candidate`` objects. The service merges duplicates, measures distance and only
then renders the public ``Place`` (including the localized ``accepted_note``).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date
from typing import Literal

Source = Literal["google", "osm", "curated"]


class ProviderError(Exception):
    """A provider could not answer (network error, bad status, unusable body)."""


@dataclass
class Candidate:
    id: str
    source: Source
    name: str
    lat: float
    lng: float
    category_keys: list[str]
    facility_types: list[str]
    address: str | None = None
    open_now: bool | None = None
    phone: str | None = None
    website: str | None = None
    maps_url: str | None = None
    accepted_materials: list[str] | None = None
    rating: float | None = None
    # A label Kanz chose ("Recycling point") because the source gives no name. Never a made-up proper name.
    generic_name: bool = False
    # An OpenStreetMap recycling point that does not list what it accepts.
    unlisted: bool = False
    # Recognized as a charity clothing bin by its operator name (see osm.known_operators in the config).
    charity_bin: bool = False
    hours: str | None = None
    verified_by: str | None = None
    verified_on: date | None = None
    sources: set[str] = field(default_factory=set)

    def __post_init__(self) -> None:
        self.sources.add(self.source)
