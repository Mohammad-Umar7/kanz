"""Deterministic conversion of model output (``llm_schemas``) into the public API models.

Nothing here calls a model. Everything the app displays that can be computed is computed
here, the same way every time: item and idea ids, bounding boxes, localized quality labels
and quantity strings, and which of an idea's tools the user already has.
"""

from __future__ import annotations

import hashlib
import math
from collections.abc import Iterable, Sequence

from app.ai import labels
from app.ai.llm_schemas import LlmAnalysis, LlmItem
from app.schemas.analysis import (
    Analysis,
    BBox,
    Item,
    PhotoCheck,
    Quality,
    Quantity,
    Recyclability,
    ReusePotential,
)
from app.schemas.vocab import DISPOSAL_ONLY_HAZARDS, SAFETY_GEAR

# Degenerate boxes (a sliver thinner than this, as a fraction of the image) are dropped.
_MIN_BOX = 0.01
MAX_ITEMS = 6


# ----------------------------------------------------------------------- bounding boxes
def bbox_from_box2d(box: Sequence[float] | None) -> BBox | None:
    """Gemini ``box_2d`` ([ymin, xmin, ymax, xmax] on 0-1000) -> ``BBox`` (x, y, w, h on 0-1).

    Values are clamped to the grid and min/max are swapped when the model reverses them.
    A box given in 0-1 fractions is scaled up. Returns None for missing, malformed or
    degenerate boxes rather than drawing a wrong one.
    """
    if not box or len(box) != 4:
        return None
    try:
        vals = [float(v) for v in box]
    except (TypeError, ValueError):
        return None
    if any(math.isnan(v) or math.isinf(v) for v in vals):
        return None
    if 0 < max(vals) <= 1.0:
        # The model answered in 0-1 fractions instead of the 0-1000 grid; on the grid such a
        # box would be a sliver in the top-left corner, so read it as fractions.
        vals = [v * 1000.0 for v in vals]
    ymin, xmin, ymax, xmax = (min(1000.0, max(0.0, v)) / 1000.0 for v in vals)
    if ymin > ymax:
        ymin, ymax = ymax, ymin
    if xmin > xmax:
        xmin, xmax = xmax, xmin
    w, h = xmax - xmin, ymax - ymin
    if w < _MIN_BOX or h < _MIN_BOX:
        return None
    return BBox(x=round(xmin, 4), y=round(ymin, 4), w=round(w, 4), h=round(h, 4))


# --------------------------------------------------------------------- quantity display
_UNITS_EN = {
    "pcs": ("pc", "pcs"),
    "kg": ("kg", "kg"),
    "g": ("g", "g"),
    "m": ("m", "m"),
    "m2": ("m²", "m²"),
    "L": ("L", "L"),
    "handful": ("handful", "handfuls"),
    "bag": ("bag", "bags"),
}
# Arabic counted nouns: exactly one, exactly two, 3-10 (plural), 11+ (accusative singular),
# and the plain singular used for fractions and small estimates.
_COUNTED_AR = {
    "pcs": ("قطعة واحدة", "قطعتان", "قطع", "قطعة", "قطعة"),
    "handful": ("حفنة واحدة", "حفنتان", "حفنات", "حفنة", "حفنة"),
    "bag": ("كيس واحد", "كيسان", "أكياس", "كيسًا", "كيس"),
}
_MEASURE_AR = {"kg": "كغ", "g": "غ", "m": "م", "m2": "م²", "L": "لتر"}


def _num(value: float) -> str:
    if abs(value - round(value)) < 1e-6:
        return str(round(value))
    return f"{value:.1f}".rstrip("0").rstrip(".")


def quantity_display(value: float, unit: str, is_estimate: bool, lang: str) -> str:
    """Ready-to-show quantity: '1 pc', '~30 pcs', '~0.5 kg'; Arabic uses proper counted forms."""
    value = max(0.0, float(value))
    approx = "~" if is_estimate else ""
    if lang == "ar":
        if unit in _COUNTED_AR:
            one, two, few, many, single = _COUNTED_AR[unit]
            if not is_estimate and value == 1:
                return one
            if not is_estimate and value == 2:
                return two
            noun = few if 3 <= value <= 10 else many if value > 10 else single
            prefix = "حوالي " if is_estimate else ""
            return f"{prefix}{_num(value)} {noun}"
        prefix = "حوالي " if is_estimate else ""
        return f"{prefix}{_num(value)} {_MEASURE_AR.get(unit, unit)}"
    singular, plural = _UNITS_EN.get(unit, (unit, unit))
    noun = singular if value == 1 else plural
    if unit in {"kg", "g", "m", "m2", "L"}:
        noun = singular
    return f"{approx}{_num(value)} {noun}"


# -------------------------------------------------------------------------- items
def _dedupe(values: Iterable[str]) -> list[str]:
    seen: list[str] = []
    for v in values:
        if v not in seen:
            seen.append(v)
    return seen


