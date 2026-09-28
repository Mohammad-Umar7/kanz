"""Bilingual keyword matching for the safety rules: where a word occurs and whether it is negated.

The safety validators (``app.ai.safety``) must tell advice from instructions in English and
Arabic model output without a model call. This module provides the pieces:

* ``normalize_ar`` folds Arabic spelling variants (diacritics, hamza and alef forms, taa
  marbuta); tokens are matched with and without common clitic prefixes (و، ف، ب، ل، ال...).
* ``Terms`` is a keyword set: English regex fragments plus Arabic stems or phrases. It can
  say whether a sentence contains a term and where (``spans``).
* ``live`` keeps only the occurrences that are instructions. An occurrence is governed
  (advice, not an instruction) when a negation comes *before* it in the same clause:
  "Never heat, melt or burn plastic" is advice, while "Melt the caps in the oven, no glue
  needed" is an instruction even though the sentence contains "no". Clauses that explain a
  risk ("plastic gives off toxic fumes when heated") are warnings, not instructions.
"""

from __future__ import annotations

import re
from collections.abc import Iterable, Sequence
from typing import NamedTuple

_AR_MARKS = re.compile(r"[ً-ْٰـ]")
_AR_FOLD = str.maketrans({"أ": "ا", "إ": "ا", "آ": "ا", "ى": "ي", "ة": "ه", "ؤ": "و", "ئ": "ي"})
AR_WORD = re.compile(r"[ء-ي]+")
_AR_LAST_WORD = re.compile(r"([ء-ي]+)\W*$")
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
        for tok in AR_WORD.findall(self.ar):
            self.ar_tokens |= _ar_variants(tok)


class Span(NamedTuple):
    """Where a keyword occurs: ``text`` is the lowered English or the folded Arabic sentence."""

    text: str
    start: int
    end: int

    @property
    def word(self) -> str:
        return self.text[self.start : self.end]


class Terms:
    """A keyword set: English regex fragments (word-bounded) plus Arabic stems or phrases.

    Arabic single words match as prefixes of clitic-stripped tokens ("بلاستيك" matches
    "البلاستيكية"); a leading "=" demands the whole token ("=اكل" must not match "اكليل");
    Arabic entries containing a space match as phrases in the folded text.
    """

    def __init__(self, en: Sequence[str] = (), ar: Sequence[str] = ()) -> None:
        body = "|".join(en)
        self._en = re.compile(r"\b(?:" + body + r")\b") if en else None
        self._en_tail = re.compile(r"\b(?:" + body + r")\W*$") if en else None
        folded = [normalize_ar(a) for a in ar]
        self._ar_exact = frozenset(a[1:] for a in folded if a.startswith("="))
        self._ar_stems = tuple(a for a in folded if " " not in a and not a.startswith("="))
        self._ar_phrases = tuple(a for a in folded if " " in a)

    def _ar_hit(self, variants: set[str]) -> bool:
        return bool(self._ar_exact & variants) or any(v.startswith(s) for s in self._ar_stems for v in variants)

    def found(self, s: Sentence) -> bool:
        if self._en and self._en.search(s.en):
            return True
        if any(p in s.ar for p in self._ar_phrases):
            return True
        return self._ar_hit(s.ar_tokens)

    def spans(self, s: Sentence) -> list[Span]:
        """Every occurrence, so each one can be judged in its own clause."""
        out: list[Span] = []
        if self._en:
            out += [Span(s.en, m.start(), m.end()) for m in self._en.finditer(s.en)]
        for phrase in self._ar_phrases:
            start = s.ar.find(phrase)
            while start != -1:
                out.append(Span(s.ar, start, start + len(phrase)))
                start = s.ar.find(phrase, start + 1)
        if self._ar_exact or self._ar_stems:
            out += [Span(s.ar, m.start(), m.end()) for m in AR_WORD.finditer(s.ar) if self._ar_hit(_ar_variants(m[0]))]
        return out

    def matches(self, word: str) -> bool:
        """True when ``word`` (one matched span) is itself one of these terms."""
        if self._en and self._en.fullmatch(word):
            return True
        return word in self._ar_phrases or self._ar_hit(_ar_variants(word))

    def ends_with(self, text: str) -> bool:
        """True when ``text`` ends with one of the terms (a negation reaches along such a list)."""
        text = normalize_ar(text.strip())
        if self._en_tail and self._en_tail.search(text):
            return True
        if any(text.endswith(p) for p in self._ar_phrases):
            return True
        last = _AR_LAST_WORD.search(text)
        return bool(last) and self._ar_hit(_ar_variants(last[1]))


