"""Versioned prompt files, the loader and the few-shot examples."""

import json

import pytest

from app.ai.llm_schemas import LlmAnalysis, LlmIdeas
from app.ai.prompts import load_prompt, parse_prompt, prompt_versions
from app.ai.safety import gear_rules_text
from app.config import BACKEND_DIR

AGENTS = [
    "material_analyst",
    "upcycle_designer",
    "recycling_advisor",
    "donation_advisor",
    "disposal_advisor",
    "tutorial_writer",
]
PROMPTS_DIR = BACKEND_DIR / "prompts"


@pytest.mark.parametrize("name", AGENTS)
def test_every_agent_prompt_loads_with_front_matter(name):
    prompt = load_prompt(name, PROMPTS_DIR)
    assert prompt.name == name
    assert prompt.version.isdigit()
    assert prompt.tag == f"{name}@v{prompt.version}"
    assert prompt.role and prompt.notes
    assert prompt.model_role in {"vision", "text"}
    assert 0 <= prompt.temperature <= 1
    assert "{lang_name}" in prompt.body


@pytest.mark.parametrize("name", AGENTS)
def test_prompts_state_the_language_rules(name):
    body = load_prompt(name, PROMPTS_DIR).body
    assert "## Language" in body
    assert "English" in body


def test_only_the_analyst_uses_the_vision_model():
    roles = {name: load_prompt(name, PROMPTS_DIR).model_role for name in AGENTS}
    assert roles.pop("material_analyst") == "vision"
    assert set(roles.values()) == {"text"}


def test_render_fills_known_placeholders_and_keeps_unknown_ones():
    prompt = parse_prompt(
        "---\nname: x\nversion: 2\nrole: X\nmodel_role: text\ntemperature: 0.1\n---\nSpeak {lang_name}. {other}"
    )
    assert prompt.render(lang_name="Modern Standard Arabic") == "Speak Modern Standard Arabic. {other}\n"


def test_rendered_designer_prompt_contains_the_gear_table():
    text = load_prompt("upcycle_designer", PROMPTS_DIR).render(lang_name="English", gear_rules=gear_rules_text())
    assert "{" not in text
    assert "spray painting: a dust mask" in text


@pytest.mark.parametrize(
    "text",
    [
        "no front matter at all",
        "---\nname: x\n---\nbody",
        "---\nname: x\nversion: 1\nrole: X\nmodel_role: audio\ntemperature: 0.1\n---\nbody",
    ],
)
def test_invalid_prompt_files_are_rejected(text):
    with pytest.raises(ValueError):
        parse_prompt(text)


def test_prompt_names_are_validated():
    with pytest.raises(ValueError):
        load_prompt("../secrets", PROMPTS_DIR)


def test_versions_are_listed_for_every_agent():
    versions = prompt_versions(PROMPTS_DIR)
    assert set(AGENTS) <= set(versions)


@pytest.mark.parametrize(("name", "schema"), [("material_analyst", LlmAnalysis), ("upcycle_designer", LlmIdeas)])
def test_few_shot_answers_match_the_output_schema(name, schema):
    prompt = load_prompt(name, PROMPTS_DIR)
    assert prompt.examples
    for shot in prompt.examples:
        schema.model_validate(json.loads(shot.answer_json()))


def test_designer_example_cites_only_ids_it_was_given():
    shot = load_prompt("upcycle_designer", PROMPTS_DIR).examples[0]
    for idea in json.loads(shot.answer_json())["ideas"]:
        assert all(f"[{sid}]" in shot.user for sid in idea["source_ids"])
