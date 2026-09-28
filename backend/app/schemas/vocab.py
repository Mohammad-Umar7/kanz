"""Closed vocabularies shared with the app.

These Literal types mirror ``contracts/vocab.json`` (the app ships an exact copy as
``app/assets/config/vocab.json``). IDs are English and never translated; the app
localizes them. ``tests/test_contracts.py`` fails if the two drift apart.

Using closed enums in the LLM response schemas is deliberate prompt engineering:
Gemini's structured output can only pick valid IDs, so the app never has to guess
what "Glass jar (clear)" or "hot-glue" means.
"""

from typing import Literal, get_args

Lang = Literal["en", "ar"]

MaterialCategory = Literal[
    "glass",
    "plastic",
    "paper",
    "metal",
    "textile",
    "wood",
    "electronics",
    "hazardous",
    "organic",
    "other",
]

ToolId = Literal[
    "scissors",
    "craft_knife",
    "hot_glue_gun",
    "strong_glue",
    "wood_glue",
    "sandpaper",
    "paintbrush",
    "acrylic_paint",
    "spray_paint",
    "varnish",
    "drill",
    "screwdriver",
    "hammer",
    "handsaw",
    "pliers",
    "wire_cutter",
    "measuring_tape",
    "ruler_pencil",
    "sewing_kit",
    "sewing_machine",
    "iron",
    "twine",
    "craft_wire",
    "masking_tape",
    "clamps",
    "staple_gun",
    "gloves",
    "safety_glasses",
    "dust_mask",
]

# Protective gear is always recommended in safety notes but never counted in
# "You have 3 of 4 tools".
SAFETY_GEAR: frozenset[str] = frozenset({"gloves", "safety_glasses", "dust_mask"})

StateTag = Literal[
    "clean",
    "dirty",
    "greasy",
    "contains_residue",
    "empty",
    "wet",
    "intact",
    "cracked",
    "chipped",
    "broken",
    "torn",
    "stained",
    "faded",
    "worn",
    "rusted",
    "dented",
    "bent",
    "moldy",
    "missing_parts",
    "label_on",
    "label_off",
    "lid_on",
    "lid_off",
    "cap_on",
    "cap_off",
    "flattened",
]

HazardFlag = Literal[
    "battery",
    "e_waste",
    "chemical",
    "aerosol",
    "medicine",
    "light_bulb",
    "broken_glass",
    "sharp_edges",
    "mold",
]

# Items carrying any of these hazards are routed to the disposal-only branch:
# no DIY ideas, only safe disposal guidance and matching drop-off points.
DISPOSAL_ONLY_HAZARDS: frozenset[str] = frozenset(
    {"battery", "e_waste", "chemical", "aerosol", "medicine", "light_bulb", "broken_glass"}
)

FacilityType = Literal[
    "recycling_center",
    "collection_point",
    "donation",
    "e_waste",
    "hazardous_waste",
    "scrap_metal",
    "wood_collection",
]

CityId = Literal[
    "abu_dhabi",
    "al_ain",
    "dubai",
    "sharjah",
    "ajman",
    "umm_al_quwain",
    "ras_al_khaimah",
    "fujairah",
]

SkillLevel = Literal["beginner", "intermediate", "advanced"]
Difficulty = Literal["easy", "medium", "hard"]
Level = Literal["low", "medium", "high"]
RecyclabilityStatus = Literal["yes", "conditional", "no"]

MATERIAL_CATEGORIES: tuple[str, ...] = get_args(MaterialCategory)
TOOL_IDS: tuple[str, ...] = get_args(ToolId)
STATE_TAGS: tuple[str, ...] = get_args(StateTag)
HAZARD_FLAGS: tuple[str, ...] = get_args(HazardFlag)
FACILITY_TYPES: tuple[str, ...] = get_args(FacilityType)
CITY_IDS: tuple[str, ...] = get_args(CityId)
