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
"""
