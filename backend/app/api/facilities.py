"""POST /v1/facilities and GET /v1/facilities/categories: nearby drop-off points."""

from typing import Annotated

from fastapi import APIRouter, Query

from app.api.responses import COMMON, error_responses
from app.core.errors import PlacesUnavailable
from app.places import categories, service
from app.schemas.facilities import FacilitiesRequest, FacilitiesResponse, FacilityCategoriesResponse
from app.schemas.vocab import Lang

router = APIRouter(prefix="/facilities", tags=["drop-off"])


@router.post(
    "",
    response_model=FacilitiesResponse,
    summary="Find drop-off points near a location or city",
    responses=error_responses(
        *COMMON,
        overrides={503: ("`places_unavailable`: Google Places and OpenStreetMap both failed.", PlacesUnavailable())},
    ),
)
async def search(req: FacilitiesRequest) -> FacilitiesResponse:
    """Google Places API (New) when a key is configured, OpenStreetMap Overpass otherwise
    (or when Google fails), merged with the team's verified list. Nearest first.

    Place names, addresses and coordinates always come from those sources, never from a model.
    """
    return await service.search(req)


@router.get(
    "/categories",
    response_model=FacilityCategoriesResponse,
    summary="Drop-off category catalog",
    responses=error_responses(*COMMON),
)
async def category_catalog(
    lang: Annotated[Lang, Query(description="Language of the chip labels.")] = "en",
) -> FacilityCategoriesResponse:
    """Every category the Drop-off tab can filter by, with localized labels."""
    return FacilityCategoriesResponse(categories=categories.catalog(lang), lang=lang)
