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

The checks look at each keyword where it occurs, not at the whole sentence, and skip the
ones a negation governs ("Never heat, melt or burn plastic" is advice; "Melt the caps in
the oven, no glue needed" is not). The bilingual matching lives in ``app.ai.textmatch``.
"""

from __future__ import annotations

import re
from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass
from typing import Generic, TypeVar

from app.ai import labels
from app.ai.textmatch import (
    AR_WORD,
    Sentence,
    Span,
    Terms,
    has_arabic,
    is_negated,
    live,
    negated,
    normalize_ar,
    quote,
    sentences,
)
from app.schemas.analysis import Item
from app.schemas.recommend import Routing
from app.schemas.vocab import DISPOSAL_ONLY_HAZARDS

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
# Devices are e-waste even when the model (or a user's correction) files them under
# plastic or metal: a phone must never reach the Upcycle Designer.
_DEVICE = Terms(
    en=(
        r"smart ?phones?",
        r"phones?",
        r"laptops?",
        r"tablet (?:computers?|pcs?)",
        r"chargers?",
        r"(?:charging|usb|phone|power) (?:cables?|cords?|leads?)",
        r"power (?:adapters?|supply|supplies|banks?)",
        r"extension cords?",
        r"headphones?",
        r"headsets?",
        r"earphones?",
        r"earbuds?",
        r"remote controls?",
        r"circuit boards?",
        r"computers?",
        r"keyboards?",
        r"printers?",
        r"routers?",
        r"modems?",
        r"hard drives?",
        r"game controllers?",
        r"consoles?",
        r"e-?cigarettes?",
        r"vapes?",
        r"smart ?watch(?:es)?",
        r"electronic (?:devices?|gadgets?|toys?|waste)",
        r"e-?waste",
        r"electrical appliances?",
    ),
    ar=(
        "هاتف",
        "جوال",
        "موبايل",
        "لابتوب",
        "حاسوب",
        "كمبيوتر",
        "شاحن",
        "سماعات",
        "ريموت",
        "جهاز تحكم",
        "لوحه مفاتيح",
        "طابعه",
        "راوتر",
        "سيجاره الكترونيه",
        "الكترونيات",
        "جهاز الكتروني",
        "اجهزه الكترونيه",
    ),
)
_DEVICE_ACCESSORY = Terms(
    en=(r"phone (?:cases?|covers?|stands?|holders?|mounts?|straps?)", r"(?:laptop|computer) (?:bags?|sleeves?|desks?)"),
    ar=("جراب", "غطاء هاتف", "غطاء الهاتف", "حامل هاتف", "حامل الهاتف", "حقيبه لابتوب"),
)
_CASING_CATEGORIES = frozenset({"plastic", "metal", "glass", "other"})
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
        r"paint (?:tins?|cans?|buckets?|pots?|containers?)",
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
        r"tins?",
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
        r"pet(?= bottles?\b| plastic\b| ?#| 1\b)",  # PET the plastic, not a pet
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
        r"hair ?dryers?",
        r"blow ?dryers?",
        r"hot air",
        r"boil(?:s|ed|ing)?",
    ),
    ar=(
        "صهر",
        "اصهر",
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
        "مجفف الشعر",
        "سشوار",
        "=غلي",
        "غليان",
    ),
)
_SAFE_LIGHT = Terms(en=(r"led", r"battery[- ]powered", r"electric"), ar=("ليد", "كهربائي", "بالبطاريه"))
# Light sources are fine next to an LED ("an LED tea light"); anything else still counts.
_LIGHT_SOURCE = Terms(en=(r"candles?", r"tea ?lights?"), ar=("شمع",))
_PAPER = Terms(
    en=(r"paper", r"papers", r"cardboard", r"card", r"newspapers?", r"magazines?", r"cartons?", r"tissue"),
    ar=("ورق", "اوراق", "كرتون", "جريد", "صحف", "مجلات"),
)
_FLAME = Terms(
    en=(
        r"candles?",
        r"tea ?lights?",
        r"flames?",
        r"lighters?",
        r"matches",
        r"matchsticks?",
        r"burn(?:s|ed|ing|t)?",
        r"torch(?:es)?",
        r"incense",
        r"sparklers?",
    ),
    ar=("شمع", "لهب", "ولاعه", "كبريت", "حرق", "احرق", "بخور"),
)
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

    device = _DEVICE.found(s) and not _DEVICE_ACCESSORY.found(s)
    category = item.category
    if device and category in _CASING_CATEGORIES:
        category = "electronics"  # a device filed under the material of its casing
    if category == "electronics" or (device and category == "hazardous"):
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
@dataclass(frozen=True)
class MaterialScope:
    """How advice can refer to a sensitive material (plastic, paper) among the scanned items.

    A sentence is about the material when it names it ("plastic", "PET"), names a scanned
    item made of it by its head noun ("caps", "bottle"), or when every scanned item is made
    of it: for a scan of bottle caps, "melt them in the oven" can only mean the plastic.
    """

    terms: Terms
    nouns: tuple[str, ...] = ()
    only: bool = False

    def mentioned(self, s: Sentence) -> bool:
        return self.only or self.terms.found(s) or any(_mentions(s, noun) for noun in self.nouns)


def _singular(word: str) -> str:
    if len(word) > 4 and word.endswith("ies"):
        return word[:-3] + "y"
    if len(word) > 3 and word.endswith("es") and word[-3] in "sxz":
        return word[:-2]
    if len(word) > 3 and word.endswith("s") and not word.endswith("ss"):
        return word[:-1]
    return word


def head_noun(name: str) -> str | None:
    """The noun a sentence would use for an item: "caps" for "Plastic bottle caps", "قارورة" for "قارورة مياه"."""
    english = re.findall(r"[a-z]+", name.lower())
    if english:
        noun = _singular(english[-1])
        return noun if len(noun) >= 3 else None
    arabic = AR_WORD.findall(normalize_ar(name))
    if arabic:
        noun = arabic[0][2:] if arabic[0].startswith("ال") and len(arabic[0]) > 4 else arabic[0]
        return noun if len(noun) >= 2 else None
    return None


def _mentions(s: Sentence, noun: str) -> bool:
    if noun.isascii():
        return bool(re.search(rf"\b{re.escape(noun)}(?:e?s)?\b", s.en))
    return any(tok.startswith(noun) for tok in s.ar_tokens)


def material_scope(items: Sequence[Item], category: str, terms: Terms) -> MaterialScope:
    made_of = [it for it in items if it.category == category or terms.found(Sentence(f"{it.name}. {it.material}"))]
    nouns = tuple(dict.fromkeys(n for n in (head_noun(it.name) for it in made_of) if n))
    return MaterialScope(terms, nouns, only=bool(items) and all(it.category == category for it in items))


def _flame_problems(texts: Iterable[str | None], heat: Terms, scope: MaterialScope, message: str) -> list[str]:
    problems = []
    for s in sentences(texts):
        found = live(heat, s)
        if not found or not scope.mentioned(s):
            continue
        if _SAFE_LIGHT.found(s) and all(_LIGHT_SOURCE.matches(sp.word) for sp in found):
            continue  # "an LED tea light inside the bottle" is fine
        problems.append(message.format(quote=quote(s)))
    return problems


def check_plastic_heat(texts: Iterable[str | None], *, items: Sequence[Item] = (), where: str = "") -> list[str]:
    """Never melt, burn or heat plastic, and never put a flame inside it."""
    return _flame_problems(
        texts,
        _HEAT,
        material_scope(items, "plastic", _PLASTIC),
        f"{where}heats, melts or burns plastic ('{{quote}}'). Hot plastic gives off toxic fumes: use a cold "
        "technique instead (cutting, gluing, weaving, lacing) and LED lights only.",
    )


def check_open_flame(texts: Iterable[str | None], *, items: Sequence[Item] = (), where: str = "") -> list[str]:
    """No candles or open flames in or on paper and cardboard."""
    return _flame_problems(
        texts,
        _FLAME,
        material_scope(items, "paper", _PAPER),
        f"{where}puts a flame in or near paper or cardboard ('{{quote}}'). Paper catches fire easily: use an LED "
        "light and no open flame.",
    )


def check_chemical_food(texts: Iterable[str | None], *, item_names: Iterable[str] = (), where: str = "") -> list[str]:
    """Never reuse a container that held chemicals for food, drink, edible plants or pets."""
    chemical_items = any(_CHEMICAL.found(Sentence(n)) for n in item_names)
    problems = []
    for s in sentences(texts):
        if not live(_FOOD_OR_PETS, s):
            continue
        # "a jar that held food, never one that held chemicals" names chemicals only to rule them out.
        if chemical_items or (live(_CHEMICAL, s, warnings=False) and _CONTAINER.found(s)):
            problems.append(
                f"{where}puts food, drink, edible plants or pets in contact with a container that held chemicals "
                f"('{quote(s)}'). Residue cannot be washed out safely: choose a non-food use."
            )
    return problems


def check_painted_food_contact(texts: Iterable[str | None], *, where: str = "") -> list[str]:
    """Painted or varnished surfaces must not touch food unless a food-safe finish is stated."""
    sents = sentences(texts)
    # "not food-safe" is not a food-safe finish, so only a live mention counts.
    if any(live(_FOOD_SAFE, s, warnings=False) for s in sents):
        return []
    painted = [s for s in sents if live(_PAINT, s)]
    food = [s for s in sents if live(_FOOD_CONTACT, s)]
    if painted and food:
        return [
            f"{where}uses a painted or varnished surface for food ('{quote(food[0])}'). Either keep paint to the "
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


def check_fire_rules(texts: Sequence[str | None], *, items: Sequence[Item] = (), where: str = "") -> list[str]:
    """Heat and flame rules: no heated plastic, no open flame near paper."""
    return check_plastic_heat(texts, items=items, where=where) + check_open_flame(texts, items=items, where=where)


def check_text_rules(texts: Sequence[str | None], *, items: Sequence[Item] = (), where: str = "") -> list[str]:
    """All content rules that apply to any generated advice about ``items``."""
    return (
        check_fire_rules(texts, items=items, where=where)
        + check_chemical_food(texts, item_names=[it.name for it in items], where=where)
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


def _live_pattern(pattern: re.Pattern[str], s: Sentence) -> bool:
    return any(not negated(Span(s.en, m.start(), m.end())) for m in pattern.finditer(s.en))


def detect_techniques(
    texts: Iterable[str | None], tools: Iterable[str] = (), *, include_painting: bool = True
) -> set[str]:
    """Which risky techniques the text (where not negated) or the tool list implies."""
    found = {_TOOL_TECHNIQUES[t] for t in tools if t in _TOOL_TECHNIQUES}
    for s in sentences(texts):
        found |= {name for name, terms in TECHNIQUES.items() if live(terms, s, warnings=False)}
        # Arabic "زجاجة" also means a plastic bottle, so plastic sentences are not glass work.
        glass_ar = _GLASS_AR.found(s) and live(_GLASS_ACTION_AR, s, warnings=False) and not _PLASTIC.found(s)
        if _live_pattern(_GLASS_WORK_EN, s) or glass_ar:
            found.add("glass_work")
        if _live_pattern(_METAL_WORK_EN, s) or (_METAL_AR.found(s) and live(_METAL_ACTION_AR, s, warnings=False)):
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
                    f"('{quote(hits[0])}'). Rewrite it with the alternative or tools they have."
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
    reported only before the repair round, so the model gets one chance to fix them; after
    that the node repairs the output deterministically instead of failing the request.

    The gateway calls ``begin_repair()`` before the repair round. That matters when the first
    answer was not even valid JSON: the validator never saw it, yet the repair round is
    already the last attempt, so soft rules must not fail it.
    """

    def __init__(self, hard: Callable[[T], list[str]], soft: Callable[[T], list[str]] | None = None) -> None:
        self.hard = hard
        self.soft = soft
        self.repairing = False

    def begin_repair(self) -> None:
        self.repairing = True

    def __call__(self, obj: T) -> list[str]:
        problems = self.hard(obj)
        if self.soft is not None and not self.repairing:
            problems = problems + self.soft(obj)
        return problems
