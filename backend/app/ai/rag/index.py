"""The knowledge index: ChromaDB vectors (Gemini embeddings) with a BM25 fallback.

* **Seeding** is idempotent. Each document's embedded text is hashed (salted with the
  embedding model and dimension); a manifest hash over all of them lets a restart skip
  the work entirely when nothing changed. Otherwise only new or edited documents are
  embedded (``RETRIEVAL_DOCUMENT``) and upserted, and removed ones are deleted.
* **Metadata filters.** Every vector carries ``kind`` plus one boolean flag per material
  (``m_glass=True``...), so a query can be limited to e.g. projects for glass or metal
  with a Chroma ``$and`` / ``$or`` filter.
* **Queries** are embedded with ``RETRIEVAL_QUERY`` (asymmetric retrieval) and cached,
  since the recommend graph asks several filtered questions about the same scan.
* **Fallback.** If embeddings fail at seed or query time, the same documents are searched
  with BM25, so ``retrieve`` always answers.
"""

from __future__ import annotations

import asyncio
import hashlib
import json
import logging
from collections import OrderedDict
from collections.abc import Iterable, Sequence
from typing import Any

import chromadb
from chromadb.config import Settings as ChromaSettings

from app.ai.gemini import GeminiGateway, get_gateway
from app.ai.rag.documents import (
    KnowledgeDoc,
    KnowledgeHit,
    MaterialGuideDoc,
    SafetyDoc,
    doc_hash,
    load_documents,
    render_text,
    to_hit,
)
from app.ai.rag.keyword import KeywordIndex
from app.config import Settings, get_settings
from app.schemas.vocab import MATERIAL_CATEGORIES

log = logging.getLogger("kanz.rag")

COLLECTION = "kanz_knowledge"
_EMBED_CHUNK = 50  # documents per embedding request; keeps each call well inside free-tier token limits
_QUERY_CACHE = 256


def material_flag(category: str) -> str:
    return f"m_{category}"


def build_where(kinds: Sequence[str], materials: Sequence[str] | None) -> dict[str, Any] | None:
    """Chroma metadata filter: kind in ``kinds`` AND (any of the material flags)."""
    clauses: list[dict[str, Any]] = []
    kinds = list(dict.fromkeys(kinds))
    if len(kinds) == 1:
        clauses.append({"kind": kinds[0]})
    elif kinds:
        clauses.append({"kind": {"$in": kinds}})
    flags = [{material_flag(m): True} for m in dict.fromkeys(materials or []) if m in MATERIAL_CATEGORIES]
    if len(flags) == 1:
        clauses.append(flags[0])
    elif flags:
        clauses.append({"$or": flags})
    if not clauses:
        return None
    return clauses[0] if len(clauses) == 1 else {"$and": clauses}


