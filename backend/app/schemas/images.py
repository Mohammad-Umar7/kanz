"""POST /v1/images/after, /step, /bin, /reference: generated images served as static URLs."""

from typing import Literal

from pydantic import Field

from app.schemas.analysis import Item
from app.schemas.common import ApiModel, Timings
from app.schemas.recommend import UpcycleIdea
from app.schemas.vocab import SkillLevel


class AfterImageRequest(ApiModel):
    image_id: str
    idea: UpcycleIdea
    regenerate: bool = False


class StepImageRequest(ApiModel):
    image_id: str
    tutorial_id: str
    step: int = Field(ge=1, description="1-based step number. Earlier steps are generated first if missing.")
    regenerate: bool = False


class BinImageRequest(ApiModel):
    """Nice-to-have: the item correctly prepared for the bin (rinsed, cap off, flattened)."""

    image_id: str
    item: Item
    prep_steps: list[str] = Field(default_factory=list)
    regenerate: bool = False


class ReferenceImageRequest(ApiModel):
    """Text scans only ('txt_...'): a realistic photo of the described item, used as the 'before' image."""

    image_id: str


class ImageResponse(ApiModel):
    url: str = Field(description="Path under the API base URL, e.g. '/static/generated/img_ab12/after_idea_9f.jpg'.")
    width: int
    height: int
    kind: Literal["after", "step", "bin", "reference"]
    key: str = Field(description="Cache key: identical requests return the same image.")
    cached: bool
    step: int | None = None
    skill: SkillLevel | None = None
    timings_ms: Timings = Field(default_factory=dict)
