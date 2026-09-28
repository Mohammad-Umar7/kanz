"""Builders for scan items used across the places tests."""

from app.schemas.analysis import Item, Quality, Quantity, Recyclability, ReusePotential


def make_item(
    item_id: str,
    name: str,
    category: str,
    *,
    quality: int = 4,
    hazards: tuple[str, ...] = (),
    reuse: str = "medium",
    raw: bool = False,
    state: tuple[str, ...] = (),
) -> Item:
    return Item(
        id=item_id,
        name=name,
        category=category,
        material=name,
        is_raw_material=raw,
        quantity=Quantity(value=1, unit="pcs", is_estimate=False, display="1 pc"),
        quality=Quality(score=quality, label=str(quality)),
        state=list(state),
        recyclability=Recyclability(status="yes", stream="bin"),
        reuse=ReusePotential(level=reuse, note="note"),
        hazards=list(hazards),
        confidence=0.9,
    )
