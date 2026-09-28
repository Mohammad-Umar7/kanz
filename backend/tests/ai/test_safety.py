"""Hazard normalisation, the Safety Router and the multilingual output validators."""

import pytest

from app.ai import safety
from app.ai.convert import to_item
from app.ai.llm_schemas import LlmItem

from .conftest import fixture_analysis, llm_item


def item(**overrides):
    return to_item(LlmItem.model_validate(llm_item(**overrides)), 0, "en")


# ---------------------------------------------------------------- normalisation
class TestNormalisation:
    def test_electronics_always_carry_e_waste(self):
        phone = safety.normalise_item(
            item(name="Old smartphone", category="electronics", material="Glass and metal"), "en"
        )
        assert "e_waste" in phone.hazards

    def test_batteries_are_flagged_and_promoted_to_hazardous(self):
        cells = safety.normalise_item(item(name="AA batteries", category="other", material="Alkaline cells"), "en")
        assert cells.hazards == ["battery"] and cells.category == "hazardous"

    def test_bulb_filed_as_electronics_becomes_hazardous_but_phones_stay_electronics(self):
        bulb = safety.normalise_item(
            item(name="Incandescent light bulb", category="electronics", material="Glass"), "en"
        )
        assert bulb.category == "hazardous" and {"light_bulb", "e_waste"} <= set(bulb.hazards)
        phone = safety.normalise_item(item(name="Phone with battery", category="electronics", material="Mixed"), "en")
        assert phone.category == "electronics"

    @pytest.mark.parametrize(
        ("name", "category"),
        [
            ("Old smartphone", "plastic"),
            ("Phone charger", "plastic"),
            ("Wireless earbuds", "other"),
            ("TV remote control", "plastic"),
            ("هاتف قديم", "metal"),
        ],
    )
    def test_devices_filed_under_their_casing_are_e_waste(self, name, category):
        device = safety.normalise_item(item(name=name, category=category, material="x"), "en")
        assert "e_waste" in device.hazards and device.category == "electronics"

    @pytest.mark.parametrize("name", ["Phone case", "Laptop sleeve", "جراب هاتف"])
    def test_device_accessories_are_not_devices(self, name):
        accessory = safety.normalise_item(item(name=name, category="plastic", material="x"), "en")
        assert accessory.hazards == [] and accessory.category == "plastic"

    def test_a_phone_corrected_to_plastic_still_gets_no_diy(self):
        phone = item(name="Old smartphone", category="plastic", hazards=[], state=["intact"])
        assert safety.route(safety.normalise_items([phone], "en"), "en").mode == "disposal_only"

    def test_arabic_battery_name_is_recognised(self):
        cells = safety.normalise_item(item(name="بطاريات قديمة", category="other", material="خلايا قلوية"), "ar")
        assert "battery" in cells.hazards

    def test_broken_glass_state_adds_broken_glass(self):
        jar = safety.normalise_item(item(state=["broken"]), "en")
        assert "broken_glass" in jar.hazards

    def test_chemical_container_with_residue_is_chemical(self):
        bottle = safety.normalise_item(
            item(name="Bleach bottle", category="plastic", material="HDPE #2", state=["contains_residue"]), "en"
        )
        assert "chemical" in bottle.hazards and bottle.category == "plastic"

    @pytest.mark.parametrize(
        ("name", "category", "state"),
        [
            ("Coffee capsules", "metal", ["empty"]),
            ("Maple syrup bottle", "glass", ["empty"]),
            ("Laundry detergent bottle", "plastic", ["contains_residue"]),
            ("زجاجة بخاخ بلاستيكية", "plastic", ["empty"]),
        ],
    )
    def test_everyday_items_are_not_mistaken_for_hazards(self, name, category, state):
        assert safety.normalise_item(item(name=name, category=category, material="x", state=state), "en").hazards == []

    def test_rinsed_detergent_bottle_is_not_flagged(self):
        bottle = safety.normalise_item(
            item(name="Detergent bottle", category="plastic", material="HDPE #2", state=["empty", "clean"]), "en"
        )
        assert bottle.hazards == []

    def test_aerosol_can_is_flagged(self):
        can = safety.normalise_item(item(name="Deodorant spray can", category="metal", material="Aluminium"), "en")
        assert "aerosol" in can.hazards and can.category == "hazardous"

    def test_unexplained_hazardous_item_is_treated_as_chemical(self):
        thing = safety.normalise_item(item(name="Unknown liquid", category="hazardous", material="Unknown"), "en")
        assert thing.hazards == ["chemical"]

    def test_disposal_only_items_are_never_plain_recyclable(self):
        cells = safety.normalise_item(
            item(name="Lithium battery", category="hazardous", recyclability_status="yes"), "en"
        )
        assert cells.recyclability.status == "conditional"
        assert cells.recyclability.reason

    def test_safe_items_are_returned_unchanged(self):
        jar = item()
        assert safety.normalise_item(jar, "en") is jar


