"""Safety: hazard normalisation, the Safety Router, and output safety validators.

Three layers keep Kanz from ever suggesting something dangerous:

1. **Normalisation** (after the Material Analyst). Deterministic rules make sure hazards
   the model might under-report are flagged: electronics always carry ``e_waste``, broken
   glass carries ``broken_glass``, batteries, aerosols, medicines and bulbs are recognised
   by name in English and Arabic, and chemical containers with residue carry ``chemical``.
2. **Routing** (before any generation). Items with a disposal-only hazard never reach the
   Upcycle Designer: the router returns ``diy``, ``mixed`` or ``disposal_only``.
3. **Validators** (after every generating node). Keyword and regex checks in English and
   Arabic return human-readable problems that the gateway feeds back to the model in its
   repair round: never melt, burn or heat plastic; never reuse chemical containers for
   food, drink, edible plants or pets; no DIY on disposal-only items; protective gear for
   cutting, sanding, drilling, painting, glass and sharp metal; no food contact with painted
   or varnished surfaces unless food-safe is stated.

The checks are sentence-based and skip negated sentences ("Never melt plastic" is advice,
not a violation). Arabic text is normalised (diacritics, alef/yaa/taa marbuta forms) and
tokens are matched after stripping common clitic prefixes (و، ف، ب، ل، ال...).
"""

from __future__ import annotations

import re
from collections.abc import Callable, Iterable, Sequence
from typing import Generic, TypeVar

from app.ai import labels
from app.schemas.analysis import Item
from app.schemas.recommend import Routing
from app.schemas.vocab import DISPOSAL_ONLY_HAZARDS

# ============================================================================ matching
_AR_MARKS = re.compile(r"[ً-ْٰـ]")
_AR_FOLD = str.maketrans({"أ": "ا", "إ": "ا", "آ": "ا", "ى": "ي", "ة": "ه", "ؤ": "و", "ئ": "ي"})
_AR_WORD = re.compile(r"[ء-ي]+")
_AR_PREFIXES = ("وبال", "وال", "بال", "كال", "فال", "لل", "ال", "و", "ف", "ب", "ل", "ك")
_ARABIC_CHARS = re.compile(r"[؀-ۿ]")


def normalize_ar(text: str) -> str:
    """Fold Arabic spelling variants so keyword checks are robust to diacritics and hamza forms."""
    return _AR_MARKS.sub("", text).translate(_AR_FOLD)


def _ar_variants(token: str) -> set[str]:
    out, frontier = {token}, [token]
    while frontier:
        tok = frontier.pop()
        for prefix in _AR_PREFIXES:
            if tok.startswith(prefix) and len(tok) - len(prefix) >= 2:
                rest = tok[len(prefix) :]
                if rest not in out:
                    out.add(rest)
                    frontier.append(rest)
    return out


class Sentence:
    """One sentence prepared for matching in both languages."""

    __slots__ = ("ar", "ar_tokens", "en", "raw")

    def __init__(self, raw: str) -> None:
        self.raw = raw.strip()
        self.en = self.raw.lower()
        self.ar = normalize_ar(self.en)
        self.ar_tokens: set[str] = set()
        for tok in _AR_WORD.findall(self.ar):
            self.ar_tokens |= _ar_variants(tok)


class Terms:
    """A keyword set: English regex fragments (word-bounded) plus Arabic stems or phrases.

    Arabic single words match as prefixes of clitic-stripped tokens ("بلاستيك" matches
    "البلاستيكية"); a leading "=" demands the whole token ("=اكل" must not match "اكليل");
    Arabic entries containing a space match as phrases in the folded text.
    """

    def __init__(self, en: Sequence[str] = (), ar: Sequence[str] = ()) -> None:
        self._en = re.compile(r"\b(?:" + "|".join(en) + r")\b") if en else None
        folded = [normalize_ar(a) for a in ar]
        self._ar_exact = frozenset(a[1:] for a in folded if a.startswith("="))
        self._ar_stems = tuple(a for a in folded if " " not in a and not a.startswith("="))
        self._ar_phrases = tuple(a for a in folded if " " in a)

    def found(self, s: Sentence) -> bool:
        if self._en and self._en.search(s.en):
            return True
        if any(p in s.ar for p in self._ar_phrases):
            return True
        if self._ar_exact & s.ar_tokens:
            return True
        return any(tok.startswith(stem) for stem in self._ar_stems for tok in s.ar_tokens)


_SENTENCE_SPLIT = re.compile(r"(?<=[.!?؟؛;])\s+|\n+")
_NEGATION_EN = re.compile(
    r"\b(?:never|not|no|don'?t|do not|avoid|without|mustn'?t|shouldn'?t|can'?t|cannot|instead of)\b"
)
_NEGATION_AR = {"لا", "ولا", "فلا", "لن", "ابدا", "اياك", "ممنوع", "بدون", "دون", "عدم", "بلا", "ليس", "بدلا"}
_NEGATION_AR_STEMS = ("تجنب", "يمنع", "احذر")


