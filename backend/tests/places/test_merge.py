"""Duplicate merging across providers, radius filtering and ordering."""

from datetime import date

from app.places.geo import haversine_m
from app.places.merge import merge, names_similar, select
from app.places.models import Candidate

LAT, LNG = 24.4539, 54.3773


def cand(cid, source, name, lat, lng, **kw) -> Candidate:
    kw.setdefault("category_keys", ["glass"])
    kw.setdefault("facility_types", ["collection_point"])
    return Candidate(id=cid, source=source, name=name, lat=lat, lng=lng, **kw)


def north(metres: float) -> float:
    """The latitude a given number of metres north of LAT."""
    return LAT + metres / 111_195


def test_haversine_is_accurate_for_short_distances():
    assert abs(haversine_m(LAT, LNG, north(1000), LNG) - 1000) < 1


def test_google_and_osm_at_the_same_spot_merge_with_google_fields_winning():
    g = cand("g:1", "google", "Synthetic Recycling Hub", north(20), LNG, open_now=True, rating=4.1, maps_url="g-link")
    o = cand(
        "osm:node/1",
        "osm",
        "Recycling point",
        LAT,
        LNG,
        generic_name=True,
        accepted_materials=["glass"],
        hours="24/7",
        category_keys=["glass", "paper"],
        maps_url="osm-link",
    )
    [m] = merge([o, g])
    assert m.id == "g:1"
    assert m.source == "google"
    assert m.name == "Synthetic Recycling Hub"
    assert (m.open_now, m.rating, m.maps_url) == (True, 4.1, "g-link")
    assert m.accepted_materials == ["glass"]
    assert m.hours == "24/7"
    assert m.category_keys == ["glass", "paper"]
    assert m.sources == {"google", "osm"}


def test_different_named_places_close_together_stay_separate():
    a = cand("g:1", "google", "Synthetic Charity Shop", LAT, LNG)
    b = cand("g:2", "google", "Synthetic Glass Depot", north(30), LNG)
    assert len(merge([a, b])) == 2


def test_same_name_within_150_m_merges():
    a = cand("osm:node/1", "osm", "Make-A-Wish", LAT, LNG)
    b = cand("osm:node/2", "osm", "Make a wish", north(120), LNG)
    c = cand("osm:node/3", "osm", "Make a wish", north(400), LNG)
    assert len(merge([a, b, c])) == 2


def test_generic_labels_merge_only_at_the_same_spot():
    a = cand("osm:node/1", "osm", "Recycling point", LAT, LNG, generic_name=True, unlisted=True)
    b = cand("osm:node/2", "osm", "Recycling point", north(25), LNG, generic_name=True, accepted_materials=["plastic"])
    c = cand("osm:node/3", "osm", "Recycling point", north(100), LNG, generic_name=True)
    merged = merge([a, b, c])
    assert len(merged) == 2
    first = next(m for m in merged if m.id == "osm:node/1")
    assert first.unlisted is False  # one of the bins at the spot says what it takes
    assert first.accepted_materials == ["plastic"]


def test_curated_outranks_osm():
    o = cand("osm:node/1", "osm", "Synthetic Bin", LAT, LNG)
    c = cand("cur:bin", "curated", "Synthetic Bin", north(10), LNG, verified_by="QA", verified_on=date(2026, 9, 1))
    [m] = merge([o, c])
    assert m.source == "curated"
    assert m.verified_by == "QA"
    assert m.sources == {"curated", "osm"}


def test_names_similar():
    assert names_similar("Emirates Red Crescent", "Emirates Red Crescent clothes bin")
    assert names_similar("Make-A-Wish", "make a wish")
    assert not names_similar("Synthetic Charity Shop", "Synthetic Glass Depot")


def test_select_filters_radius_sorts_nearest_first_and_limits():
    cands = [
        cand("a", "osm", "A", north(3000), LNG),
        cand("b", "osm", "B", north(500), LNG),
        cand("c", "osm", "C", north(20000), LNG),
        cand("d", "osm", "D", north(1500), LNG),
    ]
    chosen = select(cands, LAT, LNG, radius_m=5000, limit=2)
    assert [(c.id, d) for c, d in chosen] == [("b", 500), ("d", 1500)]


def test_points_that_state_materials_win_limited_slots_but_order_stays_by_distance():
    cands = [
        cand("near-unlisted-1", "osm", "Recycling point", north(100), LNG, unlisted=True, generic_name=True),
        cand("near-unlisted-2", "osm", "Recycling point", north(200), LNG, unlisted=True, generic_name=True),
        cand("far-listed", "osm", "Glass bank", north(3000), LNG, accepted_materials=["glass"]),
    ]
    chosen = select(cands, LAT, LNG, radius_m=5000, limit=2)
    assert [c.id for c, _ in chosen] == ["near-unlisted-1", "far-listed"]
