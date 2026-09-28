"""Knowledge Retriever: idempotent seeding, metadata filters, keyword fallback, citations."""

import json

import pytest

from app.ai import rag
from app.ai.rag.documents import KnowledgeHit
from app.ai.rag.index import KnowledgeIndex, build_where
from app.config import BACKEND_DIR, Settings
from app.core.errors import AiQuotaExhausted

from .conftest import FakeGateway

KNOWLEDGE = BACKEND_DIR / "knowledge"


@pytest.fixture
def small_kb(tmp_path):
    """A three-project knowledge dir the tests can edit."""
    kb = tmp_path / "kb"
    (kb / "projects").mkdir(parents=True)
    glass = json.loads((KNOWLEDGE / "projects" / "glass.json").read_text(encoding="utf-8"))[:2]
    textile = json.loads((KNOWLEDGE / "projects" / "textile.json").read_text(encoding="utf-8"))[:1]
    (kb / "projects" / "glass.json").write_text(json.dumps(glass), encoding="utf-8")
    (kb / "projects" / "textile.json").write_text(json.dumps(textile), encoding="utf-8")
    return kb


def make_index(tmp_path, gateway, knowledge_dir=KNOWLEDGE) -> KnowledgeIndex:
    s = Settings(_env_file=None, gemini_api_key="k", data_dir=tmp_path / "data", knowledge_dir=knowledge_dir)
    return KnowledgeIndex(s, gateway=gateway)


async def test_keyword_fallback_when_embeddings_fail(tmp_path):
    index = make_index(tmp_path, FakeGateway(embed_error=AiQuotaExhausted()))
    count = await index.seed()
    assert count >= 86
    assert index.status() == (count, False)
    hits = await index.retrieve("glass jar lantern tea light", kinds=["project"], materials=["glass"], k=3)
    assert hits[0].id == "proj_glass_jar_lantern"
    assert all(h.kind == "project" and "glass" in h.metadata["materials"] for h in hits)


async def test_keyword_filters_by_kind_and_material(tmp_path):
    index = make_index(tmp_path, FakeGateway(embed_error=AiQuotaExhausted()))
    hits = await index.retrieve("battery tape terminals", kinds=["safety"], k=3)
    assert hits and hits[0].id == "safety_batteries"
    wood = await index.retrieve("crate shelf planter", kinds=["project"], materials=["wood"], k=5)
    assert wood and all("wood" in h.metadata["materials"] for h in wood)


async def test_seeding_embeds_once_and_is_idempotent(tmp_path, small_kb):
    gateway = FakeGateway()
    index = make_index(tmp_path, gateway, small_kb)
    assert await index.seed() == 3
    assert index.status() == (3, True)
    assert len(gateway.embedded) == 3

    again = make_index(tmp_path, gateway, small_kb)  # a restart: same chroma dir, same files
    assert await again.seed() == 3
    assert again.vector_ready
    assert len(gateway.embedded) == 3  # nothing re-embedded


async def test_changed_and_removed_documents_are_synced(tmp_path, small_kb):
    gateway = FakeGateway()
    await make_index(tmp_path, gateway, small_kb).seed()
    glass = json.loads((small_kb / "projects" / "glass.json").read_text(encoding="utf-8"))
    glass[0]["summary"] = "A different summary that changes the embedded text entirely."
    (small_kb / "projects" / "glass.json").write_text(json.dumps(glass[:1]), encoding="utf-8")

    index = make_index(tmp_path, gateway, small_kb)
    assert await index.seed() == 2
    assert len(gateway.embedded) == 4  # three at first, then only the edited one
    stored = index._collection.get()["ids"]
    assert sorted(stored) == sorted(index.docs)


async def test_vector_search_uses_query_embeddings_and_filters(tmp_path):
    gateway = FakeGateway()
    index = make_index(tmp_path, gateway)
    await index.seed()
    hits = await index.retrieve("hanging jar lantern with wire and tea light", kinds=["project"], materials=["glass"])
    assert hits[0].id == "proj_glass_jar_lantern"
    assert all("glass" in h.metadata["materials"] for h in hits)
    assert 0 <= hits[0].score <= 1
    before = len(gateway.embedded)
    await index.retrieve("hanging jar lantern with wire and tea light", kinds=["project"])
    assert len(gateway.embedded) == before  # the query embedding is cached


async def test_query_embedding_failure_falls_back_to_keywords(tmp_path):
    gateway = FakeGateway()
    index = make_index(tmp_path, gateway)
    await index.seed()
    gateway.embed_error = AiQuotaExhausted()
    hits = await index.retrieve("t-shirt tote bag", kinds=["project"], materials=["textile"])
    assert hits and hits[0].id == "proj_textile_tshirt_tote"


def test_where_filter_combines_kinds_and_material_flags():
    assert build_where(["project"], None) == {"kind": "project"}
    assert build_where(["project", "safety"], ["glass"]) == {
        "$and": [{"kind": {"$in": ["project", "safety"]}}, {"m_glass": True}]
    }
    assert build_where(["project"], ["glass", "metal", "unknown"]) == {
        "$and": [{"kind": "project"}, {"$or": [{"m_glass": True}, {"m_metal": True}]}]
    }


def test_direct_lookups_cover_guides_and_safety(tmp_path):
    index = make_index(tmp_path, FakeGateway())
    guides = index.material_guides(["glass", "plastic"], [1])
    assert [g.id for g in guides] == ["mat_glass", "mat_plastic", "resin_1_pet"]
    safety_ids = {h.id for h in index.safety_for(hazards=["battery"], techniques=["drilling"])}
    assert {"safety_batteries", "safety_drilling"} <= safety_ids


def test_source_ref_is_localized():
    hit = KnowledgeHit(id="mat_glass", kind="material_guide", title="Glass guide", title_ar="دليل الزجاج", text="")
    assert rag.source_ref(hit, "en").title == "Glass guide"
    assert rag.source_ref(hit, "ar").title == "دليل الزجاج"


async def test_public_seam_uses_the_shared_index():
    hits = await rag.retrieve("glass jar", kinds=["project"], materials=["glass"], k=2)
    assert len(hits) == 2
    count, ready = rag.status()
    assert count >= 86 and ready is False


async def test_missing_chroma_dir_permissions_do_not_break_retrieval(tmp_path, monkeypatch):
    index = make_index(tmp_path, FakeGateway())
    monkeypatch.setattr(index, "_open_collection", lambda: (_ for _ in ()).throw(OSError("read-only")))
    assert await index.seed() >= 86
    assert not index.vector_ready
    assert await index.retrieve("jar", kinds=["project"])
