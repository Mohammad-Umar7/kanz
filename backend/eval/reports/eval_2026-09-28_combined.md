# Kanz eval: 2026-09-28 (combined)

Models: vision `gemini-3.1-flash-lite`, text `gemini-3.1-flash-lite`, embeddings `gemini-embedding-001`. Prompts: disposal_advisor v1, donation_advisor v1, material_analyst v2, recycling_advisor v1, swap_advisor v1, tutorial_writer v1, upcycle_designer v1. Language: en. Knowledge index: 128 documents, vector (Chroma).

## Summary

| Metric | Value |
| --- | --- |
| photos | 21 |
| errors | 0 |
| passed | 21/21 (100%) |
| category accuracy | 20/20 (100%) |
| category any item | 20/20 (100%) |
| hazard accuracy | 20/20 (100%) |
| item count ok | 20/20 (100%) |
| unclear detected | 1/1 (100%) |
| analysis ms p50 | 7555 |
| analysis ms p90 | 17286 |
| total ms p50 | 7613 |
| total ms p90 | 17309 |
| recommend total ms | [8212, 6138, 12535] |

Category accuracy uses the focus (primary) item; for hazardous photos the hazardous item counts, because
the focus item is deliberately chosen among the safe ones. Hazard accuracy asks whether a disposal-only
hazard was flagged exactly when one was expected.

## Per photo

| Photo | Expected | Predicted | Items | Hazards flagged | Category | Hazard | Top conf. | Usable | Analysis ms | Total ms | Model | Run |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| glass_jar.jpg | glass | glass | Glass mason jar; Metal lid | - | yes | yes | 1.0 | yes | 4847 | 4898 | gemini-3.1-flash-lite | rerun |
| glass_bottle.jpg | glass | glass | Glass wine bottle; Metal screw cap | - | yes | yes | 1.0 | yes | 7629 | 7683 | gemini-3.1-flash-lite | first |
| pet_bottle.jpg | plastic | plastic | PET water bottle | - | yes | yes | 1.0 | yes | 4416 | 4454 | gemini-3.1-flash-lite | first |
| plastic_container.jpg | plastic | plastic | Plastic food container | - | yes | yes | 1.0 | yes | 4692 | 4737 | gemini-3.1-flash-lite | rerun |
| aluminum_can.jpg | metal | metal | Aluminium soda can | - | yes | yes | 1.0 | yes | 38113 | 38154 | gemini-3.1-flash-lite | first |
| tin_can.jpg | metal | metal | Empty food can | - | yes | yes | 1.0 | yes | 3048 | 3072 | gemini-3.1-flash-lite | rerun |
| aa_batteries.jpg | hazardous + hazard | hazardous | Rechargeable AA batteries | battery | yes | yes | 1.0 | yes | 4285 | 4307 | gemini-3.1-flash-lite | rerun |
| old_tshirt.jpg | textile | textile | Green cotton t-shirt | - | yes | yes | 1.0 | yes | 13845 | 13884 | gemini-3.1-flash-lite | rerun |
| denim_jeans.jpg | textile | textile | Blue denim jeans | - | yes | yes | 1.0 | yes | 7555 | 7613 | gemini-3.1-flash-lite | rerun |
| wooden_crate.jpg | wood | wood | Wooden crates | - | yes | yes | 1.0 | yes | 16250 | 16288 | gemini-3.1-flash-lite | rerun |
| wooden_pallet.jpg | wood | wood | Wooden shipping pallet; Leather work glove | sharp_edges | yes | yes | 1.0 | yes | 10978 | 11003 | gemini-3.1-flash-lite | first |
| cardboard_box.jpg | paper | paper | Corrugated cardboard box | - | yes | yes | 1.0 | yes | 17286 | 17309 | gemini-3.1-flash-lite | rerun |
| newspapers.jpg | paper | paper | Newspaper stack | - | yes | yes | 1.0 | yes | 4016 | 4045 | gemini-3.1-flash-lite | rerun |
| light_bulb.jpg | hazardous + hazard | hazardous | Incandescent light bulb | light_bulb | yes | yes | 1.0 | yes | 5851 | 5873 | gemini-3.1-flash-lite | first |
| aerosol_can.jpg | hazardous + hazard | hazardous | Aerosol contact cleaner | aerosol, chemical | yes | yes | 1.0 | yes | 12640 | 12676 | gemini-3.1-flash-lite | first |
| fabric_scraps.jpg | textile | textile | Fabric scraps | - | yes | yes | 0.95 | yes | 7807 | 7835 | gemini-3.1-flash-lite | rerun |
| bottle_caps.jpg | plastic | plastic | Plastic bottle caps | - | yes | yes | 1.0 | yes | 6292 | 6336 | gemini-3.1-flash-lite | rerun |
| smartphone_old.jpg | electronics + hazard | electronics | Wiko smartphone | battery, broken_glass, e_waste | yes | yes | 1.0 | yes | 5762 | 5802 | gemini-3.1-flash-lite | first |
| medicine_blister.jpg | hazardous + hazard | hazardous | Birth control pill blister pack | medicine | yes | yes | 1.0 | yes | 23225 | 23302 | gemini-3.1-flash-lite | rerun |
| mixed_recyclables.jpg | plastic | plastic | Plastic milk bottles; Mixed plastic packaging | - | yes | yes | 0.95 | yes | 13829 | 13880 | gemini-3.1-flash-lite | rerun |
| unclear_blurry.jpg | glass (unclear) | - | - | - | - | - | - | no | 2837 | 2853 | gemini-3.1-flash-lite | rerun |

## Recommend

### glass_jar.jpg

- Mode: `diy`; donate available: True
- Ideas: Painted desk organizer (easy; sources: proj_glass_painted_jar); Labelled pantry storage (easy; sources: proj_glass_jar_pantry_storage); Hanging jar lantern (easy; sources: proj_glass_jar_lantern)
- Recycle streams: Glass bottle bank; Metal recycling bin
- Disposal: none
- Facility categories: glass, metal
- Timings (ms): {"safety_router": 0, "retrieval": 485, "donate": 2656, "dropoff": 9, "recycle": 4025, "upcycle": 7705, "total": 8212}
- Models: embed: gemini-embedding-001; donation_advisor@v1: gemini-3.1-flash-lite; recycling_advisor@v1: gemini-3.1-flash-lite; upcycle_designer@v1: gemini-3.1-flash-lite

### aa_batteries.jpg

- Mode: `disposal_only`; donate available: False
- Ideas: none
- Recycle streams: Battery collection point
- Disposal: battery: Take the rechargeable batteries to a dedicated battery collection point.
- Facility categories: battery
- Timings (ms): {"safety_router": 0, "disposal": 6129, "dropoff": 10, "total": 6138}
- Models: disposal_advisor@v1: gemini-3.1-flash-lite

### old_tshirt.jpg

- Mode: `diy`; donate available: True
- Ideas: No-sew shopping tote (easy; sources: proj_textile_tshirt_tote); Washable cleaning cloths (easy; sources: proj_textile_cleaning_cloths); T-shirt yarn plant hanger (easy; sources: proj_textile_braided_coasters, proj_textile_tshirt_tote)
- Recycle streams: Textile donation bin
- Disposal: none
- Facility categories: textile_donation, textile_recycling
- Timings (ms): {"safety_router": 0, "retrieval": 523, "donate": 12009, "dropoff": 0, "recycle": 7658, "upcycle": 8178, "total": 12535}
- Models: embed: gemini-embedding-001; recycling_advisor@v1: gemini-3.1-flash-lite; upcycle_designer@v1: gemini-3.1-flash-lite