# ---------------------------------------------------------------------- routing
class TestRouting:
    def test_battery_alone_is_disposal_only(self):
        battery = fixture_analysis("analyze_battery.json").items[0]
        routing = safety.route([battery], "en")
        assert routing.mode == "disposal_only"
        assert routing.hazardous_item_ids == [battery.id]
        assert "Batteries" in routing.reason

    def test_jar_and_battery_is_mixed(self):
        jar = fixture_analysis("analyze_glass_jar.json").items[0]
        battery = fixture_analysis("analyze_battery.json").items[0].model_copy(update={"id": "item_2"})
        routing = safety.route([jar, battery], "ar")
        assert routing.mode == "mixed"
        assert routing.hazardous_item_ids == ["item_2"]
        assert battery.name in routing.reason

    def test_no_hazards_is_diy(self):
        routing = safety.route(fixture_analysis("analyze_glass_jar.json").items, "en")
        assert routing.mode == "diy" and routing.reason is None

    def test_sharp_edges_alone_do_not_block_diy(self):
        can = item(name="Opened tin can", category="metal", hazards=["sharp_edges"])
        assert safety.route([can], "en").mode == "diy"

    def test_devices_are_disposed_of_as_e_waste(self):
        phone = item(name="Phone", category="electronics", hazards=["e_waste", "battery"])
        assert safety.primary_hazard(phone) == "e_waste"


# ------------------------------------------------------------------- validators
class TestPlasticHeat:
    @pytest.mark.parametrize(
        "text",
        [
            "Melt the bottle caps in the oven to make a coaster.",
            "Use a heat gun to soften the PET bottle.",
            "Iron the plastic bags between baking paper to fuse them.",
            "Put a tea light inside the plastic bottle.",
            "قم بصهر أغطية البلاستيك في الفرن.",
            "سخّن القارورة البلاستيكية بمسدس حراري.",
            "Use a hair dryer to soften the PET bottle so it bends.",
        ],
    )
    def test_heating_plastic_is_rejected(self, text):
        assert safety.check_plastic_heat([text])

    @pytest.mark.parametrize(
        "text",
        [
            # A negation later in the sentence does not excuse the instruction before it.
            "Melt the plastic caps in the oven, no glue needed.",
            "Use a lighter to seal the edges of the plastic bag strips so they do not fray.",
            "Seal the plastic bag edges with a lighter, no sewing needed.",
            # A new clause starts a new instruction.
            "Don't use glue: melt the plastic edges together with a heat gun.",
            "Instead of gluing, fuse the plastic bags with an iron.",
            "لا حاجة للغراء: قم بصهر أطراف البلاستيك بالولاعة.",
            # Explaining the risk does not make an instruction safe.
            "Melt the plastic in a ventilated room to avoid toxic fumes.",
        ],
    )
    def test_negation_only_covers_the_words_after_it(self, text):
        assert safety.check_plastic_heat([text])

    @pytest.mark.parametrize(
        "text",
        [
            "Never melt or burn plastic.",
            "Never heat, melt or burn plastic.",
            "Do not use a lighter, candle or heat gun on the plastic.",
            "Put an LED tea light inside the plastic bottle.",
            "Use an LED tea light, never a real candle, inside the plastic bottle.",
            "Glue the plastic caps with a hot glue gun.",
            "Use glue instead of melting the plastic.",
            "Keep the plastic lantern away from heat.",
            "Plastic gives off toxic fumes when heated, so cut it instead.",
            "Heated plastic releases toxic fumes.",
            "لا تقم أبدًا بصهر البلاستيك.",
            "لا تسخّن البلاستيك ولا تحرقه.",
            "Put a candle in the glass jar.",
            "Iron the fabric for the pet bed.",
        ],
    )
    def test_safe_negated_or_warning_text_passes(self, text):
        assert safety.check_plastic_heat([text]) == []

    def test_scanned_plastic_items_count_even_when_the_word_plastic_is_missing(self):
        caps = item(name="Plastic bottle caps", category="plastic", material="HDPE")
        assert safety.check_plastic_heat(["Melt the caps in the oven."], items=[caps])
        assert safety.check_plastic_heat(["Heat them until they soften."], items=[caps])  # every item is plastic
        assert safety.check_plastic_heat(["Melt the caps in the oven."], items=[item()]) == []  # a glass jar

    def test_mixed_scans_only_flag_heat_on_the_plastic_item(self):
        jar, lid = item(), item(name="Plastic lid", category="plastic", material="PP #5")
        assert safety.check_plastic_heat(["Put a candle in the jar."], items=[jar, lid]) == []
        assert safety.check_plastic_heat(["Soften the lid with a heat gun."], items=[jar, lid])