_SENTENCE_SPLIT = re.compile(r"(?<=[.!?؟؛;])\s+|\n+")

# ------------------------------------------------------------------- negation scope
# A negation governs the keywords after it, up to the end of its clause. Clauses end at
# these marks and contrast words ("Don't glue it: melt it" starts a new instruction).
_CLAUSE_END = re.compile(
    r"[;:()؛]|\s[-–—]\s"
    r"|\b(?:but|instead(?! of)|then|so|until|unless|while|because|although|whereas|لكن|ولكن|بل|ثم)\b"
)
_COMMA = re.compile(r"[,،]")
_LIST_JOIN = re.compile(r"\b(?:or|and|nor)\b|(?:^|\s)(?:او|ولا)(?:\s|$)")
_NEGATION_EN = re.compile(
    r"\b(?:never|not|no|nor|don['’]?t|do not|doesn['’]?t|does not|avoid\w*|mustn['’]?t|must not"
    r"|shouldn['’]?t|should not|can['’]?t|cannot|won['’]?t|without|instead of|rather than"
    r"|away from|out of reach of|clear of)\b"
)
# "without X, ..." and "instead of X, ..." only cover X: a comma ends their scope.
_SHORT_SCOPE_EN = frozenset({"without", "instead of", "rather than"})
_NEGATION_AR = frozenset({"لا", "ولا", "فلا", "لن", "ابدا", "اياك", "ممنوع", "عدم", "ليس"})
_NEGATION_AR_STEMS = ("تجنب", "يمنع", "احذر")
_SHORT_SCOPE_AR = frozenset({"بدون", "دون", "بلا", "بدلا", "بدل"})
_AWAY_AR = ("بعيدا عن", "بعيد عن", "بعيدا من")
# Clauses that explain a risk are warnings, not instructions: "plastic gives off toxic
# fumes when heated", "a real candle is a fire hazard in a paper lantern".
_WARNING = Terms(
    en=(
        r"toxic",
        r"poisonous",
        r"fumes",
        r"flammable",
        r"catch(?:es)? fire",
        r"on fire",
        r"starts? a fire",
        r"harmful",
        r"dangerous",
        r"unsafe",
        r"hazard\w*",
        r"carcinogen\w*",
    ),
    ar=("سام", "ابخره", "دخان", "اشتعال", "حريق", "خطر", "ضار", "مسرطن"),
)
# "non-toxic paint" and "غير سام" describe a product, not a risk.
_NOT_A_WARNING = re.compile(r"\bnon[- ]?\w+|\b\w+-free\b|(?:^|\s)غير\s+\S+")
_CONDITIONAL = re.compile(
    r"\b(?:when|if|once|as)\s+(?:it\s+|they\s+)?(?:is\s+|are\s+|gets?\s+)?$|(?:^|\s)(?:عند|اذا|لو|حين)\s*$"
)
_IMPERATIVE_LEAD_EN = frozenset({"carefully", "gently", "slowly", "now", "first", "next", "finally", "and", "just"})
_IMPERATIVE_OBJECT_EN = frozenset(
    {"the", "a", "an", "it", "them", "your", "each", "all", "both", "this", "these", "those", "some", "down"}
    | {"over", "with", "until", "for", "in", "on", "together", "into", "off", "up"}
)
_IMPERATIVE_LEAD_AR = frozenset({"قم", "ثم", "و"})


