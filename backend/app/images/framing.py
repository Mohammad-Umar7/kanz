"""Framing helpers: output aspect ratio and item crops.

* **Aspect ratio.** Every generated picture uses the supported aspect ratio closest to
  the photo it edits. A portrait phone photo therefore gets a portrait after image, and
  the app's before/after slider lines the two up pixel for pixel. Text scans have no
  photo and use the configured default (4:3).
* **Item crop.** A bin picture is about one item, but the photo may show several.
  When the analysis has the item's bounding box, the photo is cropped to it (with some
  context around it) before editing, so the model works on the right object.
"""

from __future__ import annotations

import io
import math

from PIL import Image

from app.schemas.analysis import BBox

# Aspect ratios accepted by Gemini image generation (ImageConfig.aspect_ratio).
SUPPORTED_ASPECT_RATIOS: dict[str, float] = {
    "1:1": 1.0,
    "4:3": 4 / 3,
    "3:4": 3 / 4,
    "3:2": 3 / 2,
    "2:3": 2 / 3,
    "5:4": 5 / 4,
    "4:5": 4 / 5,
    "16:9": 16 / 9,
    "9:16": 9 / 16,
    "21:9": 21 / 9,
}

CROP_PADDING = 0.15  # context kept around the box, as a fraction of the box size
CROP_MIN_SIDE = 256  # never hand the model a crop smaller than this (pixels)
CROP_MAX_AREA = 0.6  # a box covering more of the photo than this is left uncropped
JPEG_QUALITY = 90


def image_size(data: bytes) -> tuple[int, int]:
    """(width, height) of an encoded image, read from its header."""
    with Image.open(io.BytesIO(data)) as img:
        return img.size


def closest_aspect_ratio(width: int, height: int) -> str:
    """The supported ratio nearest to width/height (compared on a log scale, so 4:3 and 3:4 are symmetric)."""
    if width <= 0 or height <= 0:
        return "4:3"
    ratio = math.log(width / height)
    return min(SUPPORTED_ASPECT_RATIOS, key=lambda k: abs(math.log(SUPPORTED_ASPECT_RATIOS[k]) - ratio))


def crop_box_pixels(width: int, height: int, bbox: BBox) -> tuple[int, int, int, int] | None:
    """Pixel crop (left, top, right, bottom) around a normalized box, or None when cropping would not help."""
    if bbox.w * bbox.h >= CROP_MAX_AREA or bbox.w <= 0 or bbox.h <= 0:
        return None
    pad_x, pad_y = bbox.w * CROP_PADDING, bbox.h * CROP_PADDING
    left, right = (bbox.x - pad_x) * width, (bbox.x + bbox.w + pad_x) * width
    top, bottom = (bbox.y - pad_y) * height, (bbox.y + bbox.h + pad_y) * height

    # Grow small crops around their center so the model still gets enough pixels.
    min_side = min(CROP_MIN_SIDE, width, height)
    if right - left < min_side:
        cx = (left + right) / 2
        left, right = cx - min_side / 2, cx + min_side / 2
    if bottom - top < min_side:
        cy = (top + bottom) / 2
        top, bottom = cy - min_side / 2, cy + min_side / 2

    # Shift back inside the photo instead of shrinking the crop.
    if left < 0:
        left, right = 0, right - left
    if right > width:
        left, right = max(0, left - (right - width)), width
    if top < 0:
        top, bottom = 0, bottom - top
    if bottom > height:
        top, bottom = max(0, top - (bottom - height)), height

    box = (round(left), round(top), round(right), round(bottom))
    if box == (0, 0, width, height):
        return None
    return box


def crop_to_box(data: bytes, bbox: BBox | None) -> bytes:
    """JPEG of the photo cropped around ``bbox``; the original bytes when there is nothing useful to crop."""
    if bbox is None:
        return data
    with Image.open(io.BytesIO(data)) as img:
        box = crop_box_pixels(img.width, img.height, bbox)
        if box is None:
            return data
        crop = img.convert("RGB").crop(box)
    buf = io.BytesIO()
    crop.save(buf, "JPEG", quality=JPEG_QUALITY)
    return buf.getvalue()
