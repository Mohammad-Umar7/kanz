"""Deterministic, localized fallbacks for when one branch of the recommend graph fails.

The four recommendation branches run in parallel. If one of them fails (a timeout, a
quota error, output that failed validation twice), the user still gets the other three,
and the failed path is filled from data we already trust: the analysis itself (the
analyst's recyclability fields), the retrieved knowledge documents, and the reviewed copy
below. Nothing here is generated, so nothing here can be unsafe.
"""

from __future__ import annotations

from collections.abc import Sequence

from app.ai import rag, safety
from app.ai.convert import idea_id, split_tools
from app.ai.rag import KnowledgeHit
from app.schemas.analysis import Item
from app.schemas.common import Profile
from app.schemas.recommend import (
    DisposalGuidance,
    DonateOption,
    DonatePath,
    RecycleInstruction,
    RecyclePath,
    UpcycleIdea,
)

L = dict[str, str]  # {"en": ..., "ar": ...}


def _t(copy: L, lang: str) -> str:
    return copy["ar"] if lang == "ar" else copy["en"]


# ------------------------------------------------------------------------ recycling
RECYCLE_TIPS: dict[str, tuple[L, L]] = {
    "glass": (
        {"en": "Sort by color if the bank has separate slots", "ar": "افرز حسب اللون إن كانت الحاوية مقسّمة"},
        {"en": "Don't include drinking glasses, mirrors or ceramics", "ar": "لا تضع أكواب الشرب أو المرايا أو الخزف"},
    ),
    "plastic": (
        {"en": "Squash bottles flat and keep the caps on", "ar": "اضغط القوارير لتسطيحها وأبقِ الأغطية عليها"},
        {"en": "Don't include greasy or food-filled containers", "ar": "لا تضع العلب الدهنية أو التي فيها بقايا طعام"},
    ),
    "paper": (
        {"en": "Flatten boxes to save space", "ar": "سطّح الصناديق لتوفير المساحة"},
        {"en": "Don't include wet, greasy or waxed paper", "ar": "لا تضع الورق المبلل أو الدهني أو المشمّع"},
    ),
    "metal": (
        {"en": "Rinse cans and push sharp lids inside", "ar": "اشطف العلب وأدخل الأغطية الحادة إلى داخلها"},
        {
            "en": "Don't include aerosol or paint cans that aren't empty",
            "ar": "لا تضع علب الرذاذ أو الطلاء غير الفارغة",
        },
    ),
    "textile": (
        {"en": "Wash, dry and bag textiles before drop-off", "ar": "اغسل المنسوجات وجففها وضعها في كيس قبل التسليم"},
        {"en": "Don't include wet or moldy items", "ar": "لا تضع القطع المبللة أو المتعفنة"},
    ),
    "wood": (
        {"en": "Remove nails and metal fittings where you can", "ar": "انزع المسامير والقطع المعدنية قدر الإمكان"},
        {"en": "Don't burn painted or treated wood", "ar": "لا تحرق الخشب المطلي أو المعالج"},
    ),
    "electronics": (
        {"en": "Wipe your personal data first", "ar": "امسح بياناتك الشخصية أولًا"},
        {"en": "Don't put electronics in household bins", "ar": "لا تضع الأجهزة الإلكترونية في سلال المنزل"},
    ),
    "hazardous": (
        {"en": "Keep it in its original container", "ar": "أبقِه في عبوته الأصلية"},
        {"en": "Don't put it in household bins", "ar": "لا تضعه في سلال المنزل"},
    ),
    "organic": (
        {"en": "Compost it if you can", "ar": "حوّله إلى سماد إن استطعت"},
        {"en": "Don't mix it with recyclables", "ar": "لا تخلطه مع المواد القابلة للتدوير"},
    ),
    "other": (
        {"en": "Separate parts made of different materials", "ar": "افصل الأجزاء المصنوعة من مواد مختلفة"},
        {"en": "When in doubt, keep it out of the recycling bin", "ar": "إن لم تكن متأكدًا فلا تضعه في حاوية التدوير"},
    ),
}
LOCAL_RULES_NOTE: L = {
    "en": "Rules differ between emirates, so check the label on the bin.",
    "ar": "تختلف القواعد بين الإمارات، فتحقق من الملصق على الحاوية.",
}
GENERIC_PREP: L = {"en": "Empty and rinse it", "ar": "أفرغه واشطفه"}


