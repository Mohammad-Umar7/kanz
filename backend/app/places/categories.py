"""Material -> facility category mapping (backend/config/facility_categories.json). Owned by Places & Swaps.

Public seam (keep these signatures):

    def catalog(lang: str) -> list[FacilityCategory]
    def categories_for_items(items: list[Item], lang: str) -> list[FacilityCategory]
"""