def sentences(texts: Iterable[str | None]) -> list[Sentence]:
    out: list[Sentence] = []
    for text in texts:
        if text:
            out.extend(Sentence(part) for part in _SENTENCE_SPLIT.split(text) if part.strip())
    return out


def is_negated(s: Sentence) -> bool:
    if _NEGATION_EN.search(s.en):
        return True
    if s.ar_tokens & _NEGATION_AR:
        return True
    return any(tok.startswith(stem) for stem in _NEGATION_AR_STEMS for tok in s.ar_tokens)


def _quote(s: Sentence) -> str:
    return s.raw if len(s.raw) <= 90 else s.raw[:87] + "..."


def has_arabic(text: str | None) -> bool:
    return bool(text and _ARABIC_CHARS.search(text))


# ====================================================================== hazard keywords
_BATTERY = Terms(
    en=(r"batter(?:y|ies)", r"(?:aa|aaa|9v|lithium|li-ion|button|coin) cells?", r"power ?banks?", r"accumulators?"),
    ar=("بطاري", "مدخره", "باور بانك"),
)
_AEROSOL = Terms(
    en=(
        r"aerosols?",
        r"spray ?cans?",
        r"spray ?paint",
        r"hair ?spray",
        r"deodorant spray",
        r"air freshener",
        r"wd-?40",
    ),
    # "بخاخ" alone also means a plastic trigger sprayer, so only can-specific phrases count.
    ar=("علبه بخاخ", "بخاخ معدني", "ايروسول", "علبه رذاذ", "معطر جو", "مزيل عرق بخاخ", "طلاء بخاخ"),
)
_MEDICINE = Terms(
    en=(
        r"medicines?",
        r"medications?",
        r"pills?",
        r"(?<!coffee )capsules?",
        r"blister ?packs?",
        r"cough syrups?",
        r"antibiotics?",
        r"painkillers?",
        r"inhalers?",
        r"syringes?",
    ),
    ar=("دواء", "ادويه", "اقراص", "كبسولات دواء", "مضاد حيوي", "حقن"),
)
_BULB = Terms(
    en=(r"(?:light ?)?bulbs?", r"fluorescent", r"cfls?", r"halogen", r"light tubes?", r"neon tubes?"),
    ar=("مصباح", "مصابيح", "لمبه", "لمبات", "فلورسنت", "نيون"),
)
_CHEMICAL = Terms(
    en=(
        r"bleach",
        r"pesticides?",
        r"insecticides?",
        r"herbicides?",
        r"weed ?killer",
        r"solvents?",
        r"(?:paint )?thinners?",
        r"turpentine",
        r"white spirit",
        r"motor oil",
        r"engine oil",
        r"antifreeze",
        r"coolant",
        r"drain cleaner",
        r"oven cleaner",
        r"chemicals?",
        r"acids?",
        r"ammonia",
        r"detergents?",
        r"disinfectants?",
    ),
    ar=(
        "مبيض",
        "كلور",
        "مبيد",
        "مذيب",
        "تنر",
        "زيت محرك",
        "زيت المحرك",
        "مانع تجمد",
        "كيماوي",
        "كيميائي",
        "كيميايي",
        "حمض",
        "نشادر",
        "منظف",
        "مطهر",
    ),
)
# Strong chemicals only: a container of these with residue is routed to disposal. Everyday
# detergents and dish soap are not (their bottles are rinsed and recycled), but they still
# count for the food-reuse rule through _CHEMICAL.
_CHEMICAL_HAZARD = Terms(
    en=(
        r"bleach",
        r"pesticides?",
        r"insecticides?",
        r"herbicides?",
        r"weed ?killer",
        r"solvents?",
        r"(?:paint )?thinners?",
        r"turpentine",
        r"white spirit",
        r"motor oil",
        r"engine oil",
        r"antifreeze",
        r"coolant",
        r"drain cleaner",
        r"oven cleaner",
        r"chemicals?",
        r"acids?",
        r"ammonia",
        r"paint tins?",
    ),
    ar=(
        "مبيض",
        "كلور",
        "مبيد",
        "مذيب",
        "تنر",
        "زيت محرك",
        "زيت المحرك",
        "مانع تجمد",
        "كيماوي",
        "كيميائي",
        "حمض",
        "نشادر",
        "منظف مجاري",
        "منظف افران",
    ),
)
_CONTAINER = Terms(
    en=(
        r"bottles?",
        r"containers?",
        r"cans?",
        r"jugs?",
        r"tubs?",
        r"drums?",
        r"canisters?",
        r"jerry ?cans?",
        r"buckets?",
        r"jars?",
        r"sprayers?",
    ),
    ar=("قاروره", "زجاجه", "عبوه", "علبه", "علب", "وعاء", "برميل", "جالون", "غالون", "دلو", "برطمان"),
)
_FOOD_OR_PETS = Terms(
    en=(
        r"food",
        r"snacks?",
        r"drink(?:s|ing)?",
        r"beverages?",
        r"juice",
        r"cereal",
        r"rice",
        r"flour",
        r"spices?",
        r"lunch",
        r"edible",
        r"herbs?",
        r"vegetables?",
        r"veggies",
        r"tomato(?:es)?",
        r"fruits?",
        r"lettuce",
        r"mint",
        r"basil",
        r"pets?",
        r"dogs?",
        r"cats?",
        r"birds?",
        r"bird ?feeders?",
        r"bird ?bath",
        r"feeders?",
        r"water bowls?",
        r"chickens?",
        r"fish",
        r"aquariums?",
        r"hamsters?",
    ),
    ar=(
        "طعام",
        "غذاء",
        "غذائي",
        "=اكل",
        "وجبه",
        "=شراب",
        "مشروب",
        "=شرب",
        "عصير",
        "توابل",
        "بهارات",
        "=ارز",
        "طحين",
        "اعشاب",
        "نعناع",
        "ريحان",
        "خضار",
        "خضروات",
        "فاكهه",
        "فواكه",
        "طماطم",
        "حيوان اليف",
        "حيوانات اليفه",
        "=قطه",
        "قطط",
        "=كلب",
        "كلاب",
        "طيور",
        "=طاير",
        "معلف",
        "حوض سمك",
        "اسماك",
    ),
)
_PLASTIC = Terms(
    en=(
        r"plastics?",
        r"pet",
        r"hdpe",
        r"ldpe",
        r"pvc",
        r"polypropylene",
        r"polyethylene",
        r"polystyrene",
        r"styrofoam",
        r"bottle caps?",
        r"plastic bags?",
        r"carrier bags?",
    ),
    ar=("بلاستيك", "بولي", "ستايروفوم", "فلين", "اكياس نايلون", "نايلون"),
)
_HEAT = Terms(
    en=(
        r"melt(?:s|ed|ing)?",
        r"burn(?:s|ed|ing|t)?",
        r"heat(?:s|ed|ing)?(?: up)?",
        r"heat ?guns?",
        r"torch(?:es)?",
        r"blow ?torch",
        r"flames?",
        r"lighters?",
        r"candles?",
        r"tea ?lights?",
        r"ovens?",
        r"bake|baking",
        r"microwav\w*",
        r"iron(?:s|ed|ing)?",
        r"fus(?:e|ed|ing)",
        r"soldering",
    ),
    ar=(
        "صهر",
        "اذاب",
        "اذابه",
        "ذوب",
        "تذويب",
        "حرق",
        "احرق",
        "احتراق",
        "تسخين",
        "سخن",
        "مسدس حراري",
        "مسدس الهواء الساخن",
        "لهب",
        "ولاعه",
        "فرن",
        "شمع",
        "مكواه",
        "لحام",
    ),
)
_SAFE_LIGHT = Terms(en=(r"led", r"battery[- ]powered", r"electric"), ar=("ليد", "كهربائي", "بالبطاريه"))
_PAINT = Terms(
    en=(
        r"paint(?:s|ed|ing)?",
        r"varnish\w*",
        r"lacquer\w*",
        r"sealer",
        r"sealant",
        r"spray[- ]?paint\w*",
        r"stain(?:ed|ing)? (?:the )?wood",
    ),
    ar=("طلاء", "مطلي", "دهان", "مدهون", "ادهن", "ورنيش", "ورنش", "لاكيه"),
)
_FOOD_CONTACT = Terms(
    en=(
        r"food",
        r"eat(?:s|ing)? (?:from|off|out of)",
        r"serv(?:e|es|ing) (?:food|snacks|fruit|bread|salad|sweets|dates|cookies|nuts)",
        r"serving (?:trays?|bowls?|boards?|plates?|dish(?:es)?)",
        r"snack bowls?",
        r"fruit (?:bowls?|baskets?)",
        r"bread (?:baskets?|boxes?)",
        r"plates?",
        r"drink(?:ing)? (?:from|out of)",
        r"drinking (?:glass(?:es)?|cups?|vessels?)",
        r"cutlery",
        r"salad bowls?",
        r"lunch ?box(?:es)?",
    ),
    ar=(
        "طعام",
        "=للاكل",
        "=اكل",
        "تقديم الطعام",
        "تقديم الحلويات",
        "=صحن",
        "صحون",
        "طبق تقديم",
        "اطباق",
        "الشرب منه",
        "اكواب الشرب",
        "كوب للشرب",
        "=خبز",
        "حلويات",
        "سلطه",
        "وجبات",
        "فاكهه",
        "فواكه",
    ),
)
_FOOD_SAFE = Terms(
    en=(
        r"food[- ]safe",
        r"food[- ]grade",
        r"not for food",
        r"decorative only",
        r"outside only",
        r"exterior only",
        r"outside of the",
    ),
    ar=("امن للطعام", "امنه للطعام", "امن غذاييا", "للزينه فقط", "من الخارج فقط", "ليس للطعام"),
)


