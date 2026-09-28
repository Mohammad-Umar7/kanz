"""The three LangGraph state graphs behind /v1/analyze, /v1/recommend and /v1/tutorial.

Analyze (sequential)::

    classifier_hint -> material_analyst -> safety_normalise

Recommend (routed, then a parallel fan-out)::

    safety_router --disposal_only--> [disposal_advisor || dropoff_locator] --------------------> assemble
                  --diy / mixed----> knowledge_retriever
                                       -> [upcycle_designer || recycling_advisor || donation_advisor
                                           || dropoff_locator (|| disposal_advisor when mixed)] -> assemble

Tutorial (sequential)::

    tutorial_retriever -> tutorial_writer -> finalize (save + start the step-image chain)

Every node is an ``async`` function of the typed state (``app.ai.state``) and receives its
dependencies through the runtime context, so the same graphs run against Gemini in
production and against a scripted fake in the tests.
"""

from __future__ import annotations

from functools import lru_cache

from langgraph.graph import END, START, StateGraph

from app.ai.nodes.analyst import classifier_hint, material_analyst, safety_normalise
from app.ai.nodes.assemble import assemble
from app.ai.nodes.disposal import disposal_advisor
from app.ai.nodes.donation import donation_advisor
from app.ai.nodes.dropoff import dropoff_locator
from app.ai.nodes.recycling import recycling_advisor
from app.ai.nodes.retriever import knowledge_retriever, tutorial_retriever
from app.ai.nodes.router import branch_after_retrieval, branch_after_router, safety_router
from app.ai.nodes.tutorial import finalize, tutorial_writer
from app.ai.nodes.upcycle import upcycle_designer
from app.ai.state import AnalyzeState, PipelineContext, RecommendState, TutorialState


@lru_cache
def analyze_graph():
    g = StateGraph(AnalyzeState, context_schema=PipelineContext)
    g.add_node("classifier_hint", classifier_hint)
    g.add_node("material_analyst", material_analyst)
    g.add_node("safety_normalise", safety_normalise)
    g.add_edge(START, "classifier_hint")
    g.add_edge("classifier_hint", "material_analyst")
    g.add_edge("material_analyst", "safety_normalise")
    g.add_edge("safety_normalise", END)
    return g.compile(name="kanz_analyze")


@lru_cache
def recommend_graph():
    g = StateGraph(RecommendState, context_schema=PipelineContext)
    g.add_node("safety_router", safety_router)
    g.add_node("knowledge_retriever", knowledge_retriever)
    g.add_node("upcycle_designer", upcycle_designer)
    g.add_node("recycling_advisor", recycling_advisor)
    g.add_node("donation_advisor", donation_advisor)
    g.add_node("disposal_advisor", disposal_advisor)
    g.add_node("dropoff_locator", dropoff_locator)
    g.add_node("assemble", assemble)

    g.add_edge(START, "safety_router")
    g.add_conditional_edges(
        "safety_router", branch_after_router, ["knowledge_retriever", "disposal_advisor", "dropoff_locator"]
    )
    g.add_conditional_edges(
        "knowledge_retriever",
        branch_after_retrieval,
        ["upcycle_designer", "recycling_advisor", "donation_advisor", "dropoff_locator", "disposal_advisor"],
    )
    # Every branch of a fan-out finishes in the same step, so assemble runs once, after all of them.
    for branch in ("upcycle_designer", "recycling_advisor", "donation_advisor", "disposal_advisor", "dropoff_locator"):
        g.add_edge(branch, "assemble")
    g.add_edge("assemble", END)
    return g.compile(name="kanz_recommend")


@lru_cache
def tutorial_graph():
    g = StateGraph(TutorialState, context_schema=PipelineContext)
    g.add_node("tutorial_retriever", tutorial_retriever)
    g.add_node("tutorial_writer", tutorial_writer)
    g.add_node("finalize", finalize)
    g.add_edge(START, "tutorial_retriever")
    g.add_edge("tutorial_retriever", "tutorial_writer")
    g.add_edge("tutorial_writer", "finalize")
    g.add_edge("finalize", END)
    return g.compile(name="kanz_tutorial")
