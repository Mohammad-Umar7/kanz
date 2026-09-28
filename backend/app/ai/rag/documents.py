"""Knowledge-base documents: schemas, loading, and the text that gets embedded.

Every file in ``backend/knowledge/`` is a JSON list of documents validated here, so a typo
in a tool id or a missing Arabic title fails the test suite instead of silently weakening
retrieval. See ``backend/knowledge/README.md`` for the field-by-field description.
"""

from __future__ import annotations

import hashlib
import json
import logging
from dataclasses import dataclass, field
from pathlib import Path
from typing import Annotated, Any, Literal

from pydantic import BaseModel, ConfigDict, Field, TypeAdapter, ValidationError, field_validator, model_validator

from app.schemas.vocab import (
    SAFETY_GEAR,
    Difficulty,
    HazardFlag,
    MaterialCategory,
    RecyclabilityStatus,
    ToolId,
)

log = logging.getLogger("kanz.rag")

Technique = Literal[
    "cutting",
    "blade_cutting",
    "sawing",
    "drilling",
    "sanding",
    "painting",
    "spray_painting",
    "varnishing",
    "gluing",
    "hot_glue",
    "sewing",
    "knotting",
    "weaving",
    "wiring",
    "hammering",
    "planting",
    "folding",
    "candles",
    "glass_work",
    "sharp_metal",
]
DocKind = Literal["project", "material_guide", "safety", "swap"]


@dataclass
class KnowledgeHit:
    """One retrieved document, ready to cite (``source_ref``) and to paste into a prompt (``text``)."""

    id: str
    kind: str
    title: str
    title_ar: str | None
    text: str
    metadata: dict[str, Any] = field(default_factory=dict)
    score: float = 0.0