# ================================================================== 1. normalisation
_PROMOTE_TO_HAZARDOUS = {"battery", "aerosol", "medicine", "light_bulb"}


def normalise_item(item: Item, lang: str) -> Item:
    """Deterministically add hazards the model under-reported and make routing-relevant fields consistent."""
    s = Sentence(f"{item.name}. {item.material}")
    hazards = list(item.hazards)

    def add(flag: str) -> None:
        if flag not in hazards:
            hazards.append(flag)

    if item.category == "electronics":
        add("e_waste")
    if _BATTERY.found(s):
        add("battery")
    if _AEROSOL.found(s) and item.category in {"metal", "hazardous", "other"}:
        add("aerosol")
    if _MEDICINE.found(s) and item.category not in {"electronics", "organic", "textile", "wood"}:
        add("medicine")
    if _BULB.found(s) and item.category in {"hazardous", "glass", "electronics", "other"}:
        add("light_bulb")
    if _CHEMICAL_HAZARD.found(s) and ("contains_residue" in item.state or item.category == "hazardous"):
        add("chemical")
    if item.category == "glass" and "broken" in item.state:
        add("broken_glass")
    if item.category == "hazardous" and not hazards:
        add("chemical")  # an unexplained "hazardous" item is treated as the most cautious case

    category = item.category
    # Devices keep "electronics" (they go to e-waste); a bulb is a hazardous item even when
    # the model files it under electronics.
    if set(hazards) & _PROMOTE_TO_HAZARDOUS and (category != "electronics" or "light_bulb" in hazards):
        category = "hazardous"

    recyclability = item.recyclability
    if set(hazards) & DISPOSAL_ONLY_HAZARDS and recyclability.status == "yes":
        recyclability = recyclability.model_copy(
            update={
                "status": "conditional",
                "reason": recyclability.reason
                or (
                    "لا يُسلَّم إلا لنقطة تجميع مخصصة."
                    if lang == "ar"
                    else "Only through a dedicated collection point, never the household bin."
                ),
            }
        )
    if hazards == item.hazards and category == item.category and recyclability is item.recyclability:
        return item
    return item.model_copy(update={"hazards": hazards, "category": category, "recyclability": recyclability})


