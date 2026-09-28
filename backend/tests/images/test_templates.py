"""Prompt template format: front matter, sections, strict single-pass placeholders."""

from pathlib import Path

import pytest

from app.config import get_settings
from app.images.templates import TemplateError, load_template, parse_template

GOOD = """---
name: demo
version: 3
description: A demo prompt.
---

## intro
Hello {{who}}.
<!-- author note, never sent -->

## outro
Bye {{ who }}, see you {{when}}.
"""

SHIPPED = ["image_after", "image_step", "image_bin", "image_reference"]


def test_parses_front_matter_and_sections() -> None:
    t = parse_template(GOOD)
    assert (t.name, t.version, t.ref) == ("demo", 3, "demo@v3")
    assert t.meta["description"] == "A demo prompt."
    assert list(t.sections) == ["intro", "outro"]
    assert "author note" not in t.sections["intro"]
    assert t.placeholders("outro") == {"who", "when"}


def test_compose_joins_sections_in_the_requested_order() -> None:
    t = parse_template(GOOD)
    text = t.compose(["outro", "intro"], {"who": "Sara", "when": "soon"})
    assert text == "Bye Sara, see you soon.\n\nHello Sara."


def test_missing_value_raises_instead_of_leaving_a_hole() -> None:
    with pytest.raises(TemplateError, match="when"):
        parse_template(GOOD).render("outro", {"who": "Sara"})


def test_values_are_substituted_in_a_single_pass() -> None:
    # Text from users or other models must never expand into another placeholder.
    text = parse_template(GOOD).render("intro", {"who": "{{when}}"})
    assert text == "Hello {{when}}."


def test_unknown_section_raises() -> None:
    with pytest.raises(TemplateError, match="no section"):
        parse_template(GOOD).render("middle", {})


@pytest.mark.parametrize(
    ("text", "message"),
    [
        ("## intro\nHi", "front matter"),
        ("---\nname: demo\nversion: two\n---\n## intro\nHi", "integer 'version'"),
        ("---\nversion: 1\n---\n## intro\nHi", "'name'"),
        ("---\nname: demo\nversion: 1\n---\nstray text\n## intro\nHi", "before the first"),
        ("---\nname: demo\nversion: 1\n---\n## intro\nA\n## intro\nB", "duplicate"),
        ("---\nname: demo\nversion: 1\n---\n", "no '## section'"),
        ("---\nname demo\n---\n## intro\nHi", "key: value"),
    ],
)
def test_malformed_files_are_rejected(text: str, message: str) -> None:
    with pytest.raises(TemplateError, match=message):
        parse_template(text)


def test_file_name_must_match_front_matter_name(tmp_path: Path) -> None:
    (tmp_path / "other.md").write_text(GOOD, encoding="utf-8")
    with pytest.raises(TemplateError, match="does not match"):
        load_template(tmp_path, "other")


def test_missing_file_raises_template_error(tmp_path: Path) -> None:
    with pytest.raises(TemplateError, match="cannot be read"):
        load_template(tmp_path, "absent")


@pytest.mark.parametrize("name", SHIPPED)
def test_shipped_image_prompts_are_versioned_and_clean(name: str) -> None:
    t = load_template(get_settings().prompts_dir, name)
    assert t.name == name
    assert t.version >= 1
    assert t.meta.get("description")
    assert t.meta.get("references")
    for text in t.sections.values():
        assert "<!--" not in text
        assert "TODO" not in text
