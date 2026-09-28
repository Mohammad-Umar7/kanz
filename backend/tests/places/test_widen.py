"""An empty search widens once to 40 km before giving up."""

from app.places import service
from app.schemas.common import LatLng
from app.schemas.facilities import FacilitiesRequest, FacilitiesResponse, Place


def _response(places: list[Place], radius: int) -> FacilitiesResponse:
    return FacilitiesResponse(
        places=places,
        center=LatLng(lat=24.45, lng=54.38),
        center_label="Abu Dhabi",
        sources_used=["osm"] if places else [],
        notice=None if places else f"none within {radius}",
        timings_ms={"total": 5},
    )


PLACE = Place(
    id="osm:node/1",
    name="Battery box",
    lat=24.6,
    lng=54.5,
    distance_m=31000,
    facility_types=["collection_point"],
    category_keys=["battery"],
    source="osm",
)


async def test_empty_result_retries_once_with_a_wider_radius(monkeypatch):
    radii: list[int] = []

    async def fake_search(req, settings):
        radii.append(req.radius_m)
        return _response([PLACE] if req.radius_m >= service.WIDE_RADIUS_M else [], req.radius_m)

    monkeypatch.setattr(service, "_search", fake_search)
    res = await service.search(FacilitiesRequest(categories=["battery"], city="abu_dhabi"))
    assert radii == [15000, service.WIDE_RADIUS_M]
    assert [p.id for p in res.places] == ["osm:node/1"]
    assert res.notice.startswith("Nothing within 15 km")
    assert "wide_total" in res.timings_ms


async def test_still_empty_keeps_the_original_answer(monkeypatch):
    async def fake_search(req, settings):
        return _response([], req.radius_m)

    monkeypatch.setattr(service, "_search", fake_search)
    res = await service.search(FacilitiesRequest(categories=["battery"], city="abu_dhabi", lang="ar"))
    assert res.places == []
    assert res.notice == "none within 15000"


async def test_results_in_range_do_not_widen(monkeypatch):
    radii: list[int] = []

    async def fake_search(req, settings):
        radii.append(req.radius_m)
        return _response([PLACE], req.radius_m)

    monkeypatch.setattr(service, "_search", fake_search)
    await service.search(FacilitiesRequest(categories=["glass"], city="abu_dhabi"))
    assert radii == [15000]
