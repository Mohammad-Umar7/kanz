"""Distances and map links."""

from __future__ import annotations

import math

EARTH_RADIUS_M = 6_371_000.0


def haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Great-circle distance in metres."""
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = p2 - p1
    dl = math.radians(lng2 - lng1)
    h = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * EARTH_RADIUS_M * math.asin(min(1.0, math.sqrt(h)))


def maps_search_url(lat: float, lng: float) -> str:
    """A Google Maps link that opens the coordinates (used when a source has no link of its own)."""
    return f"https://www.google.com/maps/search/?api=1&query={lat:.5f},{lng:.5f}"
