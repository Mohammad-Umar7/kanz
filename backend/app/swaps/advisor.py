"""The Swap Advisor's contract with the model: response schema, validator and request text.

Three layers keep the cards grounded:

1. **Closed enums.** The response schema is built per request: ``source_id`` may only be
   one of the retrieved document ids and ``matched_input`` only one of the user's inputs
   (or null). Gemini's structured output cannot cite anything else.
2. **Validator.** ``advice_problems`` checks what a schema cannot: card count, duplicate
   documents, history cards without history, numbers quoted without a source, and text
   in the wrong language. Problems go back to the model in the gateway's repair round.
3. **Facts from code.** Effort, cost, material and the source chip are copied from the
   knowledge base when the cards are assembled; the model only writes the copy.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, create_model

from app.schemas.swaps import HistorySummary
from app.swaps.inputs import UserInput
from app.swaps.knowledge import SwapEntry

MIN_CARDS = 3
MAX_CARDS = 6

_DIGITS = re.compile(r"[0-9٠-٩۰-۹%٪]")  # Western, Arabic-Indic and Persian digits, % and ٪
_ARABIC = re.compile(r"[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]")
_LATIN = re.compile(r"[A-Za-z]")
LANG_NAMES = {"en": "English", "ar": "Modern Standard Arabic"}


def _text_fields() -> dict[str, Any]:
    """The fields the model writes, after citing (fresh FieldInfo objects for each schema)."""
    return {
        "from_item": (str, Field(min_length=2, max_length=90, description="What it replaces: a short noun phrase.")),
        "to_item": (str, Field(min_length=2, max_length=110, description="The alternative: a short noun phrase.")),
        "why": (
            str,
            Field(min_length=10, max_length=360, description="One or two sentences on why it helps, for this user."),
        ),
        "tip": (
            str,
            Field(min_length=10, max_length=240, description="One concrete action that makes the switch easy."),
        ),
        "impact_note": (
            str | None,
            Field(default=None, max_length=220, description="One short qualitative sentence, or null. No numbers."),
        ),
    }


def advice_schema(doc_ids: list[str], input_labels: list[str]) -> type[BaseModel]:
    """The response model for one request, with ids and inputs as closed enums.

    Field order is the order the model writes: it cites a document and an input first,
    then writes the copy for them.
    """
    source_id = Literal[tuple(doc_ids)]  # type: ignore[valid-type]
    matched = (Literal[tuple(input_labels)] | None) if input_labels else None  # type: ignore[valid-type]
    card = create_model(
        "SwapCard",
        __config__=ConfigDict(extra="forbid"),
        source_id=(source_id, Field(description="Id of the one swap document this card is based on.")),
        matched_input=(
            matched,
            Field(description="The user input this card answers, copied exactly; null for a history card."),
        ),
        **_text_fields(),
    )
    upper = min(MAX_CARDS, len(doc_ids))
    return create_model(
        "SwapAdvice",
        __config__=ConfigDict(extra="forbid"),
        swaps=(list[card], Field(min_length=min(MIN_CARDS, upper), max_length=upper)),  # type: ignore[valid-type]
    )


@dataclass(frozen=True)
class AdviceContext:
    docs: dict[str, SwapEntry]
    inputs: list[UserInput]
    has_history: bool
    lang: str

    def canonical_input(self, value: str | None) -> str | None:
        """The input label ``value`` refers to (case- and space-insensitive), or None."""
        if value is None:
            return None
        wanted = " ".join(value.split()).casefold()
        return next((i.label for i in self.inputs if i.label.casefold() == wanted), None)


def advice_problems(advice: Any, ctx: AdviceContext) -> list[str]:
    """Every rule the advice breaks, phrased as an instruction the model can act on."""
    cards = list(getattr(advice, "swaps", []) or [])
    upper = min(MAX_CARDS, len(ctx.docs))
    lower = min(MIN_CARDS, upper)
    problems: list[str] = []
    if not lower <= len(cards) <= upper:
        problems.append(f"Return between {lower} and {upper} swap cards (you returned {len(cards)}).")
    seen: set[str] = set()
    for i, card in enumerate(cards):
        if card.source_id in seen:
            problems.append(f"swaps[{i}] reuses document {card.source_id}; each card needs a different document.")
        seen.add(card.source_id)
        problems += card_problems(i, card, ctx)
    return problems


def card_problems(i: int, card: Any, ctx: AdviceContext) -> list[str]:
    """Rules for a single card (also used to drop a bad card if one ever gets through)."""
    doc = ctx.docs.get(card.source_id)
    if doc is None:
        return [f"swaps[{i}].source_id {card.source_id!r} is not one of the provided documents."]
    problems: list[str] = []
    if card.matched_input is not None and ctx.canonical_input(card.matched_input) is None:
        problems.append(f"swaps[{i}].matched_input must be copied exactly from the user's inputs, or be null.")
    if card.matched_input is None and ctx.inputs and not ctx.has_history:
        problems.append(f"swaps[{i}] must answer one of the user's inputs: set matched_input (there is no history).")
    if not doc.impact_source:
        for field in ("why", "impact_note"):
            if _DIGITS.search(getattr(card, field) or ""):
                problems.append(
                    f"swaps[{i}].{field} states a number, but document {doc.id} has no impact_source. "
                    "Describe the benefit in words instead."
                )
    for field in ("from_item", "to_item", "why", "tip", "impact_note"):
        text = getattr(card, field) or ""
        if text and not _in_language(text, ctx.lang):
            problems.append(f"swaps[{i}].{field} must be written in {LANG_NAMES.get(ctx.lang, ctx.lang)}.")
    return problems


def _in_language(text: str, lang: str) -> bool:
    arabic, latin = len(_ARABIC.findall(text)), len(_LATIN.findall(text))
    if lang == "ar":
        return arabic > 0 and latin <= arabic  # short Latin terms such as "LED" are fine
    return arabic == 0


def render_request(inputs: list[UserInput], history: HistorySummary | None, docs: list[SwapEntry], lang: str) -> str:
    """The user turn: inputs, history and the retrieved documents with their ids."""
    lines = [f"Output language: {LANG_NAMES.get(lang, lang)}.", ""]
    if inputs:
        lines.append("User inputs (answer these first; copy the text exactly into matched_input):")
        lines += [f'- "{i.label}"' for i in inputs]
    else:
        lines.append("The user gave no inputs; suggest the most useful everyday swaps from the documents.")
    lines.append("")
    if history is not None and (history.top_items or history.counts):
        items = ", ".join(
            f"{name} x{count}" for name, count in zip(history.top_items, history.top_item_counts, strict=False)
        ) or ", ".join(history.top_items)
        materials = ", ".join(f"{m} {n}" for m, n in sorted(history.counts.items(), key=lambda kv: -kv[1]) if n > 0)
        lines.append(
            f"Scan history (last {history.period_days} days): items: {items or 'none'}; materials: {materials or 'none'}."
        )
    else:
        lines.append("No scan history was shared: every card must answer one of the inputs.")
    lines += ["", "Swap documents (cite only these ids):"]
    for d in docs:
        lines += [
            f"[{d.id}] {d.title}",
            f"Replaces: {d.from_item} ({d.replaces_category}). Alternative: {d.to_item}.",
            f"Why: {d.why}",
            f"Tip: {d.tip}",
            f"Effort: {d.effort}. Cost: {d.cost}.",
            f"Impact note: {d.impact_note or 'none'}",
            f"Numbers allowed: {'yes, source: ' + d.impact_source if d.impact_source else 'no (no impact_source)'}",
            "",
        ]
    return "\n".join(lines).rstrip() + "\n"