def normalise_items(items: Sequence[Item], lang: str) -> list[Item]:
    return [normalise_item(it, lang) for it in items]


# ======================================================================= 2. routing
_HAZARD_PRIORITY = ("battery", "chemical", "aerosol", "medicine", "light_bulb", "broken_glass", "e_waste")


def disposal_hazards(item: Item) -> list[str]:
    return [h for h in item.hazards if h in DISPOSAL_ONLY_HAZARDS]


def primary_hazard(item: Item) -> str | None:
    """The hazard that decides how an item is disposed of (devices are handled as e-waste)."""
    found = disposal_hazards(item)
    if not found:
        return None
    if item.category == "electronics" and "e_waste" in found:
        return "e_waste"
    return next(h for h in _HAZARD_PRIORITY if h in found)


ROUTING_REASONS: dict[str, dict[str, str]] = {
    "battery": {
        "en": "Batteries can leak or catch fire, so there's no DIY here. Here's how to get rid of them safely.",
        "ar": "البطاريات قد تسرّب موادّ ضارة أو تشتعل، لذلك لا مشاريع يدوية هنا. إليك طريقة التخلص منها بأمان.",
    },
    "e_waste": {
        "en": "Electronics hold batteries and metals that need special handling, so there's no DIY here.",
        "ar": "الأجهزة الإلكترونية تحتوي على بطاريات ومعادن تحتاج معاملة خاصة، لذلك لا مشاريع يدوية هنا.",
    },
    "chemical": {
        "en": "Containers with chemical residue aren't safe to reuse. Here's how to dispose of them safely.",
        "ar": "العبوات التي فيها بقايا كيميائية غير آمنة لإعادة الاستخدام. إليك طريقة التخلص منها بأمان.",
    },
    "aerosol": {
        "en": "Aerosol cans are pressurised and can burst, so there's no DIY here.",
        "ar": "علب الرذاذ مضغوطة وقد تنفجر، لذلك لا مشاريع يدوية هنا.",
    },
    "medicine": {
        "en": "Medicines go back to a pharmacy, not into DIY projects or the bin.",
        "ar": "الأدوية تعود إلى الصيدلية، لا إلى المشاريع اليدوية ولا إلى القمامة.",
    },
    "light_bulb": {
        "en": "Bulbs break into sharp glass and some contain mercury, so there's no DIY here.",
        "ar": "المصابيح تنكسر إلى زجاج حاد وبعضها يحتوي على الزئبق، لذلك لا مشاريع يدوية هنا.",
    },
    "broken_glass": {
        "en": "Broken glass is too sharp to work with. Here's how to wrap it and dispose of it safely.",
        "ar": "الزجاج المكسور أحدّ من أن يُعمل به. إليك طريقة لفّه والتخلص منه بأمان.",
    },
}


