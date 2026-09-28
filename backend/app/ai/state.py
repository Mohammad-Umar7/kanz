"""Typed state and runtime context for the LangGraph graphs.

Each graph has a ``TypedDict`` state. Parallel branches write to *separate* keys
(``upcycle``, ``recycle``, ``donate``...) so they never race; the two keys every node
touches, ``timings`` and ``errors``, use a merging reducer. Dependencies (the Gemini
gateway, settings, stores) travel in ``PipelineContext`` through LangGraph's runtime
context rather than globals, which is what lets the tests swap in a fake gateway.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Annotated, Any, TypedDict

from app.ai.classifier import MaterialClassifier
from app.ai.gemini import GeminiGateway
from app.ai.rag import KnowledgeHit
from app.config import Settings
from app.core.tutorials import TutorialStore
from app.schemas.analysis import Analysis, Item
from app.schemas.common import SourceRef
from app.schemas.recommend import (
    DisposalGuidance,
    DonatePath,
    FacilityCategory,
    RecommendRequest,
    RecommendResponse,
    RecycleInstruction,
    RecyclePath,
    Routing,
    UpcycleIdea,
)
from app.schemas.tutorial import Tutorial, TutorialRequest


def merge(left: dict[str, Any] | None, right: dict[str, Any] | None) -> dict[str, Any]:
    """Reducer for keys written by several (possibly parallel) nodes."""
    return {**(left or {}), **(right or {})}


@dataclass
class PipelineContext:
    gateway: GeminiGateway
    settings: Settings
    tutorials: TutorialStore | None = None
    classifier: MaterialClassifier | None = None


class AnalyzeState(TypedDict, total=False):
    image: bytes | None
    text: str | None
    lang: str
    classifier_hint: str | None
    analysis: Analysis
    timings: Annotated[dict[str, int], merge]


class RecommendState(TypedDict, total=False):
    request: RecommendRequest
    lang: str
    items: list[Item]  # every item, after safety normalisation
    diy_items: list[Item]  # items without a disposal-only hazard
    hazardous_items: list[Item]
    focus_id: str | None
    routing: Routing
    projects: list[KnowledgeHit]
    guides: list[KnowledgeHit]
    upcycle: list[UpcycleIdea]
    recycle: RecyclePath
    donate: DonatePath
    disposal: list[DisposalGuidance]
    disposal_recycle: list[RecycleInstruction]
    disposal_sources: list[SourceRef]
    facility_categories: list[FacilityCategory]
    response: RecommendResponse
    timings: Annotated[dict[str, int], merge]
    errors: Annotated[dict[str, Exception], merge]


class TutorialState(TypedDict, total=False):
    request: TutorialRequest
    tutorial_id: str
    knowledge: list[KnowledgeHit]
    tutorial: Tutorial
    timings: Annotated[dict[str, int], merge]
