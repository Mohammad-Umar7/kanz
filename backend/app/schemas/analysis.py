"""POST /v1/analyze: photo (or text) -> structured material analysis."""

from typing import Literal

from pydantic import Field

from app.schemas.common import ApiModel, Timings
from app.schemas.vocab import (
    HazardFlag,
    Lang,
    MaterialCategory,
    RecyclabilityStatus,
    StateTag,
)


class BBox(ApiModel):
    """Bounding box normalized to 0..1 relative to the uploaded image (top-left origin).

    Gemini returns ``box_2d`` as [ymin, xmin, ymax, xmax] on a 0..1000 grid; the
    Material Analyst node converts it to this shape.
    """

    x: float = Field(ge=0, le=1)
    y: float = Field(ge=0, le=1)
    w: float = Field(ge=0, le=1)
    h: float = Field(ge=0, le=1)


class Quantity(ApiModel):
    value: float = Field(ge=0, description="Count, or an estimate in `unit`.")
    unit: str = Field(description="'pcs', 'kg', 'g', 'm', 'm2', 'L', 'handful', 'bag'.")
    is_estimate: bool
    display: str = Field(description="Ready to show, localized: '3 pcs', '~0.5 kg'.")


class Quality(ApiModel):
    score: int = Field(ge=1, le=5, description="1 poor, 2 worn, 3 fair, 4 good, 5 like new.")
    label: str = Field(description="Localized label for the score.")
    notes: str | None = Field(default=None, description="One short phrase explaining the score.")


class Recyclability(ApiModel):
    status: RecyclabilityStatus
    stream: str = Field(description="Where it goes, localized, e.g. 'Glass bottle bank'.")
    prep_steps: list[str] = Field(default_factory=list, description="Short imperative steps: 'Rinse', 'Remove lid'.")
    reason: str | None = Field(default=None, description="Why conditional/no.")


class ReusePotential(ApiModel):
    level: Literal["high", "medium", "low"]
    note: str = Field(description="One short sentence on what makes it reusable (or not).")


class Item(ApiModel):
    """One item or raw material detected in the photo."""

    id: str = Field(description="Stable within a scan: 'item_1', 'item_2'...")
    name: str = Field(description="Localized, specific: 'Glass jam jar'.")
    category: MaterialCategory
    material: str = Field(
        description="Specific material, localized: 'Clear soda-lime glass', 'PET #1', 'Cotton denim'."
    )
    resin_code: int | None = Field(
        default=None, ge=1, le=7, description="Plastic resin identification code when known."
    )
    is_raw_material: bool = Field(default=False, description="Scraps, offcuts, caps... rather than a whole object.")
    quantity: Quantity
    quality: Quality
    state: list[StateTag] = Field(default_factory=list)
    recyclability: Recyclability
    reuse: ReusePotential
    hazards: list[HazardFlag] = Field(default_factory=list)
    confidence: float = Field(ge=0, le=1)
    bbox: BBox | None = None
    user_corrected: bool = Field(default=False, description="Set by the app when the user edited this item.")


PhotoIssue = Literal["ok", "blurry", "too_dark", "too_far", "too_close", "cluttered", "no_items", "glare"]


class PhotoCheck(ApiModel):
    usable: bool
    issue: PhotoIssue = "ok"
    retake_tip: str | None = Field(default=None, description="One specific, localized tip when not usable.")


class Analysis(ApiModel):
    items: list[Item]
    summary: str = Field(description="One localized line describing the scene.")
    photo: PhotoCheck
    primary_item_id: str | None = Field(default=None, description="Item the recommendations focus on by default.")
    source: Literal["image", "text"]
    classifier_hint: str | None = Field(
        default=None,
        description="Label from the pluggable MaterialClassifier, if one is installed (no-op by default).",
    )


class AnalyzeResponse(ApiModel):
    """Multipart request fields: `image` (file) and/or `text` (str), `lang` ('en'|'ar')."""

    image_id: str = Field(description="Upload id ('img_...') or, for text input, a text id ('txt_...').")
    image_url: str | None = Field(description="Path of the stored upload ('/static/uploads/...'); null for text input.")
    image_width: int | None = None
    image_height: int | None = None
    analysis: Analysis
    lang: Lang
    timings_ms: Timings = Field(default_factory=dict)
