"""Build the JSON fixtures in contracts/fixtures/ from the Pydantic contract.

Fixtures are constructed as model instances, so they are valid by construction.
Backend tests, the Dart model tests and the app's screenshot tests all read them.
Facility entries are clearly labelled test data ("Fixture ...") and never shipped.

    cd backend && .venv/Scripts/python scripts/make_fixtures.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.schemas.analysis import (
    Analysis,
    AnalyzeResponse,
    BBox,
    Item,
    PhotoCheck,
    Quality,
    Quantity,
    Recyclability,
    ReusePotential,
)
from app.schemas.common import ErrorBody, ErrorResponse, LatLng, Profile, SourceRef
from app.schemas.facilities import FacilitiesResponse, FacilityCategoriesResponse, Place
from app.schemas.health import HealthResponse
from app.schemas.images import ImageResponse
from app.schemas.recommend import (
    DisposalGuidance,
    DonateOption,
    DonatePath,
    FacilityCategory,
    RecommendRequest,
    RecommendResponse,
    RecycleInstruction,
    RecyclePath,
    Routing,
    UpcycleIdea,
)
from app.schemas.swaps import HistorySummary, Swap, SwapsRequest, SwapsResponse
from app.schemas.tutorial import (
    Tutorial,
    TutorialMaterial,
    TutorialRequest,
    TutorialResponse,
    TutorialStep,
    TutorialTool,
)

OUT = Path(__file__).resolve().parents[2] / "contracts" / "fixtures"
JAR_IMG = "img_3f9a1c2b7d4e5f60"

# ----------------------------------------------------------------------------- analysis
jar = Item(
    id="item_1",
    name="Glass jam jar",
    category="glass",
    material="Clear soda-lime glass",
    quantity=Quantity(value=1, unit="pcs", is_estimate=False, display="1 pc"),
    quality=Quality(score=4, label="Good", notes="No chips or cracks; label residue on one side."),
    state=["empty", "label_on", "lid_on", "intact"],
    recyclability=Recyclability(
        status="yes",
        stream="Glass bottle bank",
        prep_steps=["Rinse out food residue", "Remove the metal lid", "Peel off the label if it comes away easily"],
    ),
    reuse=ReusePotential(level="high", note="Thick, clear glass with a screw thread: ideal for storage or lighting."),
    hazards=[],
    confidence=0.93,
    bbox=BBox(x=0.31, y=0.18, w=0.36, h=0.62),
)
lid = Item(
    id="item_2",
    name="Metal jar lid",
    category="metal",
    material="Tin-plated steel with plastic liner",
    quantity=Quantity(value=1, unit="pcs", is_estimate=False, display="1 pc"),
    quality=Quality(score=4, label="Good", notes="Slight scratches, no rust."),
    state=["clean", "intact"],
    recyclability=Recyclability(
        status="yes",
        stream="Metal recycling (cans)",
        prep_steps=["Keep it separate from the jar"],
    ),
    reuse=ReusePotential(level="medium", note="Can be punched for a hanging lantern or used as a coaster."),
    hazards=[],
    confidence=0.81,
    bbox=BBox(x=0.33, y=0.15, w=0.32, h=0.08),
)
analysis_jar = Analysis(
    items=[jar, lid],
    summary="An empty glass jam jar with its metal lid on.",
    photo=PhotoCheck(usable=True),
    primary_item_id="item_1",
    source="image",
)
analyze_jar = AnalyzeResponse(
    image_id=JAR_IMG,
    image_url=f"/static/uploads/{JAR_IMG}.jpg",
    image_width=1200,
    image_height=1600,
    analysis=analysis_jar,
    lang="en",
    timings_ms={"analysis": 4180, "total": 4390},
)

jar_ar = jar.model_copy(
    update={
        "name": "برطمان مربى زجاجي",
        "material": "زجاج شفاف (صودا-جير)",
        "quantity": Quantity(value=1, unit="pcs", is_estimate=False, display="قطعة واحدة"),
        "quality": Quality(score=4, label="جيد", notes="لا شقوق ولا كسور، وبقايا ملصق على جانب واحد."),
        "recyclability": Recyclability(
            status="yes",
            stream="حاوية الزجاج",
            prep_steps=["اشطفه من بقايا الطعام", "انزع الغطاء المعدني", "أزل الملصق إن انفصل بسهولة"],
        ),
        "reuse": ReusePotential(level="high", note="زجاج سميك وشفاف بفوهة ملولبة، مثالي للتخزين أو الإضاءة."),
    }
)
lid_ar = lid.model_copy(
    update={
        "name": "غطاء برطمان معدني",
        "material": "فولاذ مطلي بالقصدير مع بطانة بلاستيكية",
        "quantity": Quantity(value=1, unit="pcs", is_estimate=False, display="قطعة واحدة"),
        "quality": Quality(score=4, label="جيد", notes="خدوش خفيفة ولا صدأ."),
        "recyclability": Recyclability(status="yes", stream="تدوير المعادن (العلب)", prep_steps=["افصله عن البرطمان"]),
        "reuse": ReusePotential(level="medium", note="يمكن ثقبه لفانوس معلّق أو استخدامه كقاعدة أكواب."),
    }
)
analyze_jar_ar = analyze_jar.model_copy(
    update={
        "analysis": analysis_jar.model_copy(
            update={"items": [jar_ar, lid_ar], "summary": "برطمان مربى زجاجي فارغ بغطائه المعدني."}
        ),
        "lang": "ar",
    }
)

battery = Item(
    id="item_1",
    name="AA alkaline batteries",
    category="hazardous",
    material="Alkaline cell (zinc / manganese dioxide)",
    quantity=Quantity(value=4, unit="pcs", is_estimate=False, display="4 pcs"),
    quality=Quality(score=2, label="Worn", notes="Used; one shows light corrosion at the terminal."),
    state=["worn", "dirty"],
    recyclability=Recyclability(
        status="conditional",
        stream="Battery collection point",
        prep_steps=["Tape the terminals", "Keep them dry in a jar until drop-off"],
        reason="Only through dedicated battery collection, never household bins.",
    ),
    reuse=ReusePotential(level="low", note="Spent single-use cells have no safe reuse."),
    hazards=["battery"],
    confidence=0.96,
    bbox=BBox(x=0.22, y=0.30, w=0.55, h=0.40),
)
analyze_battery = AnalyzeResponse(
    image_id="img_b477e2a91c0d3e55",
    image_url="/static/uploads/img_b477e2a91c0d3e55.jpg",
    image_width=1600,
    image_height=1200,
    analysis=Analysis(
        items=[battery],
        summary="Four used AA batteries.",
        photo=PhotoCheck(usable=True),
        primary_item_id="item_1",
        source="image",
    ),
    lang="en",
    timings_ms={"analysis": 3920, "total": 4105},
)

tshirt = Item(
    id="item_1",
    name="Cotton t-shirt",
    category="textile",
    material="100% cotton jersey",
    quantity=Quantity(value=1, unit="pcs", is_estimate=False, display="1 pc"),
    quality=Quality(score=3, label="Fair", notes="Faded print and a small hole near the hem."),
    state=["clean", "faded", "worn", "torn"],
    recyclability=Recyclability(
        status="conditional",
        stream="Textile recycling bank",
        prep_steps=["Wash and dry it", "Bag it to keep it dry"],
        reason="Clean, dry textiles only.",
    ),
    reuse=ReusePotential(level="high", note="Soft knit cotton cuts cleanly and does not fray."),
    hazards=[],
    confidence=0.9,
    bbox=BBox(x=0.12, y=0.1, w=0.76, h=0.8),
)
analyze_tshirt = AnalyzeResponse(
    image_id="img_7e5d0c4b3a291f88",
    image_url="/static/uploads/img_7e5d0c4b3a291f88.jpg",
    image_width=1200,
    image_height=1600,
    analysis=Analysis(
        items=[tshirt],
        summary="A faded grey cotton t-shirt, laid flat.",
        photo=PhotoCheck(usable=True),
        primary_item_id="item_1",
        source="image",
    ),
    lang="en",
    timings_ms={"analysis": 4010, "total": 4200},
)

analyze_unclear = AnalyzeResponse(
    image_id="img_0c1d2e3f4a5b6c7d",
    image_url="/static/uploads/img_0c1d2e3f4a5b6c7d.jpg",
    image_width=1600,
    image_height=1200,
    analysis=Analysis(
        items=[],
        summary="The photo is too dark and blurred to identify anything.",
        photo=PhotoCheck(
            usable=False,
            issue="too_dark",
            retake_tip="Move next to a window or turn on a light, then hold the phone still for a second.",
        ),
        primary_item_id=None,
        source="image",
    ),
    lang="en",
    timings_ms={"analysis": 2950, "total": 3100},
)

caps = Item(
    id="item_1",
    name="Plastic bottle caps",
    category="plastic",
    material="HDPE #2 / PP #5 caps",
    resin_code=2,
    is_raw_material=True,
    quantity=Quantity(value=30, unit="pcs", is_estimate=True, display="~30 pcs"),
    quality=Quality(score=4, label="Good"),
    state=["clean"],
    recyclability=Recyclability(
        status="conditional",
        stream="Plastics recycling",
        prep_steps=["Collect in a bottle"],
        reason="Loose caps are too small for some sorting lines.",
    ),
    reuse=ReusePotential(level="high", note="Bright, uniform pieces work well for mosaics."),
    confidence=0.72,
)
analyze_text = AnalyzeResponse(
    image_id="txt_5a6b7c8d9e0f1a2b",
    image_url=None,
    analysis=Analysis(
        items=[caps],
        summary="About thirty mixed plastic bottle caps.",
        photo=PhotoCheck(usable=True),
        primary_item_id="item_1",
        source="text",
    ),
    lang="en",
    timings_ms={"analysis": 2600, "total": 2650},
)

# ----------------------------------------------------------------------------- recommend
src_lantern = SourceRef(id="proj_glass_jar_lantern", title="Jar lantern project", kind="project")
src_glass_safety = SourceRef(id="safety_glass_handling", title="Glass safety", kind="safety")
src_glass_guide = SourceRef(id="mat_glass", title="Glass: identification and prep", kind="material_guide")

lantern = UpcycleIdea(
    id="idea_9f2c41aa",
    title="Hanging jar lantern",
    pitch="A warm tea-light lantern with a twine handle, for the balcony or a dinner table.",
    difficulty="easy",
    time_minutes=35,
    tools_needed=["twine", "craft_wire", "pliers", "scissors"],
    tools_have=["twine", "pliers", "scissors"],
    tools_missing=["craft_wire"],
    uses_item_ids=["item_1"],
    extra_materials=["Tea light", "Sand or small pebbles"],
    after_visual=(
        "the same clear glass jar, label removed, a wire loop wrapped tightly under the rim with a twine-wrapped "
        "handle, a lit tea light sitting on a thin layer of sand inside"
    ),
    safety_note="Never leave a lit candle unattended; use an LED tea light indoors.",
    sources=[src_lantern, src_glass_safety],
)
herb = UpcycleIdea(
    id="idea_1b7e03d5",
    title="Kitchen herb jar",
    pitch="Grow basil or mint on the windowsill, with a pebble layer for drainage.",
    difficulty="easy",
    time_minutes=25,
    tools_needed=["scissors"],
    tools_have=["scissors"],
    tools_missing=[],
    uses_item_ids=["item_1"],
    extra_materials=["Pebbles", "Potting mix", "Herb seedling"],
    after_visual="the same glass jar filled with a pebble layer, dark potting soil and a small basil plant",
    sources=[SourceRef(id="proj_glass_jar_herb_garden", title="Jar herb garden", kind="project")],
)
organizer = UpcycleIdea(
    id="idea_c40d9e17",
    title="Painted desk organizer",
    pitch="Frosted paint and a twine band turn it into a pen and brush holder.",
    difficulty="medium",
    time_minutes=60,
    tools_needed=["acrylic_paint", "paintbrush", "masking_tape", "twine"],
    tools_have=["twine"],
    tools_missing=["acrylic_paint", "paintbrush", "masking_tape"],
    uses_item_ids=["item_1", "item_2"],
    extra_materials=["Pens and brushes to fill it"],
    after_visual="the same jar painted matte white on the outside with a clean unpainted band, holding pens and pencils",
    sources=[SourceRef(id="proj_glass_painted_jar", title="Painted jar organizer", kind="project")],
)
recommend_jar = RecommendResponse(
    routing=Routing(mode="diy"),
    upcycle=[lantern, herb, organizer],
    recycle=RecyclePath(
        instructions=[
            RecycleInstruction(
                item_id="item_1",
                status="yes",
                stream="Glass bottle bank",
                prep_steps=["Rinse out food residue", "Remove the lid", "Labels can stay on if they won't peel"],
                dos=["Sort by color if the bank has separate slots"],
                donts=["Don't include drinking glasses, mirrors or ceramics", "Don't bag the glass"],
            ),
            RecycleInstruction(
                item_id="item_2",
                status="yes",
                stream="Metal recycling (cans)",
                prep_steps=["Keep the lid separate from the jar"],
                dos=["Put several small lids inside a can and pinch it closed"],
                donts=["Don't leave the lid screwed on the jar"],
            ),
        ],
        sources=[src_glass_guide],
    ),
    donate=DonatePath(
        available=True,
        summary="Clean jars are welcome at community kitchens and refill shops.",
        options=[
            DonateOption(
                item_id="item_1",
                suitable=True,
                reason="Intact, clean jar with a working lid.",
                where=["Refill and zero-waste shops", "Community kitchens"],
                prep_steps=["Wash and dry it", "Keep the lid with it"],
            )
        ],
    ),
    facility_categories=[
        FacilityCategory(
            key="glass",
            label="Glass recycling",
            facility_types=["recycling_center", "collection_point"],
            material_categories=["glass"],
            item_ids=["item_1"],
        ),
        FacilityCategory(
            key="metal",
            label="Metal recycling",
            facility_types=["recycling_center", "scrap_metal"],
            material_categories=["metal"],
            item_ids=["item_2"],
        ),
    ],
    lang="en",
    timings_ms={"safety_router": 1, "retrieval": 420, "upcycle": 6150, "recycle": 3900, "donate": 2700, "total": 6620},
)

recommend_battery = RecommendResponse(
    routing=Routing(
        mode="disposal_only",
        hazardous_item_ids=["item_1"],
        reason="Batteries can leak or catch fire, so there's no DIY here. Here's how to get rid of them safely.",
    ),
    upcycle=[],
    recycle=RecyclePath(
        instructions=[
            RecycleInstruction(
                item_id="item_1",
                status="conditional",
                stream="Battery collection point",
                prep_steps=["Put tape over both terminals", "Store in a dry jar until you drop them off"],
                dos=["Use the battery boxes at supermarkets and electronics stores"],
                donts=["Never put batteries in the household bin", "Don't store them loose in a drawer with metal"],
            )
        ],
        sources=[SourceRef(id="safety_batteries", title="Battery safety", kind="safety")],
    ),
    donate=DonatePath(available=False, summary="Used batteries can't be donated.", options=[]),
    disposal=[
        DisposalGuidance(
            item_id="item_1",
            hazard="battery",
            headline="Take the batteries to a battery collection point.",
            steps=["Tape both ends of every battery", "Keep them in a dry glass jar", "Drop them at a collection box"],
            never=[
                "Never throw them in the bin",
                "Never burn, crush or open them",
                "Never try to recharge alkaline cells",
            ],
        )
    ],
    facility_categories=[
        FacilityCategory(
            key="battery",
            label="Battery collection",
            facility_types=["hazardous_waste", "e_waste", "collection_point"],
            material_categories=["hazardous"],
            item_ids=["item_1"],
        )
    ],
    lang="en",
    timings_ms={"safety_router": 1, "retrieval": 380, "recycle": 3300, "total": 3450},
)

recommend_tshirt = RecommendResponse(
    routing=Routing(mode="diy"),
    upcycle=[
        UpcycleIdea(
            id="idea_5e8a0b21",
            title="No-sew tote bag",
            pitch="Cut the sleeves and neck, tie the hem: a washable shopping bag in 20 minutes.",
            difficulty="easy",
            time_minutes=20,
            tools_needed=["scissors", "ruler_pencil"],
            tools_have=["scissors"],
            tools_missing=["ruler_pencil"],
            uses_item_ids=["item_1"],
            after_visual="the same grey cotton t-shirt made into a tote bag: sleeves and neckline cut away, bottom hem cut into fringe strips tied in knots",
            sources=[SourceRef(id="proj_textile_tshirt_tote", title="T-shirt tote bag", kind="project")],
        ),
        UpcycleIdea(
            id="idea_2d9f6c30",
            title="Braided rag rug coaster set",
            pitch="Cut the shirt into yarn and braid four sturdy coasters.",
            difficulty="medium",
            time_minutes=75,
            tools_needed=["scissors", "sewing_kit"],
            tools_have=["scissors"],
            tools_missing=["sewing_kit"],
            uses_item_ids=["item_1"],
            after_visual="four round coasters coiled from braided strips of the same grey cotton jersey",
            sources=[SourceRef(id="proj_textile_braided_coasters", title="Braided coasters", kind="project")],
        ),
        UpcycleIdea(
            id="idea_8c1a4e77",
            title="Cleaning cloths",
            pitch="Square, hemless cloths that beat paper towels for dusting and polishing.",
            difficulty="easy",
            time_minutes=10,
            tools_needed=["scissors"],
            tools_have=["scissors"],
            tools_missing=[],
            uses_item_ids=["item_1"],
            after_visual="a neat stack of square cloths cut from the same grey cotton t-shirt",
            sources=[SourceRef(id="proj_textile_cleaning_cloths", title="Rag cleaning cloths", kind="project")],
        ),
    ],
    recycle=RecyclePath(
        instructions=[
            RecycleInstruction(
                item_id="item_1",
                status="conditional",
                stream="Textile recycling bank",
                prep_steps=["Wash and dry it", "Put it in a tied bag"],
                dos=["Include worn or torn cotton: it becomes insulation or rags"],
                donts=["Don't include wet or mouldy textiles"],
            )
        ]
    ),
    donate=DonatePath(
        available=True,
        summary="Wearable despite fading: a clothing donation bin can pass it on.",
        options=[
            DonateOption(
                item_id="item_1",
                suitable=True,
                reason="Clean and wearable; the small hole can be mended.",
                where=["Clothing donation bins", "Charity shops"],
                prep_steps=["Wash it", "Fold it into a bag"],
            )
        ],
    ),
    facility_categories=[
        FacilityCategory(
            key="textile_donation",
            label="Clothes donation",
            facility_types=["donation", "collection_point"],
            material_categories=["textile"],
            item_ids=["item_1"],
        )
    ],
    lang="en",
    timings_ms={"safety_router": 1, "retrieval": 410, "upcycle": 5900, "recycle": 3100, "donate": 2800, "total": 6300},
)

lantern_ar = lantern.model_copy(
    update={
        "title": "فانوس برطمان معلّق",
        "pitch": "فانوس دافئ بشمعة صغيرة ومقبض من الخيط، للشرفة أو مائدة العشاء.",
        "extra_materials": ["شمعة صغيرة", "رمل أو حصى صغيرة"],
        "safety_note": "لا تترك الشمعة مشتعلة دون مراقبة، واستخدم شمعة LED داخل المنزل.",
        "sources": [
            SourceRef(id="proj_glass_jar_lantern", title="مشروع فانوس البرطمان", kind="project"),
            SourceRef(id="safety_glass_handling", title="سلامة التعامل مع الزجاج", kind="safety"),
        ],
    }
)
herb_ar = herb.model_copy(
    update={
        "title": "برطمان أعشاب للمطبخ",
        "pitch": "ازرع الريحان أو النعناع على حافة النافذة مع طبقة حصى للتصريف.",
        "extra_materials": ["حصى", "تربة زراعية", "شتلة أعشاب"],
        "sources": [SourceRef(id="proj_glass_jar_herb_garden", title="حديقة أعشاب في برطمان", kind="project")],
    }
)
organizer_ar = organizer.model_copy(
    update={
        "title": "منظّم مكتب مطلي",
        "pitch": "طلاء مطفأ وحزام من الخيط يحوّلانه إلى حامل أقلام وفرش.",
        "extra_materials": ["أقلام وفرش لملئه"],
        "sources": [SourceRef(id="proj_glass_painted_jar", title="منظّم البرطمان المطلي", kind="project")],
    }
)
recommend_jar_ar = recommend_jar.model_copy(
    update={
        "upcycle": [lantern_ar, herb_ar, organizer_ar],
        "recycle": RecyclePath(
            instructions=[
                RecycleInstruction(
                    item_id="item_1",
                    status="yes",
                    stream="حاوية الزجاج",
                    prep_steps=["اشطفه من بقايا الطعام", "انزع الغطاء", "لا بأس ببقاء الملصق إن لم ينفصل"],
                    dos=["افرز حسب اللون إن كانت للحاوية فتحات منفصلة"],
                    donts=["لا تضع أكواب الشرب أو المرايا أو الخزف", "لا تضع الزجاج في كيس"],
                ),
                RecycleInstruction(
                    item_id="item_2",
                    status="yes",
                    stream="تدوير المعادن (العلب)",
                    prep_steps=["افصل الغطاء عن البرطمان"],
                    dos=["اجمع الأغطية الصغيرة داخل علبة واضغط فوهتها"],
                    donts=["لا تترك الغطاء مركّبًا على البرطمان"],
                ),
            ],
            sources=[SourceRef(id="mat_glass", title="الزجاج: التعرّف والتحضير", kind="material_guide")],
        ),
        "donate": DonatePath(
            available=True,
            summary="البرطمانات النظيفة مرحّب بها في مطابخ المجتمع ومتاجر إعادة التعبئة.",
            options=[
                DonateOption(
                    item_id="item_1",
                    suitable=True,
                    reason="برطمان سليم ونظيف بغطاء يعمل.",
                    where=["متاجر إعادة التعبئة", "المطابخ المجتمعية"],
                    prep_steps=["اغسله وجففه", "أبقِ الغطاء معه"],
                )
            ],
        ),
        "facility_categories": [
            FacilityCategory(
                key="glass",
                label="تدوير الزجاج",
                facility_types=["recycling_center", "collection_point"],
                material_categories=["glass"],
                item_ids=["item_1"],
            ),
            FacilityCategory(
                key="metal",
                label="تدوير المعادن",
                facility_types=["recycling_center", "scrap_metal"],
                material_categories=["metal"],
                item_ids=["item_2"],
            ),
        ],
        "lang": "ar",
    }
)

recommend_request = RecommendRequest(
    image_id=JAR_IMG,
    analysis=analysis_jar,
    profile=Profile(skill="beginner", tools=["scissors", "pliers", "twine"], lang="en"),
)

# ----------------------------------------------------------------------------- tutorial
steps = [
    TutorialStep(
        number=1,
        title="Soak off the label",
        instruction="Fill a bowl with warm soapy water and soak the jar for 10 minutes, then peel the label and rub off the glue with a cloth.",
        tip="A little cooking oil lifts stubborn glue.",
        duration_minutes=12,
        image_prompt="the same jar with the paper label fully removed, clean and dry on the counter, lid set aside",
    ),
    TutorialStep(
        number=2,
        title="Wrap the wire collar",
        instruction="Wrap craft wire twice around the groove under the rim and twist the ends together with pliers until it doesn't slide.",
        warning="Wire ends are sharp: tuck them flat against the glass.",
        duration_minutes=5,
        image_prompt="the same clean jar with a snug double loop of thin silver wire twisted around the neck under the rim",
    ),
    TutorialStep(
        number=3,
        title="Add the handle",
        instruction="Cut 30 cm of wire, hook each end through the collar on opposite sides and bend them closed to form an arch.",
        duration_minutes=5,
        image_prompt="the same jar now with an arched wire handle attached to the neck collar on both sides",
    ),
    TutorialStep(
        number=4,
        title="Wrap the handle in twine",
        instruction="Tie twine to one end of the handle and wind it tightly along the arch. Tie off and dab the knot with glue if you have some.",
        tip="Keep each turn touching the last for a neat finish.",
        duration_minutes=8,
        image_prompt="the same jar lantern with its wire handle fully wrapped in natural brown twine",
    ),
    TutorialStep(
        number=5,
        title="Add sand and a tea light",
        instruction="Pour 2 cm of sand or pebbles into the jar and press a tea light into the middle.",
        warning="Use an LED tea light indoors and never leave a flame unattended.",
        duration_minutes=3,
        image_prompt="the finished jar lantern with a layer of pale sand inside and a tea light sitting in the middle, lit",
    ),
]
tutorial_jar = Tutorial(
    tutorial_id="tut_8d1e2f3a4b5c6d7e",
    idea_id=lantern.id,
    image_id=JAR_IMG,
    title="Hanging jar lantern",
    adapted_note="Adapted for Beginner: pliers instead of a drill, no glass cutting.",
    skill="beginner",
    total_minutes=33,
    materials=[
        TutorialMaterial(name="Glass jam jar", quantity="1", from_scan=True, item_id="item_1"),
        TutorialMaterial(name="Craft wire", quantity="60 cm", from_scan=False),
        TutorialMaterial(name="Twine", quantity="2 m", from_scan=False),
        TutorialMaterial(name="Sand or small pebbles", quantity="1 cup", from_scan=False),
        TutorialMaterial(name="Tea light", quantity="1", from_scan=False),
    ],
    tools=[
        TutorialTool(tool_id="pliers", have=True),
        TutorialTool(tool_id="scissors", have=True),
        TutorialTool(tool_id="twine", have=True),
        TutorialTool(
            tool_id="craft_wire", have=False, alternative="A straightened metal coat hanger or a sturdy key-ring chain"
        ),
    ],
    safety=["Wear work gloves when bending wire", "Check the jar for chips before you start"],
    steps=steps,
    finishing=["Hang it from a hook at least 30 cm below anything that can burn"],
    care=["Wipe soot off the inside with a damp cloth", "Replace the sand if wax spills into it"],
    sources=[src_lantern, src_glass_safety],
    lang="en",
)
tutorial_request = TutorialRequest(
    image_id=JAR_IMG,
    idea=lantern,
    items=[jar],
    profile=Profile(skill="beginner", tools=["scissors", "pliers", "twine"], lang="en"),
)
tutorial_jar_ar = tutorial_jar.model_copy(
    update={
        "title": "فانوس برطمان معلّق",
        "adapted_note": "مُعدّ للمبتدئين: كماشة بدل المثقاب، ودون قص للزجاج.",
        "materials": [
            TutorialMaterial(name="برطمان مربى زجاجي", quantity="1", from_scan=True, item_id="item_1"),
            TutorialMaterial(name="سلك حِرفي", quantity="60 سم", from_scan=False),
            TutorialMaterial(name="خيط قنّب", quantity="2 م", from_scan=False),
            TutorialMaterial(name="رمل أو حصى صغيرة", quantity="كوب واحد", from_scan=False),
            TutorialMaterial(name="شمعة صغيرة", quantity="1", from_scan=False),
        ],
        "tools": [
            TutorialTool(tool_id="pliers", have=True),
            TutorialTool(tool_id="scissors", have=True),
            TutorialTool(tool_id="twine", have=True),
            TutorialTool(
                tool_id="craft_wire", have=False, alternative="علاقة ملابس معدنية مفرودة أو سلسلة مفاتيح متينة"
            ),
        ],
        "safety": ["ارتدِ قفازات العمل عند ثني السلك", "افحص البرطمان بحثًا عن أي كسور قبل البدء"],
        "steps": [
            s.model_copy(update=u)
            for s, u in zip(
                steps,
                [
                    {
                        "title": "انزع الملصق بالنقع",
                        "instruction": "املأ وعاءً بماء دافئ وصابون وانقع البرطمان 10 دقائق، ثم انزع الملصق وامسح الغراء بقطعة قماش.",
                        "tip": "قليل من زيت الطبخ يزيل الغراء العنيد.",
                    },
                    {
                        "title": "لفّ طوق السلك",
                        "instruction": "لفّ السلك مرتين حول التجويف أسفل الحافة واجدل طرفيه بالكماشة حتى لا ينزلق.",
                        "warning": "أطراف السلك حادة: اثنها لتلتصق بالزجاج.",
                    },
                    {
                        "title": "أضف المقبض",
                        "instruction": "قصّ 30 سم من السلك، وعلّق كل طرف في الطوق من جهتين متقابلتين واثنهما لتشكيل قوس.",
                    },
                    {
                        "title": "لفّ المقبض بالخيط",
                        "instruction": "اربط الخيط بطرف المقبض ولفّه بإحكام على طول القوس، ثم اعقده وضع نقطة غراء إن توفّر.",
                        "tip": "اجعل كل لفّة ملاصقة للتي قبلها لمظهر أنيق.",
                    },
                    {
                        "title": "أضف الرمل والشمعة",
                        "instruction": "اسكب 2 سم من الرمل أو الحصى داخل البرطمان وثبّت الشمعة في المنتصف.",
                        "warning": "استخدم شمعة LED داخل المنزل ولا تترك اللهب دون مراقبة.",
                    },
                ],
                strict=True,
            )
        ],
        "finishing": ["علّقه على خطاف يبعد 30 سم على الأقل عن أي شيء قابل للاشتعال"],
        "care": ["امسح السخام من الداخل بقطعة قماش مبللة", "استبدل الرمل إذا سال عليه الشمع"],
        "sources": [
            SourceRef(id="proj_glass_jar_lantern", title="مشروع فانوس البرطمان", kind="project"),
            SourceRef(id="safety_glass_handling", title="سلامة التعامل مع الزجاج", kind="safety"),
        ],
        "lang": "ar",
    }
)

# ----------------------------------------------------------------------------- images
image_after = ImageResponse(
    url=f"/static/generated/{JAR_IMG}/after_{lantern.id}.jpg",
    width=1184,
    height=880,
    kind="after",
    key=f"{JAR_IMG}:after:{lantern.id}",
    cached=False,
    timings_ms={"image_after": 9800},
)
image_step = ImageResponse(
    url=f"/static/generated/{JAR_IMG}/step_{tutorial_jar.tutorial_id}_1.jpg",
    width=1184,
    height=880,
    kind="step",
    key=f"{JAR_IMG}:step:{lantern.id}:beginner:1",
    cached=True,
    step=1,
    skill="beginner",
    timings_ms={"image_step": 0},
)

# ----------------------------------------------------------------------------- facilities
glass_cat = recommend_jar.facility_categories[0]
facilities = FacilitiesResponse(
    places=[
        Place(
            id="osm:node/1000000001",
            name="Fixture glass bank A",
            address="Fixture street 1",
            lat=24.4610,
            lng=54.3720,
            distance_m=950,
            open_now=None,
            facility_types=["collection_point"],
            category_keys=["glass"],
            accepted_materials=["glass", "paper", "plastic"],
            accepted_note="Glass, paper, plastic",
            maps_url="https://www.google.com/maps/search/?api=1&query=24.4610,54.3720",
            source="osm",
        ),
        Place(
            id="g:FIXTURE_PLACE_B",
            name="Fixture recycling centre B",
            address="Fixture road 2",
            lat=24.4402,
            lng=54.3995,
            distance_m=2700,
            open_now=True,
            phone="+971 2 000 0000",
            website="https://example.org",
            facility_types=["recycling_center"],
            category_keys=["glass", "metal"],
            maps_url="https://www.google.com/maps/search/?api=1&query=24.4402,54.3995",
            rating=4.3,
            source="google",
        ),
        Place(
            id="osm:way/1000000003",
            name="Fixture collection point C",
            lat=24.4789,
            lng=54.3551,
            distance_m=3400,
            facility_types=["collection_point"],
            category_keys=["glass"],
            accepted_materials=["glass"],
            maps_url="https://www.google.com/maps/search/?api=1&query=24.4789,54.3551",
            source="osm",
        ),
    ],
    center=LatLng(lat=24.4539, lng=54.3773),
    center_label="Abu Dhabi",
    sources_used=["google", "osm"],
    timings_ms={"google": 820, "osm": 1450, "total": 1480},
)
facility_categories = FacilityCategoriesResponse(
    categories=[
        FacilityCategory(
            key="glass",
            label="Glass recycling",
            facility_types=["recycling_center", "collection_point"],
            material_categories=["glass"],
        ),
        FacilityCategory(
            key="plastic",
            label="Plastic recycling",
            facility_types=["recycling_center", "collection_point"],
            material_categories=["plastic"],
        ),
        FacilityCategory(
            key="paper",
            label="Paper and cardboard",
            facility_types=["recycling_center", "collection_point"],
            material_categories=["paper"],
        ),
        FacilityCategory(
            key="metal",
            label="Metal recycling",
            facility_types=["recycling_center", "scrap_metal"],
            material_categories=["metal"],
        ),
        FacilityCategory(
            key="textile_donation",
            label="Clothes donation",
            facility_types=["donation", "collection_point"],
            material_categories=["textile"],
        ),
        FacilityCategory(
            key="wood",
            label="Wood collection",
            facility_types=["wood_collection", "recycling_center"],
            material_categories=["wood"],
        ),
        FacilityCategory(
            key="e_waste",
            label="E-waste",
            facility_types=["e_waste", "recycling_center"],
            material_categories=["electronics"],
        ),
        FacilityCategory(
            key="battery",
            label="Battery collection",
            facility_types=["hazardous_waste", "e_waste", "collection_point"],
            material_categories=["hazardous"],
        ),
        FacilityCategory(
            key="hazardous",
            label="Hazardous waste",
            facility_types=["hazardous_waste"],
            material_categories=["hazardous"],
        ),
        FacilityCategory(
            key="donation",
            label="Donation points",
            facility_types=["donation"],
            material_categories=["textile", "wood", "other"],
        ),
    ],
    lang="en",
)

# ----------------------------------------------------------------------------- swaps
swaps_request = SwapsRequest(
    materials=["plastic bags", "cling film"],
    history=HistorySummary(
        period_days=30, counts={"plastic": 6, "glass": 2}, top_items=["plastic bottle"], top_item_counts=[6]
    ),
    lang="en",
)
swaps = SwapsResponse(
    swaps=[
        Swap(
            id="swap_plastic_bag_tote",
            from_item="Single-use plastic bags",
            to_item="A folding cotton or canvas tote",
            why="One tote replaces hundreds of thin bags that tear quickly and end up as litter.",
            tip="Keep one folded in your car and one clipped to your keys so it is there when you shop.",
            effort="low",
            cost="low",
            category="plastic",
            matched_input="plastic bags",
            sources=[SourceRef(id="swap_plastic_bag_tote", title="Reusable shopping bags", kind="swap")],
        ),
        Swap(
            id="swap_cling_film_beeswax",
            from_item="Cling film",
            to_item="Beeswax wraps or a plate over the bowl",
            why="Wraps are washable and last about a year; a plate costs nothing.",
            tip="Warm the wrap in your hands so it grips the bowl's edge.",
            effort="low",
            cost="medium",
            category="plastic",
            matched_input="cling film",
            sources=[SourceRef(id="swap_cling_film_beeswax", title="Food wraps", kind="swap")],
        ),
        Swap(
            id="swap_bottled_water_filter",
            from_item="Bottled water",
            to_item="A filter jug and a steel bottle",
            why="You scanned mostly plastic bottles; refilling one bottle removes that stream.",
            tip="Fill the bottle the night before and keep it by your keys.",
            effort="low",
            cost="medium",
            category="plastic",
            from_history=True,
            sources=[SourceRef(id="swap_bottled_water_filter", title="Refillable water", kind="swap")],
        ),
    ],
    history_insight="You scanned 6 plastic bottles this month.",
    lang="en",
    timings_ms={"retrieval": 350, "swap_advisor": 4200, "total": 4600},
)

health = HealthResponse(
    status="ok",
    app_name="Kanz",
    version="1.0.0",
    models={
        "vision": "gemini-3.6-flash",
        "text": "gemini-3.6-flash",
        "image": "gemini-3.1-flash-image",
        "embed": "gemini-embedding-001",
    },
    ai_configured=True,
    knowledge_docs=96,
    rag_ready=True,
    places_google=True,
    places_osm=True,
    uptime_s=42,
)
error = ErrorResponse(
    error=ErrorBody(
        code="ai_unavailable",
        message="The AI service is busy right now. Please try again in a moment.",
        retryable=True,
        request_id="req_5f3c2a1b",
    )
)

FIXTURES = {
    "health": health,
    "error_ai_unavailable": error,
    "analyze_glass_jar": analyze_jar,
    "analyze_glass_jar_ar": analyze_jar_ar,
    "analyze_battery": analyze_battery,
    "analyze_tshirt": analyze_tshirt,
    "analyze_unclear": analyze_unclear,
    "analyze_text_caps": analyze_text,
    "recommend_request_glass_jar": recommend_request,
    "recommend_glass_jar": recommend_jar,
    "recommend_glass_jar_ar": recommend_jar_ar,
    "recommend_battery": recommend_battery,
    "recommend_tshirt": recommend_tshirt,
    "tutorial_request_jar_lantern": tutorial_request,
    "tutorial_jar_lantern": TutorialResponse(
        tutorial=tutorial_jar, timings_ms={"retrieval": 300, "tutorial_writer": 8200, "total": 8550}
    ),
    "tutorial_jar_lantern_ar": TutorialResponse(
        tutorial=tutorial_jar_ar, timings_ms={"retrieval": 300, "tutorial_writer": 8900, "total": 9250}
    ),
    "image_after": image_after,
    "image_step": image_step,
    "facilities_glass": facilities,
    "facility_categories": facility_categories,
    "swaps_request": swaps_request,
    "swaps_plastic": swaps,
}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    assert glass_cat.key == "glass"
    for name, model in FIXTURES.items():
        data = model.model_dump(mode="json")
        (OUT / f"{name}.json").write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {len(FIXTURES)} fixtures to {OUT}")


if __name__ == "__main__":
    main()
