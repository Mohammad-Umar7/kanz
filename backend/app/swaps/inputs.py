"""Normalize what the user tells the Swap Advisor: chip ids and free text.

The app's Swaps tab sends chip ids such as ``plastic_bags`` next to anything the user
typed. Chip ids become readable text in the request language (shown back as
``matched_input``) plus an English retrieval query, because the swap documents are
written in English. Free text is kept as typed.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

MAX_INPUTS = 6  # a response has at most six cards
MAX_INPUT_CHARS = 80

# Chip id -> (English, Arabic). Unknown snake_case ids fall back to their words.
CHIP_LABELS: dict[str, tuple[str, str]] = {
    "plastic_bags": ("plastic bags", "أكياس بلاستيكية"),
    "cling_film": ("cling film", "غلاف بلاستيكي للطعام"),
    "takeaway_containers": ("takeaway containers", "علب الطعام الجاهز"),
    "coffee_capsules": ("coffee capsules", "كبسولات القهوة"),
    "plastic_bottles": ("plastic bottles", "قوارير بلاستيكية"),
    "paper_towels": ("paper towels", "مناشف ورقية"),
    "wet_wipes": ("wet wipes", "مناديل مبللة"),
    "batteries": ("batteries", "بطاريات"),
    "straws": ("plastic straws", "مصاصات بلاستيكية"),
    "disposable_cups": ("disposable cups", "أكواب الاستعمال الواحد"),
    "plastic_cutlery": ("plastic cutlery", "أدوات مائدة بلاستيكية"),
    "zip_bags": ("zip bags", "أكياس سحّاب"),
    "aluminium_foil": ("aluminium foil", "ورق الألمنيوم"),
    "baking_paper": ("baking paper", "ورق الخبز"),
    "sponges": ("kitchen sponges", "إسفنج المطبخ"),
    "toothbrushes": ("plastic toothbrushes", "فرش أسنان بلاستيكية"),
    "razors": ("disposable razors", "شفرات حلاقة للاستعمال الواحد"),
    "tea_bags": ("tea bags", "أكياس الشاي"),
    "detergent_bottles": ("detergent bottles", "عبوات المنظفات"),
    "shampoo_bottles": ("shampoo bottles", "عبوات الشامبو"),
    "gift_wrap": ("gift wrap", "ورق تغليف الهدايا"),
    "fast_fashion": ("fast fashion", "الأزياء السريعة"),
    "printer_paper": ("printer paper", "ورق الطباعة"),
    "water_bottles": ("water bottles", "قوارير المياه"),
    "light_bulbs": ("light bulbs", "المصابيح الكهربائية"),
    "aerosols": ("aerosol sprays", "علب الرذاذ"),
    "paper_napkins": ("paper napkins", "مناديل المائدة الورقية"),
    "disposable_plates": ("disposable plates", "أطباق الاستعمال الواحد"),
    "snack_packets": ("snack packets", "أكياس الوجبات الخفيفة"),
    "food_waste": ("food waste", "بقايا الطعام"),
}

_CHIP_ID = re.compile(r"^[a-z]+(?:_[a-z]+)+$")
_SPACES = re.compile(r"\s+")


@dataclass(frozen=True)
class UserInput:
    raw: str  # as sent by the app
    label: str  # readable, in the request language; echoed as ``matched_input``
    query: str  # what retrieval searches for (English for chips)


def normalize_inputs(materials: list[str], lang: str) -> list[UserInput]:
    """Readable, deduplicated inputs (at most ``MAX_INPUTS``), in the order the user gave them."""
    out: list[UserInput] = []
    seen: set[str] = set()
    for raw in materials:
        text = _SPACES.sub(" ", raw or "").strip()[:MAX_INPUT_CHARS].strip()
        if not text:
            continue
        item = _from_chip(text, lang) or UserInput(raw=raw, label=text, query=text)
        key = item.label.casefold()
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
        if len(out) == MAX_INPUTS:
            break
    return out


def _from_chip(text: str, lang: str) -> UserInput | None:
    if text in CHIP_LABELS:
        en, ar = CHIP_LABELS[text]
        return UserInput(raw=text, label=ar if lang == "ar" else en, query=en)
    if _CHIP_ID.match(text):
        words = text.replace("_", " ")
        return UserInput(raw=text, label=words, query=words)
    return None
