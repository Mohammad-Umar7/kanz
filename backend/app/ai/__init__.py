"""Kanz AI pipeline: multimodal agents orchestrated with LangGraph, grounded with RAG.

Layout:

* ``gemini.py``       the single gateway to Gemini (structured output, repair round, fallbacks).
* ``prompts.py``      versioned agent prompts loaded from ``backend/prompts/<agent>.md``.
* ``llm_schemas.py``  compact JSON shapes the models must produce (sent as response schemas).
* ``convert.py``      deterministic conversion of model output into the public API models.
* ``labels.py``       localized labels from the shared vocabulary (``contracts/vocab.json``).
* ``safety.py``       hazard normalisation, the Safety Router and the output safety validators.
* ``textmatch.py``    bilingual keyword matching with negation scope, used by the validators.
* ``fallbacks.py``    reviewed, localized content used when a recommendation branch fails.
* ``classifier.py``   pluggable fine-tuned material classifier hook (no-op by default).
* ``rag/``            the Knowledge Retriever: ChromaDB + Gemini embeddings, BM25 fallback.
* ``state.py``        typed graph state and the runtime context carrying dependencies.
* ``nodes/``          one module per agent node.
* ``graph.py``        the analyze, recommend and tutorial LangGraph state graphs.
* ``pipeline.py``     the three public entry points used by the API routes.

Division of labour: models do what needs judgement (seeing, writing, adapting); code does
everything that must be exact (ids, bounding boxes, labels, hazard routing, tool
availability, citations) and checks the models' output before anyone sees it.
"""