def route(items: Sequence[Item], lang: str) -> Routing:
    """The Safety Router: decide what the recommend graph may generate. Fully deterministic."""
    hazardous = [it for it in items if disposal_hazards(it)]
    if not hazardous:
        return Routing(mode="diy", hazardous_item_ids=[], reason=None)
    ids = [it.id for it in hazardous]
    key = "ar" if lang == "ar" else "en"
    if len(hazardous) == len(items):
        return Routing(
            mode="disposal_only",
            hazardous_item_ids=ids,
            reason=ROUTING_REASONS[primary_hazard(hazardous[0]) or "chemical"][key],
        )
    names = ("، " if key == "ar" else ", ").join(it.name for it in hazardous)
    reason = (
        f"{names}: للتخلص الآمن فقط، لذا تستخدم الأفكار الأغراض الأخرى."
        if key == "ar"
        else f"{names}: safe disposal only, so the ideas use the other items."
    )
    return Routing(mode="mixed", hazardous_item_ids=ids, reason=reason)


# ==================================================================== 3. validators
def check_plastic_heat(texts: Iterable[str | None], *, where: str = "") -> list[str]:
    """Never melt, burn or heat plastic (and never put a flame inside it)."""
    problems = []
    for s in sentences(texts):
        if is_negated(s) or not (_PLASTIC.found(s) and _HEAT.found(s)):
            continue
        if _SAFE_LIGHT.found(s) and not re.search(r"\b(?:melt|burn|heat|iron|fus)", s.en):
            continue  # "an LED tea light inside the bottle" is fine
        problems.append(
            f"{where}heats, melts or burns plastic ('{_quote(s)}'). Heated plastic releases toxic fumes: "
            "use a cold technique instead (cutting, gluing, weaving, lacing) and LED lights only."
        )
    return problems


def check_chemical_food(texts: Iterable[str | None], *, item_names: Iterable[str] = (), where: str = "") -> list[str]:
    """Never reuse a container that held chemicals for food, drink, edible plants or pets."""
    sents = sentences(texts)
    chemical_items = any(_CHEMICAL.found(Sentence(n)) for n in item_names)
    problems = []
    for s in sents:
        if is_negated(s) or not _FOOD_OR_PETS.found(s):
            continue
        if chemical_items or (_CHEMICAL.found(s) and _CONTAINER.found(s)):
            problems.append(
                f"{where}puts food, drink, edible plants or pets in contact with a container that held chemicals "
                f"('{_quote(s)}'). Residue cannot be washed out safely: choose a non-food use."
            )
    return problems


def check_painted_food_contact(texts: Iterable[str | None], *, where: str = "") -> list[str]:
    """Painted or varnished surfaces must not touch food unless a food-safe finish is stated."""
    sents = [s for s in sentences(texts)]
    if any(_FOOD_SAFE.found(s) for s in sents):
        return []
    live = [s for s in sents if not is_negated(s)]
    painted = [s for s in live if _PAINT.found(s)]
    food = [s for s in live if _FOOD_CONTACT.found(s)]
    if painted and food:
        return [
            f"{where}uses a painted or varnished surface for food ('{_quote(food[0])}'). Either keep paint to the "
            "outside and say so, state a food-safe finish, or make it a non-food object."
        ]
    return []


def check_no_hazardous_diy(used_ids: Iterable[str], hazardous_ids: Iterable[str], *, where: str = "") -> list[str]:
    bad = sorted(set(used_ids) & set(hazardous_ids))
    if bad:
        return [f"{where}uses {', '.join(bad)}, which must only be disposed of safely. Use only the other items."]
    return []


def check_english(value: str | None, *, field: str) -> list[str]:
    if has_arabic(value):
        return [f"{field} must be written in English: it drives image generation."]
    return []


def check_text_rules(texts: Sequence[str | None], *, item_names: Iterable[str] = (), where: str = "") -> list[str]:
    """All content rules that apply to any generated advice."""
    return (
        check_plastic_heat(texts, where=where)
        + check_chemical_food(texts, item_names=item_names, where=where)
        + check_painted_food_contact(texts, where=where)
    )


