"""The knowledge base: valid, complete, bilingual, and consistent with the safety rules."""

from collections import Counter

import pytest

from app.ai import safety
from app.ai.rag.documents import MaterialGuideDoc, ProjectDoc, SafetyDoc, load_documents, render_text
from app.config import BACKEND_DIR
from app.schemas.vocab import DISPOSAL_ONLY_HAZARDS, MATERIAL_CATEGORIES, SAFETY_GEAR, TOOL_IDS

from .conftest import FIXTURES

KNOWLEDGE = BACKEND_DIR / "knowledge"
DIY_MATERIALS = ("glass", "plastic", "paper", "metal", "textile", "wood")


@pytest.fixture(scope="module")
def docs():
    documents, problems = load_documents(KNOWLEDGE, strict=True)
    assert problems == []
    return documents


@pytest.fixture(scope="module")
def projects(docs):
    return [d for d in docs if isinstance(d, ProjectDoc)]


def test_at_least_42_projects_and_7_per_diy_material(projects):
    assert len(projects) >= 42
    per_file = Counter(p.id.split("_")[1] for p in projects)
    for material in DIY_MATERIALS:
        assert per_file[material] >= 7, material


def test_project_ids_match_their_file_material(projects):
    for p in projects:
        assert p.materials[0] == p.id.split("_")[1], p.id


def test_every_document_has_an_arabic_title(docs):
    for d in docs:
        assert safety.has_arabic(d.title_ar), d.id


def test_projects_have_arabic_summaries_and_valid_tools(projects):
    for p in projects:
        assert safety.has_arabic(p.summary_ar), p.id
        assert set(p.tools) <= set(TOOL_IDS) - SAFETY_GEAR, p.id
        assert 4 <= len(p.steps_outline) <= 8, p.id


def test_project_results_are_english_image_captions(projects):
    for p in projects:
        assert not safety.has_arabic(p.result), p.id


def test_there_is_a_material_guide_for_every_category(docs):
    guides = {d.id for d in docs if isinstance(d, MaterialGuideDoc)}
    assert {f"mat_{c}" for c in MATERIAL_CATEGORIES} <= guides


def test_resin_codes_one_to_seven_are_covered(docs):
    codes = sorted(d.resin_code for d in docs if isinstance(d, MaterialGuideDoc) and d.resin_code)
    assert codes == [1, 2, 3, 4, 5, 6, 7]


def test_every_disposal_only_hazard_has_safety_rules(docs):
    covered = {h for d in docs if isinstance(d, SafetyDoc) for h in d.applies_to.hazards}
    assert covered >= DISPOSAL_ONLY_HAZARDS


def test_every_gear_technique_has_safety_rules(docs):
    applies = [d.applies_to for d in docs if isinstance(d, SafetyDoc)]
    covered = {t for a in applies for t in a.techniques} | {h for a in applies for h in a.hazards}
    assert covered >= set(safety.GEAR_RULES)


def test_ids_used_by_the_contract_fixtures_exist(docs):
    ids = {d.id for d in docs}
    fixture_text = " ".join(p.read_text(encoding="utf-8") for p in FIXTURES.glob("*.json"))
    for doc_id in ("proj_glass_jar_lantern", "proj_glass_jar_herb_garden", "proj_textile_tshirt_tote", "mat_glass"):
        assert doc_id in fixture_text and doc_id in ids


def test_projects_obey_the_same_safety_rules_as_the_agents(projects):
    """The knowledge base must never teach what the validators would reject."""
    for p in projects:
        texts = [p.summary, p.result, *p.steps_outline]
        assert safety.check_text_rules(texts) == [], p.id


def test_projects_name_the_gear_their_techniques_need(projects):
    for p in projects:
        lacking = safety.missing_gear(p.steps_outline, p.tools, p.safety, include_painting=False)
        assert lacking == {}, (p.id, lacking)


def test_rendered_text_carries_the_id_and_stays_compact(docs):
    for d in docs:
        text = render_text(d)
        assert text.startswith(f"[{d.id}]")
        assert len(text) < 2000, d.id


def test_invalid_documents_are_reported(tmp_path):
    (tmp_path / "safety.json").write_text(
        '[{"id": "safety_x", "kind": "safety", "title": "X rules", "title_ar": "", "materials": ["glass"],'
        ' "applies_to": {}, "rules": ["a", "b"], "never": ["c"]}]',
        encoding="utf-8",
    )
    docs, problems = load_documents(tmp_path)
    assert docs == [] and problems
    with pytest.raises(ValueError):
        load_documents(tmp_path, strict=True)
