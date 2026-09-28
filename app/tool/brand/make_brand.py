"""Render the Kanz brand PNGs from the mark's geometry.

The mark is a front-view cut gem: two ink crown facets flank a clay table
facet above a solid ink pavilion. The coordinates below are the same unit
square coordinates as BrandMarkGeometry in
app/lib/core/design/components/brand_mark.dart; change both together.

Outputs (app/assets/brand/):
  icon.png             1024 px, paper background, for iOS and legacy Android
  icon_foreground.png  1024 px, transparent, mark inside the adaptive-icon
                       safe zone (66 of 108 dp)
  icon_monochrome.png  1024 px, single color, for Android 13 themed icons
  splash.png           1152 px, transparent, mark inside the Android 12
                       splash circle (768 px)
  splash_dark.png      the same for the dark splash

Run from the repository root:
  backend/.venv/Scripts/python app/tool/brand/make_brand.py
Then regenerate platform resources from app/:
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[2] / "assets" / "brand"

# Tokens (app/lib/core/design/tokens.dart).
PAPER = (244, 241, 234, 255)
INK = (22, 22, 22, 255)
CLAY = (198, 80, 38, 255)
DARK_BG = (17, 18, 16, 255)
DARK_INK = (242, 239, 232, 255)
DARK_CLAY = (240, 122, 79, 255)
CLEAR = (0, 0, 0, 0)

CROWN_START = [(0.285, 0.16), (0.10, 0.36), (0.325, 0.36)]
TABLE = [(0.335, 0.16), (0.665, 0.16), (0.625, 0.36), (0.375, 0.36)]
CROWN_END = [(0.715, 0.16), (0.90, 0.36), (0.675, 0.36)]
PAVILION = [(0.10, 0.41), (0.90, 0.41), (0.50, 0.84)]

# The mark's visual center in unit coordinates (bounding box center).
CENTER = (0.5, 0.5)

SUPERSAMPLE = 4


def render(
    size: int,
    *,
    scale: float,
    background: tuple[int, int, int, int],
    ink: tuple[int, int, int, int],
    accent: tuple[int, int, int, int],
) -> Image.Image:
    """Draws the mark with its unit square spanning `scale` of the canvas."""
    big = size * SUPERSAMPLE
    image = Image.new("RGBA", (big, big), background)
    draw = ImageDraw.Draw(image)
    unit = big * scale
    ox = big / 2 - CENTER[0] * unit
    oy = big / 2 - CENTER[1] * unit

    def poly(
        points: list[tuple[float, float]], color: tuple[int, int, int, int]
    ) -> None:
        draw.polygon([(ox + x * unit, oy + y * unit) for x, y in points], fill=color)

    poly(CROWN_START, ink)
    poly(CROWN_END, ink)
    poly(PAVILION, ink)
    poly(TABLE, accent)
    return image.resize((size, size), Image.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    outputs = {
        # Full-bleed square icon: the mark at 80 % of the canvas reads well
        # at 48 px and leaves an even paper margin.
        "icon.png": render(1024, scale=0.80, background=PAPER, ink=INK, accent=CLAY),
        # Adaptive foreground: flutter_launcher_icons wraps it in a 16 % inset,
        # so this canvas becomes the middle 68 % of the 108 dp icon (73 dp).
        # At 0.85 the mark is ~50 dp wide and its farthest point (0.41 units
        # from the center) stays 26 dp out, inside the 33 dp safe radius.
        "icon_foreground.png": render(
            1024, scale=0.85, background=CLEAR, ink=INK, accent=CLAY
        ),
        "icon_monochrome.png": render(
            1024, scale=0.85, background=CLEAR, ink=INK, accent=INK
        ),
        # Android 12 splash: 1152 px canvas, visible circle 768 px.
        "splash.png": render(1152, scale=0.62, background=CLEAR, ink=INK, accent=CLAY),
        "splash_dark.png": render(
            1152, scale=0.62, background=CLEAR, ink=DARK_INK, accent=DARK_CLAY
        ),
    }
    for name, image in outputs.items():
        target = OUT / name
        if name == "icon.png":
            image = image.convert("RGB")
        image.save(target, optimize=True)
        print(f"wrote {target.relative_to(OUT.parents[1])} ({image.width} px)")


if __name__ == "__main__":
    main()
