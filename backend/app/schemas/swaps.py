"""POST /v1/swaps: materials the user often throws away -> eco-friendly swap cards."""

from pydantic import Field

from app.schemas.common import ApiModel, SourceRef, Timings
from app.schemas.vocab import Lang, Level, MaterialCategory


class HistorySummary(ApiModel):
    """Computed on the device from scan history; lets the Swap Advisor personalize."""

    period_days: int = Field(default=30, ge=1, le=365)
    counts: dict[MaterialCategory, int] = Field(default_factory=dict, description="Items scanned per material.")
    top_items: list[str] = Field(default_factory=list, description="Most frequent item names, e.g. 'plastic bottle'.")
    top_item_counts: list[int] = Field(default_factory=list, description="Counts aligned with top_items.")


class SwapsRequest(ApiModel):
    materials: list[str] = Field(
        default_factory=list, description="Chip ids and/or free text: 'plastic bags', 'cling film'."
    )
    history: HistorySummary | None = None
    lang: Lang = "en"


class Swap(ApiModel):
    id: str
    from_item: str = Field(description="What it replaces, localized.")
    to_item: str = Field(description="The alternative, localized.")
    why: str
    tip: str = Field(description="One practical tip for making the switch.")
    effort: Level
    cost: Level
    category: MaterialCategory = Field(description="Material of the thing being replaced.")
    impact_note: str | None = Field(
        default=None, description="Qualitative, unless a knowledge-base source with a number is cited."
    )
    matched_input: str | None = Field(default=None, description="The user input this card answers.")
    from_history: bool = False
    sources: list[SourceRef] = Field(default_factory=list)


class SwapsResponse(ApiModel):
    swaps: list[Swap]
    history_insight: str | None = Field(default=None, description="'You scanned 6 plastic bottles this month.'")
    lang: Lang
    timings_ms: Timings = Field(default_factory=dict)
