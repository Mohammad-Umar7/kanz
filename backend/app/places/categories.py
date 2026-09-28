"""Material -> facility category mapping, driven by ``backend/config/facility_categories.json``.

Public seam (keep these signatures):

    def catalog(lang: str) -> list[FacilityCategory]
    def categories_for_items(items: list[Item], lang: str) -> list[FacilityCategory]

The routing is deterministic on purpose: whether a battery goes to a battery box or a
t-shirt to a donation bin is a safety and policy decision, so it follows written rules
rather than a model's judgement. The rules live in the config file; this module only
evaluates them.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass, field

from app.places.config import Condition, FacilityConfig, get_config
from app.schemas.analysis import Item
from app.schemas.recommend import FacilityCategory
from app.schemas.vocab import DISPOSAL_ONLY_HAZARDS

# Relevance tiers: every item's primary route is listed before any secondary route
# (e.g. a worn t-shirt's "textile_recycling" after another item's "glass").
_PRIMARY, _SECONDARY = 0, 1


def catalog(lang: str, config: FacilityConfig | None = None) -> list[FacilityCategory]:
    """Every category in config order, for the Drop-off tab's filter chips."""
    cfg = config or get_config()
    return [_category(cfg, key, lang, []) for key in cfg.categories]


def keys_for_item(item: Item, config: FacilityConfig | None = None) -> list[str]:
    """Ordered category keys for one item: primary route first, then secondary routes and extras."""
    cfg = config or get_config()
    routing = cfg.routing

    disposal_hazards = [h for h in routing.by_hazard if h in item.hazards and h in DISPOSAL_ONLY_HAZARDS]
    if disposal_hazards:
        # A hazardous item goes only where it can be handled safely: no general bins, no donation.
        return _dedupe(key for hazard in disposal_hazards for key in routing.by_hazard[hazard])

    keys: list[str] = []
    rule = next((r for r in routing.by_condition if _matches(item, r.when)), None)
    keys += rule.keys if rule else routing.by_material.get(item.category, [])
    for extra in routing.extras:
        if _matches(item, extra.when):
            keys += extra.keys
    return _dedupe(keys)


def categories_for_items(items: list[Item], lang: str, config: FacilityConfig | None = None) -> list[FacilityCategory]:
    """Categories needed for a scan, deduplicated, each listing the item ids that need it.

    Ordered by relevance: primary routes before secondary ones, then by item order (the
    analysis lists the most prominent item first), then by rule order within an item.
    """
    cfg = config or get_config()
    ranked: dict[str, _Ranked] = {}
    for item_index, item in enumerate(items):
        for position, key in enumerate(keys_for_item(item, cfg)):
            tier = _PRIMARY if position == 0 else _SECONDARY
            rank = (tier, item_index, position)
            entry = ranked.setdefault(key, _Ranked(rank=rank))
            entry.rank = min(entry.rank, rank)
            if item.id not in entry.item_ids:
                entry.item_ids.append(item.id)
    ordered = sorted(ranked.items(), key=lambda kv: kv[1].rank)
    return [_category(cfg, key, lang, entry.item_ids) for key, entry in ordered]


# ---------------------------------------------------------------------- internals
@dataclass
class _Ranked:
    rank: tuple[int, int, int]
    item_ids: list[str] = field(default_factory=list)


def _matches(item: Item, when: Condition) -> bool:
    if when.category is not None and item.category not in when.category:
        return False
    if when.min_quality is not None and item.quality.score < when.min_quality:
        return False
    if when.no_hazards and item.hazards:
        return False
    if when.reuse_level is not None and item.reuse.level not in when.reuse_level:
        return False
    return when.is_raw_material is None or item.is_raw_material == when.is_raw_material


def _category(cfg: FacilityConfig, key: str, lang: str, item_ids: list[str]) -> FacilityCategory:
    c = cfg.categories[key]
    return FacilityCategory(
        key=key,
        label=c.labels.get(lang),
        facility_types=list(c.facility_types),
        material_categories=list(c.material_categories),
        item_ids=list(item_ids),
    )


def _dedupe(keys: Iterable[str]) -> list[str]:
    return list(dict.fromkeys(keys))