def recycle_instruction(item: Item, lang: str) -> RecycleInstruction:
    """The analyst's own recyclability fields, plus reviewed tips for the material."""
    do, dont = RECYCLE_TIPS.get(item.category, RECYCLE_TIPS["other"])
    rec = item.recyclability
    return RecycleInstruction(
        item_id=item.id,
        status=rec.status,
        stream=rec.stream,
        prep_steps=list(rec.prep_steps) or [_t(GENERIC_PREP, lang)],
        dos=[_t(do, lang)],
        donts=[_t(dont, lang)],
        note=rec.reason or _t(LOCAL_RULES_NOTE, lang),
    )


def recycle_path(items: Sequence[Item], lang: str, guides: Sequence[KnowledgeHit] = ()) -> RecyclePath:
    return RecyclePath(
        instructions=[recycle_instruction(it, lang) for it in items],
        sources=[rag.source_ref(h, lang) for h in guides],
    )


# ------------------------------------------------------------------------- donation
DONATE_WHERE: dict[str, list[L]] = {
    "textile": [
        {"en": "Clothing donation bins", "ar": "حاويات التبرع بالملابس"},
        {"en": "Charity shops", "ar": "متاجر الجمعيات الخيرية"},
    ],
    "glass": [
        {"en": "Refill and zero-waste shops", "ar": "متاجر إعادة التعبئة وصفر نفايات"},
        {"en": "Community kitchens", "ar": "المطابخ المجتمعية"},
    ],
    "plastic": [
        {"en": "School art rooms", "ar": "غرف الفنون في المدارس"},
        {"en": "Community gardens", "ar": "الحدائق المجتمعية"},
    ],
    "paper": [
        {"en": "Schools and nurseries", "ar": "المدارس ودور الحضانة"},
        {"en": "People moving house", "ar": "من ينتقلون إلى منزل جديد"},
    ],
    "metal": [
        {"en": "School art rooms", "ar": "غرف الفنون في المدارس"},
        {"en": "Charity shops", "ar": "متاجر الجمعيات الخيرية"},
    ],
    "wood": [
        {"en": "Gardeners and makers", "ar": "هواة الزراعة والحرف"},
        {"en": "Charity shops", "ar": "متاجر الجمعيات الخيرية"},
    ],
}
DONATE_WHERE_DEFAULT: list[L] = [{"en": "Community swap groups", "ar": "مجموعات التبادل المجتمعية"}]
DONATE_PREP: dict[str, list[L]] = {
    "textile": [
        {"en": "Wash and dry it", "ar": "اغسله وجففه"},
        {"en": "Fold it into a closed bag", "ar": "اطوه وضعه في كيس مغلق"},
    ],
}
DONATE_PREP_DEFAULT: list[L] = [{"en": "Clean and dry it", "ar": "نظّفه وجففه"}]
REASON_OK: L = {
    "en": "In good enough condition for someone else to use.",
    "ar": "بحالة جيدة تكفي ليستفيد منه شخص آخر.",
}
REASON_HAZARD: L = {"en": "Hazardous items can't be donated.", "ar": "لا يمكن التبرع بالأغراض الخطرة."}
REASON_CONDITION: L = {
    "en": "Its condition makes it unsuitable for donation; recycling is the better route.",
    "ar": "حالته لا تناسب التبرع، وإعادة التدوير هي الخيار الأفضل.",
}
SUMMARY_AVAILABLE: L = {
    "en": "Some of these can go to someone who will use them.",
    "ar": "يمكن أن يستفيد غيرك من بعض هذه الأغراض.",
}
SUMMARY_NONE: L = {
    "en": "These are better recycled than donated.",
    "ar": "إعادة تدوير هذه الأغراض أفضل من التبرع بها.",
}

# States that rule out donation whatever the model says.
UNDONATABLE_STATES = frozenset({"moldy", "broken"})


def donation_blocker(item: Item) -> str | None:
    """Why an item can never be donated ('hazard' / 'condition'), or None."""
    if item.hazards:
        return "hazard"
    if set(item.state) & UNDONATABLE_STATES:
        return "condition"
    return None


def donate_option(item: Item, lang: str) -> DonateOption:
    blocker = donation_blocker(item)
    suitable = blocker is None and item.quality.score >= 3
    if suitable:
        return DonateOption(
            item_id=item.id,
            suitable=True,
            reason=_t(REASON_OK, lang),
            where=[_t(w, lang) for w in DONATE_WHERE.get(item.category, DONATE_WHERE_DEFAULT)],
            prep_steps=[_t(p, lang) for p in DONATE_PREP.get(item.category, DONATE_PREP_DEFAULT)],
        )
    reason = REASON_HAZARD if blocker == "hazard" else REASON_CONDITION
    return DonateOption(item_id=item.id, suitable=False, reason=_t(reason, lang), where=[], prep_steps=[])


