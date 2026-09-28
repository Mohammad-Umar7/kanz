"""OpenStreetMap drop-off points through the Overpass API (keyless; always queried).

One combined Overpass QL query per search asks for every requested category's tag
filters around the center. The response is then matched back to categories locally,
so each point knows which of the requested categories it serves.

OpenStreetMap data in the UAE is uneven: most recycling containers are mapped without
saying what they take, and many charity clothing bins only carry the charity's name.
Two config switches handle that honestly:

* ``include_unlisted`` offers such containers for material categories, flagged so
  the app says "accepted materials aren't listed" and so that points which do state
  their materials win the limited result slots.
* ``known_operators`` reads a bin named after a known clothing charity as a clothes
  bin when the feature lists no materials itself.

Names are never invented: an unnamed feature gets a generic, localized label such as
"Recycling point", optionally followed by the operator OpenStreetMap records.
"""

from __future__ import annotations

import json
import logging
import re
import time

import httpx

from app.config import Settings, get_settings
from app.places.config import FacilityConfig, KnownOperator, OsmFilter, get_config
from app.places.geo import maps_search_url
from app.places.models import Candidate, ProviderError
from app.places.text import t
from app.schemas.vocab import MATERIAL_CATEGORIES

log = logging.getLogger("kanz.places.osm")

USER_AGENT = "Kanz/1.0 (student project)"
# Public instances, tried in order when one is busy (429/504 are common at peak times).
MIRRORS = (
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
)
RECYCLING = {"amenity": "recycling"}
# Tags that can carry a bin's name or its operator (many UAE nodes only have name:en).
LABEL_TAGS = ("name", "name:en", "name:ar", "operator", "brand")


# --------------------------------------------------------------------- query
def build_query(keys: list[str], lat: float, lng: float, radius_m: int, *, timeout_s: int, cfg: FacilityConfig) -> str:
    """One union query for all requested categories; ``out tags center`` gives ways a center point."""
    selectors: list[dict[str, str]] = []
    wants_unlisted = any(cfg.categories[k].osm.include_unlisted for k in keys)
    if wants_unlisted:
        selectors.append(RECYCLING)  # every recycling point; categories are matched locally afterwards
    for key in keys:
        for f in cfg.categories[key].osm.filters:
            if not (wants_unlisted and f.tags.get("amenity") == "recycling"):
                selectors.append(f.tags)
    if not wants_unlisted:
        for op in _operators_for(keys, cfg):
            selectors += [{**RECYCLING, tag: f"~{op.pattern}"} for tag in ("name", "name:en", "operator")]

    around = f"(around:{radius_m},{lat:.6f},{lng:.6f})"
    lines = [f"  nw{_selector(tags)}{around};" for tags in _unique(selectors)]
    return f"[out:json][timeout:{timeout_s}];\n(\n" + "\n".join(lines) + "\n);\nout tags center;"


def _selector(tags: dict[str, str]) -> str:
    parts = []
    for key, value in tags.items():
        if value == "*":
            parts.append(f"[{_q(key)}]")
        elif value.startswith("~"):
            parts.append(f"[{_q(key)}~{_q(value[1:])},i]")
        else:
            parts.append(f"[{_q(key)}={_q(value)}]")
    return "".join(parts)


def _q(text: str) -> str:
    return json.dumps(text, ensure_ascii=False)


def _unique(selectors: list[dict[str, str]]) -> list[dict[str, str]]:
    seen: dict[tuple, dict[str, str]] = {}
    for s in selectors:
        seen.setdefault(tuple(sorted(s.items())), s)
    return list(seen.values())


def _operators_for(keys: list[str], cfg: FacilityConfig) -> list[KnownOperator]:
    """Known operators whose implied tags matter for the requested categories."""
    wanted_tags = {tag for k in keys for f in cfg.categories[k].osm.filters for tag in f.tags}
    return [op for op in cfg.osm.known_operators if wanted_tags & set(op.implies)]