class TestOpenFlame:
    def test_candle_in_a_cardboard_lantern_is_rejected(self):
        assert safety.check_open_flame(["Put a tea light inside the cardboard lantern."])

    def test_led_light_or_negated_flame_passes(self):
        assert safety.check_open_flame(["Put an LED tea light inside the cardboard lantern."]) == []
        assert safety.check_open_flame(["Never use a real candle in a paper lantern."]) == []

    def test_paper_scans_need_no_explicit_word(self):
        box = item(name="Cardboard box", category="paper", material="Corrugated cardboard")
        assert safety.check_open_flame(["Place a candle inside it."], items=[box])


class TestChemicalFood:
    @pytest.mark.parametrize(
        "text",
        [
            "Rinse the old bleach bottle and use it to store rice.",
            "Use the pesticide container as a water bowl for your cat.",
            "Turn the motor oil can into a planter for herbs.",
            "استخدم عبوة المبيد القديمة لتخزين الأرز.",
        ],
    )
    def test_chemical_container_for_food_or_pets_is_rejected(self, text):
        assert safety.check_chemical_food([text])

    def test_item_that_held_chemicals_blocks_any_food_use(self):
        assert safety.check_chemical_food(["Turn it into a planter for herbs."], item_names=["Empty bleach bottle"])

    def test_paint_tins_count_as_chemical_containers(self):
        assert safety.check_chemical_food(["Use the old paint tin as a planter for tomatoes."])

    @pytest.mark.parametrize(
        "text",
        [
            "Wash the jar with warm water, then plant basil.",
            "Never reuse a bleach bottle for food.",
            "Use the detergent bottle as a pen holder.",
            "Keep the bleach bottle away from food and pets.",
            "Store the pesticide container away from food, drink and pets until drop-off.",
            "Store the chemical container out of reach of children and pets.",
        ],
    )
    def test_ordinary_food_reuse_and_storage_advice_pass(self, text):
        assert safety.check_chemical_food([text]) == []


class TestPaintedFoodContact:
    def test_painted_bowl_for_snacks_is_rejected(self):
        assert safety.check_painted_food_contact(["Paint the bowl in bright colors.", "Use it to serve snacks."])

    def test_saying_paint_is_not_food_safe_is_not_a_food_safe_finish(self):
        texts = ["Acrylic paint is not food-safe.", "Paint the bowl and use it to serve fruit."]
        assert safety.check_painted_food_contact(texts)

    def test_arabic_painted_plate_is_rejected(self):
        assert safety.check_painted_food_contact(["ادهن الصحن بألوان زاهية.", "استخدمه لتقديم الحلويات."])

    @pytest.mark.parametrize(
        "texts",
        [
            ["Paint the outside of the bowl only.", "Use it to serve snacks."],
            ["Seal it with a food-safe finish.", "Paint the tray and use it for serving bread."],
            ["Paint the lids.", "Use them as coasters for your drinks."],
            ["أضف طبقة طلاء ثانية.", "ضع فيه الأقلام."],
        ],
    )
    def test_outside_only_food_safe_or_non_food_passes(self, texts):
        assert safety.check_painted_food_contact(texts) == []


