"""Merge duplicates across providers, then pick and order the points to show.

The same recycling centre often appears in Google and in OpenStreetMap, and several
bins at one car park are mapped as separate nodes. Two candidates are the same place
when they are within ``SAME_SPOT_M`` and their names do not contradict each other (one
is a generic label, or the names are similar), or when they carry the same name within
``SAME_NAME_M``. Fields are taken by source priority google > curated > osm: live Google
details win, the curated file fills gaps, OpenStreetMap fills the rest.
"""

from __future__ import annotations

import math
import re
from collections import defaultdict
from dataclasses import replace

from app.places.geo import haversine_m
from app.places.models import Candidate

SOURCE_PRIORITY = {"google": 0, "curated": 1, "osm": 2}
SAME_SPOT_M = 40.0
SAME_NAME_M = 150.0
# Grid cell in degrees: larger than SAME_NAME_M up to about 60 degrees of latitude, so any two
# duplicates sit in the same or neighbouring cells and only those are compared.
_CELL_DEG = 0.003


def normalize_name(name: str) -> str:
    """Casefold and drop punctuation and spaces: 'Make-A-Wish' == 'make a wish'."""
    return re.sub(r"[\W_]+", "", name.casefold())


def names_similar(a: str, b: str) -> bool:
    na, nb = normalize_name(a), normalize_name(b)
    if not na or not nb:
        return False
    if na == nb or (min(len(na), len(nb)) >= 4 and (na in nb or nb in na)):
        return True
    ta, tb = set(re.findall(r"\w+", a.casefold())), set(re.findall(r"\w+", b.casefold()))
    return bool(ta and tb) and len(ta & tb) / len(ta | tb) >= 0.5


def same_place(a: Candidate, b: Candidate) -> bool:
    distance = haversine_m(a.lat, a.lng, b.lat, b.lng)
    if distance <= SAME_SPOT_M and (a.generic_name or b.generic_name or names_similar(a.name, b.name)):
        return True
    if a.generic_name and b.generic_name:
        return False  # two unnamed bins further apart are two separate points
    return distance <= SAME_NAME_M and normalize_name(a.name) == normalize_name(b.name)


def merge(candidates: list[Candidate]) -> list[Candidate]:
    """Collapse duplicates. Higher-priority sources are placed first so they own the merged record."""
    ordered = sorted(candidates, key=lambda c: SOURCE_PRIORITY[c.source])
    merged: list[Candidate] = []
    grid: dict[tuple[int, int], list[int]] = defaultdict(list)
    for cand in ordered:
        cell = _cell(cand)
        match = next(
            (
                i
                for dx in (-1, 0, 1)
                for dy in (-1, 0, 1)
                for i in grid[(cell[0] + dx, cell[1] + dy)]
                if same_place(merged[i], cand)
            ),
            None,
        )
        if match is None:
            grid[cell].append(len(merged))
            merged.append(replace(cand, sources=set(cand.sources)))
        else:
            _absorb(merged[match], cand)
    return merged


def select(
    candidates: list[Candidate], lat: float, lng: float, radius_m: int, limit: int
) -> list[tuple[Candidate, int]]:
    """Points within the radius, nearest first, at most ``limit``.

    When there are more points than slots, places that state what they accept (and every
    Google or curated place) take the slots before unlisted OpenStreetMap containers.
    """
    within = []
    for c in candidates:
        d = haversine_m(lat, lng, c.lat, c.lng)
        if d <= radius_m:
            within.append((c, round(d)))
    chosen = sorted(within, key=lambda cd: (cd[0].unlisted, cd[1]))[:limit]
    return sorted(chosen, key=lambda cd: cd[1])


def _cell(c: Candidate) -> tuple[int, int]:
    return math.floor(c.lat / _CELL_DEG), math.floor(c.lng / _CELL_DEG)


def _absorb(target: Candidate, other: Candidate) -> None:
    """Fold ``other`` into ``target`` (which has equal or higher source priority)."""
    if target.generic_name and not other.generic_name:
        target.name, target.generic_name = other.name, False
    for attr in ("address", "open_now", "phone", "website", "rating", "hours", "verified_by", "verified_on"):
        if getattr(target, attr) is None:
            setattr(target, attr, getattr(other, attr))
    if target.maps_url is None:
        target.maps_url = other.maps_url
    target.category_keys = list(dict.fromkeys(target.category_keys + other.category_keys))
    target.facility_types = list(dict.fromkeys(target.facility_types + other.facility_types))
    if other.accepted_materials:
        combined = (target.accepted_materials or []) + other.accepted_materials
        target.accepted_materials = list(dict.fromkeys(combined))
    target.unlisted = target.unlisted and other.unlisted
    target.charity_bin = target.charity_bin or other.charity_bin
    target.sources |= other.sources
