"""The facility search service: providers, merging, center resolution, notices, cache and failures."""

import httpx
import pytest
import respx

from app.core.errors import BadRequest, PlacesUnavailable
from app.places import curated, google, overpass, service
from app.places.models import Candidate, ProviderError
from app.schemas.facilities import FacilitiesRequest

LAT, LNG = 24.4539, 54.3773


def north(metres: float) -> float:
    return LAT + metres / 111_195


def osm_cand(cid, metres, **kw) -> Candidate:
    kw.setdefault("category_keys", ["glass"])
    kw.setdefault("facility_types", ["collection_point"])
    return Candidate(id=cid, source="osm", name=kw.pop("name", "Recycling point"), lat=north(metres), lng=LNG, **kw)


class Providers:
    """Replaces the three providers with scripted results and counts calls."""

    def __init__(self, monkeypatch, *, osm=(), google_places=(), curated_places=()):
        self.calls = {"osm": 0, "google": 0}
        self.osm, self.google = osm, google_places

        async def fake_osm(**kwargs):
            self.calls["osm"] += 1
            if isinstance(self.osm, Exception):
                raise self.osm
            return [c for c in self.osm if set(c.category_keys) & set(kwargs["keys"])]

        async def fake_google(**kwargs):
            self.calls["google"] += 1
            if isinstance(self.google, Exception):
                raise self.google
            return list(self.google)

        monkeypatch.setattr(overpass, "search", fake_osm)
        monkeypatch.setattr(google, "search", fake_google)
        monkeypatch.setattr(curated, "candidates", lambda keys, lang, entries=None: list(curated_places))


async def test_results_are_sorted_filtered_and_limited(monkeypatch, osm_only_settings):
    Providers(
        monkeypatch,
        osm=[
            osm_cand("osm:node/1", 3000, accepted_materials=["glass"]),
            osm_cand("osm:node/2", 800, accepted_materials=["glass"]),
            osm_cand("osm:node/3", 40000),
            osm_cand("osm:node/4", 1500, name="Glass bank", accepted_materials=["glass"]),
        ],
    )
    req = FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG, radius_m=10000, limit=2)
    res = await service.search(req, settings=osm_only_settings)
    assert [p.id for p in res.places] == ["osm:node/2", "osm:node/4"]
    assert [p.distance_m for p in res.places] == [800, 1500]
    assert res.center_label == "Your location"
    assert res.sources_used == ["osm"]
    assert "OpenStreetMap" in res.notice
    assert {"osm", "curated", "merge", "total"} <= set(res.timings_ms)


async def test_city_is_the_center_when_there_is_no_position(monkeypatch, osm_only_settings):
    Providers(monkeypatch, osm=[])
    res = await service.search(
        FacilitiesRequest(categories=["glass"], city="dubai", lang="ar"), settings=osm_only_settings
    )
    assert (res.center.lat, res.center.lng) == (25.2048, 55.2708)
    assert res.center_label == "دبي"
    en = await service.search(FacilitiesRequest(categories=["glass"], city="sharjah"), settings=osm_only_settings)
    assert en.center_label == "Sharjah"


async def test_nothing_found_gives_a_localized_notice(monkeypatch, osm_only_settings):
    Providers(monkeypatch, osm=[])
    res = await service.search(FacilitiesRequest(categories=["battery"], lat=LAT, lng=LNG), settings=osm_only_settings)
    assert res.places == []
    assert res.notice.startswith("No drop-off points found within 15 km. Try a wider radius or another category.")
    assert "battery box" in res.notice  # the category's hint on where else batteries are taken
    ar = await service.search(
        FacilitiesRequest(categories=["battery"], lat=LAT, lng=LNG, radius_m=2500, lang="ar"),
        settings=osm_only_settings,
    )
    assert "2.5" in ar.notice and "كم" in ar.notice


async def test_google_and_osm_duplicates_merge(monkeypatch, google_settings):
    g = Candidate(
        id="g:A",
        source="google",
        name="Synthetic Recycling Hub",
        lat=north(510),
        lng=LNG,
        category_keys=["glass"],
        facility_types=["recycling_center"],
        open_now=True,
    )
    Providers(
        monkeypatch,
        google_places=[g],
        osm=[osm_cand("osm:node/1", 500, generic_name=True, accepted_materials=["glass", "paper"], hours="24/7")],
    )
    res = await service.search(FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG), settings=google_settings)
    [place] = res.places
    assert place.id == "g:A"
    assert place.source == "google"
    assert place.accepted_materials == ["glass", "paper"]
    assert place.accepted_note == "Hours: 24/7."
    assert place.facility_types == ["recycling_center", "collection_point"]
    assert res.sources_used == ["google", "osm"]
    assert res.notice is None


async def test_unlisted_osm_points_say_so(monkeypatch, osm_only_settings):
    Providers(monkeypatch, osm=[osm_cand("osm:node/1", 300, unlisted=True, generic_name=True)])
    res = await service.search(FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG), settings=osm_only_settings)
    assert res.places[0].accepted_note.startswith("Accepted materials aren't listed")


