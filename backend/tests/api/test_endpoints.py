"""Happy paths for recommend, tutorial, images, facilities and swaps, with seams stubbed.

Each test posts a contract request, checks the seam received the parsed model, and
checks the response body is exactly the contract fixture the seam returned.
"""

from __future__ import annotations

import httpx

from app.schemas.facilities import FacilitiesRequest, FacilitiesResponse
from app.schemas.images import AfterImageRequest, BinImageRequest, ImageResponse, StepImageRequest
from app.schemas.recommend import FacilityCategory, RecommendRequest, RecommendResponse
from app.schemas.swaps import SwapsRequest, SwapsResponse
from app.schemas.tutorial import TutorialRequest, TutorialResponse
from tests.api.helpers import Seams, assert_error
from tests.conftest import load_fixture


# ------------------------------------------------------------------------------ recommend
async def test_recommend(client: httpx.AsyncClient, seams: Seams) -> None:
    request = load_fixture("recommend_request_glass_jar")
    fixture = load_fixture("recommend_glass_jar")
    calls = seams.returns("app.ai.pipeline.recommend", RecommendResponse.model_validate(fixture))

    response = await client.post("/v1/recommend", json=request)

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].args == (RecommendRequest.model_validate(request),)


async def test_recommend_rejects_unknown_focus_item(client: httpx.AsyncClient, seams: Seams) -> None:
    calls = seams.returns("app.ai.pipeline.recommend", None)
    request = load_fixture("recommend_request_glass_jar") | {"focus_item_id": "item_99"}
    error = assert_error(await client.post("/v1/recommend", json=request), 400, "bad_request")
    assert "item_99" in error["message"]
    assert calls == []


async def test_recommend_rejects_a_scan_without_items(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns("app.ai.pipeline.recommend", None)
    request = load_fixture("recommend_request_glass_jar")
    request["analysis"]["items"] = []
    request["focus_item_id"] = None
    assert_error(await client.post("/v1/recommend", json=request), 400, "bad_request")


# ------------------------------------------------------------------------------- tutorial
async def test_tutorial(client: httpx.AsyncClient, seams: Seams) -> None:
    request = load_fixture("tutorial_request_jar_lantern")
    fixture = load_fixture("tutorial_jar_lantern")
    calls = seams.returns("app.ai.pipeline.tutorial", TutorialResponse.model_validate(fixture))

    response = await client.post("/v1/tutorial", json=request)

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].args == (TutorialRequest.model_validate(request),)


# --------------------------------------------------------------------------------- images
async def test_after_image(client: httpx.AsyncClient, seams: Seams) -> None:
    idea = load_fixture("recommend_glass_jar")["upcycle"][0]
    request = {"image_id": "img_3f9a1c2b7d4e5f60", "idea": idea}
    fixture = load_fixture("image_after")
    calls = seams.returns("app.images.service.after_image", ImageResponse.model_validate(fixture))

    response = await client.post("/v1/images/after", json=request)

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].args == (AfterImageRequest.model_validate(request),)
    assert calls[0].args[0].regenerate is False


async def test_step_image(client: httpx.AsyncClient, seams: Seams) -> None:
    request = {"image_id": "img_3f9a1c2b7d4e5f60", "tutorial_id": "tut_8d1e2f3a4b5c6d7e", "step": 1}
    fixture = load_fixture("image_step")
    calls = seams.returns("app.images.service.step_image", ImageResponse.model_validate(fixture))

    response = await client.post("/v1/images/step", json=request)

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].args == (StepImageRequest.model_validate(request),)


async def test_step_numbers_start_at_one(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns("app.images.service.step_image", None)
    request = {"image_id": "img_3f9a1c2b7d4e5f60", "tutorial_id": "tut_8d1e2f3a4b5c6d7e", "step": 0}
    error = assert_error(await client.post("/v1/images/step", json=request), 422, "bad_request")
    assert error["message"].startswith("'step' is invalid")


async def test_bin_image(client: httpx.AsyncClient, seams: Seams) -> None:
    item = load_fixture("analyze_glass_jar")["analysis"]["items"][0]
    request = {"image_id": "img_3f9a1c2b7d4e5f60", "item": item, "prep_steps": ["Rinse", "Remove the lid"]}
    result = ImageResponse.model_validate(load_fixture("image_after")).model_copy(
        update={"kind": "bin", "url": "/static/generated/img_3f9a1c2b7d4e5f60/bin_item_1.jpg"}
    )
    calls = seams.returns("app.images.service.bin_image", result)

    response = await client.post("/v1/images/bin", json=request)

    assert response.status_code == 200, response.text
    assert response.json()["kind"] == "bin"
    assert calls[0].args == (BinImageRequest.model_validate(request),)


# ----------------------------------------------------------------------------- facilities
async def test_facilities(client: httpx.AsyncClient, seams: Seams) -> None:
    request = {"categories": ["glass"], "city": "abu_dhabi"}
    fixture = load_fixture("facilities_glass")
    calls = seams.returns("app.places.service.search", FacilitiesResponse.model_validate(fixture))

    response = await client.post("/v1/facilities", json=request)

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].args == (FacilitiesRequest.model_validate(request),)
    assert calls[0].args[0].radius_m == 15000


async def test_facilities_need_a_location(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns("app.places.service.search", None)
    response = await client.post("/v1/facilities", json={"categories": ["glass"]})
    error = assert_error(response, 422, "bad_request")
    assert error["message"] == "Provide lat and lng, or a city."


async def test_facility_categories_in_arabic(client: httpx.AsyncClient, seams: Seams) -> None:
    fixture = load_fixture("facility_categories")
    categories = [FacilityCategory.model_validate(c) for c in fixture["categories"]]
    calls = seams.returns("app.places.categories.catalog", categories, sync=True)

    response = await client.get("/v1/facilities/categories", params={"lang": "ar"})

    assert response.status_code == 200, response.text
    assert response.json() == {"categories": fixture["categories"], "lang": "ar"}
    assert calls[0].args == ("ar",)


async def test_facility_categories_default_to_english(client: httpx.AsyncClient, seams: Seams) -> None:
    calls = seams.returns("app.places.categories.catalog", [], sync=True)
    response = await client.get("/v1/facilities/categories")
    assert response.json() == {"categories": [], "lang": "en"}
    assert calls[0].args == ("en",)


async def test_facility_categories_reject_unknown_language(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns("app.places.categories.catalog", [], sync=True)
    response = await client.get("/v1/facilities/categories", params={"lang": "fr"})
    assert assert_error(response, 422, "bad_request")["message"].startswith("'lang' is invalid")


# ---------------------------------------------------------------------------------- swaps
async def test_swaps(client: httpx.AsyncClient, seams: Seams) -> None:
    request = load_fixture("swaps_request")
    fixture = load_fixture("swaps_plastic")
    calls = seams.returns("app.swaps.service.suggest", SwapsResponse.model_validate(fixture))

    response = await client.post("/v1/swaps", json=request)

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].args == (SwapsRequest.model_validate(request),)
