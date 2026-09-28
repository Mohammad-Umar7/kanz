"""What each agent asks Gemini to produce (sent as ``response_json_schema``).

These are deliberately smaller and flatter than the public API models in ``app.schemas``:

* The model only produces what needs judgement. Everything derivable is computed by the
  backend in ``app.ai.convert`` (ids, localized labels, display strings, bounding-box
  conversion, which tools the user has), so the model cannot get it wrong and spends no
  output tokens on it.
* Closed vocabularies are ``Literal`` enums, so constrained decoding can only emit valid ids.
* Field descriptions are part of the prompt: Gemini reads them as per-field instructions.
* Numeric ranges are stated in descriptions but not enforced here; the converters clamp
  them. A value like ``confidence=1.02`` should never cost a repair round.
"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.analysis import PhotoIssue
from app.schemas.vocab import (
    Difficulty,
    HazardFlag,
    MaterialCategory,
    RecyclabilityStatus,
    StateTag,
    ToolId,
)

QuantityUnit = Literal["pcs", "kg", "g", "m", "m2", "L", "handful", "bag"]


class LlmModel(BaseModel):
    model_config = ConfigDict(extra="ignore")


# ------------------------------------------------------------------ Material Analyst
class LlmPhoto(LlmModel):
    usable: bool = Field(description="False only if the items cannot be identified with reasonable confidence.")
    issue: PhotoIssue = Field(description="'ok' when usable; otherwise the main problem.")
    retake_tip: str | None = Field(
        default=None, description="When not usable: ONE specific, actionable tip for the retake. Otherwise null."
    )


class LlmItem(LlmModel):
    name: str = Field(description="Specific everyday name, e.g. 'Glass jam jar', 'Blue denim jeans'.")
    category: MaterialCategory = Field(
        description="Main material family. Batteries, aerosol cans, medicines, light bulbs: 'hazardous'. Devices: 'electronics'."
    )
    material: str = Field(description="Specific material, e.g. 'Clear soda-lime glass', 'PET #1', 'Cotton denim'.")
    resin_code: int | None = Field(default=None, description="Plastic resin code 1-7 if visible or certain; else null.")
    is_raw_material: bool = Field(description="True for scraps, offcuts, strips, caps or loose pieces.")
    quantity_value: float = Field(description="How many (pcs) or an estimate in quantity_unit.")
    quantity_unit: QuantityUnit
    quantity_is_estimate: bool
    quality_score: int = Field(description="Condition 1-5: 1 poor, 2 worn, 3 fair, 4 good, 5 like new.")
    quality_notes: str = Field(description="One short phrase explaining the score from visible evidence.")
    state: list[StateTag] = Field(description="Visible condition tags only.")
    recyclability_status: RecyclabilityStatus
    recycling_stream: str = Field(description="Where it goes, e.g. 'Glass bottle bank', 'Battery collection point'.")
    prep_steps: list[str] = Field(description="Up to 3 short imperative prep steps before recycling.")
    recyclability_reason: str | None = Field(default=None, description="Why, when status is conditional or no.")
    reuse_level: Literal["high", "medium", "low"]
    reuse_note: str = Field(description="One short sentence on what makes it reusable (or not).")
    hazards: list[HazardFlag] = Field(description="Every hazard that applies; empty if none.")
    confidence: float = Field(description="0-1 confidence in name and category.")
    box_2d: list[float] | None = Field(
        default=None,
        description="[ymin, xmin, ymax, xmax] on a 0-1000 grid around this item (or group of identical items). Null for text input.",
    )


class LlmAnalysis(LlmModel):
    photo: LlmPhoto
    items: list[LlmItem] = Field(description="Every distinct item or raw material, most prominent first. Max 6.")
    summary: str = Field(description="One short line describing the scene.")


# ------------------------------------------------------------------ Upcycle Designer
class LlmIdea(LlmModel):
    title: str = Field(description="What it becomes, 2-5 words, e.g. 'Hanging jar lantern'.")
    pitch: str = Field(description="One line: what it becomes and why it is nice to have.")
    difficulty: Difficulty
    time_minutes: int = Field(description="Realistic active time in minutes, 5-600.")
    tools_needed: list[ToolId] = Field(description="Tools the project needs. Protective gear is not a tool here.")
    uses_item_ids: list[str] = Field(description="Ids of the scanned items this idea uses.")
    extra_materials: list[str] = Field(description="Other things needed that are not tools, e.g. 'Tea light'.")
    after_visual: str = Field(
        description="ENGLISH ONLY. The finished object as a photo caption, starting 'the same ...' and keeping the scanned object's shape, color and material."
    )
    safety_note: str | None = Field(default=None, description="Protective gear or safety point when relevant.")
    source_ids: list[str] = Field(
        description="Ids of the knowledge documents this idea is based on; only ids provided."
    )


class LlmIdeas(LlmModel):
    ideas: list[LlmIdea] = Field(min_length=3, max_length=3, description="Exactly three distinct ideas.")


# ------------------------------------------------------------------ Recycling Advisor
class LlmRecycleInstruction(LlmModel):
    item_id: str
    status: RecyclabilityStatus
    stream: str = Field(description="Where it goes, e.g. 'Glass bottle bank', 'Mixed recycling bin'.")
    prep_steps: list[str] = Field(description="2-4 short imperative steps, in order.")
    dos: list[str] = Field(description="1-2 short tips.")
    donts: list[str] = Field(description="1-3 common mistakes to avoid.")
    note: str | None = Field(default=None, description="Optional caveat, e.g. local rules vary.")


class LlmRecycle(LlmModel):
    instructions: list[LlmRecycleInstruction]
    source_ids: list[str] = Field(description="Ids of the knowledge documents used; only ids provided.")


# ------------------------------------------------------------------ Donation Advisor
class LlmDonateOption(LlmModel):
    item_id: str
    suitable: bool
    reason: str = Field(description="Why it can or cannot be donated, based on its condition.")
    where: list[str] = Field(
        description="Kinds of places that take it, e.g. 'Clothing donation bins'. Never invent names."
    )
    prep_steps: list[str] = Field(description="Short steps before donating; empty if not suitable.")


class LlmDonate(LlmModel):
    summary: str = Field(description="One line summing up the donation options.")
    options: list[LlmDonateOption]


# ------------------------------------------------------------------ Disposal Advisor
class LlmDisposal(LlmModel):
    item_id: str
    hazard: HazardFlag = Field(description="The hazard this guidance addresses.")
    headline: str = Field(description="One sentence: where it must go.")
    stream: str = Field(description="Drop-off stream, e.g. 'Battery collection point'.")
    steps: list[str] = Field(description="2-4 short steps to store and hand it in safely.")
    never: list[str] = Field(description="2-3 things to never do with it.")


class LlmDisposalPlan(LlmModel):
    guidance: list[LlmDisposal]
    source_ids: list[str] = Field(description="Ids of the safety documents used; only ids provided.")


# ------------------------------------------------------------------ Tutorial Writer
class LlmTutorialMaterial(LlmModel):
    name: str
    quantity: str | None = None
    from_scan: bool = Field(description="True if it is (part of) a scanned item.")
    item_id: str | None = Field(default=None, description="The scanned item's id when from_scan is true.")


class LlmTutorialTool(LlmModel):
    tool_id: ToolId
    alternative: str | None = Field(
        default=None, description="For tools the user lacks: a substitute that uses only things they have."
    )


class LlmTutorialStep(LlmModel):
    title: str = Field(description="2-5 words.")
    instruction: str = Field(description="1-3 plain sentences a beginner can follow.")
    tip: str | None = None
    warning: str | None = Field(default=None, description="Only for a real risk in this step.")
    duration_minutes: int = Field(description="Minutes for this step, 1-240.")
    image_prompt: str = Field(
        description="ENGLISH ONLY. What the SAME object looks like right after this step: same shape, color, material and background."
    )


class LlmTutorial(LlmModel):
    title: str
    adapted_note: str = Field(
        description="One line saying concretely what was adapted for this user's skill and tools."
    )
    materials: list[LlmTutorialMaterial]
    tools: list[LlmTutorialTool] = Field(description="Every tool used (not protective gear).")
    safety: list[str] = Field(description="Protective gear and safety notes, most important first.")
    steps: list[LlmTutorialStep] = Field(min_length=5, max_length=8, description="5-8 steps in order.")
    finishing: list[str] = Field(description="1-3 finishing touches.")
    care: list[str] = Field(description="1-3 care or maintenance tips.")
    source_ids: list[str] = Field(description="Ids of the knowledge documents used; only ids provided.")