def donate_summary(available: bool, lang: str) -> str:
    return _t(SUMMARY_AVAILABLE if available else SUMMARY_NONE, lang)


def donate_path(items: Sequence[Item], lang: str) -> DonatePath:
    options = [donate_option(it, lang) for it in items]
    available = any(o.suitable for o in options)
    return DonatePath(available=available, summary=donate_summary(available, lang), options=options)


def donate_unavailable(lang: str) -> DonatePath:
    return DonatePath(available=False, summary=_t(REASON_HAZARD, lang), options=[])


# ------------------------------------------------------------------------- disposal
DISPOSAL_COPY: dict[str, dict[str, dict[str, str | list[str]]]] = {
    "battery": {
        "en": {
            "headline": "Take the batteries to a battery collection point.",
            "stream": "Battery collection point",
            "steps": [
                "Tape both ends of each battery",
                "Keep them in a dry jar away from heat",
                "Drop them in a battery box at a supermarket or electronics store",
            ],
            "never": [
                "Never put batteries in the household bin",
                "Never burn, crush or open them",
                "Never recharge single-use batteries",
            ],
            "dos": ["Collect used batteries in one jar and drop them off together"],
        },
        "ar": {
            "headline": "سلّم البطاريات إلى نقطة تجميع البطاريات.",
            "stream": "نقطة تجميع البطاريات",
            "steps": [
                "غطِّ طرفي كل بطارية بشريط لاصق",
                "احفظها في برطمان جاف بعيدًا عن الحرارة",
                "ضعها في صندوق البطاريات في أحد المتاجر الكبرى أو متاجر الإلكترونيات",
            ],
            "never": [
                "لا ترمِ البطاريات في سلة المنزل أبدًا",
                "لا تحرقها ولا تسحقها ولا تفتحها",
                "لا تعِد شحن البطاريات أحادية الاستخدام",
            ],
            "dos": ["اجمع البطاريات المستعملة في برطمان واحد وسلّمها معًا"],
        },
    },
    "e_waste": {
        "en": {
            "headline": "Take it to an e-waste collection point.",
            "stream": "E-waste collection",
            "steps": [
                "Back up and erase your personal data, then factory-reset it",
                "Tape over any cracked screen",
                "Hand it in at an e-waste box or a retailer take-back",
            ],
            "never": [
                "Never put electronics in the household bin",
                "Never open a device with a built-in battery",
                "Never burn cables",
            ],
            "dos": ["If it still works, ask a certified refurbisher or a trade-in programme first"],
        },
        "ar": {
            "headline": "سلّم الجهاز إلى نقطة تجميع النفايات الإلكترونية.",
            "stream": "تجميع النفايات الإلكترونية",
            "steps": [
                "انسخ بياناتك احتياطيًا ثم امسحها وأعد ضبط الجهاز",
                "غطِّ الشاشة المكسورة بشريط لاصق",
                "سلّمه إلى صندوق النفايات الإلكترونية أو برنامج الاسترجاع لدى المتاجر",
            ],
            "never": [
                "لا ترمِ الأجهزة الإلكترونية في سلة المنزل",
                "لا تفتح جهازًا بداخله بطارية مدمجة",
                "لا تحرق الأسلاك",
            ],
            "dos": ["إن كان يعمل، اسأل أولًا عن جهة معتمدة لإعادة التأهيل أو برنامج استبدال"],
        },
    },
    "chemical": {
        "en": {
            "headline": "Take it to a hazardous waste collection point.",
            "stream": "Hazardous waste collection",
            "steps": [
                "Keep it in its original container with the label on",
                "Close the lid tightly and stand it upright in a box",
                "Ask your municipality where hazardous waste is collected",
            ],
            "never": [
                "Never pour chemicals down the drain or onto the ground",
                "Never mix different chemicals",
                "Never reuse the container for food, drink or plants",
            ],
            "dos": ["Give unopened, in-date products to someone who can use them"],
        },
        "ar": {
            "headline": "سلّم العبوة إلى نقطة تجميع النفايات الخطرة.",
            "stream": "تجميع النفايات الخطرة",
            "steps": [
                "أبقِها في عبوتها الأصلية مع الملصق",
                "أحكم إغلاق الغطاء وضعها قائمة داخل صندوق",
                "اسأل البلدية عن مكان تجميع النفايات الخطرة",
            ],
            "never": [
                "لا تسكب المواد الكيميائية في المصرف أو على الأرض",
                "لا تخلط المواد الكيميائية ببعضها",
                "لا تعِد استخدام العبوة للطعام أو الشراب أو النباتات",
            ],
            "dos": ["أعطِ المنتجات غير المفتوحة والصالحة لمن يحتاجها"],
        },
    },
    "aerosol": {
        "en": {
            "headline": "Take the aerosol can to hazardous waste collection.",
            "stream": "Hazardous waste collection",
            "steps": [
                "Use it until it stops hissing",
                "Put the cap back on",
                "Keep it upright and out of the sun until drop-off",
            ],
            "never": [
                "Never puncture, crush or burn the can",
                "Never leave it in a hot car",
                "Never reuse it for crafts",
            ],
            "dos": ["Ask whether your local metal recycling accepts completely empty cans"],
        },
        "ar": {
            "headline": "سلّم علبة الرذاذ إلى نقطة تجميع النفايات الخطرة.",
            "stream": "تجميع النفايات الخطرة",
            "steps": [
                "استخدمها حتى يتوقف صوت الرذاذ تمامًا",
                "أعِد الغطاء إليها",
                "احفظها قائمة بعيدًا عن الشمس حتى تسليمها",
            ],
            "never": [
                "لا تثقب العلبة ولا تسحقها ولا تحرقها",
                "لا تتركها في سيارة ساخنة",
                "لا تعِد استخدامها في الحرف اليدوية",
            ],
            "dos": ["اسأل إن كانت حاوية المعادن المحلية تقبل العلب الفارغة تمامًا"],
        },
    },
    "medicine": {
        "en": {
            "headline": "Return the medicine to a pharmacy.",
            "stream": "Pharmacy take-back",
            "steps": [
                "Keep medicines in their original packaging",
                "Cross out your name on the label",
                "Ask your pharmacy how they collect expired medicines",
            ],
            "never": [
                "Never flush medicines down the toilet or sink",
                "Never give prescription medicines to someone else",
                "Never use blister packs for crafts",
            ],
            "dos": ["Check your medicine cabinet twice a year and return what has expired"],
        },
        "ar": {
            "headline": "أعِد الدواء إلى الصيدلية.",
            "stream": "استرجاع الأدوية في الصيدلية",
            "steps": [
                "أبقِ الأدوية في عبواتها الأصلية",
                "اشطب اسمك على الملصق",
                "اسأل الصيدلية عن طريقة تجميع الأدوية المنتهية",
            ],
            "never": [
                "لا تتخلص من الأدوية في المرحاض أو المغسلة",
                "لا تعطِ أدويتك الموصوفة لغيرك",
                "لا تستخدم أشرطة الأدوية في الحرف اليدوية",
            ],
            "dos": ["راجع خزانة الأدوية مرتين في السنة وأعِد المنتهي منها"],
        },
    },
    "light_bulb": {
        "en": {
            "headline": "Take the bulb to a lamp or e-waste collection point.",
            "stream": "Lamp and e-waste collection",
            "steps": [
                "Keep it in its box or wrap it in paper",
                "Store it where it cannot roll or break",
                "Hand it in at an e-waste or hazardous waste point",
            ],
            "never": [
                "Never put bulbs in the glass bank",
                "Never break a bulb on purpose",
                "Never vacuum up a broken energy-saving bulb",
            ],
            "dos": ["Switch to LED bulbs: they last much longer"],
        },
        "ar": {
            "headline": "سلّم المصباح إلى نقطة تجميع المصابيح أو النفايات الإلكترونية.",
            "stream": "تجميع المصابيح والنفايات الإلكترونية",
            "steps": [
                "احفظه في علبته أو لفّه بالورق",
                "ضعه حيث لا يتدحرج أو ينكسر",
                "سلّمه إلى نقطة النفايات الإلكترونية أو الخطرة",
            ],
            "never": [
                "لا تضع المصابيح في حاوية الزجاج",
                "لا تكسر المصباح عمدًا",
                "لا تنظّف مصباحًا موفرًا للطاقة مكسورًا بالمكنسة الكهربائية",
            ],
            "dos": ["استبدلها بمصابيح LED فهي تدوم أطول بكثير"],
        },
    },
    "broken_glass": {
        "en": {
            "headline": "Wrap the broken glass and put it out safely.",
            "stream": "Sealed box with general waste",
            "steps": [
                "Put on thick gloves and pick up the large pieces",
                "Press tape on small splinters to lift them",
                "Wrap everything in newspaper or seal it in a box labelled 'broken glass'",
            ],
            "never": [
                "Never pick up splinters with bare hands",
                "Never put loose broken glass in a plastic bag",
                "Never use broken glass for crafts",
            ],
            "dos": ["Check whether your glass bank accepts broken bottles and jars"],
        },
        "ar": {
            "headline": "لُفّ الزجاج المكسور وتخلّص منه بأمان.",
            "stream": "صندوق مغلق مع النفايات العامة",
            "steps": [
                "ارتدِ قفازات سميكة والتقط القطع الكبيرة",
                "اضغط شريطًا لاصقًا على الشظايا الصغيرة لالتقاطها",
                "لُفّ كل شيء بالجرائد أو أغلقه في صندوق مكتوب عليه: زجاج مكسور",
            ],
            "never": [
                "لا تلتقط الشظايا بيدين عاريتين",
                "لا تضع الزجاج المكسور مكشوفًا في كيس بلاستيكي",
                "لا تستخدم الزجاج المكسور في الحرف اليدوية",
            ],
            "dos": ["تحقق إن كانت حاوية الزجاج تقبل الزجاجات والبرطمانات المكسورة"],
        },
    },
}


