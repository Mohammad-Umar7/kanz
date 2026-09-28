"""Facility search: Google Places (New) + OpenStreetMap Overpass + curated entries, merged.

Public seam:  async def search(req: FacilitiesRequest) -> FacilitiesResponse

Every place comes from one of three real sources, never from a model:

1. Google Places API (New) Text Search, when a Maps key is configured;
2. OpenStreetMap through Overpass, always (keyless, and it adds bins Google lacks);
3. the team's verified ``config/curated_facilities.json``.

Providers run concurrently; one failing only removes its share of the results. The
search fails with ``PlacesUnavailable`` only when Google and Overpass both failed and
no curated point is nearby.
"""

from __future__ import annotations

import asyncio
import json
import logging
import time
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from functools import lru_cache

from app.config import Settings, get_settings
from app.core.errors import BadRequest, PlacesUnavailable
from app.core.timing import stage_timer
from app.places import curated, google, overpass
from app.places.cache import DEFAULT_TTL_S, TtlCache
from app.places.config import get_config
from app.places.merge import merge, select
from app.places.models import Candidate
from app.places.text import t
from app.schemas.common import LatLng
from app.schemas.facilities import FacilitiesRequest, FacilitiesResponse, Place

log = logging.getLogger("kanz.places")

CITIES_FILE = "cities.json"  # copy of contracts/vocab.json cities; see backend/config/README.md
PARTIAL_TTL_S = 60.0  # when a provider failed, retry it sooner
SOURCE_ORDER = ("google", "osm", "curated")

_cache: TtlCache[_Merged] = TtlCache()


@dataclass(frozen=True)
class _Merged:
    candidates: list[Candidate]
    remote_failed: bool  # Google (if configured) and Overpass both failed


@dataclass
class _Outcome:
    source: str
    candidates: list[Candidate]
    error: Exception | None = None


async def search(req: FacilitiesRequest, *, settings: Settings | None = None) -> FacilitiesResponse:
    started = time.perf_counter()
    settings = settings or get_settings()
    keys = _known_keys(req.categories)
    center, center_label = resolve_center(req)
    timings: dict[str, int] = {}

    cache_key = (round(center.lat, 3), round(center.lng, 3), tuple(sorted(keys)), req.lang, req.radius_m)
    merged = _cache.get(cache_key)
    if merged is None:
        merged = await _gather(keys, center, req, settings, timings)
        if merged.candidates or not merged.remote_failed:
            _cache.put(cache_key, merged, ttl_s=PARTIAL_TTL_S if merged.remote_failed else DEFAULT_TTL_S)
    else:
        log.info("facilities cache hit key=%s", cache_key)

    chosen = select(merged.candidates, center.lat, center.lng, req.radius_m, req.limit)
    if merged.remote_failed and not chosen:
        raise PlacesUnavailable(detail="Google Places and Overpass both failed and no curated point is nearby")

    places = [_to_place(c, distance, keys, req.lang) for c, distance in chosen]
    sources_used = [s for s in SOURCE_ORDER if any(s in c.sources for c, _ in chosen)]
    timings["total"] = int((time.perf_counter() - started) * 1000)
    return FacilitiesResponse(
        places=places,
        center=center,
        center_label=center_label,
        sources_used=sources_used,
        notice=_notice(places, sources_used, merged.remote_failed, req, keys),
        timings_ms=timings,
    )


def clear_cache() -> None:
    _cache.clear()


# --------------------------------------------------------------------- steps
def _known_keys(requested: list[str]) -> list[str]:
    categories = get_config().categories
    keys = list(dict.fromkeys(k for k in requested if k in categories))
    unknown = [k for k in requested if k not in categories]
    if unknown:
        log.warning("facilities: ignoring unknown categories %s", unknown)
    if not keys:
        raise BadRequest("We don't know that kind of drop-off point.", detail=f"unknown categories: {unknown}")
    return keys


