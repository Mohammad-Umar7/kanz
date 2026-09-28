"""POST /v1/recommend: analysis + profile -> routing, upcycle ideas, recycle, donate, drop-off categories."""

from typing import Literal

from pydantic import Field

from app.schemas.analysis import Analysis
from app.schemas.common import ApiModel, Profile, SourceRef, Timings
from app.schemas.vocab import (
    Difficulty,
    FacilityType,
    HazardFlag,
    Lang,
    MaterialCategory,
    RecyclabilityStatus,
    ToolId,
)


class RecommendRequest(ApiModel):
    image_id: str
    analysis: Analysis = Field(description="The (possibly user-corrected) analysis.")
    profile: Profile = Field(default_factory=Profile)
    focus_item_id: str | None = Field(default=None, description="Item to focus ideas on; defaults to primary_item_id.")


class UpcycleIdea(ApiModel):
    id: str = Field(description="Backend-assigned stable id: 'idea_<8 hex>'.")
    title: str
    pitch: str = Field(description="One line: what it becomes and why it's nice.")
    difficulty: Difficulty
    time_minutes: int = Field(ge=5, le=600)
    tools_needed: list[ToolId] = Field(description="Tools (not safety gear) the project needs.")
    tools_have: list[ToolId] = Field(description="tools_needed the user has (computed by backend).")
    tools_missing: list[ToolId] = Field(description="tools_needed the user lacks (computed by backend).")
    uses_item_ids: list[str] = Field(description="Scan items this idea uses.")
    extra_materials: list[str] = Field(default_factory=list, description="Localized: 'Tea light', 'Twine'.")
    after_visual: str = Field(
        description="ENGLISH description of the finished object, used by the Image Director for the after image."
    )
    safety_note: str | None = None
    sources: list[SourceRef] = Field(default_factory=list)


class RecycleInstruction(ApiModel):
    item_id: str
    status: RecyclabilityStatus
    stream: str = Field(description="Localized: 'Glass bottle bank', 'Mixed recycling bin'.")
    prep_steps: list[str]
    dos: list[str]
    donts: list[str]
    note: str | None = None


class RecyclePath(ApiModel):
    instructions: list[RecycleInstruction]
    sources: list[SourceRef] = Field(default_factory=list)


class DonateOption(ApiModel):
    item_id: str
    suitable: bool
    reason: str = Field(description="Why it can (or can't) be donated, based on its condition.")
    where: list[str] = Field(default_factory=list, description="Localized kinds of places: 'Clothing donation bins'.")
    prep_steps: list[str] = Field(default_factory=list)


class DonatePath(ApiModel):
    available: bool = Field(description="True if at least one item is suitable for donation or reuse.")
    summary: str
    options: list[DonateOption]


class DisposalGuidance(ApiModel):
    """Disposal-only guidance for hazardous items (no DIY)."""

    item_id: str
    hazard: HazardFlag
    headline: str = Field(description="'Take batteries to a battery collection point.'")
    steps: list[str]
    never: list[str] = Field(description="Things to never do with it: 'Never put it in the household bin'.")


class FacilityCategory(ApiModel):
    """A kind of drop-off point to search for. Keys come from backend/config/facility_categories.json."""

    key: str = Field(description="'glass', 'textile_donation', 'battery', 'e_waste', ...")
    label: str = Field(description="Localized chip label.")
    facility_types: list[FacilityType]
    material_categories: list[MaterialCategory]
    item_ids: list[str] = Field(
        default_factory=list, description="Scan items that need this category (empty in catalog listings)."
    )


class Routing(ApiModel):
    """Output of the Safety Router."""

    mode: Literal["diy", "mixed", "disposal_only"] = Field(
        description="diy: no hazards; mixed: some items hazardous; disposal_only: every item hazardous."
    )
    hazardous_item_ids: list[str] = Field(default_factory=list)
    reason: str | None = Field(default=None, description="Localized one-liner shown when DIY is withheld.")


class RecommendResponse(ApiModel):
    routing: Routing
    upcycle: list[UpcycleIdea] = Field(description="Exactly 3 unless routing.mode == 'disposal_only' (then empty).")
    recycle: RecyclePath
    donate: DonatePath
    disposal: list[DisposalGuidance] = Field(default_factory=list)
    facility_categories: list[FacilityCategory]
    lang: Lang
    timings_ms: Timings = Field(default_factory=dict)