# --------------------------------------------------------------- protective gear
TECHNIQUES: dict[str, Terms] = {
    "blade_cutting": Terms(
        en=(
            r"craft ?knife",
            r"utility ?knife",
            r"box ?cutter",
            r"stanley ?knife",
            r"scalpel",
            r"blades?",
            r"x-?acto",
            r"sharp knife",
            r"kitchen knife",
        ),
        ar=("مشرط", "=كتر", "=الكتر", "شفره", "سكين حاد", "=سكين"),
    ),
    "sawing": Terms(en=(r"saw(?:s|ing|ed|n)?", r"hand ?saw", r"hacksaw", r"jigsaw"), ar=("منشار",)),
    "sanding": Terms(
        en=(
            r"sand ?paper",
            r"sanding",
            r"sander",
            r"sand (?:it|them|the|down|lightly|smooth|each|all|any|every|off|away|edges?)",
        ),
        ar=("صنفر",),
    ),
    "drilling": Terms(en=(r"drill(?:s|ed|ing)?", r"drill bits?"), ar=("مثقاب", "دريل")),
    "spray_painting": Terms(
        en=(r"spray[- ]?paint\w*", r"spray (?:it|them|the|a|an|two|three|light|thin|even)", r"aerosol paint"),
        ar=("طلاء بخاخ", "بخاخ", "رذاذ الطلاء"),
    ),
    "varnishing": Terms(
        en=(r"varnish\w*", r"lacquer\w*", r"polyurethane", r"sealer", r"sealant", r"resin"),
        ar=("ورنيش", "ورنش", "لاكيه", "ماده مانعه"),
    ),
    "painting": Terms(en=(r"paint(?:s|ed|ing)?", r"acrylics?"), ar=("طلاء", "دهان", "ادهن", "الوان اكريليك")),
    "sharp_edges": Terms(en=(r"sharp (?:edges?|rims?|ends?)", r"jagged"), ar=("حواف حاده", "حافه حاده", "حاده")),
}
# Glass and sharp-metal work need an action applied to the material, so a verb-object
# pattern ("cut the bottle", "punch holes in the can") is used rather than two loose words:
# "cut a length of twine to wrap the jar" is not glass work.
_GLASS_WORK_EN = re.compile(
    r"\b(?:cut|scor|drill|break|smash|grind|sand)\w*\s+(?:\w+\s+){0,3}?glass\b"
    r"|\b(?:glass|bottle)\s+cutters?\b|\bglass\s+(?:cutting|drilling|shards?|edges?)\b"
    r"|\bbroken glass\b|\b(?:cut|sharp|rough|raw) edges?\b.*\bglass\b"
)
_GLASS_AR = Terms(ar=("زجاج",))
_GLASS_ACTION_AR = Terms(ar=("اقطع", "=قطع", "تقطيع", "اكسر", "=كسر", "مكسور", "حواف", "شظايا", "اثقب", "صنفر"))
_METAL_WORK_EN = re.compile(
    r"\b(?:cut|snip|punch|pierc|poke|hammer)\w*\s+(?:\w+\s+){0,4}?(?:cans?|tins?|lids?|metal|alumin(?:i)?um|steel)\b"
    r"|\b(?:cans?|tins?|lids?|metal)\b.*\b(?:sharp|cut|jagged) (?:edges?|rims?)\b"
)
_METAL_AR = Terms(ar=("معدن", "المنيوم", "الومنيوم", "صفيح", "=علبه", "=علب", "غطاء معدني"))
_METAL_ACTION_AR = Terms(ar=("اقطع", "=قطع", "تقطيع", "=ثقب", "اثقب", "ثقوب", "حواف", "مسمار", "مسامير"))
_TOOL_TECHNIQUES = {
    "craft_knife": "blade_cutting",
    "handsaw": "sawing",
    "sandpaper": "sanding",
    "drill": "drilling",
    "spray_paint": "spray_painting",
    "varnish": "varnishing",
    "acrylic_paint": "painting",
}

GEAR_RULES: dict[str, tuple[str, ...]] = {
    "blade_cutting": ("gloves",),
    "sawing": ("gloves", "safety_glasses"),
    "glass_work": ("gloves", "safety_glasses"),
    "sharp_metal": ("gloves",),
    "sharp_edges": ("gloves",),
    "sanding": ("dust_mask",),
    "drilling": ("safety_glasses",),
    "spray_painting": ("dust_mask", "ventilation"),
    "varnishing": ("gloves", "ventilation"),
    "painting": ("gloves",),
}
TECHNIQUE_LABELS = {
    "blade_cutting": "cutting with a craft knife or blade",
    "sawing": "sawing",
    "glass_work": "cutting, drilling, sanding or breaking glass",
    "sharp_metal": "cutting or punching metal cans and lids",
    "sharp_edges": "handling sharp edges",
    "sanding": "sanding",
    "drilling": "drilling",
    "spray_painting": "spray painting",
    "varnishing": "varnishing or sealing",
    "painting": "painting",
}
GEAR_TERMS: dict[str, Terms] = {
    "gloves": Terms(en=(r"gloves?",), ar=("قفاز", "كفوف")),
    "safety_glasses": Terms(
        en=(r"safety glasses", r"goggles", r"eye protection", r"protective glasses", r"safety specs", r"glasses"),
        ar=("نظارات", "نظاره"),
    ),
    "dust_mask": Terms(en=(r"(?:dust )?masks?", r"respirators?"), ar=("كمامه", "كمامات", "قناع")),
    "ventilation": Terms(
        en=(r"ventilat\w*", r"outdoors", r"outside", r"open (?:a )?windows?", r"fresh air", r"well-?aired"),
        ar=("تهويه", "الهواء الطلق", "نافذه مفتوحه", "نوافذ مفتوحه", "خارج المنزل", "في الخارج", "مكان مفتوح"),
    ),
}
GEAR_NAMES = {
    "gloves": "work gloves",
    "safety_glasses": "safety glasses",
    "dust_mask": "a dust mask",
    "ventilation": "good ventilation (outdoors or by an open window)",
}
# Deterministic backstop lines, added when the model still leaves required gear out.
GEAR_LINES: dict[str, dict[str, str]] = {
    "blade_cutting": {
        "en": "Wear work gloves when using a blade and always cut away from your body.",
        "ar": "ارتدِ قفازات عمل عند استخدام الشفرة واقطع دائمًا بعيدًا عن جسمك.",
    },
    "sawing": {
        "en": "Wear work gloves and safety glasses while sawing, and clamp the piece first.",
        "ar": "ارتدِ قفازات عمل ونظارات واقية أثناء النشر، وثبّت القطعة أولًا.",
    },
    "glass_work": {
        "en": "Wear work gloves and safety glasses whenever you cut, drill or sand glass.",
        "ar": "ارتدِ قفازات عمل ونظارات واقية كلما قطعت الزجاج أو ثقبته أو صنفرته.",
    },
    "sharp_metal": {
        "en": "Wear work gloves: cut or punched metal edges are sharp.",
        "ar": "ارتدِ قفازات عمل، فحواف المعدن المقطوع أو المثقوب حادة.",
    },
    "sharp_edges": {
        "en": "Wear work gloves when handling sharp edges.",
        "ar": "ارتدِ قفازات عمل عند التعامل مع الحواف الحادة.",
    },
    "sanding": {
        "en": "Wear a dust mask while sanding and wipe the dust up with a damp cloth.",
        "ar": "ضع كمامة أثناء الصنفرة وامسح الغبار بقطعة قماش رطبة.",
    },
    "drilling": {
        "en": "Wear safety glasses when drilling.",
        "ar": "ارتدِ نظارات واقية عند الثقب بالمثقاب.",
    },
    "spray_painting": {
        "en": "Spray outdoors or by an open window and wear a dust mask.",
        "ar": "رشّ الطلاء في الهواء الطلق أو قرب نافذة مفتوحة وضع كمامة.",
    },
    "varnishing": {
        "en": "Apply varnish or sealer with good ventilation and wear gloves.",
        "ar": "ضع الورنيش أو المادة المانعة في مكان جيد التهوية وارتدِ قفازات.",
    },
    "painting": {
        "en": "Wear gloves or old clothes when painting and cover your work surface.",
        "ar": "ارتدِ قفازات أو ملابس قديمة عند الطلاء وغطِّ سطح العمل.",
    },
}


