"""The swap knowledge base: valid, original, qualitative, and loadable by the RAG seeder."""

import re
import shutil

from app.ai.rag.documents import load_documents
from app.config import get_settings
from app.swaps.knowledge import SWAPS_FILE, load_swaps, swap_catalog

DIGITS = re.compile(r"[0-9٠-٩%]")
ARABIC = re.compile(r"[؀-ۿ]")


def test_at_least_32_valid_documents_with_unique_ids():
    entries = load_swaps(get_settings().knowledge_dir / SWAPS_FILE)
    assert len(entries) >= 32
    assert len({e.id for e in entries}) == len(entries)
    assert all(e.id.startswith("swap_") for e in entries)


def test_every_title_has_an_arabic_version():
    for entry in swap_catalog().values():
        assert ARABIC.search(entry.title_ar), entry.id


def test_no_numeric_claims_without_a_source():
    for entry in swap_catalog().values():
        if entry.impact_source is None:
            assert not DIGITS.search(entry.why), entry.id
            assert not DIGITS.search(entry.impact_note or ""), entry.id


def test_covers_the_common_single_use_items():
    keywords = " ".join(k.lower() for e in swap_catalog().values() for k in e.keywords)
    for topic in (
        "plastic bags",
        "cling film",
        "takeaway containers",
        "coffee capsules",
        "plastic bottles",
        "straws",
        "paper towels",
        "wet wipes",
        "razors",
        "sponges",
        "toothbrush",
        "tea bags",
        "zip bags",
        "foil",
        "baking paper",
        "batteries",
        "coffee cups",
        "plastic cutlery",
        "water bottle",
        "detergent bottles",
        "shampoo bottles",
        "gift wrap",
        "fast fashion",
        "printer paper",
    ):
        assert topic in keywords, topic


def test_the_rag_loader_accepts_the_file(tmp_path):
    shutil.copy(get_settings().knowledge_dir / SWAPS_FILE, tmp_path / SWAPS_FILE)
    docs, problems = load_documents(tmp_path, strict=True)
    assert problems == []
    assert len(docs) == len(swap_catalog())
    assert {d.kind for d in docs} == {"swap"}
