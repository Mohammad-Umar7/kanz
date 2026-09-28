"""Image Director: every prompt carries the style suffix, identity rules and the right reference notes."""

import pytest

from app.config import get_settings
from app.images.director import SOURCE_LANGUAGE_NOTE, STYLE_SUFFIX, ImageDirector, ImagePrompt, clean
from app.schemas.analysis import Item
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial
from tests.images.fakes import load_fixture, make_tutorial

IDENTITY_WORDS = ["shape", "color", "material", "dents", "camera angle", "lighting"]


@pytest.fixture
def director() -> ImageDirector:
    return ImageDirector(get_settings().prompts_dir)


@pytest.fixture
def lantern(idea: UpcycleIdea) -> Tutorial:
    return make_tutorial("img_0123456789abcdef", idea)


@pytest.fixture
def arabic_item() -> Item:
    return Item.model_validate(load_fixture("analyze_glass_jar_ar")["analysis"]["items"][0])


def all_prompts(director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial, jar_item: Item) -> list[ImagePrompt]:
    return [
        director.after(idea),
        *(director.step(lantern, n, idea=idea, with_after=True) for n in range(1, 6)),
        director.step(lantern, 5, idea=None, with_after=False),
        director.bin(jar_item, jar_item.recyclability.prep_steps),
        director.bin(jar_item, []),
        director.reference("a pile of old denim jeans"),
    ]


def test_style_suffix_covers_the_house_style() -> None:
    for phrase in [
        "realistic smartphone photo",
        "natural light",
        "camera angle",
        "framing",
        "4:3",
        "no text, captions",
        "watermarks or logos",
        "No people's faces",
        "hands appear only when they show the technique",
    ]:
        assert phrase in STYLE_SUFFIX


def test_every_prompt_ends_with_the_style_suffix_and_has_no_holes(
    director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial, jar_item: Item
) -> None:
    for prompt in all_prompts(director, idea, lantern, jar_item):
        assert prompt.text.endswith(STYLE_SUFFIX)
        assert "{{" not in prompt.text and "}}" not in prompt.text
        assert "<!--" not in prompt.text
        assert ".." not in prompt.text
        assert prompt.template.split("@v")[0].startswith("image_")


def test_edit_prompts_insist_on_preserving_identity(
    director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial, jar_item: Item
) -> None:
    edits = [
        director.after(idea),
        director.step(lantern, 1, idea=idea, with_after=False),
        director.step(lantern, 3, idea=idea, with_after=False),
        director.bin(jar_item, ["Rinse"]),
    ]
    for prompt in edits:
        body = prompt.text.removesuffix(STYLE_SUFFIX)
        for word in IDENTITY_WORDS:
            assert word in body, f"{prompt.template} lacks '{word}'"
    assert "label remnants" in edits[0].text and "label remnants" in edits[1].text
    assert "Change only what the project changes" in edits[0].text


def test_after_prompt_uses_the_english_after_visual(director: ImageDirector, idea: UpcycleIdea) -> None:
    prompt = director.after(idea)
    assert clean(idea.after_visual) in prompt.text
    assert prompt.template == "image_after@v2"
    assert "before and after pictures line up" in prompt.text


def test_projects_that_reshape_the_item_are_not_told_to_keep_its_shape(
    director: ImageDirector, lantern: Tutorial
) -> None:
    # A t-shirt tote bag cuts the sleeves away: "keep the exact shape" would fight the idea,
    # and restoring the original's shape mid-chain would grow the sleeves back.
    tote = UpcycleIdea.model_validate(load_fixture("recommend_tshirt")["upcycle"][0])
    after = director.after(tote).text
    assert "exact shape" not in after
    assert "wherever the project does not cut, fold or reshape it" in after
    assert "every piece is visibly made from this item" in after

    chain = director.step(lantern, 3, idea=None, with_after=False)
    assert chain.template == "image_step@v2"
    assert "exact shape" not in chain.text
    assert "keep every change the earlier steps made" in chain.text
    assert "except where this step or an earlier one cuts, reshapes" in chain.text