class KnowledgeIndex:
    def __init__(self, settings: Settings | None = None, gateway: GeminiGateway | None = None) -> None:
        self.settings = settings or get_settings()
        self._gateway = gateway
        self.docs: dict[str, KnowledgeDoc] = {}
        self.texts: dict[str, str] = {}
        self.keyword: KeywordIndex | None = None
        self.vector_ready = False
        self._collection: Any = None
        self._queries: OrderedDict[str, list[float]] = OrderedDict()
        self._seed_lock = asyncio.Lock()

    # ------------------------------------------------------------------ loading
    @property
    def gateway(self) -> GeminiGateway:
        return self._gateway or get_gateway()

    @property
    def salt(self) -> str:
        return f"{self.settings.model_embed}:{self.settings.embed_dim}"

    def load(self) -> None:
        """Load documents and build the keyword index (cheap, synchronous, done once)."""
        if self.keyword is not None:
            return
        docs, _ = load_documents(self.settings.knowledge_dir)
        self.docs = {d.id: d for d in docs}
        self.texts = {d.id: render_text(d) for d in docs}
        self.keyword = KeywordIndex(self.texts.items())
        log.info("knowledge loaded docs=%d", len(docs))

    # ------------------------------------------------------------------ seeding
    def _open_collection(self) -> Any:
        self.settings.chroma_dir.mkdir(parents=True, exist_ok=True)
        client = chromadb.PersistentClient(
            path=str(self.settings.chroma_dir), settings=ChromaSettings(anonymized_telemetry=False)
        )
        meta = {"embed_model": self.settings.model_embed, "embed_dim": self.settings.embed_dim}
        collection = client.get_or_create_collection(
            COLLECTION, configuration={"hnsw": {"space": "cosine"}}, metadata=meta, embedding_function=None
        )
        stored = collection.metadata or {}
        if stored.get("embed_model") != meta["embed_model"] or stored.get("embed_dim") != meta["embed_dim"]:
            # Vectors from another model or dimension are not comparable: start the collection over.
            client.delete_collection(COLLECTION)
            collection = client.get_or_create_collection(
                COLLECTION, configuration={"hnsw": {"space": "cosine"}}, metadata=meta, embedding_function=None
            )
        return collection

    def manifest_hash(self) -> str:
        parts = sorted(f"{doc_id}:{doc_hash(doc, self.salt)}" for doc_id, doc in self.docs.items())
        return hashlib.sha256("\n".join(parts).encode()).hexdigest()[:24]

    def _metadata(self, doc: KnowledgeDoc) -> dict[str, Any]:
        meta: dict[str, Any] = {"kind": doc.kind, "hash": doc_hash(doc, self.salt)}
        for m in MATERIAL_CATEGORIES:
            meta[material_flag(m)] = m in doc.materials
        return meta

    async def seed(self) -> int:
        """Idempotently sync the Chroma collection with the knowledge files. Returns the document count."""
        async with self._seed_lock:
            self.load()
            manifest_path = self.settings.chroma_dir / "manifest.json"
            manifest = self.manifest_hash()
            try:
                collection = await asyncio.to_thread(self._open_collection)
            except Exception as exc:
                log.warning("chroma unavailable, using keyword retrieval: %s", exc)
                self.vector_ready = False
                return len(self.docs)
            self._collection = collection

            try:
                previous = json.loads(manifest_path.read_text(encoding="utf-8")).get("hash")
            except (OSError, ValueError):
                previous = None
            count = await asyncio.to_thread(collection.count)
            if previous == manifest and count == len(self.docs):
                self.vector_ready = True
                log.info("knowledge index up to date docs=%d manifest=%s", count, manifest)
                return len(self.docs)

            existing = await asyncio.to_thread(collection.get, include=["metadatas"])
            stored = {
                i: (m or {}).get("hash") for i, m in zip(existing["ids"], existing["metadatas"] or [], strict=False)
            }
            removed = [i for i in stored if i not in self.docs]
            changed = [d for i, d in self.docs.items() if stored.get(i) != doc_hash(d, self.salt)]
            if removed:
                await asyncio.to_thread(collection.delete, ids=removed)
            try:
                for start in range(0, len(changed), _EMBED_CHUNK):
                    chunk = changed[start : start + _EMBED_CHUNK]
                    vectors = await self.gateway.embed(
                        [self.texts[d.id] for d in chunk], task_type="RETRIEVAL_DOCUMENT"
                    )
                    await asyncio.to_thread(
                        collection.upsert,
                        ids=[d.id for d in chunk],
                        embeddings=vectors,
                        documents=[self.texts[d.id] for d in chunk],
                        metadatas=[self._metadata(d) for d in chunk],
                    )
            except Exception as exc:
                # Partial progress is kept (hashes are per document); the next start resumes.
                log.warning("embedding failed, using keyword retrieval until the next seed: %s", exc)
                self.vector_ready = False
                return len(self.docs)

            count = await asyncio.to_thread(collection.count)
            self.vector_ready = count == len(self.docs)
            if self.vector_ready:
                manifest_path.write_text(json.dumps({"hash": manifest, "count": count, "salt": self.salt}), "utf-8")
            log.info(
                "knowledge index seeded docs=%d embedded=%d removed=%d ready=%s",
                count,
                len(changed),
                len(removed),
                self.vector_ready,
            )
            return len(self.docs)

    # ------------------------------------------------------------------ queries
    async def _query_vector(self, query: str) -> list[float]:
        cached = self._queries.get(query)
        if cached is not None:
            self._queries.move_to_end(query)
            return cached
        (vector,) = await self.gateway.embed([query], task_type="RETRIEVAL_QUERY")
        self._queries[query] = vector
        if len(self._queries) > _QUERY_CACHE:
            self._queries.popitem(last=False)
        return vector

    def _allowed(self, kinds: Sequence[str], materials: Sequence[str] | None):
        wanted_kinds, wanted_materials = set(kinds), set(materials or [])

        def allow(doc_id: str) -> bool:
            doc = self.docs[doc_id]
            if wanted_kinds and doc.kind not in wanted_kinds:
                return False
            return not wanted_materials or bool(wanted_materials & set(doc.materials))

        return allow

    async def retrieve(
        self, query: str, *, kinds: Sequence[str], materials: Sequence[str] | None = None, k: int = 6
    ) -> list[KnowledgeHit]:
        self.load()
        if self.vector_ready and self._collection is not None and query.strip():
            try:
                vector = await self._query_vector(query)
                result = await asyncio.to_thread(
                    self._collection.query,
                    query_embeddings=[vector],
                    n_results=max(1, k),
                    where=build_where(kinds, materials),
                    include=["distances"],
                )
                ids, distances = result["ids"][0], result["distances"][0]
                return [
                    to_hit(self.docs[i], score=max(0.0, 1.0 - float(d)))
                    for i, d in zip(ids, distances, strict=False)
                    if i in self.docs
                ]
            except Exception as exc:
                log.warning("vector query failed, falling back to keywords: %s", exc)
        assert self.keyword is not None
        pairs = self.keyword.search(query, k=k, allow=self._allowed(kinds, materials))
        return [to_hit(self.docs[i], score=s) for i, s in pairs]

    # ------------------------------------------------------------ direct lookups
    def get(self, ids: Iterable[str]) -> list[KnowledgeHit]:
        """Documents by id, in the given order (unknown ids are skipped)."""
        self.load()
        return [to_hit(self.docs[i]) for i in dict.fromkeys(ids) if i in self.docs]

    def material_guides(self, categories: Iterable[str], resin_codes: Iterable[int] = ()) -> list[KnowledgeHit]:
        """The material guide for each category plus the resin-code guide for each code."""
        self.load()
        wanted = [f"mat_{c}" for c in dict.fromkeys(categories)]
        codes = set(resin_codes)
        resin = [d.id for d in self.docs.values() if isinstance(d, MaterialGuideDoc) and d.resin_code in codes]
        return self.get([*wanted, *resin])

    def safety_for(self, *, hazards: Iterable[str] = (), techniques: Iterable[str] = ()) -> list[KnowledgeHit]:
        """Safety documents that apply to any of the hazards or techniques."""
        self.load()
        hz, tq = set(hazards), set(techniques)
        return [
            to_hit(d)
            for d in self.docs.values()
            if isinstance(d, SafetyDoc) and (hz & set(d.applies_to.hazards) or tq & set(d.applies_to.techniques))
        ]

    def status(self) -> tuple[int, bool]:
        self.load()
        return len(self.docs), self.vector_ready


_index: KnowledgeIndex | None = None


def get_index() -> KnowledgeIndex:
    global _index
    if _index is None:
        _index = KnowledgeIndex()
    return _index