def detect_techniques(
    texts: Iterable[str | None], tools: Iterable[str] = (), *, include_painting: bool = True
) -> set[str]:
    """Which risky techniques the text (non-negated sentences) or the tool list implies."""
    found = {_TOOL_TECHNIQUES[t] for t in tools if t in _TOOL_TECHNIQUES}
    for s in sentences(texts):
        if is_negated(s):
            continue
        found |= {name for name, terms in TECHNIQUES.items() if terms.found(s)}
        # Arabic "زجاجة" also means a plastic bottle, so plastic sentences are not glass work.
        if _GLASS_WORK_EN.search(s.en) or (_GLASS_AR.found(s) and _GLASS_ACTION_AR.found(s) and not _PLASTIC.found(s)):
            found.add("glass_work")
        if _METAL_WORK_EN.search(s.en) or (_METAL_AR.found(s) and _METAL_ACTION_AR.found(s)):
            found.add("sharp_metal")
    if not include_painting:
        found.discard("painting")
    return found


def missing_gear(
    texts: Iterable[str | None],
    tools: Iterable[str],
    safety_texts: Iterable[str | None],
    *,
    include_painting: bool = True,
) -> dict[str, list[str]]:
    """``{technique: [gear not mentioned in the safety texts]}`` for every detected technique."""
    techniques = detect_techniques(texts, tools, include_painting=include_painting)
    safety = sentences(safety_texts)
    mentioned = {gear for gear, terms in GEAR_TERMS.items() if any(terms.found(s) for s in safety)}
    out: dict[str, list[str]] = {}
    for tech in sorted(techniques):
        lacking = [g for g in GEAR_RULES[tech] if g not in mentioned]
        if lacking:
            out[tech] = lacking
    return out


def check_protective_gear(
    texts: Iterable[str | None],
    tools: Iterable[str],
    safety_texts: Iterable[str | None],
    *,
    where: str = "",
    include_painting: bool = True,
) -> list[str]:
    """Protective gear must be named whenever the work involves cutting, sanding, drilling, painting, glass or sharp metal."""
    problems = []
    for tech, lacking in missing_gear(texts, tools, safety_texts, include_painting=include_painting).items():
        gear = " and ".join(GEAR_NAMES[g] for g in lacking)
        problems.append(
            f"{where}involves {TECHNIQUE_LABELS[tech]} but the safety notes do not mention {gear}. "
            f"Add a line such as: '{GEAR_LINES[tech]['en']}'"
        )
    return problems


def gear_lines(missing: dict[str, list[str]], lang: str) -> list[str]:
    key = "ar" if lang == "ar" else "en"
    return [GEAR_LINES[tech][key] for tech in missing]


def gear_rules_text() -> str:
    """The gear table rendered for prompts, so the prompt and the validator share one source of truth."""
    return "\n".join(
        f"- {TECHNIQUE_LABELS[t]}: {', '.join(GEAR_NAMES[g] for g in gear)}" for t, gear in GEAR_RULES.items()
    )


