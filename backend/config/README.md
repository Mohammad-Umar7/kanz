# backend/config

Data files that drive the drop-off finder. They are read by `app/places/` at first use and validated on load, so a typo shows up as a clear error in the log and in `pytest`, not as an empty map.

| File | What it is |
| --- | --- |
| `facility_categories.json` | The one mapping from what Kanz recognizes (material, hazards, condition) to kinds of drop-off points, plus how each kind is searched on Google Places and OpenStreetMap |
| `curated_facilities.json` | Drop-off points the team has verified. Ships as an empty list |
| `curated_facilities.schema.json` | JSON Schema for the curated entries (editors such as VS Code validate against it) |

## facility_categories.json

`categories.<key>` defines one kind of drop-off point (the key is what the app sends to `POST /v1/facilities`):

- `labels`: chip label in English and Arabic.
- `facility_types`, `material_categories`: ids from `contracts/vocab.json`. The first facility type is what a Google result found by this category is shown as.
- `google_queries`: Text Search queries per language. Arabic searches also send the first English query, because many UAE listings are named in English.
- `osm.filters`: OpenStreetMap tag filters. A value is matched exactly, `"*"` means "any value", and `"~pattern"` is a case-insensitive regular expression. Keep regular expressions to keys with few distinct values (such as `waste`): a regex on `name` makes Overpass scan every name it stores. `facility_type` sets what a matching place is shown as.
- `osm.include_unlisted`: also offer recycling containers that do not say what they accept. Most containers in UAE OpenStreetMap data are mapped this way; the app marks them "accepted materials aren't listed".

`routing` decides which categories a scanned item needs:

1. A disposal-only hazard (battery, e-waste, chemical, aerosol, medicine, light bulb, broken glass) decides alone, through `by_hazard`.
2. Otherwise the first `by_condition` rule that matches decides (for example, a textile in fair condition or better goes to clothes donation first).
3. Otherwise `by_material` decides.
4. Every matching `extras` rule adds its keys (a reusable wooden or household item in good condition can also be donated).

Rule conditions (`when`) can use `category`, `min_quality`, `no_hazards`, `reuse_level` and `is_raw_material`.

`osm.material_tags` maps `recycling:<suffix>=yes` tags to material categories (shown as "accepts glass, paper"). `osm.known_operators` reads a bin named after a known clothing charity as a clothes bin when the bin lists no materials itself.

## Adding a verified drop-off point

Only add places you have checked in person or confirmed with the operator. Never copy entries from another app or website.

1. Open `curated_facilities.json` and add an object to the list. Fields:

   | Field | Required | Notes |
   | --- | --- | --- |
   | `id` | yes | Lowercase, stable, e.g. `<city>_<area>_<kind>`. Returned to the app as `cur:<id>` |
   | `name`, `name_ar` | `name` | As written on site; `name_ar` if the site shows an Arabic name |
   | `lat`, `lng` | yes | From the pin you dropped on site (Google Maps: long-press, copy the numbers) |
   | `address`, `city` | no | `city` is a city id from `contracts/vocab.json` |
   | `facility_types` | yes | Ids from `contracts/vocab.json` |
   | `category_keys` | yes | Keys from `facility_categories.json` this point serves |
   | `accepted_materials` | no | Only what the site itself says it accepts |
   | `phone`, `website` | no | `+971 ...`; `https://...` |
   | `verified_by`, `verified_on` | yes | Who checked it and when (`YYYY-MM-DD`, not in the future) |

   The shape of one entry (angle brackets mark what you fill in):

   ```json
   {
     "id": "<city>_<area>_clothes_bin",
     "name": "<name as shown on site>",
     "name_ar": null,
     "lat": 0.0,
     "lng": 0.0,
     "address": "<building, street, area>",
     "city": "<city id>",
     "facility_types": ["donation", "collection_point"],
     "category_keys": ["textile_donation", "textile_recycling"],
     "accepted_materials": ["textile"],
     "phone": null,
     "website": null,
     "verified_by": "<your name or initials>",
     "verified_on": "<YYYY-MM-DD>"
   }
   ```

2. Check the file: `cd backend && .venv/Scripts/python -m app.places.curated`. It prints `REJECTED` with a reason for any invalid entry and exits non-zero.
3. Run `pytest tests/places` and commit the file on its own (`feat(places): add verified drop-off point in <area>`).

Curated points appear in results with `source: "curated"` and a "Checked by ... on ..." note. When Google or OpenStreetMap lists the same place (within about 40 m), the entries are merged: Google's live details (opening status, rating) win, curated details fill in the rest.
