"""Knowledge Retriever nodes (RAG) for the recommend and tutorial graphs.

Two retrieval styles are combined on purpose:

* **Semantic search** (Chroma + Gemini embeddings) for open questions such as "which
  projects suit a cracked blue jar and a lid?", filtered by kind and material.
* **Direct lookup** for facts that must always be present: the material guide for every
  scanned material, the resin-code guide for every resin code, and the safety document
  for every hazard or technique involved. Safety grounding should never depend on a
  similarity score.
"""

from __future__ import annotations

from collections.abc import Iterable, Sequence

from app.ai import rag
from app.ai.nodes.common import timed
from app.ai.rag import KnowledgeHit
from app.ai.rag.index import get_index
from app.ai.safety import detect_techniques
from app.ai.state import RecommendState, TutorialState
from app.schemas.analysis import Item

DIY_MATERIALS = ("glass", "plastic", "paper", "metal", "textile", "wood")
PROJECTS_K = 8


def _dedupe(hits: Iterable[KnowledgeHit]) -> list[KnowledgeHit]:
    seen: dict[str, KnowledgeHit] = {}
    for h in hits:
        seen.setdefault(h.id, h)
    return list(seen.values())


def project_query(items: Sequence[Item], focus: Item | None) -> str:
    """Query text for project search: names plus English category ids (which the documents share)."""
    ordered = ([focus] if focus else []) + [it for it in items if focus is None or it.id != focus.id]
    parts = [f"{it.name} ({it.category}, {it.material})" for it in ordered]
    query = "Upcycling project ideas for: " + "; ".join(parts)
    if focus is not None and focus.is_raw_material:
        query += ". Uses many small pieces or scraps."
    return query


@timed("retrieval")
async def knowledge_retriever(state: RecommendState) -> dict:
    items = state["diy_items"]
    focus = next((it for it in items if it.id == state.get("focus_id")), items[0] if items else None)
    materials = [m for m in dict.fromkeys(it.category for it in items) if m in DIY_MATERIALS]
    query = project_query(items, focus)

    projects = await rag.retrieve(query, kinds=["project"], materials=materials or None, k=PROJECTS_K)
    if len(projects) < 4:
        # Unusual materials (organic, other) or a thin match: widen to every project.
        projects = _dedupe([*projects, *await rag.retrieve(query, kinds=["project"], k=PROJECTS_K)])

    index = get_index()
    guides = index.material_guides(
        (it.category for it in items), (it.resin_code for it in items if it.resin_code is not None)
    )
    return {"projects": projects, "guides": guides}


@timed("retrieval")
async def tutorial_retriever(state: TutorialState) -> dict:
    req = state["request"]
    idea = req.idea
    index = get_index()
    cited = index.get(s.id for s in idea.sources)
    categories = [m for m in dict.fromkeys(it.category for it in req.items) if m in DIY_MATERIALS]
    similar = await rag.retrieve(
        f"{idea.title}. {idea.pitch} {idea.after_visual}", kinds=["project"], materials=categories or None, k=3
    )
    projects = _dedupe([*cited, *similar])[:3]

    techniques = detect_techniques([idea.title, idea.pitch, idea.after_visual], idea.tools_needed)
    for hit in projects:
        techniques |= set(hit.metadata.get("techniques", []))
    hazards = {h for it in req.items for h in it.hazards}
    safety_docs = index.safety_for(hazards=hazards, techniques=techniques)
    return {"knowledge": _dedupe([*projects, *safety_docs[:5]])}
