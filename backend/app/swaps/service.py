"""Swap Advisor: a small LangGraph agent over the swap knowledge base.

Public seam:  async def suggest(req: SwapsRequest) -> SwapsResponse

    START -> retrieve -> advise -> validate -> END
                 \\________(no documents)______/

* **retrieve** normalizes the inputs (chip ids become readable text) and asks the
  Knowledge Retriever (``app.ai.rag``) for swap documents: one query per input plus one
  for the scan history, run concurrently and interleaved so every input is represented.
* **advise** asks Gemini for 3-6 cards through the shared gateway, with a per-request
  schema (document ids and inputs as enums) and the validator from ``advisor.py``; the
  gateway runs one repair round if the validator objects.
* **validate** is the deterministic last word: it re-checks every card, drops any that
  still break a rule, copies effort, cost, material and the source chip from the
  knowledge base, and orders cards by the user's inputs.

The history insight line is computed from the device's counts without a model.
"""

from __future__ import annotations

import asyncio
import logging
import time
from collections.abc import Awaitable, Callable, Sequence
from dataclasses import dataclass
from typing import Annotated, Any, TypedDict

from langgraph.graph import END, START, StateGraph
from langgraph.runtime import Runtime

from app.ai.gemini import GeminiGateway, get_gateway
from app.ai.prompts import load_prompt
from app.core.errors import AiUnavailable, KanzError
from app.core.timing import stage_timer
from app.schemas.common import SourceRef
from app.schemas.swaps import Swap, SwapsRequest, SwapsResponse
from app.swaps.advisor import (
    LANG_NAMES,
    MAX_CARDS,
    AdviceContext,
    advice_problems,
    advice_schema,
    card_problems,
    render_request,
)
from app.swaps.inputs import UserInput, normalize_inputs
from app.swaps.insight import history_insight, history_query
from app.swaps.knowledge import SwapEntry, swap_catalog

log = logging.getLogger("kanz.swaps")

PER_INPUT_K = 3  # documents retrieved for each input
HISTORY_K = 3
GENERAL_K = 6
MAX_DOCS = 10  # keeps the prompt short; more choice than that does not improve the cards
GENERAL_QUERY = "everyday single-use items at home: bags, bottles, wraps, cups"

# The retriever seam: ``app.ai.rag.retrieve`` (returns KnowledgeHit objects with an ``id``).
Retriever = Callable[..., Awaitable[Sequence[Any]]]


def _merge(a: dict[str, int], b: dict[str, int]) -> dict[str, int]:
    return {**a, **b}


class SwapState(TypedDict, total=False):
    request: SwapsRequest
    inputs: list[UserInput]
    docs: list[SwapEntry]
    advice: Any
    swaps: list[Swap]
    timings: Annotated[dict[str, int], _merge]


@dataclass(frozen=True)
class SwapContext:
    gateway: GeminiGateway
    retriever: Retriever


# ------------------------------------------------------------------------ nodes
async def retrieve(state: SwapState, runtime: Runtime[SwapContext]) -> dict:
    req = state["request"]
    inputs = normalize_inputs(req.materials, req.lang)
    queries = [(i.query, PER_INPUT_K) for i in inputs]
    if hq := history_query(req.history):
        queries.append((hq, HISTORY_K))
    if not queries:
        queries = [(GENERAL_QUERY, GENERAL_K)]

    timings: dict[str, int] = {}
    with stage_timer(timings, "retrieval"):
        try:
            results = await asyncio.gather(*(runtime.context.retriever(q, kinds=["swap"], k=k) for q, k in queries))
        except KanzError:
            raise
        except Exception as exc:
            raise AiUnavailable(detail=f"swap retrieval failed: {type(exc).__name__}: {exc}") from exc

    catalog = swap_catalog()
    docs: list[SwapEntry] = []
    # Round-robin over the queries so the best match for every input comes first.
    for rank in range(max(len(r) for r in results)):
        for hits in results:
            if rank < len(hits) and (doc := catalog.get(hits[rank].id)) and doc not in docs:
                docs.append(doc)
    return {"inputs": inputs, "docs": docs[:MAX_DOCS], "timings": timings}


