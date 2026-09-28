"""Helpers shared by the agent nodes: timing, prompt blocks and citations.

Case data (items, profile, knowledge) goes in the user turn as short labelled blocks,
while the system prompt stays static apart from the output language. Stable system
prompts are easier to review and version, and the model sees each fact once, in the
same format for every agent.
"""

from __future__ import annotations

import functools
import logging
from collections.abc import Awaitable, Callable, Iterable, Sequence
from typing import Any

from app.ai import labels, rag
from app.ai.rag import KnowledgeHit
from app.ai.safety import has_arabic
from app.core.timing import stage_timer
from app.schemas.analysis import Item
from app.schemas.common import Profile, SourceRef
from app.schemas.vocab import SAFETY_GEAR

log = logging.getLogger("kanz.pipeline")

# Total time a parallel branch may spend on Gemini (retries and fallback models included)
# before the node switches to its deterministic fallback. The gateway's own timeouts are
# per attempt; these budgets cap the whole branch so one slow model cannot hold the
# recommendation hostage. The designer gets longer because its fallback is plainer.
DESIGNER_BUDGET_S = 20.0
ADVISOR_BUDGET_S = 12.0

Node = Callable[..., Awaitable[dict[str, Any]]]


def timed(stage: str) -> Callable[[Node], Node]:
    """Record a node's latency under ``timings[stage]`` (and in the log via ``stage_timer``)."""

    def decorate(fn: Node) -> Node:
        @functools.wraps(fn)
        async def wrapper(*args: Any, **kwargs: Any) -> dict[str, Any]:
            spent: dict[str, int] = {}
            with stage_timer(spent, stage):
                out = await fn(*args, **kwargs)
            out = dict(out or {})
            out["timings"] = {**out.get("timings", {}), **spent}
            return out

        return wrapper

    return decorate


# ------------------------------------------------------------------------ prompt blocks
def item_line(item: Item, *, focus_id: str | None = None) -> str:
    parts = [
        f"- {item.id}{' (focus)' if item.id == focus_id else ''}: {item.name}",
        f"category {item.category}",
        f"material {item.material}",
        item.quantity.display,
        f"quality {item.quality.score}/5" + (f" ({item.quality.notes})" if item.quality.notes else ""),
    ]
    if item.state:
        parts.append("state: " + ", ".join(item.state))
    if item.hazards:
        parts.append("hazards: " + ", ".join(item.hazards))
    if item.is_raw_material:
        parts.append("raw material")
    if item.resin_code:
        parts.append(f"resin code {item.resin_code}")
    return " | ".join(parts)


def items_block(items: Sequence[Item], *, focus_id: str | None = None) -> str:
    return "\n".join(item_line(it, focus_id=focus_id) for it in items)


def recyclability_line(item: Item) -> str:
    rec = item.recyclability
    prep = "; ".join(rec.prep_steps) or "none given"
    return f"  analyst: status {rec.status}, stream '{rec.stream}', prep: {prep}" + (
        f", reason: {rec.reason}" if rec.reason else ""
    )


def tool_names(tools: Iterable[str]) -> str:
    names = [f"{t} ({labels.tool_label(t, 'en')})" for t in tools if t not in SAFETY_GEAR]
    return ", ".join(names) or "none"


def profile_block(profile: Profile, *, missing: Iterable[str] = ()) -> str:
    lines = [f"Skill: {profile.skill}", f"Tools they have: {tool_names(profile.tools)}"]
    missing = [t for t in missing if t not in SAFETY_GEAR]
    if missing:
        lines.append(f"Tools they do NOT have (give alternatives, never require them): {tool_names(missing)}")
    return "\n".join(lines)


def knowledge_block(hits: Sequence[KnowledgeHit]) -> str:
    if not hits:
        return "(no documents matched; rely on general good practice and cite nothing)"
    return "\n\n".join(h.text for h in hits)


def cite(source_ids: Iterable[str], hits: Sequence[KnowledgeHit], lang: str) -> list[SourceRef]:
    """Citations for the app: only ids that were actually given to the model, in order, once."""
    by_id = {h.id: h for h in hits}
    return [rag.source_ref(by_id[i], lang) for i in dict.fromkeys(source_ids) if i in by_id]


def language_problems(texts: Iterable[str | None], lang: str, *, what: str) -> list[str]:
    """Soft check that free text is in the requested language (enum ids are exempt)."""
    values = [t for t in texts if t and t.strip()]
    if not values:
        return []
    arabic = sum(1 for t in values if has_arabic(t))
    if lang == "ar" and arabic < len(values) / 2:
        return [f"Write {what} in Modern Standard Arabic; keep ids and enum values in English."]
    if lang != "ar" and arabic:
        return [f"Write {what} in English."]
    return []
