"""Google Places API (New) Text Search provider, with HTTP mocked by respx."""

import json

import httpx
import pytest
import respx

from app.places import google
from app.places.config import get_config
from app.places.models import ProviderError

CFG = get_config()


def test_query_plan_is_round_robin_and_capped():
    plan = google.plan_queries(["glass", "battery", "metal", "paper"], "en", CFG)
    assert plan[:4] == [
        ("glass", "glass recycling"),
        ("battery", "battery recycling drop off"),
        ("metal", "scrap metal recycling"),
        ("paper", "paper recycling"),
    ]
    assert len(plan) == google.MAX_REQUESTS


def test_arabic_plan_also_sends_the_english_query():
    plan = google.plan_queries(["glass"], "ar", CFG)
    assert plan == [("glass", "إعادة تدوير الزجاج"), ("glass", "glass recycling")]


def test_parse_keeps_open_places_and_maps_fields(google_sample):
    cands = {c.id: c for c in google.parse_places(google_sample, "glass", CFG)}
    assert set(cands) == {"g:SYNTHETIC_PLACE_A", "g:SYNTHETIC_PLACE_B"}
    a = cands["g:SYNTHETIC_PLACE_A"]
    assert a.name == "Synthetic Glass Recycling Centre"
    assert (a.lat, a.lng) == (24.4551, 54.3781)
    assert a.address == "1 Test Road, Test City"
    assert a.open_now is True
    assert a.phone == "+971 2 111 1111"
    assert a.website == "https://example.org/glass"
    assert a.maps_url == "https://maps.google.com/?cid=1"
    assert a.rating == 4.4
    assert a.category_keys == ["glass"]
    assert a.facility_types == ["recycling_center"]
    b = cands["g:SYNTHETIC_PLACE_B"]
    assert b.open_now is None
    assert b.address is None
    assert b.rating is None


@respx.mock
async def test_request_shape(google_sample, google_settings):
    route = respx.post(google.SEARCH_URL).mock(return_value=httpx.Response(200, json=google_sample))
    await google.search(keys=["glass"], lat=24.45, lng=54.37, radius_m=60000, lang="en", settings=google_settings)
    request = route.calls[0].request
    assert request.headers["X-Goog-Api-Key"] == "test-key"
    mask = request.headers["X-Goog-FieldMask"].split(",")
    assert "places.currentOpeningHours.openNow" in mask
    assert "places.displayName" in mask
    assert "places.location" in mask
    assert "*" not in mask
    body = json.loads(request.content)
    assert body["textQuery"] == "glass recycling"
    assert body["languageCode"] == "en"
    assert body["pageSize"] == 20
    circle = body["locationBias"]["circle"]
    assert circle["center"] == {"latitude": 24.45, "longitude": 54.37}
    assert circle["radius"] == 50000.0  # clamped to the API maximum


@respx.mock
async def test_same_place_from_two_categories_is_returned_once(google_sample, google_settings):
    respx.post(google.SEARCH_URL).mock(return_value=httpx.Response(200, json=google_sample))
    cands = await google.search(
        keys=["glass", "general_recycling"], lat=24.45, lng=54.37, radius_m=5000, lang="en", settings=google_settings
    )
    matches = [c for c in cands if c.id == "g:SYNTHETIC_PLACE_A"]
    assert len(matches) == 1
    assert matches[0].category_keys == ["glass", "general_recycling"]


@respx.mock
async def test_partial_failure_still_returns_results(google_sample, google_settings):
    respx.post(google.SEARCH_URL).mock(side_effect=[httpx.Response(200, json=google_sample), httpx.Response(500)])
    cands = await google.search(
        keys=["glass"], lat=24.45, lng=54.37, radius_m=5000, lang="en", settings=google_settings
    )
    assert len(cands) == 2


@respx.mock
async def test_all_queries_failing_raises(google_settings):
    respx.post(google.SEARCH_URL).mock(
        return_value=httpx.Response(403, json={"error": {"status": "PERMISSION_DENIED"}})
    )
    with pytest.raises(ProviderError):
        await google.search(keys=["glass"], lat=24.45, lng=54.37, radius_m=5000, lang="en", settings=google_settings)


async def test_missing_key_is_a_provider_error(osm_only_settings):
    with pytest.raises(ProviderError):
        await google.search(keys=["glass"], lat=24.45, lng=54.37, radius_m=5000, lang="en", settings=osm_only_settings)