# -------------------------------------------------------------- tool availability
TOOL_TERMS: dict[str, Terms] = {
    "drill": Terms(en=(r"drill\w*",), ar=("مثقاب", "دريل")),
    "hot_glue_gun": Terms(
        en=(r"hot[- ]?glue", r"glue ?gun"), ar=("مسدس غراء", "غراء حراري", "الغراء الحراري", "غراء ساخن")
    ),
    "craft_knife": Terms(en=(r"craft ?knife", r"utility ?knife", r"box ?cutter"), ar=("مشرط", "كتر")),
    "handsaw": Terms(en=(r"saw", r"hand ?saw", r"hacksaw"), ar=("منشار",)),
    "sewing_machine": Terms(en=(r"sewing machine",), ar=("ماكينه خياطه", "ماكينه الخياطه")),
    "spray_paint": Terms(en=(r"spray[- ]?paint\w*",), ar=("طلاء بخاخ",)),
    "staple_gun": Terms(en=(r"staple ?gun", r"staples?"), ar=("دباسه",)),
    "iron": Terms(en=(r"iron(?:ing)?",), ar=("مكواه",)),
    "sandpaper": Terms(en=(r"sand ?paper", r"sanding"), ar=("صنفر",)),
    "wire_cutter": Terms(en=(r"wire ?cutters?",), ar=("قطاعه اسلاك",)),
    "clamps": Terms(en=(r"clamps?",), ar=("ملزمه", "ملازم")),
    "pliers": Terms(en=(r"pliers",), ar=("كماشه", "زرديه")),
    "screwdriver": Terms(en=(r"screwdrivers?",), ar=("مفك",)),
    "hammer": Terms(en=(r"hammer",), ar=("مطرقه", "شاكوش")),
    "sewing_kit": Terms(en=(r"needle",), ar=("ابره",)),
    "varnish": Terms(en=(r"varnish\w*", r"sealer"), ar=("ورنيش",)),
    "paintbrush": Terms(en=(r"paint ?brush\w*", r"brush"), ar=("فرشاه",)),
}
_OPTIONAL = re.compile(
    r"\b(?:instead of|rather than|if you have|if you don'?t|or an? |no need|optional|alternatively)\b"
)
_OPTIONAL_AR = ("بدلا", "بدل ", "ان وجد", "ان كان لديك", "اذا كان لديك", "اذا توفر", "لا حاجه", "اختياري")


def _optional(s: Sentence) -> bool:
    return bool(_OPTIONAL.search(s.en)) or any(p in s.ar for p in _OPTIONAL_AR) or is_negated(s)


def _tool_terms(tool_id: str) -> Terms:
    if tool_id in TOOL_TERMS:
        return TOOL_TERMS[tool_id]
    return Terms(en=(re.escape(labels.tool_label(tool_id, "en").lower()),), ar=(labels.tool_label(tool_id, "ar"),))


def check_missing_tools_used(step_texts: Sequence[tuple[int, str]], missing: Iterable[str]) -> list[str]:
    """A tutorial must work around tools the user lacks instead of requiring them."""
    problems = []
    for tool in missing:
        terms = _tool_terms(tool)
        for number, text in step_texts:
            hits = [s for s in sentences([text]) if terms.found(s) and not _optional(s)]
            if hits:
                problems.append(
                    f"Step {number} needs a {labels.tool_label(tool, 'en').lower()}, which the user does not have "
                    f"('{_quote(hits[0])}'). Rewrite it with the alternative or tools they have."
                )
                break
    return problems


def check_alternatives(alternatives: dict[str, str | None], missing: Iterable[str]) -> list[str]:
    """Every missing tool needs an alternative, and no alternative may rely on another missing tool."""
    missing = list(missing)
    problems = []
    for tool in missing:
        alt = (alternatives.get(tool) or "").strip()
        if not alt:
            problems.append(
                f"tools: '{tool}' is missing for this user; give an alternative that uses only things they have."
            )
            continue
        for other in missing:
            if other != tool and any(_tool_terms(other).found(s) and not _optional(s) for s in sentences([alt])):
                problems.append(f"tools: the alternative for '{tool}' relies on '{other}', which the user also lacks.")
    return problems


# ------------------------------------------------------------- two-tier validator
T = TypeVar("T")


class TwoTierValidator(Generic[T]):
    """Validator for ``GeminiGateway.structured`` with hard and soft rules.

    Hard rules (dangerous advice, wrong language for image prompts, DIY on hazardous items)
    are checked on every attempt: if the repair round still breaks one, the request fails
    rather than showing unsafe advice. Soft rules (missing gear lines, tool adaptation) are
    reported on the first attempt so the model can fix them itself; if it still misses them,
    the node repairs the output deterministically instead of failing the user's request.
    """

    def __init__(self, hard: Callable[[T], list[str]], soft: Callable[[T], list[str]] | None = None) -> None:
        self.hard = hard
        self.soft = soft
        self.calls = 0

    def __call__(self, obj: T) -> list[str]:
        self.calls += 1
        problems = self.hard(obj)
        if self.soft is not None and self.calls == 1:
            problems = problems + self.soft(obj)
        return problems