def to_item(raw: LlmItem, index: int, lang: str, *, with_box: bool = True) -> Item:
    """One analyst item -> API ``Item`` with a stable id (``item_1``...) and localized labels."""
    score = min(5, max(1, round(raw.quality_score)))
    resin = raw.resin_code if raw.category == "plastic" and raw.resin_code in range(1, 8) else None
    unit = raw.quantity_unit
    value = max(0.0, float(raw.quantity_value))
    if unit == "pcs" and not raw.quantity_is_estimate:
        value = float(max(1, round(value)))
    return Item(
        id=f"item_{index + 1}",
        name=raw.name.strip(),
        category=raw.category,
        material=raw.material.strip(),
        resin_code=resin,
        is_raw_material=raw.is_raw_material,
        quantity=Quantity(
            value=value,
            unit=unit,
            is_estimate=raw.quantity_is_estimate,
            display=quantity_display(value, unit, raw.quantity_is_estimate, lang),
        ),
        quality=Quality(score=score, label=labels.quality_label(score, lang), notes=(raw.quality_notes or None)),
        state=_dedupe(raw.state),
        recyclability=Recyclability(
            status=raw.recyclability_status,
            stream=raw.recycling_stream.strip(),
            prep_steps=[s.strip() for s in raw.prep_steps if s.strip()][:4],
            reason=raw.recyclability_reason or None,
        ),
        reuse=ReusePotential(level=raw.reuse_level, note=raw.reuse_note.strip()),
        hazards=_dedupe(raw.hazards),
        confidence=round(min(1.0, max(0.0, float(raw.confidence))), 2),
        bbox=bbox_from_box2d(raw.box_2d) if with_box else None,
    )


# ----------------------------------------------------------------------- photo check
RETAKE_TIPS: dict[str, dict[str, str]] = {
    "blurry": {
        "en": "Hold the phone still for a second and tap the item to focus before you shoot.",
        "ar": "ثبّت الهاتف لثانية واضغط على الغرض ليتضح قبل التصوير.",
    },
    "too_dark": {
        "en": "Move next to a window or turn on a light, then take the photo again.",
        "ar": "اقترب من نافذة أو شغّل الإضاءة، ثم أعد التصوير.",
    },
    "too_far": {
        "en": "Step closer so the item fills most of the frame.",
        "ar": "اقترب أكثر حتى يملأ الغرض معظم الصورة.",
    },
    "too_close": {
        "en": "Step back a little so the whole item fits in the frame.",
        "ar": "ابتعد قليلًا حتى يظهر الغرض كاملًا في الصورة.",
    },
    "cluttered": {
        "en": "Put the item on a plain surface on its own and shoot again.",
        "ar": "ضع الغرض وحده على سطح بسيط وأعد التصوير.",
    },
    "no_items": {
        "en": "Point the camera at the item you want to recycle or reuse.",
        "ar": "وجّه الكاميرا نحو الغرض الذي تريد تدويره أو إعادة استخدامه.",
    },
    "glare": {
        "en": "Tilt the item or the phone slightly to get rid of the reflection.",
        "ar": "أمِل الغرض أو الهاتف قليلًا للتخلص من الانعكاس.",
    },
}


# A description that names nothing gets a writing tip, not a camera tip.
DESCRIBE_TIP: dict[str, str] = {
    "en": "Name the item and what it is made of, for example 'an empty glass jam jar'.",
    "ar": "اذكر اسم الغرض ومادته، مثل: برطمان مربى زجاجي فارغ.",
}


def to_photo_check(raw: LlmAnalysis, lang: str, has_items: bool, *, source: str = "image") -> PhotoCheck:
    """Normalise the photo verdict: an unusable photo always carries exactly one retake tip."""
    usable, issue = raw.photo.usable, raw.photo.issue
    key = "ar" if lang == "ar" else "en"
    if source == "text":
        # There is no photo to judge: a description is usable exactly when it names something.
        if has_items:
            return PhotoCheck(usable=True, issue="ok", retake_tip=None)
        return PhotoCheck(
            usable=False, issue="no_items", retake_tip=(raw.photo.retake_tip or "").strip() or DESCRIBE_TIP[key]
        )
    if usable and not has_items:
        usable, issue = False, "no_items"
    if not usable and issue == "ok":
        issue = "blurry"
    if usable:
        return PhotoCheck(usable=True, issue="ok", retake_tip=None)
    tip = (raw.photo.retake_tip or "").strip() or RETAKE_TIPS[issue][key]
    return PhotoCheck(usable=False, issue=issue, retake_tip=tip)


def choose_primary(items: Sequence[Item]) -> str | None:
    """Focus item for recommendations: the most confident item without a disposal-only hazard."""
    if not items:
        return None
    safe = [it for it in items if not set(it.hazards) & DISPOSAL_ONLY_HAZARDS]
    if safe:
        return max(safe, key=lambda it: it.confidence).id
    return items[0].id


def to_analysis(raw: LlmAnalysis, lang: str, *, source: str, classifier_hint: str | None = None) -> Analysis:
    """Analyst output -> API ``Analysis`` (before safety normalisation and primary choice)."""
    with_box = source == "image"
    items = [to_item(r, i, lang, with_box=with_box) for i, r in enumerate(raw.items[:MAX_ITEMS])]
    photo = to_photo_check(raw, lang, has_items=bool(items), source=source)
    if not photo.usable:
        # An unusable photo must not produce confident-looking items the app would act on.
        items = [it for it in items if it.confidence >= 0.6]
    return Analysis(
        items=items,
        summary=raw.summary.strip(),
        photo=photo,
        primary_item_id=None,
        source="text" if source == "text" else "image",
        classifier_hint=classifier_hint,
    )


# ---------------------------------------------------------------------------- ideas
def idea_id(image_id: str, title: str) -> str:
    """Stable idea id: the same photo and idea title always give the same id (and cached images)."""
    return "idea_" + hashlib.sha1(f"{image_id}|{title.strip()}".encode()).hexdigest()[:8]


def split_tools(needed: Iterable[str], have: Iterable[str]) -> tuple[list[str], list[str], list[str]]:
    """(tools_needed, tools_have, tools_missing), protective gear excluded from all three."""
    owned = set(have)
    tools = [t for t in _dedupe(needed) if t not in SAFETY_GEAR]
    return tools, [t for t in tools if t in owned], [t for t in tools if t not in owned]