class _Doc(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str = Field(pattern=r"^[a-z0-9_]+$")
    title: str = Field(min_length=3)
    title_ar: str = Field(min_length=2)
    materials: list[MaterialCategory] = Field(min_length=1)


class ProjectDoc(_Doc):
    kind: Literal["project"]
    items: list[str] = Field(min_length=1, description="Household items this suits: 'glass jar', 'wine bottle'.")
    summary: str = Field(min_length=10)
    summary_ar: str = Field(min_length=5)
    result: str = Field(min_length=10, description="English: the finished object, as a photo caption.")
    difficulty: Difficulty
    time_minutes: int = Field(ge=5, le=600)
    tools: list[ToolId] = Field(min_length=1)
    extra_materials: list[str] = Field(default_factory=list)
    steps_outline: list[str] = Field(min_length=4, max_length=8)
    safety: list[str] = Field(default_factory=list)
    techniques: list[Technique] = Field(min_length=1)
    tags: list[str] = Field(default_factory=list)

    @field_validator("id")
    @classmethod
    def _prefix(cls, v: str) -> str:
        if not v.startswith("proj_"):
            raise ValueError("project ids start with 'proj_<material>_'")
        return v

    @field_validator("tools")
    @classmethod
    def _no_gear(cls, v: list[str]) -> list[str]:
        if set(v) & SAFETY_GEAR:
            raise ValueError("protective gear goes in 'safety', not 'tools'")
        return v


class RecyclingInfo(BaseModel):
    model_config = ConfigDict(extra="forbid")

    stream: str
    accepted: list[str] = Field(default_factory=list)
    not_accepted: list[str] = Field(default_factory=list)


class MaterialGuideDoc(_Doc):
    kind: Literal["material_guide"]
    identification: list[str] = Field(min_length=1)
    cleaning_prep: list[str] = Field(min_length=1)
    recycling: RecyclingInfo
    notes: list[str] = Field(default_factory=list)
    donation: list[str] = Field(default_factory=list, description="When and where it can be donated or reused.")
    resin_code: int | None = Field(default=None, ge=1, le=7)
    common_items: list[str] = Field(default_factory=list)
    recyclability: RecyclabilityStatus | None = None

    @model_validator(mode="after")
    def _prefix(self) -> MaterialGuideDoc:
        if self.id.startswith("resin_"):
            if self.resin_code is None or not self.common_items or self.recyclability is None:
                raise ValueError("resin guides need resin_code, common_items and recyclability")
        elif not self.id.startswith("mat_"):
            raise ValueError("material guide ids start with 'mat_' or 'resin_'")
        return self


class AppliesTo(BaseModel):
    model_config = ConfigDict(extra="forbid")

    hazards: list[HazardFlag] = Field(default_factory=list)
    materials: list[MaterialCategory] = Field(default_factory=list)
    techniques: list[Technique] = Field(default_factory=list)


class SafetyDoc(_Doc):
    kind: Literal["safety"]
    applies_to: AppliesTo
    rules: list[str] = Field(min_length=2)
    never: list[str] = Field(min_length=1)
    gear: list[ToolId] = Field(default_factory=list)

    @field_validator("id")
    @classmethod
    def _prefix(cls, v: str) -> str:
        if not v.startswith("safety_"):
            raise ValueError("safety ids start with 'safety_'")
        return v

    @field_validator("gear")
    @classmethod
    def _gear_only(cls, v: list[str]) -> list[str]:
        if set(v) - SAFETY_GEAR:
            raise ValueError("gear lists protective gear only")
        return v


class SwapDoc(_Doc):
    """Eco swaps are written by the Places & Swaps workstream; only the shared fields are strict."""

    model_config = ConfigDict(extra="allow")

    kind: Literal["swap"]
    from_item: Any = None
    to_item: Any = None
    replaces_category: str | None = None
    keywords: list[Any] = Field(default_factory=list)
    why: Any = None
    tip: Any = None
    effort: str | None = None
    cost: str | None = None
    impact_note: Any = None
    impact_source: Any = None


KnowledgeDoc = Annotated[ProjectDoc | MaterialGuideDoc | SafetyDoc | SwapDoc, Field(discriminator="kind")]
_ADAPTER: TypeAdapter[KnowledgeDoc] = TypeAdapter(KnowledgeDoc)


# ---------------------------------------------------------------------------- loading
KNOWLEDGE_FILES = ("projects/*.json", "materials.json", "resin_codes.json", "safety.json", "swaps.json")


def _records(raw: Any) -> list[Any]:
    """Accept a JSON list, or an object wrapping one list (e.g. ``{"swaps": [...]}``)."""
    if isinstance(raw, list):
        return raw
    if isinstance(raw, dict):
        for value in raw.values():
            if isinstance(value, list):
                return value
    return []


def load_documents(knowledge_dir: Path, *, strict: bool = False) -> tuple[list[KnowledgeDoc], list[str]]:
    """Load and validate every knowledge file. Returns (documents, problems).

    With ``strict=False`` (runtime) an invalid document is skipped and reported, so one bad
    entry never takes retrieval down; tests load with ``strict=True``.
    """
    docs: list[KnowledgeDoc] = []
    problems: list[str] = []
    seen: set[str] = set()
    paths: list[Path] = []
    for pattern in KNOWLEDGE_FILES:
        paths.extend(sorted(knowledge_dir.glob(pattern)))
    for path in paths:
        rel = path.relative_to(knowledge_dir).as_posix()
        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            problems.append(f"{rel}: {exc}")
            continue
        for i, entry in enumerate(_records(raw)):
            record = {"kind": "swap", **entry} if isinstance(entry, dict) and rel == "swaps.json" else entry
            try:
                doc = _ADAPTER.validate_python(record)
            except ValidationError as exc:
                first = exc.errors()[0]
                loc = ".".join(str(p) for p in first.get("loc", ()))
                problems.append(f"{rel}[{i}] {loc}: {first.get('msg')}")
                continue
            if doc.id in seen:
                problems.append(f"{rel}[{i}]: duplicate id {doc.id}")
                continue
            seen.add(doc.id)
            docs.append(doc)
    if problems:
        if strict:
            raise ValueError("invalid knowledge documents:\n" + "\n".join(problems))
        for p in problems:
            log.warning("knowledge document skipped: %s", p)
    return docs, problems


# -------------------------------------------------------------------------- rendering
def _text(value: Any) -> str:
    """Flatten a field that may be a string, a list, or a localized {'en': ..., 'ar': ...} dict."""
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        return str(value.get("en") or next((v for v in value.values() if isinstance(v, str)), ""))
    if isinstance(value, list | tuple):
        return "; ".join(_text(v) for v in value if v)
    return str(value)


def render_text(doc: KnowledgeDoc) -> str:
    """The document as compact text: what gets embedded and what agents read in their prompts."""
    head = f"[{doc.id}] {doc.title} ({', '.join(doc.materials)})"
    if isinstance(doc, ProjectDoc):
        return "\n".join(
            [
                head,
                f"For: {', '.join(doc.items)}. {doc.summary}",
                f"Result: {doc.result}",
                f"Difficulty: {doc.difficulty}; about {doc.time_minutes} min; tools: {', '.join(doc.tools)}",
                f"Extra materials: {', '.join(doc.extra_materials) or 'none'}",
                "Steps: " + " | ".join(doc.steps_outline),
                f"Safety: {' '.join(doc.safety) or 'standard care'}",
                f"Techniques: {', '.join(doc.techniques)}. Tags: {', '.join(doc.tags)}",
            ]
        )
    if isinstance(doc, MaterialGuideDoc):
        lines = [head]
        if doc.resin_code:
            lines.append(
                f"Resin code {doc.resin_code}; recyclability: {doc.recyclability}; e.g. {', '.join(doc.common_items)}"
            )
        lines += [
            "Identify: " + " ".join(doc.identification),
            "Prep: " + " ".join(doc.cleaning_prep),
            f"Stream: {doc.recycling.stream}. Accepted: {', '.join(doc.recycling.accepted)}. "
            f"Not accepted: {', '.join(doc.recycling.not_accepted)}.",
        ]
        if doc.donation:
            lines.append("Donation and reuse: " + " ".join(doc.donation))
        if doc.notes:
            lines.append("Notes: " + " ".join(doc.notes))
        return "\n".join(lines)
    if isinstance(doc, SafetyDoc):
        applies = doc.applies_to
        scope = ", ".join([*applies.hazards, *applies.techniques]) or ", ".join(applies.materials)
        lines = [f"{head} applies to: {scope}", "Rules: " + " ".join(doc.rules), "Never: " + " ".join(doc.never)]
        if doc.gear:
            lines.append(f"Gear: {', '.join(doc.gear)}")
        return "\n".join(lines)
    return "\n".join(
        line
        for line in [
            head,
            f"Swap {_text(doc.from_item)} for {_text(doc.to_item)}.",
            _text(doc.why),
            f"Tip: {_text(doc.tip)}" if doc.tip else "",
            f"Keywords: {_text(doc.keywords)}" if doc.keywords else "",
        ]
        if line
    )


def doc_metadata(doc: KnowledgeDoc) -> dict[str, Any]:
    """Rich metadata returned with every hit (fallbacks and nodes read these fields directly)."""
    meta: dict[str, Any] = {"kind": doc.kind, "materials": list(doc.materials)}
    if isinstance(doc, ProjectDoc):
        meta.update(
            items=doc.items,
            summary=doc.summary,
            summary_ar=doc.summary_ar,
            result=doc.result,
            difficulty=doc.difficulty,
            time_minutes=doc.time_minutes,
            tools=list(doc.tools),
            extra_materials=doc.extra_materials,
            techniques=list(doc.techniques),
            safety=doc.safety,
        )
    elif isinstance(doc, MaterialGuideDoc):
        meta.update(resin_code=doc.resin_code, stream=doc.recycling.stream)
    elif isinstance(doc, SafetyDoc):
        meta.update(
            hazards=list(doc.applies_to.hazards),
            techniques=list(doc.applies_to.techniques),
            gear=list(doc.gear),
            never=doc.never,
        )
    else:
        meta.update(doc.model_dump(exclude={"id", "kind", "title", "title_ar", "materials"}))
    return meta


def doc_hash(doc: KnowledgeDoc, salt: str = "") -> str:
    """Content hash of what gets embedded; a changed document (or model) is re-embedded."""
    return hashlib.sha256(f"{salt}|{render_text(doc)}".encode()).hexdigest()[:16]


def to_hit(doc: KnowledgeDoc, score: float = 1.0) -> KnowledgeHit:
    return KnowledgeHit(
        id=doc.id,
        kind=doc.kind,
        title=doc.title,
        title_ar=doc.title_ar,
        text=render_text(doc),
        metadata=doc_metadata(doc),
        score=round(float(score), 4),
    )
