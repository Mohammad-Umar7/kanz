"""Bilingual keyword matching: spans, Arabic folding and the scope of a negation."""

import pytest

from app.ai.textmatch import Sentence, Terms, has_arabic, live, normalize_ar, sentences

HEAT = Terms(en=(r"melt\w*", r"heat\w*", r"burn\w*"), ar=("صهر", "سخن", "حرق"))


def words(text: str) -> list[str]:
    return [span.word for span in live(HEAT, Sentence(text))]


def test_arabic_is_folded_and_matched_through_clitics():
    assert normalize_ar("أَإِآ ة ى") == "ااا ه ي"
    assert Terms(ar=("بلاستيك",)).found(Sentence("القوارير البلاستيكية"))
    assert not Terms(ar=("=اكل",)).found(Sentence("إكليل"))
    assert has_arabic("جرة") and not has_arabic("jar")


def test_sentences_split_on_english_and_arabic_punctuation():
    assert [s.raw for s in sentences(["One. Two؟ ثلاثة؛ Four\nFive"])] == ["One.", "Two؟", "ثلاثة؛", "Four", "Five"]


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        ("Never heat, melt or burn it.", []),
        ("Melt it in the oven, no glue needed.", ["melt"]),
        ("No glue needed: melt it in the oven.", ["melt"]),
        ("Without glue, melt the edges.", ["melt"]),
        ("Use glue instead of melting it.", []),
        ("Keep it away from heat.", []),
        ("It gives off toxic fumes when heated.", []),
        ("Melt it outdoors to avoid toxic fumes.", ["melt"]),
        ("لا تسخّن الغطاء ولا تحرقه.", []),
        ("لا حاجة للغراء: قم بصهر الأطراف.", ["بصهر"]),
    ],
)
def test_only_instructions_are_live(text, expected):
    assert words(text) == expected


def test_a_list_keeps_the_negation_that_opened_it():
    food = Terms(en=(r"food", r"drink", r"pets?"))
    text = "Never reuse a jar that held chemicals, paint, solvents or oil for food, drink or pets."
    assert live(food, Sentence(text)) == []
    assert [s.word for s in live(food, Sentence("Do not rinse it, use it for food."))] == ["food"]
