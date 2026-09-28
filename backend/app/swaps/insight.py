"""History insight for the Swaps tab, computed without a model.

``HistorySummary`` is counted on the device from the user's scans. The sentence built
from it ("You scanned 6 plastic bottles this month.") is plain arithmetic, so it is
written by code: it can never be wrong about the user's own numbers, and it costs no
model call. The same summary also becomes a retrieval query, so the advisor can suggest
swaps for what the user throws away most.
"""

from __future__ import annotations

from app.schemas.swaps import HistorySummary

# Material phrases that fit inside a sentence (the vocab labels are chip labels).
_MATERIAL: dict[str, tuple[str, str]] = {
    "glass": ("glass", "الزجاج"),
    "plastic": ("plastic", "البلاستيك"),
    "paper": ("paper and cardboard", "الورق والكرتون"),
    "metal": ("metal", "المعادن"),
    "textile": ("textiles", "المنسوجات"),
    "wood": ("wood", "الخشب"),
    "electronics": ("electronics", "الإلكترونيات"),
    "hazardous": ("hazardous items", "المواد الخطرة"),
    "organic": ("food and garden waste", "المخلفات العضوية"),
    "other": ("mixed materials", "مواد أخرى"),
}


def history_insight(history: HistorySummary | None, lang: str) -> str | None:
    """One localized sentence about the user's scans, or ``None`` when there is nothing to say."""
    if history is None:
        return None
    period = _period(history.period_days, lang)
    if history.top_items and history.top_items[0].strip():
        item = history.top_items[0].strip()
        count = history.top_item_counts[0] if history.top_item_counts else 0
        if count > 0:
            if lang == "ar":
                return f"مسحت «{item}» {_ar_times(count)} {period}."
            return f"You scanned {count} {_plural(_sentence_case(item), count)} {period}."
        if lang == "ar":
            return f"أكثر ما مسحته {period}: «{item}»."
        return f"Your most scanned item {period}: {_sentence_case(item)}."
    counts = {m: n for m, n in history.counts.items() if n > 0}
    if not counts:
        return None
    material, n = max(counts.items(), key=lambda kv: kv[1])
    total = sum(counts.values())
    en, ar = _MATERIAL.get(material, (material, material))
    if lang == "ar":
        return f"الأكثر بين ما مسحته {period}: {ar} ({n} من {total})."
    if n == total:
        return f"Everything you scanned {period} was {en} ({n} {_plural('item', n)})."
    return f"{en[0].upper() + en[1:]} made up {n} of the {total} items you scanned {period}."


def history_query(history: HistorySummary | None) -> str | None:
    """A retrieval query from the most scanned items and materials, e.g. 'plastic bottle glass jar plastic'."""
    if history is None:
        return None
    parts = [item.strip() for item in history.top_items[:3] if item.strip()]
    ranked = sorted(((n, m) for m, n in history.counts.items() if n > 0), reverse=True)
    parts += [_MATERIAL.get(m, (m, m))[0] for _, m in ranked[:2]]
    return " ".join(dict.fromkeys(parts)) or None


# ------------------------------------------------------------------ language helpers
def _period(days: int, lang: str) -> str:
    named = {
        1: ("today", "اليوم"),
        7: ("this week", "هذا الأسبوع"),
        30: ("this month", "هذا الشهر"),
        31: ("this month", "هذا الشهر"),
        365: ("this year", "هذا العام"),
        366: ("this year", "هذا العام"),
    }
    if days in named:
        en, ar = named[days]
        return ar if lang == "ar" else en
    if lang == "ar":
        if days == 2:
            return "خلال اليومين الماضيين"
        return f"خلال آخر {days} {'أيام' if days <= 10 else 'يومًا'}"
    return f"in the last {days} days"


def _ar_times(n: int) -> str:
    """Arabic 'N times' with the correct number agreement."""
    if n == 1:
        return "مرة واحدة"
    if n == 2:
        return "مرتين"
    if n <= 10:
        return f"{n} مرات"
    return f"{n} مرة"


def _sentence_case(text: str) -> str:
    """Lower-case a leading capital ('Glass jar' -> 'glass jar') but keep acronyms ('PET bottle')."""
    if len(text) > 1 and text[0].isupper() and not text[1].isupper():
        return text[0].lower() + text[1:]
    return text


def _plural(noun: str, n: int) -> str:
    """Naive English plural of the last word, enough for item names ('jar' -> 'jars', 'box' -> 'boxes')."""
    if n == 1 or not noun or not noun[-1].isalpha() or noun.endswith("s"):
        return noun
    if noun.endswith(("x", "z", "ch", "sh")):
        return noun + "es"
    if noun.endswith("y") and len(noun) > 1 and noun[-2] not in "aeiou":
        return noun[:-1] + "ies"
    return noun + "s"
