"""Drop-off finder: where each scanned item can go, and the nearest places that take it.

    config.py      loads backend/config/facility_categories.json (the one mapping file)
    categories.py  items -> drop-off categories (hazard, condition and material rules)
    google.py      Google Places API (New) Text Search, when a Maps key is configured
    overpass.py    OpenStreetMap through Overpass (keyless, always queried)
    curated.py     team-verified points from backend/config/curated_facilities.json
    merge.py       duplicate merging across sources, radius filter, nearest first
    service.py     the search seam: providers in parallel, cache, notices, errors

Places always come from those three sources; nothing about a place is generated.
"""
