"""Knowledge Retriever (RAG over backend/knowledge via ChromaDB). Owned by the AI Pipeline workstream.

Public seam used by other packages (keep these signatures):

    @dataclass
    class KnowledgeHit:
        id: str; kind: str; title: str; title_ar: str | None; text: str; metadata: dict; score: float

    async def retrieve(query: str, *, kinds: Sequence[str], materials: Sequence[str] | None = None,
                       k: int = 6) -> list[KnowledgeHit]
    def source_ref(hit: KnowledgeHit, lang: str) -> SourceRef
    async def seed_knowledge() -> int          # idempotent; called once at startup
    def status() -> tuple[int, bool]           # (documents indexed, ready)

How it grounds the agents: the knowledge base is original, reviewed writing (projects,
material guides, resin codes, safety rules). Agents receive the retrieved documents' text
with their ids and may only cite those ids, so every idea, recycling instruction and
disposal rule shown in the app can point at the document it came from (``sources``).

``seed_knowledge`` should run in a background task at startup: until the vector index is
ready (or if embeddings are unavailable), ``retrieve`` answers from the BM25 fallback.
"""

from __future__ import annotations

from collections.abc import Sequence

from app.ai.rag.documents import KnowledgeHit
from app.ai.rag.index import get_index
from app.schemas.common import SourceRef

__all__ = ["KnowledgeHit", "retrieve", "seed_knowledge", "source_ref", "status"]


async def retrieve(
    query: str, *, kinds: Sequence[str], materials: Sequence[str] | None = None, k: int = 6
) -> list[KnowledgeHit]:
    """Top ``k`` documents of the given kinds (optionally about any of ``materials``) for ``query``."""
    return await get_index().retrieve(query, kinds=kinds, materials=materials, k=k)


def source_ref(hit: KnowledgeHit, lang: str) -> SourceRef:
    """A citation chip for the app, titled in the request language."""
    title = hit.title_ar if lang == "ar" and hit.title_ar else hit.title
    return SourceRef(id=hit.id, title=title, kind=hit.kind)  # type: ignore[arg-type]


async def seed_knowledge() -> int:
    """Sync the vector index with ``backend/knowledge`` (idempotent). Returns the document count."""
    return await get_index().seed()


def status() -> tuple[int, bool]:
    """(documents loaded, vector index ready). When not ready, retrieval uses the keyword fallback."""
    return get_index().status()