def test_first_step_edits_the_original_only(director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial) -> None:
    text = director.step(lantern, 1, idea=idea, with_after=False).text
    assert "step 1 of 5" in text
    assert "Image 1 is the owner's original photo" in text
    assert "Image 2" not in text
    assert lantern.steps[0].image_prompt in text
    # Every later step is named as "not yet", so the model does not jump ahead.
    for later in lantern.steps[1:]:
        assert later.image_prompt in text


def test_middle_step_chains_from_the_previous_picture(
    director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial
) -> None:
    text = director.step(lantern, 3, idea=idea, with_after=True).text
    assert "Image 1 is the photo taken after step 2" in text
    assert lantern.steps[1].image_prompt in text  # what image 1 shows
    assert "Image 2 is the owner's original photo" in text
    assert "Image 3" not in text  # the after image is only for the final step
    upcoming = text.split("have not happened yet")[1]
    assert lantern.steps[3].image_prompt in upcoming and lantern.steps[4].image_prompt in upcoming
    assert lantern.steps[0].image_prompt not in upcoming


def test_final_step_references_the_after_image(director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial) -> None:
    with_after = director.step(lantern, 5, idea=idea, with_after=True).text
    assert "Image 3 shows the finished project" in with_after
    assert "final step" in with_after
    assert "have not happened yet" not in with_after

    without = director.step(lantern, 5, idea=idea, with_after=False).text
    assert "Image 3" not in without
    assert "final step" in without


def test_step_goal_falls_back_to_the_final_step_description(director: ImageDirector, lantern: Tutorial) -> None:
    text = director.step(lantern, 2, idea=None, with_after=False).text
    goal = text.split("the finished project will be: ")[1].split(". This picture")[0]
    assert goal == clean(lantern.steps[-1].image_prompt)


def test_step_out_of_range_is_a_bug(director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial) -> None:
    with pytest.raises(ValueError, match="outside"):
        director.step(lantern, 6, idea=idea, with_after=False)


def test_bin_prompt_lists_the_prep_steps(director: ImageDirector, jar_item: Item) -> None:
    text = director.bin(jar_item, jar_item.recyclability.prep_steps).text
    for step in jar_item.recyclability.prep_steps:
        assert f"- {step}" in text
    assert "Glass bottle bank" in text
    assert "empty, label on, lid on, intact" in text
    assert "No special preparation" not in text

    plain = director.bin(jar_item, []).text
    assert "No special preparation" in plain


def test_arabic_details_come_with_a_do_not_write_note(
    director: ImageDirector, jar_item: Item, arabic_item: Item
) -> None:
    arabic = director.bin(arabic_item, arabic_item.recyclability.prep_steps).text
    assert SOURCE_LANGUAGE_NOTE in arabic
    assert SOURCE_LANGUAGE_NOTE not in director.bin(jar_item, ["Rinse"]).text


def test_reference_prompt_quotes_a_bounded_description(director: ImageDirector) -> None:
    text = director.reference('my "old" jeans\n\n  pile').text
    assert "The owner's description: \"my 'old' jeans pile\"" in text
    long = director.reference("denim " * 500).text
    assert len(long) < 2500


def test_blank_model_fields_fall_back_to_titles(director: ImageDirector, idea: UpcycleIdea, lantern: Tutorial) -> None:
    blank_idea = idea.model_copy(update={"after_visual": "  "})
    assert f"{idea.title}. {idea.pitch}" in director.after(blank_idea).text

    steps = [s.model_copy(update={"image_prompt": ""}) if s.number == 2 else s for s in lantern.steps]
    text = director.step(lantern.model_copy(update={"steps": steps}), 2, idea=idea, with_after=False).text
    assert f"{steps[1].title}. {steps[1].instruction}" in text