async def test_category_keys_follow_the_request_order(monkeypatch, osm_only_settings):
    Providers(monkeypatch, osm=[osm_cand("osm:node/1", 300, category_keys=["plastic", "glass"])])
    req = FacilitiesRequest(categories=["glass", "plastic"], lat=LAT, lng=LNG)
    res = await service.search(req, settings=osm_only_settings)
    assert res.places[0].category_keys == ["glass", "plastic"]


async def test_google_failure_falls_back_to_osm(monkeypatch, google_settings):
    Providers(monkeypatch, google_places=ProviderError("HTTP 403"), osm=[osm_cand("osm:node/1", 300)])
    res = await service.search(FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG), settings=google_settings)
    assert [p.id for p in res.places] == ["osm:node/1"]
    assert "OpenStreetMap" in res.notice


async def test_all_providers_failing_raises_places_unavailable(monkeypatch, google_settings):
    Providers(monkeypatch, google_places=ProviderError("down"), osm=ProviderError("down"))
    with pytest.raises(PlacesUnavailable):
        await service.search(FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG), settings=google_settings)


async def test_curated_points_still_show_when_live_sources_fail(monkeypatch, osm_only_settings):
    verified = Candidate(
        id="cur:bin",
        source="curated",
        name="Synthetic verified bin",
        lat=north(200),
        lng=LNG,
        category_keys=["glass"],
        facility_types=["collection_point"],
    )
    Providers(monkeypatch, osm=ProviderError("down"), curated_places=[verified])
    res = await service.search(FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG), settings=osm_only_settings)
    assert [p.id for p in res.places] == ["cur:bin"]
    assert res.sources_used == ["curated"]
    assert "Kanz team" in res.notice


async def test_results_are_cached_per_area_categories_and_language(monkeypatch, osm_only_settings):
    providers = Providers(monkeypatch, osm=[osm_cand("osm:node/1", 300)])
    req = FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG)
    first = await service.search(req, settings=osm_only_settings)
    nearby = FacilitiesRequest(categories=["glass"], lat=LAT + 0.0001, lng=LNG)
    second = await service.search(nearby, settings=osm_only_settings)
    assert providers.calls["osm"] == 1
    assert first.places[0].id == second.places[0].id
    assert second.places[0].distance_m != first.places[0].distance_m  # distance is from the caller's position
    await service.search(
        FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG, lang="ar"), settings=osm_only_settings
    )
    assert providers.calls["osm"] == 2


async def test_failures_are_not_cached(monkeypatch, osm_only_settings):
    providers = Providers(monkeypatch, osm=ProviderError("down"))
    req = FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG)
    for _ in range(2):
        with pytest.raises(PlacesUnavailable):
            await service.search(req, settings=osm_only_settings)
    assert providers.calls["osm"] == 2


async def test_unknown_categories_are_ignored_or_rejected(monkeypatch, osm_only_settings):
    Providers(monkeypatch, osm=[osm_cand("osm:node/1", 300)])
    res = await service.search(
        FacilitiesRequest(categories=["glass", "unicorns"], lat=LAT, lng=LNG), settings=osm_only_settings
    )
    assert len(res.places) == 1
    with pytest.raises(BadRequest):
        await service.search(FacilitiesRequest(categories=["unicorns"], lat=LAT, lng=LNG), settings=osm_only_settings)


async def test_google_is_not_called_without_a_key(monkeypatch, osm_only_settings):
    providers = Providers(monkeypatch, osm=[osm_cand("osm:node/1", 300)])
    await service.search(FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG), settings=osm_only_settings)
    assert providers.calls["google"] == 0


@respx.mock
async def test_end_to_end_with_mocked_http(overpass_sample, google_sample, google_settings):
    respx.post(google.SEARCH_URL).mock(return_value=httpx.Response(200, json=google_sample))
    respx.post(overpass.MIRRORS[0]).mock(return_value=httpx.Response(200, json=overpass_sample))
    req = FacilitiesRequest(categories=["glass"], lat=LAT, lng=LNG, radius_m=5000)
    res = await service.search(req, settings=google_settings)
    ids = [p.id for p in res.places]
    # Google's glass centre sits 15 m from the unnamed OSM glass bin, so they merge.
    assert "g:SYNTHETIC_PLACE_A" in ids
    assert "osm:node/9000000001" not in ids
    merged = next(p for p in res.places if p.id == "g:SYNTHETIC_PLACE_A")
    assert merged.accepted_materials == ["glass", "paper"]
    assert res.places == sorted(res.places, key=lambda p: p.distance_m)
    assert all(p.distance_m <= 5000 for p in res.places)
    assert res.sources_used == ["google", "osm"]
    assert {"google", "osm", "total"} <= set(res.timings_ms)
