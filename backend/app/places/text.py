"""Localized strings the places service shows (labels, notes, notices)."""

from __future__ import annotations

_TEXT: dict[str, dict[str, str]] = {
    "your_location": {"en": "Your location", "ar": "موقعك الحالي"},
    # Generic names for OpenStreetMap points that have no name of their own.
    "recycling_point": {"en": "Recycling point", "ar": "نقطة إعادة تدوير"},
    "recycling_center": {"en": "Recycling center", "ar": "مركز إعادة تدوير"},
    "clothes_point": {"en": "Clothes donation point", "ar": "نقطة التبرع بالملابس"},
    "battery_point": {"en": "Battery drop-off point", "ar": "نقطة جمع البطاريات"},
    "ewaste_point": {"en": "E-waste drop-off point", "ar": "نقطة جمع النفايات الإلكترونية"},
    "hazardous_point": {"en": "Hazardous waste drop-off", "ar": "نقطة تسليم النفايات الخطرة"},
    "charity_shop": {"en": "Charity shop", "ar": "متجر خيري"},
    "second_hand": {"en": "Second-hand shop", "ar": "متجر أغراض مستعملة"},
    "give_box": {"en": "Give box", "ar": "صندوق تبادل مجاني"},
    "scrap_yard": {"en": "Scrap yard", "ar": "ساحة خردة"},
    # Notes on a place.
    "hours": {"en": "Hours: {value}.", "ar": "ساعات العمل: {value}."},
    "unlisted": {
        "en": "Accepted materials aren't listed. Check the bin labels before you go.",
        "ar": "المواد المقبولة غير مذكورة. تحقّق من ملصقات الحاوية قبل الذهاب.",
    },
    "charity_bin": {"en": "Charity clothing bin.", "ar": "حاوية ملابس خيرية."},
    "verified": {"en": "Checked by {who} on {date}.", "ar": "تحقّق منه {who} بتاريخ {date}."},
    # Notices on the whole result.
    "notice_none": {
        "en": "No drop-off points found within {km} km. Try a wider radius or another category.",
        "ar": "لم نجد نقاط تسليم ضمن {km} كم. جرّب نطاقًا أوسع أو فئة أخرى.",
    },
    "notice_widened": {
        "en": "Nothing within {near} km, so these are the nearest within {far} km.",
        "ar": "لا شيء ضمن {near} كم، لذا هذه أقرب النقاط ضمن {far} كم.",
    },
    "notice_osm_only": {
        "en": "These points come from OpenStreetMap volunteers. Hours and details may be missing, so check before you go.",
        "ar": "هذه النقاط من بيانات متطوعي OpenStreetMap، وقد تنقصها المواعيد والتفاصيل، فتحقّق قبل الذهاب.",
    },
    "notice_curated_only": {
        "en": "Live map data is unavailable right now, so only points checked by the Kanz team are shown.",
        "ar": "بيانات الخرائط الحية غير متاحة الآن، لذا نعرض فقط النقاط التي تحقّق منها فريق كنز.",
    },
}


def t(key: str, lang: str, **values: object) -> str:
    """The string for ``key`` in ``lang`` (English when a translation is missing)."""
    entry = _TEXT[key]
    text = entry.get(lang) or entry["en"]
    return text.format(**values) if values else text
