"""OpenStreetMap provider: query building, parsing of a hand-written sample, mirror fallback."""

import asyncio
import time

import httpx
import pytest
import respx

from app.places import overpass
from app.places.config import get_config
from app.places.models import ProviderError

CFG = get_config()


def by_id(cands):
    return {c.id: c for c in cands}


def test_query_for_material_category_fetches_every_recycling_point():
    q = overpass.build_query(["glass"], 24.45, 54.37, 15000, timeout_s=12, cfg=CFG)
    assert q.startswith("[out:json][timeout:12];")
    assert 'nw["amenity"="recycling"](around:15000,24.450000,54.370000);' in q
    assert "recycling:glass_bottles" not in q  # covered by the broad selector, matched locally
    assert q.rstrip().endswith("out tags center;")


def test_query_for_clothes_fetches_recycling_points_to_recognize_charity_bins_locally():
    q = overpass.build_query(["textile_donation"], 25.2, 55.27, 5000, timeout_s=12, cfg=CFG)
    assert 'nw["amenity"="recycling"](around:5000,25.200000,55.270000);' in q
    assert '["shop"="charity"]' in q
    assert "~" not in q  # no server-side regex on names: it is slow on Overpass


def test_query_for_batteries_is_specific():
    q = overpass.build_query(["battery"], 25.34, 55.42, 15000, timeout_s=12, cfg=CFG)
    assert '["recycling:batteries"="yes"]' in q
    assert 'nw["amenity"="recycling"](around' not in q


def test_glass_matches_listed_and_unlisted_points_only(overpass_sample):
    cands = by_id(overpass.parse_elements(overpass_sample, ["glass"], "en", CFG))
    assert set(cands) == {"osm:node/9000000001", "osm:node/9000000003", "osm:node/9000000007"}
    listed = cands["osm:node/9000000001"]
    assert listed.accepted_materials == ["glass", "paper"]
    assert listed.unlisted is False
    assert listed.address == "12 Test Street, Test City"
    assert listed.hours == "24/7"
    assert listed.facility_types == ["collection_point"]
    assert cands["osm:node/9000000003"].unlisted is True
    assert cands["osm:node/9000000007"].facility_types == ["recycling_center"]


def test_unnamed_points_get_a_generic_localized_label(overpass_sample):
    en = by_id(overpass.parse_elements(overpass_sample, ["glass", "battery"], "en", CFG))
    assert en["osm:node/9000000001"].name == "Recycling point"
    assert en["osm:node/9000000001"].generic_name is True
    assert en["osm:node/9000000005"].name == "Battery drop-off point · Synthetic Operator"
    ar = by_id(overpass.parse_elements(overpass_sample, ["glass"], "ar", CFG))
    assert ar["osm:node/9000000001"].name == "نقطة إعادة تدوير"


def test_named_points_keep_their_own_name_in_the_request_language(overpass_sample):
    ar = by_id(overpass.parse_elements(overpass_sample, ["glass"], "ar", CFG))
    assert ar["osm:node/9000000007"].name == "مركز تدوير تجريبي"
    assert ar["osm:node/9000000007"].generic_name is False


def test_clothes_donation_reads_tags_shops_and_known_charity_bins(overpass_sample):
    cands = by_id(overpass.parse_elements(overpass_sample, ["textile_donation"], "en", CFG))
    assert set(cands) == {"osm:way/9000000002", "osm:node/9000000004", "osm:node/9000000006"}
    way = cands["osm:way/9000000002"]
    assert (way.lat, way.lng) == (24.46, 54.38)
    assert way.facility_types == ["collection_point", "donation"]
    charity_bin = cands["osm:node/9000000004"]
    assert charity_bin.name == "Make A Wish"
    assert charity_bin.charity_bin is True
    assert charity_bin.accepted_materials is None  # inferred, not stated by the source
    shop = cands["osm:node/9000000006"]
    assert shop.facility_types == ["donation"]
    assert shop.phone == "+971 2 000 0000"
    assert shop.website == "https://example.org"


def test_trash_bins_and_features_without_coordinates_are_ignored(overpass_sample):
    cands = by_id(overpass.parse_elements(overpass_sample, ["hazardous", "glass"], "en", CFG))
    assert "osm:node/9000000008" not in cands
    assert "osm:way/9000000009" not in cands


def test_each_point_lists_the_requested_categories_it_matches(overpass_sample):
    cands = by_id(overpass.parse_elements(overpass_sample, ["textile_recycling", "textile_donation"], "en", CFG))
    assert cands["osm:way/9000000002"].category_keys == ["textile_recycling", "textile_donation"]
    assert cands["osm:node/9000000006"].category_keys == ["textile_donation"]


@respx.mock
async def test_busy_mirror_falls_back_to_the_next(overpass_sample, osm_only_settings):
    first = respx.post(overpass.MIRRORS[0]).mock(return_value=httpx.Response(504))
    second = respx.post(overpass.MIRRORS[1]).mock(return_value=httpx.Response(200, json=overpass_sample))
    cands = await overpass.search(
        keys=["glass"], lat=24.4539, lng=54.3773, radius_m=5000, lang="en", settings=osm_only_settings
    )
    assert first.called and second.called
    assert len(cands) == 3
    request = second.calls.last.request
    assert request.headers["User-Agent"] == overpass.USER_AGENT
    assert b"around%3A5000" in request.content


@respx.mock
async def test_runtime_error_remark_counts_as_a_failure(overpass_sample, osm_only_settings):
    respx.post(overpass.MIRRORS[0]).mock(
        return_value=httpx.Response(200, json={"elements": [], "remark": "runtime error: Query timed out"})
    )
    respx.post(overpass.MIRRORS[1]).mock(return_value=httpx.Response(200, json=overpass_sample))
    cands = await overpass.search(
        keys=["glass"], lat=24.4539, lng=54.3773, radius_m=5000, lang="en", settings=osm_only_settings
    )
    assert len(cands) == 3


@respx.mock
async def test_all_mirrors_failing_raises(osm_only_settings):
    respx.post(overpass.MIRRORS[0]).mock(return_value=httpx.Response(429))
    respx.post(overpass.MIRRORS[1]).mock(side_effect=httpx.ConnectError("offline"))
    with pytest.raises(ProviderError):
        await overpass.search(
            keys=["glass"], lat=24.45, lng=54.37, radius_m=5000, lang="en", settings=osm_only_settings
        )


@respx.mock
async def test_slow_mirror_is_hedged_with_the_next(monkeypatch, overpass_sample, osm_only_settings):
    monkeypatch.setattr(overpass, "HEDGE_AFTER_S", 0.05)

    async def slow(request):
        await asyncio.sleep(5)
        return httpx.Response(200, json={"elements": []})

    respx.post(overpass.MIRRORS[0]).mock(side_effect=slow)
    respx.post(overpass.MIRRORS[1]).mock(return_value=httpx.Response(200, json=overpass_sample))
    started = time.perf_counter()
    cands = await overpass.search(
        keys=["glass"], lat=24.4539, lng=54.3773, radius_m=5000, lang="en", settings=osm_only_settings
    )
    assert len(cands) == 3
    assert time.perf_counter() - started < 2
