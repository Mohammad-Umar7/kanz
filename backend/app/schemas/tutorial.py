"""POST /v1/tutorial: chosen idea + profile -> step-by-step tutorial."""

from pydantic import Field

from app.schemas.analysis import Item
from app.schemas.common import ApiModel, Profile, SourceRef, Timings
from app.schemas.recommend import UpcycleIdea
from app.schemas.vocab import Lang, SkillLevel, ToolId


class TutorialRequest(ApiModel):
    image_id: str
    idea: UpcycleIdea
    items: list[Item] = Field(description="The scan items the idea uses (their material and state shape the steps).")
    profile: Profile = Field(default_factory=Profile)


class TutorialMaterial(ApiModel):
    name: str
    quantity: str | None = None
    from_scan: bool = Field(description="True if it is (part of) a scanned item.")
    item_id: str | None = None


class TutorialTool(ApiModel):
    tool_id: ToolId
    have: bool
    alternative: str | None = Field(default=None, description="Localized substitute when the user lacks it.")


class TutorialStep(ApiModel):
    number: int = Field(ge=1)
    title: str
    instruction: str
    tip: str | None = None
    warning: str | None = None
    duration_minutes: int = Field(ge=1, le=240)
    image_prompt: str = Field(
        description="ENGLISH: what the object looks like right after this step (drives the step image)."
    )


class Tutorial(ApiModel):
    tutorial_id: str = Field(description="'tut_<hash>' of (image_id, idea.id, skill, tools, lang).")
    idea_id: str
    image_id: str
    title: str
    adapted_note: str = Field(description="Localized: 'Adapted for Beginner, no drill needed'.")
    skill: SkillLevel
    total_minutes: int
    materials: list[TutorialMaterial]
    tools: list[TutorialTool]
    safety: list[str] = Field(description="Protective gear and safety notes.")
    steps: list[TutorialStep] = Field(min_length=5, max_length=8)
    finishing: list[str] = Field(default_factory=list)
    care: list[str] = Field(default_factory=list)
    sources: list[SourceRef] = Field(default_factory=list)
    lang: Lang


class TutorialResponse(ApiModel):
    tutorial: Tutorial
    timings_ms: Timings = Field(default_factory=dict)
