"""Kanz AI pipeline: multimodal agents orchestrated with LangGraph, grounded with RAG.

Layout:

* ``gemini.py``       the single gateway to Gemini (structured output, repair round, fallbacks).
* ``prompts.py``      versioned agent prompts loaded from ``backend/prompts/<agent>.md``.
* ``llm_schemas.py``  compact JSON shapes the models must produce (sent as response schemas).
* ``convert.py``      deterministic conversion of model output into the public API models.
* ``safety.py``       hazard normalisation, the Safety Router and the output safety validators.
* ``classifier.py``   pluggable on-device/fine-tuned material classifier hook (no-op by default).
* ``rag/``            the Knowledge Retriever: ChromaDB + Gemini embeddings, keyword fallback.
* ``nodes/``          one module per agent node.
* ``graph.py``        the analyze, recommend and tutorial LangGraph state graphs.
* ``pipeline.py``     the three public entry points used by the API routes.
"""