async def advise(state: SwapState, runtime: Runtime[SwapContext]) -> dict:
    req, inputs, docs = state["request"], state["inputs"], state["docs"]
    prompt = load_prompt("swap_advisor")
    ctx = AdviceContext(docs={d.id: d for d in docs}, inputs=inputs, has_history=_has_history(req), lang=req.lang)
    timings: dict[str, int] = {}
    with stage_timer(timings, "swap_advisor"):
        advice = await runtime.context.gateway.structured(
            stage="swap_advisor",
            system=prompt.render(lang_name=LANG_NAMES[req.lang]),
            contents=[render_request(inputs, req.history, docs, req.lang)],
            schema=advice_schema([d.id for d in docs], [i.label for i in inputs]),
            model=prompt.model(),
            validator=lambda a: advice_problems(a, ctx),
            temperature=prompt.temperature,
            thinking_level=prompt.thinking_level,
        )
    log.info("swap_advisor prompt=%s cards=%d", prompt.tag, len(advice.swaps))
    return {"advice": advice, "timings": timings}


async def validate(state: SwapState) -> dict:
    req, inputs, docs = state["request"], state.get("inputs", []), state.get("docs", [])
    advice = state.get("advice")
    ctx = AdviceContext(docs={d.id: d for d in docs}, inputs=inputs, has_history=_has_history(req), lang=req.lang)
    order = {i.label: n for n, i in enumerate(inputs)}
    swaps: list[Swap] = []
    used: set[str] = set()
    for n, card in enumerate(getattr(advice, "swaps", None) or []):
        problems = card_problems(n, card, ctx)
        if problems or card.source_id in used:
            log.warning("swap card dropped: %s", "; ".join(problems) or f"duplicate {card.source_id}")
            continue
        used.add(card.source_id)
        doc = ctx.docs[card.source_id]
        matched = ctx.canonical_input(card.matched_input)
        swaps.append(
            Swap(
                id=doc.id,
                from_item=card.from_item.strip(),
                to_item=card.to_item.strip(),
                why=card.why.strip(),
                tip=card.tip.strip(),
                effort=doc.effort,
                cost=doc.cost,
                category=doc.replaces_category,
                impact_note=(card.impact_note or "").strip() or None,
                matched_input=matched,
                from_history=matched is None and _has_history(req),
                sources=[SourceRef(id=doc.id, title=doc.title_for(req.lang), kind="swap")],
            )
        )
    # Cards for the user's inputs first, in the order they were given; history cards after.
    swaps.sort(key=lambda s: order.get(s.matched_input, len(order)) if s.matched_input else len(order))
    return {"swaps": swaps[:MAX_CARDS]}


def _after_retrieve(state: SwapState) -> str:
    return "advise" if state.get("docs") else "validate"


def _has_history(req: SwapsRequest) -> bool:
    h = req.history
    return h is not None and bool(h.top_items or any(n > 0 for n in h.counts.values()))


def build_graph():
    graph = StateGraph(SwapState, context_schema=SwapContext)
    graph.add_node("retrieve", retrieve)
    graph.add_node("advise", advise)
    graph.add_node("validate", validate)
    graph.add_edge(START, "retrieve")
    graph.add_conditional_edges("retrieve", _after_retrieve, {"advise": "advise", "validate": "validate"})
    graph.add_edge("advise", "validate")
    graph.add_edge("validate", END)
    return graph.compile()


_graph = None


def _compiled():
    global _graph
    if _graph is None:
        _graph = build_graph()
    return _graph


# ------------------------------------------------------------------------ seam
async def suggest(
    req: SwapsRequest, *, gateway: GeminiGateway | None = None, retriever: Retriever | None = None
) -> SwapsResponse:
    """Swap cards for the user's inputs and scan history, grounded in the swap knowledge base."""
    started = time.perf_counter()
    if retriever is None:
        # Imported lazily: importing the index is cheap, but it pulls in ChromaDB for every caller.
        from app.ai import rag  # noqa: PLC0415

        retriever = rag.retrieve
    context = SwapContext(gateway=gateway or get_gateway(), retriever=retriever)
    final = await _compiled().ainvoke({"request": req, "timings": {}}, context=context)
    timings = dict(final.get("timings", {}))
    timings["total"] = int((time.perf_counter() - started) * 1000)
    return SwapsResponse(
        swaps=final.get("swaps", []),
        history_insight=history_insight(req.history, req.lang),
        lang=req.lang,
        timings_ms=timings,
    )
