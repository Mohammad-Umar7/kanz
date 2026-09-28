"""Localized labels come from the shared vocabulary, which also ships inside the package."""

import json

from app.ai import labels


def test_bundled_vocabulary_matches_the_contract():
    assert labels.CONTRACT_VOCAB.exists()
    contract = json.loads(labels.CONTRACT_VOCAB.read_text(encoding="utf-8"))
    assert json.loads(labels.BUNDLED_VOCAB.read_text(encoding="utf-8")) == contract


def test_labels_are_localized():
    assert labels.material_label("glass", "ar") == "زجاج"
    assert labels.tool_label("craft_knife", "en") == "Craft knife"
    assert labels.quality_label(9, "en") == "Like new"
    assert labels.hazard_label("unknown_flag", "en") == "unknown flag"


def test_a_backend_only_build_uses_the_bundled_copy(monkeypatch, tmp_path):
    monkeypatch.setattr(labels, "CONTRACT_VOCAB", tmp_path / "missing.json")
    labels.vocab.cache_clear()
    labels._table.cache_clear()
    try:
        assert labels.vocab_path() == labels.BUNDLED_VOCAB
        assert labels.quality_label(4, "ar") == "جيد"
    finally:
        labels.vocab.cache_clear()
        labels._table.cache_clear()
