"""Google Places API (New) Text Search provider. Skipped entirely when no Maps key is configured.

Docs: https://developers.google.com/maps/documentation/places/web-service/text-search

Each requested category contributes its text queries from the config ("glass recycling",
"clothes donation box", ...), biased to a circle around the center. Text Search is
billed by the richest field in the field mask, so the mask lists only what the app
shows on a place card.
"""

from __future__ import annotations

import asyncio
import logging

import httpx

from app.config import Settings, get_settings
from app.places.config import FacilityConfig, get_config
from app.places.models import Candidate, ProviderError

log = logging.getLogger("kanz.places.google")

SEARCH_URL = "https://places.googleapis.com/v1/places:searchText"
FIELD_MASK = ",".join(
    [
        "places.id",
        "places.displayName",
        "places.formattedAddress",
        "places.location",
        "places.currentOpeningHours.openNow",
        "places.internationalPhoneNumber",
        "places.websiteUri",
        "places.googleMapsUri",
        "places.rating",
        "places.businessStatus",
    ]
)
MAX_REQUESTS = 6  # per search, across all categories
MAX_BIAS_RADIUS_M = 50_000  # the API's limit for a locationBias circle
PAGE_SIZE = 20  # the API's maximum per page


def plan_queries(keys: list[str], lang: str, cfg: FacilityConfig) -> list[tuple[str, str]]:
    """``(category key, text query)`` pairs, round-robin so every category gets its best query first.

    Arabic searches also send the English query, because many UAE listings are named in English.
    """
    per_key: list[list[str]] = []
    for key in keys:
        queries = cfg.categories[key].google_queries
        chosen = list(queries.get(lang))
        if lang == "ar":
            chosen.append(queries.en[0])
        per_key.append(list(dict.fromkeys(chosen)))
    plan: list[tuple[str, str]] = []
    for rank in range(max((len(q) for q in per_key), default=0)):
        for key, queries in zip(keys, per_key, strict=True):
            if rank < len(queries):
                plan.append((key, queries[rank]))
    return plan[:MAX_REQUESTS]


def parse_places(data: dict, key: str, cfg: FacilityConfig) -> list[Candidate]:
    """Candidates from one Text Search response, tagged with the category whose query found them."""
    out: list[Candidate] = []
    facility_type = cfg.categories[key].facility_types[0]
    for p in data.get("places", []):
        loc = p.get("location") or {}
        name = (p.get("displayName") or {}).get("text")
        if not p.get("id") or not name or "latitude" not in loc or "longitude" not in loc:
            continue
        if p.get("businessStatus") == "CLOSED_PERMANENTLY":
            continue
        out.append(
            Candidate(
                id=f"g:{p['id']}",
                source="google",
                name=name,
                lat=float(loc["latitude"]),
                lng=float(loc["longitude"]),
                category_keys=[key],
                facility_types=[facility_type],
                address=p.get("formattedAddress"),
                open_now=(p.get("currentOpeningHours") or {}).get("openNow"),
                phone=p.get("internationalPhoneNumber"),
                website=p.get("websiteUri"),
                maps_url=p.get("googleMapsUri"),
                rating=p.get("rating"),
            )
        )
    return out


async def search(
    *,
    keys: list[str],
    lat: float,
    lng: float,
    radius_m: int,
    lang: str,
    settings: Settings | None = None,
    cfg: FacilityConfig | None = None,
) -> list[Candidate]:
    """Run the planned queries concurrently. Raises ``ProviderError`` only if all of them fail."""
    settings = settings or get_settings()
    cfg = cfg or get_config()
    if not settings.places_google_configured:
        raise ProviderError("Google Maps key is not configured")
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": settings.google_maps_api_key,
        "X-Goog-FieldMask": FIELD_MASK,
    }
    plan = plan_queries(keys, lang, cfg)

    async with httpx.AsyncClient(headers=headers, timeout=settings.places_timeout_s) as client:

        async def run(key: str, query: str) -> list[Candidate]:
            body = {
                "textQuery": query,
                "languageCode": lang,
                "pageSize": PAGE_SIZE,
                "locationBias": {
                    "circle": {
                        "center": {"latitude": lat, "longitude": lng},
                        "radius": float(min(radius_m, MAX_BIAS_RADIUS_M)),
                    }
                },
            }
            resp = await client.post(SEARCH_URL, json=body)
            if resp.status_code != 200:
                # The error body can echo request details, so only the status is logged.
                raise ProviderError(f"HTTP {resp.status_code} for query {query!r}")
            return parse_places(resp.json(), key, cfg)

        results = await asyncio.gather(*(run(k, q) for k, q in plan), return_exceptions=True)

    failures = [r for r in results if isinstance(r, BaseException)]
    for failure in failures:
        log.warning("google places query failed: %s", type(failure).__name__ + ": " + str(failure)[:160])
    if failures and len(failures) == len(results):
        raise ProviderError(f"all {len(results)} Google queries failed")

    by_id: dict[str, Candidate] = {}
    for batch in results:
        if isinstance(batch, BaseException):
            continue
        for cand in batch:
            seen = by_id.get(cand.id)
            if seen is None:
                by_id[cand.id] = cand
            else:  # the same place found by another category's query
                seen.category_keys = list(dict.fromkeys(seen.category_keys + cand.category_keys))
                seen.facility_types = list(dict.fromkeys(seen.facility_types + cand.facility_types))
    log.info("google places queries=%d places=%d", len(plan), len(by_id))
    return list(by_id.values())
