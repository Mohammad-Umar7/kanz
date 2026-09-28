"""Image Director: turns a request into the exact prompt sent to the image model.

Prompt engineering choices, in one place:

* **Edit, don't generate.** Every picture except a text scan's reference photo is an
  edit of a real photo, and every edit prompt opens by saying which attached image is
  which ("Image 1 is ..., image 2 is ..."). References are sent in that order by
  ``GeminiGateway.image``.
* **Identity first.** Each edit template spells out what must survive the edit: shape,
  proportions, color, material and distinctive details such as label remnants or dents,
  plus the lighting and camera angle, so only what the project changes is changed.
* **English content, any-language context.** ``after_visual`` and each step's
  ``image_prompt`` are written in English by the text agents specifically for this
  director. Localized fields (an Arabic item name or prep step) are still passed when
  they help, together with a note that they are descriptions, never text to draw.
* **One shared style.** ``STYLE_SUFFIX`` closes every prompt so after, step, bin and
  reference pictures look like one set of phone photos from the same kitchen.
* **Versioned templates.** The wording lives in ``backend/prompts/image_*.md``; the
  director only chooses sections and fills values. ``ImagePrompt.template`` carries
  ``name@vN`` for the render log.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from app.images.templates import PromptTemplate, load_template
from app.schemas.analysis import Item
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial, TutorialStep

# Closes every image prompt. Each clause fixes a failure seen with image models:
# glossy "product shots" instead of home photos, reframed compositions that break the
# before/after slider, invented text and logos, and stock-photo people.
STYLE_SUFFIX = (
    "Photo style: a realistic smartphone photo taken at home, lit by soft natural light (when editing, keep the "
    "photo's own light), with true-to-life colors, textures and small imperfections; not an illustration, a 3D "
    "render or a studio product shot. Keep the reference photo's camera angle, distance, framing and aspect ratio "
    "(4:3 when there is no reference photo). Add no text, captions, numbers, watermarks or logos anywhere in the "
    "image; print already on the object may stay but never becomes sharper or more legible. No people's faces; "
    "hands appear only when they show the technique."
)

# Added when a prompt carries Arabic text (item names, prep steps, a text-scan description).
SOURCE_LANGUAGE_NOTE = (
    "Some details above are written in Arabic. Read them only as a description of the item; never write them, "
    "or any other text, into the image."
)

_ARABIC = re.compile(r"[\u0600-\u06ff\u0750-\u077f\ufb50-\ufdff\ufe70-\ufefc]")  # Arabic script, any letter form
_SPACES = re.compile(r"\s+")

MAX_FIELD_CHARS = 600  # model-written fields are short; this bounds anything unexpected
MAX_DESCRIPTION_CHARS = 400  # user-typed text-scan descriptions


@dataclass(frozen=True)
class ImagePrompt:
    text: str
    template: str  # "image_step@v1"


def clean(text: str, limit: int = MAX_FIELD_CHARS) -> str:
    """One line, trimmed, cut at a word boundary if it is unexpectedly long."""
    flat = _SPACES.sub(" ", text or "").strip()
    if len(flat) <= limit:
        return flat
    cut = flat[:limit].rsplit(" ", 1)[0]
    return cut.rstrip(",;:")


def clause(text: str, limit: int = MAX_FIELD_CHARS) -> str:
    """``clean`` without closing punctuation, for values the template ends with its own full stop."""
    return clean(text, limit).rstrip(" .!?;:,")


def sentence(text: str, limit: int = MAX_FIELD_CHARS) -> str:
    """``clean`` plus a closing full stop, so filled templates read as prose."""
    flat = clean(text, limit)
    if flat and flat[-1] not in ".!?":
        flat += "."
    return flat


def bullets(lines: list[str]) -> str:
    return "\n".join(f"- {clean(line)}" for line in lines if clean(line))


def idea_visual(idea: UpcycleIdea) -> str:
    """What the finished project looks like: ``after_visual``, else the (localized) title and pitch."""
    return idea.after_visual.strip() or f"{idea.title}. {idea.pitch}"


def step_visual(step: TutorialStep) -> str:
    """What the object looks like after a step: ``image_prompt``, else the (localized) title and instruction."""
    return step.image_prompt.strip() or f"{step.title}. {step.instruction}"


class ImageDirector:
    def __init__(self, prompts_dir: Path) -> None:
        self.prompts_dir = prompts_dir

    # ------------------------------------------------------------------ after
    def after(self, idea: UpcycleIdea) -> ImagePrompt:
        """Edit of the original photo into the finished project (references: [original])."""
        template = self._template("image_after")
        values = {"after_visual": sentence(idea_visual(idea))}
        return self._finish(template, ["task", "identity", "scene"], values)

    # ------------------------------------------------------------------- step
    def step(self, tutorial: Tutorial, number: int, *, idea: UpcycleIdea | None, with_after: bool) -> ImagePrompt:
        """Prompt for step ``number`` (1-based).

        References: step 1 -> [original]; step N -> [step N-1, original]; plus the after
        image last when ``with_after`` (only for the final step).
        """
        template = self._template("image_step")
        steps = tutorial.steps
        total = len(steps)
        if not 1 <= number <= total:
            raise ValueError(f"step {number} is outside 1..{total}")
        final = number == total

        # The goal gives context ("the wire becomes a handle"). Without the idea, the
        # final step's image_prompt is the best English description of the finished object.
        goal = idea_visual(idea) if idea is not None else step_visual(steps[-1])
        values = {
            "step": str(number),
            "total": str(total),
            "goal": clause(goal),
            "image_prompt": sentence(step_visual(steps[number - 1])),
            "previous_step": str(number - 1),
            "previous_prompt": clause(step_visual(steps[number - 2])) if number > 1 else "",
            "upcoming": bullets([f"Step {k}: {step_visual(s)}" for k, s in enumerate(steps, 1) if k > number]),
            "after_index": "2" if number == 1 else "3",
        }

        sections = ["task", "refs_first" if number == 1 else "refs_chain"]
        if with_after and final:
            sections.append("refs_final")
        sections += ["change", "finale" if final else "progress", "identity"]
        return self._finish(template, sections, values)

    # -------------------------------------------------------------------- bin
    def bin(self, item: Item, prep_steps: list[str]) -> ImagePrompt:
        """The item prepared for its recycling stream (references: [photo cropped to the item])."""
        template = self._template("image_bin")
        condition = ", ".join(tag.replace("_", " ") for tag in item.state) or "as shown in the photo"
        values = {
            "item": clause(item.name),
            "material": clause(item.material),
            "category": item.category,
            "condition": condition,
            "stream": clause(item.recyclability.stream) or "recycling bin",
            "prep_steps": bullets(prep_steps),
        }
        sections = ["task", "prep" if values["prep_steps"] else "no_prep", "identity"]
        return self._finish(template, sections, values)

    # -------------------------------------------------------------- reference
    def reference(self, description: str) -> ImagePrompt:
        """A text scan's stand-in photo (no references)."""
        template = self._template("image_reference")
        # The description is user input: flattened, bounded and kept inside its quotes.
        values = {"description": clean(description, MAX_DESCRIPTION_CHARS).replace('"', "'")}
        return self._finish(template, ["task", "scene"], values)

    # ---------------------------------------------------------------- helpers
    def _template(self, name: str) -> PromptTemplate:
        return load_template(self.prompts_dir, name)

    @staticmethod
    def _finish(template: PromptTemplate, sections: list[str], values: dict[str, str]) -> ImagePrompt:
        body = template.compose(sections, values)
        parts = [body]
        if _ARABIC.search(body):
            parts.append(SOURCE_LANGUAGE_NOTE)
        parts.append(STYLE_SUFFIX)
        return ImagePrompt(text="\n\n".join(parts), template=template.ref)