def disposal_copy(hazard: str, lang: str) -> dict[str, str | list[str]]:
    return DISPOSAL_COPY.get(hazard, DISPOSAL_COPY["chemical"])["ar" if lang == "ar" else "en"]


def disposal_guidance(item: Item, lang: str) -> DisposalGuidance:
    hazard = safety.primary_hazard(item) or "chemical"
    copy = disposal_copy(hazard, lang)
    return DisposalGuidance(
        item_id=item.id,
        hazard=hazard,
        headline=str(copy["headline"]),
        steps=list(copy["steps"]),
        never=list(copy["never"]),
    )


def disposal_recycle_instruction(item: Item, guidance: DisposalGuidance, stream: str, lang: str) -> RecycleInstruction:
    """The Recycle tab entry for a hazardous item: its drop-off stream, never a household bin."""
    copy = disposal_copy(guidance.hazard, lang)
    return RecycleInstruction(
        item_id=item.id,
        status="no" if item.recyclability.status == "no" else "conditional",
        stream=stream,
        prep_steps=list(guidance.steps[:3]),
        dos=list(copy["dos"]),
        donts=list(guidance.never[:3]),
        note=item.recyclability.reason,
    )


# -------------------------------------------------------------------------- upcycle
def upcycle_from_projects(
    image_id: str, focus: Item, projects: Sequence[KnowledgeHit], profile: Profile
) -> list[UpcycleIdea]:
    """Three ideas straight from retrieved project documents (used when the Upcycle Designer fails)."""
    lang = profile.lang
    candidates = [h for h in projects if h.kind == "project" and focus.category in h.metadata.get("materials", [])]
    candidates = candidates or [h for h in projects if h.kind == "project"]
    if profile.skill == "beginner":
        candidates = [h for h in candidates if h.metadata.get("difficulty") != "hard"] or candidates
        candidates.sort(key=lambda h: h.metadata.get("difficulty") != "easy")
    ideas: list[UpcycleIdea] = []
    for hit in candidates[:3]:
        meta = hit.metadata
        title = hit.title_ar if lang == "ar" and hit.title_ar else hit.title
        needed, have, missing = split_tools(meta.get("tools", []), profile.tools)
        techniques = {t for t in meta.get("techniques", []) if t in safety.GEAR_RULES and t != "painting"}
        techniques |= safety.detect_techniques([], needed, include_painting=False)
        gear = safety.gear_lines({t: [] for t in sorted(techniques)}, lang)
        ideas.append(
            UpcycleIdea(
                id=idea_id(image_id, title),
                title=title,
                pitch=str(meta.get("summary_ar") if lang == "ar" else meta.get("summary")),
                difficulty=meta.get("difficulty", "easy"),
                time_minutes=int(meta.get("time_minutes", 30)),
                tools_needed=needed,
                tools_have=have,
                tools_missing=missing,
                uses_item_ids=[focus.id],
                extra_materials=[] if lang == "ar" else list(meta.get("extra_materials", [])),
                after_visual=f"the same {focus.category} item from the photo, now {meta.get('result', hit.title)}",
                safety_note=" ".join(gear[:2]) or None,
                sources=[rag.source_ref(hit, lang)],
            )
        )
    return ideas
