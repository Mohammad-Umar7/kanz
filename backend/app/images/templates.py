"""Versioned prompt templates for the Image Director.

Every image prompt lives in ``backend/prompts/image_*.md`` so its wording can be read,
reviewed and changed without touching code. File format::

    ---
    name: image_step
    version: 2
    description: One picture in a tutorial's step chain.
    ---

    ## section_name
    Prompt text with {{placeholders}}.
    <!-- Author notes in HTML comments explain a line and are never sent to the model. -->

* The front matter is flat ``key: value`` pairs. ``name`` must match the file name and
  ``version`` is an integer bumped whenever the wording changes; ``name@vN`` is logged
  with every render, so any picture can be traced to the exact prompt that produced it.
* The body is split into named sections (``## name``). The director decides which
  sections a request needs (the first step sends different reference notes than the
  last one) and joins them in order.
* Placeholders are strict: a missing value raises ``TemplateError`` instead of sending
  a prompt with a hole in it. Values are substituted in a single pass, so text coming
  from the user or another model can never inject a placeholder of its own.
"""

from __future__ import annotations

import re
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

_FRONT_MATTER = re.compile(r"\A---[ \t]*\r?\n(?P<meta>.*?)\r?\n---[ \t]*(?:\r?\n|\Z)(?P<body>.*)\Z", re.DOTALL)
_SECTION = re.compile(r"^##[ \t]+(?P<name>[a-z][a-z0-9_]*)[ \t]*$", re.MULTILINE)
_PLACEHOLDER = re.compile(r"\{\{\s*([a-z][a-z0-9_]*)\s*\}\}")
_COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
_BLANK_RUNS = re.compile(r"\n{3,}")


class TemplateError(RuntimeError):
    """A prompt file is malformed or was rendered without a value it needs (a bug, not user error)."""


@dataclass(frozen=True)
class PromptTemplate:
    name: str
    version: int
    meta: Mapping[str, str]
    sections: Mapping[str, str]

    @property
    def ref(self) -> str:
        """``image_step@v2``: logged with every render."""
        return f"{self.name}@v{self.version}"

    def placeholders(self, section: str) -> set[str]:
        return set(_PLACEHOLDER.findall(self._section(section)))

    def render(self, section: str, values: Mapping[str, str]) -> str:
        """Fill one section. Every placeholder must have a value."""
        text = self._section(section)
        missing = self.placeholders(section) - values.keys()
        if missing:
            raise TemplateError(f"{self.ref} section '{section}' needs {sorted(missing)}")
        return _PLACEHOLDER.sub(lambda m: values[m.group(1)], text).strip()

    def compose(self, sections: Sequence[str], values: Mapping[str, str]) -> str:
        """Render several sections in order, separated by blank lines."""
        return "\n\n".join(self.render(s, values) for s in sections)

    def _section(self, section: str) -> str:
        try:
            return self.sections[section]
        except KeyError:
            raise TemplateError(f"{self.ref} has no section '{section}'") from None


def parse_template(text: str, *, source: str = "<string>") -> PromptTemplate:
    """Parse a prompt file (see the module docstring for the format)."""
    match = _FRONT_MATTER.match(text.lstrip("﻿"))
    if match is None:
        raise TemplateError(f"{source}: missing '---' front matter")

    meta: dict[str, str] = {}
    for line in match.group("meta").splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        key, sep, value = line.partition(":")
        if not sep:
            raise TemplateError(f"{source}: front matter line is not 'key: value': {line!r}")
        meta[key.strip()] = value.strip()

    name = meta.get("name", "")
    version = meta.get("version", "")
    if not name or not version.isdigit():
        raise TemplateError(f"{source}: front matter needs 'name' and an integer 'version'")

    body = _COMMENT.sub("", match.group("body"))
    parts = _SECTION.split(body)
    # parts = [preamble, name1, text1, name2, text2, ...]
    if parts[0].strip():
        raise TemplateError(f"{source}: text before the first '## section' heading")
    sections: dict[str, str] = {}
    for sec_name, sec_text in zip(parts[1::2], parts[2::2], strict=True):
        if sec_name in sections:
            raise TemplateError(f"{source}: duplicate section '{sec_name}'")
        sections[sec_name] = _BLANK_RUNS.sub("\n\n", sec_text).strip()
    if not sections:
        raise TemplateError(f"{source}: no '## section' found")
    return PromptTemplate(name=name, version=int(version), meta=meta, sections=sections)


@lru_cache(maxsize=32)
def load_template(prompts_dir: Path, name: str) -> PromptTemplate:
    """Load ``<prompts_dir>/<name>.md`` once per process."""
    path = prompts_dir / f"{name}.md"
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        raise TemplateError(f"prompt file {path} cannot be read: {exc}") from exc
    template = parse_template(text, source=str(path))
    if template.name != name:
        raise TemplateError(f"{path}: front matter name '{template.name}' does not match the file name")
    return template
