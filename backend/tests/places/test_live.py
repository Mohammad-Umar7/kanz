"""One real OpenStreetMap search (excluded by default; run with ``-m live``).

    .venv/Scripts/python -m pytest tests/places/test_live.py -m live -s

It sends a single Overpass query for glass drop-off points around Abu Dhabi's city
center, with Google Places switched off, and prints what came back. The public Overpass
instances are sometimes busy; a ``PlacesUnavailable`` then means "try again in a minute",
not a bug.
"""

import time

import pytest

from app.config import Settings
from app.places import service
from app.schemas.facilities import FacilitiesRequest


@pytest.mark.live
async def test_live_glass_points_in_abu_dhabi() -> None:
    settings = Settings(google_maps_api_key="")
    start = time.perf_counter()
    res = await service.search(FacilitiesRequest(categories=["glass"], city="abu_dhabi"), settings=settings)
    elapsed = int((time.perf_counter() - start) * 1000)

    print(f"\n{len(res.places)} places in {elapsed} ms, timings={res.timings_ms}")
    for place in res.places[:5]:
        print(f"  {place.distance_m:>6} m  {place.name}  ({place.id})")
    assert res.center_label == "Abu Dhabi"
    assert res.sources_used == ["osm"] or not res.places
    assert all(p.source == "osm" and p.distance_m <= 15000 for p in res.places)
    assert [p.distance_m for p in res.places] == sorted(p.distance_m for p in res.places)