# --------------------------------------------------------------------- parsing
def parse_elements(data: dict, keys: list[str], lang: str, cfg: FacilityConfig) -> list[Candidate]:
    """Turn Overpass ``elements`` into candidates for the requested categories (others are dropped)."""
    suffix_material = cfg.material_for_osm_suffix()
    out: list[Candidate] = []
    for el in data.get("elements", []):
        cand = _to_candidate(el, keys, lang, cfg, suffix_material)
        if cand is not None:
            out.append(cand)
    return out


def _to_candidate(
    el: dict, keys: list[str], lang: str, cfg: FacilityConfig, suffix_material: dict[str, str]
) -> Candidate | None:
    tags: dict[str, str] = el.get("tags") or {}
    lat = el.get("lat", (el.get("center") or {}).get("lat"))
    lng = el.get("lon", (el.get("center") or {}).get("lon"))
    if lat is None or lng is None or not tags:
        return None

    effective, operator_rule = _effective_tags(tags, cfg)
    is_recycling = tags.get("amenity") == "recycling"
    unlisted = is_recycling and not _listed_suffixes(effective)

    category_keys: list[str] = []
    facility_types: list[str] = []
    if is_recycling:
        facility_types.append("recycling_center" if tags.get("recycling_type") == "centre" else "collection_point")
    for key in keys:
        cat = cfg.categories[key]
        matched = [f for f in cat.osm.filters if _filter_matches(f, effective)]
        if matched:
            category_keys.append(key)
            for f in matched:
                if f.facility_type:
                    facility_types.append(f.facility_type)
                elif not is_recycling:  # e.g. a shop: no recycling_type to read, so use the category's main type
                    facility_types.append(cat.facility_types[0])
        elif unlisted and cat.osm.include_unlisted:
            category_keys.append(key)
    if not category_keys:
        return None

    # accepted_materials only reports what the source itself states (not what we inferred).
    stated = {suffix_material[s] for s in _listed_suffixes(tags) if s in suffix_material}
    accepted = [m for m in MATERIAL_CATEGORIES if m in stated] or None
    effective_materials = {suffix_material[s] for s in _listed_suffixes(effective) if s in suffix_material}

    own_name = _own_name(tags, lang)
    if own_name:
        name, generic = own_name, False
    else:
        name = t(_generic_kind(tags, effective, effective_materials), lang)
        if operator := (tags.get("operator") or tags.get("brand")):
            name = f"{name} · {operator}"
        generic = True

    osm_type = el.get("type", "node")
    return Candidate(
        id=f"osm:{osm_type}/{el.get('id')}",
        source="osm",
        name=name,
        lat=float(lat),
        lng=float(lng),
        category_keys=category_keys,
        facility_types=list(dict.fromkeys(facility_types)),
        address=_address(tags),
        phone=tags.get("phone") or tags.get("contact:phone"),
        website=tags.get("website") or tags.get("contact:website") or tags.get("url"),
        maps_url=maps_search_url(float(lat), float(lng)),
        accepted_materials=accepted,
        generic_name=generic,
        unlisted=unlisted,
        charity_bin=operator_rule is not None,
        hours=tags.get("opening_hours"),
    )


def _effective_tags(tags: dict[str, str], cfg: FacilityConfig) -> tuple[dict[str, str], KnownOperator | None]:
    """Tags plus what a known operator implies, for recycling points that list no materials."""
    if tags.get("amenity") != "recycling" or _listed_suffixes(tags):
        return tags, None
    label = " ".join(tags[k] for k in LABEL_TAGS if tags.get(k))
    for op in cfg.osm.known_operators:
        if label and re.search(op.pattern, label, re.IGNORECASE):
            return {**tags, **op.implies}, op
    return tags, None


def _listed_suffixes(tags: dict[str, str]) -> list[str]:
    """``recycling:<suffix>=yes`` suffixes (the materials a point says it accepts)."""
    return [k.split(":", 1)[1] for k, v in tags.items() if k.startswith("recycling:") and v == "yes"]


