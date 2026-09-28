"""Pluggable material classifier: a hook for a small fine-tuned vision model.

The Material Analyst (Gemini) does the full analysis. A dedicated classifier can still add
value: a model fine-tuned on local waste photos is fast, cheap and good at one narrow job,
telling glass from clear plastic or aluminium from steel. Its label is passed to the
analyst as a *hint* (a second opinion the prompt tells it to weigh against what it sees),
and it is returned in ``analysis.classifier_hint`` for transparency.

To plug one in later:

1. Implement ``MaterialClassifier``: ``name`` plus ``classify(image) -> ClassifierHint | None``.
   For example, an ONNX or TFLite export of a fine-tuned MobileNet/EfficientNet run with
   onnxruntime, or a call to a Vertex AI endpoint. Return None when unsure (below a
   confidence threshold) so a weak guess never biases the analyst.
2. Register it in ``_REGISTRY`` under a short key.
3. Select it with ``MATERIAL_CLASSIFIER=<key>`` in ``backend/.env`` (``Settings.material_classifier``).

The default is ``NoOpClassifier``: no hint, no latency, no extra dependency.
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass
from functools import lru_cache
from typing import Protocol, runtime_checkable

from app.config import get_settings
from app.schemas.vocab import MaterialCategory

log = logging.getLogger("kanz.classifier")


@dataclass(frozen=True)
class ClassifierHint:
    """A classifier's best guess for the photo's main material."""

    label: str
    category: MaterialCategory | None
    confidence: float
    source: str

    def as_text(self) -> str:
        """Compact form used in the analyst prompt and in ``analysis.classifier_hint``."""
        return f"{self.label} ({self.confidence:.2f}, {self.source})"


@runtime_checkable
class MaterialClassifier(Protocol):
    name: str

    def classify(self, image: bytes) -> ClassifierHint | None:
        """Return a hint for the photo, or None when the classifier has nothing confident to add."""
        ...


class NoOpClassifier:
    """Default: contributes nothing, so the analyst relies on Gemini alone."""

    name = "none"

    def classify(self, image: bytes) -> ClassifierHint | None:
        return None


_REGISTRY: dict[str, Callable[[], MaterialClassifier]] = {"none": NoOpClassifier}


def _configured_name() -> str:
    value = get_settings().material_classifier
    return str(value).strip().lower() or "none"


@lru_cache
def get_classifier() -> MaterialClassifier:
    name = _configured_name()
    factory = _REGISTRY.get(name)
    if factory is None:
        log.warning("unknown MATERIAL_CLASSIFIER=%r; using the no-op classifier", name)
        factory = NoOpClassifier
    return factory()