def resolve_center(req: FacilitiesRequest) -> tuple[LatLng, str]:
    """GPS position when given, else the chosen city's center (the cities of contracts/vocab.json)."""
    if req.lat is not None and req.lng is not None:
        return LatLng(lat=req.lat, lng=req.lng), t("your_location", req.lang)
    city = _cities()[req.city]  # the request validator guarantees a city when there is no position
    return LatLng(lat=city["lat"], lng=city["lng"]), city["ar" if req.lang == "ar" else "en"]


@lru_cache
def _cities() -> dict[str, dict]:
    data = json.loads((get_settings().config_dir / CITIES_FILE).read_text(encoding="utf-8"))
    return {c["id"]: c for c in data["cities"]}


async def _gather(
    keys: list[str], center: LatLng, req: FacilitiesRequest, settings: Settings, timings: dict[str, int]
) -> _Merged:
    common = {"keys": keys, "lat": center.lat, "lng": center.lng, "radius_m": req.radius_m, "lang": req.lang}

    async def curated_nearby() -> list[Candidate]:
        return curated.candidates(keys, req.lang)

    runs = [_run("osm", lambda: overpass.search(**common, settings=settings), timings)]
    if settings.places_google_configured:
        runs.append(_run("google", lambda: google.search(**common, settings=settings), timings))
    runs.append(_run("curated", curated_nearby, timings))
    outcomes = await asyncio.gather(*runs)

    remote = [o for o in outcomes if o.source in ("google", "osm")]
    candidates = [c for o in outcomes for c in o.candidates]
    with stage_timer(timings, "merge"):
        merged = merge(candidates)
    log.info(
        "facilities keys=%s %s merged=%d",
        keys,
        " ".join(f"{o.source}={'error' if o.error else len(o.candidates)}" for o in outcomes),
        len(merged),
    )
    return _Merged(candidates=merged, remote_failed=all(o.error is not None for o in remote))


async def _run(source: str, call: Callable[[], Awaitable[list[Candidate]]], timings: dict[str, int]) -> _Outcome:
    """Run one provider; its failure is recorded, never raised, so the others still count."""
    try:
        with stage_timer(timings, source):
            return _Outcome(source, await call())
    except Exception as exc:
        log.warning("facilities provider=%s failed: %s: %s", source, type(exc).__name__, str(exc)[:200])
        return _Outcome(source, [], exc)


def _to_place(c: Candidate, distance_m: int, keys: list[str], lang: str) -> Place:
    return Place(
        id=c.id,
        name=c.name,
        address=c.address,
        lat=round(c.lat, 6),
        lng=round(c.lng, 6),
        distance_m=distance_m,
        open_now=c.open_now,
        phone=c.phone,
        website=c.website,
        maps_url=c.maps_url,
        facility_types=c.facility_types,
        category_keys=[k for k in keys if k in c.category_keys],
        accepted_materials=c.accepted_materials,
        accepted_note=_accepted_note(c, lang),
        rating=c.rating,
        source=c.source,
    )


def _accepted_note(c: Candidate, lang: str) -> str | None:
    parts = []
    if c.verified_by and c.verified_on:
        parts.append(t("verified", lang, who=c.verified_by, date=c.verified_on.isoformat()))
    if c.charity_bin:
        parts.append(t("charity_bin", lang))
    if c.unlisted and not c.accepted_materials and c.sources == {"osm"}:
        parts.append(t("unlisted", lang))
    if c.hours:
        parts.append(t("hours", lang, value=c.hours))
    return " ".join(parts) or None


def _notice(
    places: list[Place], sources_used: list[str], remote_failed: bool, req: FacilitiesRequest, keys: list[str]
) -> str | None:
    if not places:
        categories = get_config().categories
        hints = [h.get(req.lang) for k in keys if (h := categories[k].empty_hint)]
        return " ".join([t("notice_none", req.lang, km=f"{req.radius_m / 1000:g}"), *hints])
    if remote_failed:
        return t("notice_curated_only", req.lang)
    if "osm" in sources_used and "google" not in sources_used:
        return t("notice_osm_only", req.lang)
    return None
