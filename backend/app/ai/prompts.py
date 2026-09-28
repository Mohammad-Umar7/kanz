"""Versioned agent prompts, loaded from ``backend/prompts/<agent>.md``.

Each prompt file is a small YAML front matter block followed by the system prompt::

    ---
    name: material_analyst
    version: 3
    role: Material Analyst
    model_role: vision          # vision | text -> settings.model_vision / settings.model_text
    temperature: 0.2
    thinking_level: low         # optional: minimal | low | medium | high
    media_resolution: medium    # optional, image prompts only
    notes: why this version exists
    ---
    You are ...  {lang_name} ...

Keeping prompts in files (not string literals) means they are reviewed and versioned like
code, and every log line and eval report records exactly which prompt version produced an
answer (``prompt.tag`` -> ``material_analyst@v3``).

Placeholders such as ``{lang_name}`` or ``{skill}`` are filled with ``str.format_map`` on a
dict that leaves unknown placeholders untouched, so a missing value never crashes a request.
Literal braces in prompt text must be doubled (``{{`` and ``}}``).

Optional few-shot examples live in ``backend/prompts/examples/<agent>.json`` as a list of
``{"user": "...", "answer": {...}}`` objects and are sent as prior conversation turns.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path
from typing import Any

import yaml

from app.ai.gemini import FewShot
from app.config import Settings, get_settings

_NAME = re.compile(r"^[a-z][a-z0-9_]*$")
_FRONT_MATTER = re.compile(r"\A---\s*\n(.*?)\n---\s*\n(.*)\Z", re.DOTALL)


class _KeepMissing(dict[str, Any]):
    """format_map helper: unknown placeholders stay as written instead of raising KeyError."""

    def __missing__(self, key: str) -> str:
        return "{" + key + "}"


@dataclass(frozen=True)
class Prompt:
    name: str
    version: str
    role: str
    model_role: str
    temperature: float
    body: str
    notes: str = ""
    thinking_level: str | None = None
    media_resolution: str | None = None
    examples: tuple[FewShot, ...] = field(default_factory=tuple)

    @property
    def tag(self) -> str:
        """Short identifier for logs and eval reports, e.g. ``tutorial_writer@v2``."""
        return f"{self.name}@v{self.version}"

    def render(self, **values: Any) -> str:
        return self.body.format_map(_KeepMissing({k: "" if v is None else v for k, v in values.items()}))

    def model(self, settings: Settings | None = None) -> str:
        s = settings or get_settings()
        return s.model_vision if self.model_role == "vision" else s.model_text


def parse_prompt(text: str, *, examples: tuple[FewShot, ...] = ()) -> Prompt:
    """Parse one prompt file's text (front matter + body)."""
    match = _FRONT_MATTER.match(text.replace("\r\n", "\n"))
    if not match:
        raise ValueError("prompt file must start with a '---' YAML front matter block")
    meta = yaml.safe_load(match.group(1)) or {}
    missing = {"name", "version", "role", "model_role", "temperature"} - meta.keys()
    if missing:
        raise ValueError(f"prompt front matter is missing {sorted(missing)}")
    if meta["model_role"] not in {"vision", "text"}:
        raise ValueError("model_role must be 'vision' or 'text'")
    return Prompt(
        name=str(meta["name"]),
        version=str(meta["version"]),
        role=str(meta["role"]),
        model_role=str(meta["model_role"]),
        temperature=float(meta["temperature"]),
        notes=str(meta.get("notes") or "").strip(),
        thinking_level=meta.get("thinking_level"),
        media_resolution=meta.get("media_resolution"),
        body=match.group(2).strip() + "\n",
        examples=examples,
    )


def _load_examples(path: Path) -> tuple[FewShot, ...]:
    if not path.exists():
        return ()
    raw = json.loads(path.read_text(encoding="utf-8"))
    shots = []
    for ex in raw:
        answer = ex["answer"]
        if not isinstance(answer, str):
            answer = json.dumps(answer, ensure_ascii=False, separators=(",", ":"))
        shots.append(FewShot(user=str(ex["user"]), answer=answer))
    return tuple(shots)


@lru_cache(maxsize=64)
def _load(name: str, prompts_dir: str) -> Prompt:
    base = Path(prompts_dir)
    text = (base / f"{name}.md").read_text(encoding="utf-8")
    prompt = parse_prompt(text, examples=_load_examples(base / "examples" / f"{name}.json"))
    if prompt.name != name:
        raise ValueError(f"{name}.md declares name {prompt.name!r}")
    return prompt


def load_prompt(name: str, prompts_dir: Path | None = None) -> Prompt:
    """Load (and cache) ``<prompts_dir>/<name>.md``; ``prompts_dir`` defaults to settings."""
    if not _NAME.match(name):
        raise ValueError(f"invalid prompt name {name!r}")
    return _load(name, str(prompts_dir or get_settings().prompts_dir))


def prompt_versions(prompts_dir: Path | None = None) -> dict[str, str]:
    """``{agent: version}`` for every agent prompt, for health output and eval reports."""
    base = prompts_dir or get_settings().prompts_dir
    out: dict[str, str] = {}
    for path in sorted(base.glob("*.md")):
        if _NAME.match(path.stem):
            try:
                out[path.stem] = load_prompt(path.stem, base).version
            except (ValueError, KeyError, yaml.YAMLError):
                continue
    return out