def _last_negation(clause: str) -> tuple[int, bool] | None:
    """(end offset, short scope?) of the last negation in ``clause``, or None."""
    found: list[tuple[int, int, bool]] = [
        (m.start(), m.end(), m[0] in _SHORT_SCOPE_EN) for m in _NEGATION_EN.finditer(clause)
    ]
    for phrase in _AWAY_AR:
        at = clause.rfind(phrase)
        if at != -1:
            found.append((at, at + len(phrase), False))
    for m in AR_WORD.finditer(clause):
        if m[0] in _SHORT_SCOPE_AR:
            found.append((m.start(), m.end(), True))
            continue
        variants = _ar_variants(m[0])
        if variants & _NEGATION_AR or any(v.startswith(s) for s in _NEGATION_AR_STEMS for v in variants):
            found.append((m.start(), m.end(), False))
    if not found:
        return None
    _, end, short = max(found)
    return end, short


def negated(span: Span, terms: Terms | None = None) -> bool:
    """A negation earlier in the clause governs ``span``."""
    return _governed(normalize_ar(span.text[: span.start]), terms)


def _governed(prefix: str, terms: Terms | None) -> bool:
    """Does a negation in the clause ending ``prefix`` still apply where ``prefix`` ends?

    A comma ends a short-scope negation ("without glue, melt ...") and, in general, starts a
    new instruction ("Do not throw it away, melt it"). A negation carries on through a list:
    a term right after "<term>," inherits that term's negation ("Never heat, melt or burn"),
    and so does anything inside an enumeration such as "chemicals, pesticides, solvents or
    motor oil for food".
    """
    clause = _CLAUSE_END.split(prefix)[-1]
    negation = _last_negation(clause)
    if negation is None:
        return False
    end, short = negation
    parts = _COMMA.split(clause[end:])
    if len(parts) == 1:
        return True
    if short:
        return False
    if len(parts) >= 3 and all(len(p.split()) <= 3 for p in parts[1:-1]) and _LIST_JOIN.search(parts[-1]):
        return True
    if terms is not None and terms.ends_with(parts[-2]):
        return _governed(prefix[: len(prefix) - len(parts[-1]) - 1], terms)
    return False


def _imperative(span: Span, lead: str) -> bool:
    """The keyword opens its clause as a command ("Melt the caps", "سخّن القارورة")."""
    words = lead.split()
    if _ARABIC_CHARS.search(span.word):
        return all(w in _IMPERATIVE_LEAD_AR for w in words)
    following = span.text[span.end :].split()
    return all(w in _IMPERATIVE_LEAD_EN for w in words) and bool(following) and following[0] in _IMPERATIVE_OBJECT_EN


def _warning(span: Span) -> bool:
    """``span`` sits in a clause that explains a risk and is not itself a command."""
    before = _CLAUSE_END.split(_COMMA.split(normalize_ar(span.text[: span.start]))[-1])[-1]
    if _CONDITIONAL.search(before):
        return True  # "... when heated", "if it is burned"
    after = _CLAUSE_END.split(_COMMA.split(span.text[span.end :])[0])[0]
    context = _NOT_A_WARNING.sub(" ", f"{before} {after}")
    return _WARNING.found(Sentence(context)) and not _imperative(span, before)


def live(terms: Terms, s: Sentence, *, warnings: bool = True) -> list[Span]:
    """Occurrences of ``terms`` that are instructions: not negated and (optionally) not in a warning."""
    return [sp for sp in terms.spans(s) if not negated(sp, terms) and not (warnings and _warning(sp))]


def sentences(texts: Iterable[str | None]) -> list[Sentence]:
    out: list[Sentence] = []
    for text in texts:
        if text:
            out.extend(Sentence(part) for part in _SENTENCE_SPLIT.split(text) if part.strip())
    return out


def is_negated(s: Sentence) -> bool:
    """Sentence-level test, used only where a whole sentence may be optional ("No drill? ...")."""
    if _NEGATION_EN.search(s.en):
        return True
    if s.ar_tokens & (_NEGATION_AR | _SHORT_SCOPE_AR):
        return True
    return any(tok.startswith(stem) for stem in _NEGATION_AR_STEMS for tok in s.ar_tokens)


def quote(s: Sentence) -> str:
    """A sentence shortened for a problem message."""
    return s.raw if len(s.raw) <= 90 else s.raw[:87] + "..."


def has_arabic(text: str | None) -> bool:
    """True when the text contains Arabic script."""
    return bool(text and _ARABIC_CHARS.search(text))
