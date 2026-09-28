"""Test doubles for the Swap Advisor: a scripted retriever and a scripted Gemini gateway."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from app.core.errors import AiInvalidOutput


@dataclass
class Hit:
    """Shape of ``app.ai.rag.KnowledgeHit`` as far as the advisor uses it."""

    id: str
    kind: str = "swap"
    score: float = 1.0


@dataclass
class FakeRetriever:
    """Answers each query from a keyword -> document ids table and records every call."""

    table: dict[str, list[str]]
    calls: list[dict[str, Any]] = field(default_factory=list)

    async def __call__(self, query: str, *, kinds, materials=None, k: int = 6) -> list[Hit]:
        self.calls.append({"query": query, "kinds": list(kinds), "k": k})
        for keyword, ids in self.table.items():
            if keyword in query:
                return [Hit(i) for i in ids[:k]]
        return []


@dataclass
class FakeGateway:
    """Returns scripted answers like ``GeminiGateway.structured``, including its repair round.

    The first answer is validated against the schema and the validator; if either
    objects, the next scripted answer is used (the repair), and a second failure raises
    ``AiInvalidOutput`` exactly as the real gateway does.
    """

    answers: list[dict[str, Any]]
    calls: list[dict[str, Any]] = field(default_factory=list)
    problems_seen: list[list[str]] = field(default_factory=list)

    async def structured(self, **kwargs: Any) -> Any:
        self.calls.append(kwargs)
        schema, validator = kwargs["schema"], kwargs.get("validator")
        for attempt in range(2):
            if not self.answers:
                break
            answer = self.answers.pop(0)
            try:
                obj = schema.model_validate(answer)
            except ValueError as err:
                self.problems_seen.append([str(err)])
                continue
            problems = validator(obj) if validator else []
            self.problems_seen.append(problems)
            if not problems:
                return obj
            if attempt == 1:
                break
        raise AiInvalidOutput(detail="scripted answers failed validation")


def card(source_id: str, matched_input: str | None, **overrides: Any) -> dict[str, Any]:
    base = {
        "source_id": source_id,
        "matched_input": matched_input,
        "from_item": "Single-use plastic bags",
        "to_item": "A folding cotton tote",
        "why": "One sturdy tote replaces a long run of thin bags that tear and become litter.",
        "tip": "Keep one folded in the car and one in your daily bag.",
        "impact_note": "Less wind-blown litter.",
    }
    base.update(overrides)
    return base


def card_ar(source_id: str, matched_input: str | None, **overrides: Any) -> dict[str, Any]:
    base = {
        "source_id": source_id,
        "matched_input": matched_input,
        "from_item": "أكياس بلاستيكية للاستعمال الواحد",
        "to_item": "حقيبة قماشية قابلة للطي",
        "why": "حقيبة واحدة متينة تغني عن أكياس رقيقة كثيرة تتمزق وتتحول إلى نفايات متطايرة.",
        "tip": "احتفظ بواحدة مطوية في السيارة وأخرى في حقيبتك اليومية.",
        "impact_note": "نفايات متطايرة أقل.",
    }
    base.update(overrides)
    return base
