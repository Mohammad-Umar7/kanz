"""In-memory BM25 keyword retriever: the fallback when embeddings are unavailable.

Retrieval must never be the reason a recommendation fails. If the Gemini embedding call is
out of quota, offline or not configured, the same documents are searched with Okapi BM25
over English and Arabic tokens. It is less forgiving of paraphrase than vector search, but
item names ("jar", "bottle", "t-shirt") and material ids overlap strongly with the
knowledge base, so it stays useful.
"""

from __future__ import annotations

import math
import re
from collections import Counter
from collections.abc import Callable, Iterable

from app.ai.safety import normalize_ar

_TOKEN = re.compile(r"[a-z0-9]+|[ء-ي]+")
_STOP = frozenset(
    {
        *("a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "in", "is", "it", "its"),
        *("of", "on", "or", "the", "to", "with", "this", "that", "into", "your", "you", "use", "about"),
        *("one", "two", "up", "out", "all", "any", "can", "not", "no"),
    }
)
_AR_PREFIXES = ("وال", "بال", "لل", "ال", "و", "ب", "ل")


def _stem(tok: str) -> str:
    if tok.isascii():
        if len(tok) > 4 and tok.endswith("ies"):
            return tok[:-3] + "y"
        if len(tok) > 3 and tok.endswith("es") and tok[-3] in "sxz":
            return tok[:-2]
        if len(tok) > 3 and tok.endswith("s") and not tok.endswith("ss"):
            return tok[:-1]
        return tok
    for prefix in _AR_PREFIXES:
        if tok.startswith(prefix) and len(tok) - len(prefix) >= 3:
            return tok[len(prefix) :]
    return tok


def tokenize(text: str) -> list[str]:
    return [_stem(t) for t in _TOKEN.findall(normalize_ar(text.lower())) if len(t) > 1 and t not in _STOP]


class KeywordIndex:
    """Okapi BM25 (k1=1.5, b=0.75) over a fixed set of documents."""

    def __init__(self, docs: Iterable[tuple[str, str]], k1: float = 1.5, b: float = 0.75) -> None:
        self.k1, self.b = k1, b
        self.ids: list[str] = []
        self.tf: list[Counter[str]] = []
        self.lengths: list[int] = []
        df: Counter[str] = Counter()
        for doc_id, text in docs:
            tokens = tokenize(text)
            counts = Counter(tokens)
            self.ids.append(doc_id)
            self.tf.append(counts)
            self.lengths.append(len(tokens))
            df.update(counts.keys())
        n = len(self.ids)
        self.avg_len = (sum(self.lengths) / n) if n else 0.0
        self.idf = {t: math.log(1 + (n - f + 0.5) / (f + 0.5)) for t, f in df.items()}

    def search(self, query: str, *, k: int = 6, allow: Callable[[str], bool] | None = None) -> list[tuple[str, float]]:
        """Top ``k`` (id, score) pairs; scores are scaled to 0..1 relative to the best match."""
        terms = set(tokenize(query))
        scored: list[tuple[str, float]] = []
        for i, doc_id in enumerate(self.ids):
            if allow is not None and not allow(doc_id):
                continue
            tf, length = self.tf[i], self.lengths[i] or 1
            score = 0.0
            for t in terms:
                f = tf.get(t)
                if f:
                    norm = f * (self.k1 + 1) / (f + self.k1 * (1 - self.b + self.b * length / (self.avg_len or 1)))
                    score += self.idf.get(t, 0.0) * norm
            if score > 0:
                scored.append((doc_id, score))
        scored.sort(key=lambda pair: pair[1], reverse=True)
        top = scored[:k]
        best = top[0][1] if top else 1.0
        return [(doc_id, round(score / best, 4)) for doc_id, score in top]