def _filter_matches(f: OsmFilter, tags: dict[str, str]) -> bool:
    return all(_tag_matches(tags.get(key), expected) for key, expected in f.tags.items())


def _tag_matches(value: str | None, expected: str) -> bool:
    if value is None:
        return False
    if expected == "*":
        return True
    if expected.startswith("~"):
        return re.search(expected[1:], value, re.IGNORECASE) is not None
    return value == expected


def _own_name(tags: dict[str, str], lang: str) -> str | None:
    """The feature's own name, preferring the request language, then the default, then English."""
    for key in (f"name:{lang}", "name", "name:en"):
        if value := tags.get(key, "").strip():
            return value
    return None


def _generic_kind(tags: dict[str, str], effective: dict[str, str], materials: set[str]) -> str:
    """Which generic label fits an unnamed feature."""
    if tags.get("shop") == "charity":
        return "charity_shop"
    if tags.get("shop") == "second_hand":
        return "second_hand"
    if tags.get("amenity") == "give_box":
        return "give_box"
    if tags.get("industrial") == "scrap_yard":
        return "scrap_yard"
    if tags.get("amenity") == "waste_disposal":
        return "hazardous_point"
    if tags.get("recycling_type") == "centre":
        return "recycling_center"
    if materials and materials <= {"textile"}:
        return "clothes_point"
    if materials and materials <= {"hazardous"} and effective.get("recycling:batteries") == "yes":
        return "battery_point"
    if materials and materials <= {"electronics", "hazardous"}:
        return "ewaste_point"
    return "recycling_point"


def _address(tags: dict[str, str]) -> str | None:
    if tags.get("addr:full"):
        return tags["addr:full"]
    street = " ".join(v for v in (tags.get("addr:housenumber"), tags.get("addr:street")) if v)
    area = tags.get("addr:suburb") or tags.get("addr:district") or tags.get("addr:neighbourhood")
    parts = [p for p in (street, area, tags.get("addr:city")) if p]
    return ", ".join(parts) or None


# --------------------------------------------------------------------- network
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
    """Query Overpass (mirror by mirror) and parse the result. Raises ``ProviderError`` if every mirror fails."""
    settings = settings or get_settings()
    cfg = cfg or get_config()
    per_try = settings.places_timeout_s
    query = build_query(keys, lat, lng, radius_m, timeout_s=int(per_try), cfg=cfg)
    deadline = time.monotonic() + per_try * 1.5  # room for one quick failover, not two full timeouts
    errors: list[str] = []

    async with httpx.AsyncClient(headers={"User-Agent": USER_AGENT}) as client:
        for url in _mirrors(settings):
            remaining = deadline - time.monotonic()
            if remaining < 2:
                errors.append(f"{url}: skipped, time budget used")
                break
            try:
                resp = await client.post(url, data={"data": query}, timeout=min(per_try, remaining))
            except httpx.HTTPError as exc:
                errors.append(f"{url}: {type(exc).__name__}")
                continue
            if resp.status_code != 200:
                errors.append(f"{url}: HTTP {resp.status_code}")
                continue
            try:
                data = resp.json()
            except ValueError:
                errors.append(f"{url}: body is not JSON")
                continue
            remark = str(data.get("remark", ""))
            if "error" in remark.lower():  # Overpass reports server-side timeouts as a 200 with a remark
                errors.append(f"{url}: {remark[:120]}")
                continue
            places = parse_elements(data, keys, lang, cfg)
            log.info("overpass url=%s elements=%d places=%d", url, len(data.get("elements", [])), len(places))
            return places
    log.warning("overpass failed: %s", "; ".join(errors))
    raise ProviderError("; ".join(errors))


def _mirrors(settings: Settings) -> list[str]:
    return list(dict.fromkeys([settings.overpass_url, *MIRRORS]))