class TestProtectiveGear:
    def test_cutting_with_a_craft_knife_needs_gloves(self):
        problems = safety.check_protective_gear(["Cut the carton with a craft knife."], [], ["Work slowly."])
        assert problems and "gloves" in problems[0]

    def test_gloves_mentioned_passes(self):
        assert safety.check_protective_gear(["Cut the carton with a craft knife."], [], ["Wear work gloves."]) == []

    def test_arabic_gear_is_recognised(self):
        assert safety.check_protective_gear(["قص الكرتون بالمشرط."], [], ["ارتدِ قفازات العمل."]) == []
        assert safety.check_protective_gear(["قص الكرتون بالمشرط."], [], ["اعمل ببطء."])

    def test_tools_imply_techniques(self):
        missing = safety.missing_gear([], ["sandpaper", "spray_paint"], [])
        assert missing == {"sanding": ["dust_mask"], "spray_painting": ["dust_mask", "ventilation"]}

    def test_negated_technique_needs_no_gear(self):
        assert safety.detect_techniques(["No drill needed: use a hammer and a nail."]) == set()

    def test_a_later_negation_does_not_hide_a_technique(self):
        assert "blade_cutting" in safety.detect_techniques(["Cut the bottle with a craft knife, no glue needed."])

    def test_glass_and_metal_work_need_an_action_on_the_material(self):
        assert "glass_work" in safety.detect_techniques(["Score the glass bottle with a glass cutter."])
        assert "glass_work" not in safety.detect_techniques(["Cut a length of twine to wrap the jar."])
        assert "glass_work" not in safety.detect_techniques(["اقطع الزجاجة البلاستيكية من المنتصف."])
        assert "sharp_metal" in safety.detect_techniques(["Punch holes in the tin can with a hammer and nail."])

    def test_painting_can_be_excluded_for_idea_cards(self):
        assert safety.detect_techniques(["the same jar painted white"], include_painting=False) == set()

    def test_gear_lines_are_localized(self):
        lines = safety.gear_lines({"drilling": ["safety_glasses"]}, "ar")
        assert lines and "نظارات" in lines[0]

    def test_gear_rules_text_lists_every_technique(self):
        text = safety.gear_rules_text()
        assert all(label in text for label in safety.TECHNIQUE_LABELS.values())


class TestToolsAndLanguage:
    def test_missing_tool_used_in_a_step_is_reported(self):
        problems = safety.check_missing_tools_used(
            [(2, "Drill a hole in the lid."), (3, "Instead of a drill, use a hammer and nail.")], ["drill"]
        )
        assert len(problems) == 1 and problems[0].startswith("Step 2")

    def test_alternatives_must_exist_and_not_need_other_missing_tools(self):
        problems = safety.check_alternatives(
            {"drill": "Use the hot glue gun instead", "hot_glue_gun": None}, ["drill", "hot_glue_gun"]
        )
        assert len(problems) == 2

    def test_image_prompts_must_be_english(self):
        assert safety.check_english("the same jar", field="x") == []
        assert safety.check_english("نفس البرطمان", field="x")

    def test_hazardous_items_may_not_be_used(self):
        assert safety.check_no_hazardous_diy(["item_1", "item_2"], ["item_2"])
        assert safety.check_no_hazardous_diy(["item_1"], ["item_2"]) == []


class TestTwoTierValidator:
    def test_soft_rules_count_until_the_repair_round(self):
        validator = safety.TwoTierValidator(hard=lambda _: [], soft=lambda _: ["add gloves"])
        assert validator(object()) == ["add gloves"]
        validator.begin_repair()
        assert validator(object()) == []

    def test_hard_rules_count_every_time(self):
        validator = safety.TwoTierValidator(hard=lambda _: ["unsafe"], soft=lambda _: ["style"])
        assert validator(object()) == ["unsafe", "style"]
        validator.begin_repair()
        assert validator(object()) == ["unsafe"]
