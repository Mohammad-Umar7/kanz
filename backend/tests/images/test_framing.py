"""Aspect ratio matching and item crops."""

import pytest

from app.images.framing import CROP_MIN_SIDE, closest_aspect_ratio, crop_box_pixels, crop_to_box
from app.schemas.analysis import BBox
from tests.images.fakes import jpeg_size, make_jpeg


@pytest.mark.parametrize(
    ("size", "expected"),
    [
        ((1600, 1200), "4:3"),
        ((1200, 1600), "3:4"),
        ((1000, 1000), "1:1"),
        ((1920, 1080), "16:9"),
        ((1080, 1920), "9:16"),
        ((1500, 1000), "3:2"),
        ((1184, 880), "4:3"),
        ((0, 10), "4:3"),
    ],
)
def test_closest_aspect_ratio(size: tuple[int, int], expected: str) -> None:
    assert closest_aspect_ratio(*size) == expected


def test_crop_keeps_the_box_with_some_context() -> None:
    photo = make_jpeg(1000, 800)
    box = BBox(x=0.3, y=0.2, w=0.3, h=0.4)
    left, top, right, bottom = crop_box_pixels(1000, 800, box)
    assert left < 300 and top < 160 and right > 600 and bottom > 480
    width, height = jpeg_size(crop_to_box(photo, box))
    assert (width, height) == (right - left, bottom - top)


def test_large_or_missing_box_leaves_the_photo_untouched() -> None:
    photo = make_jpeg(1000, 800)
    assert crop_to_box(photo, None) is photo
    assert crop_to_box(photo, BBox(x=0.05, y=0.05, w=0.9, h=0.9)) is photo


def test_tiny_box_grows_to_the_minimum_side() -> None:
    left, top, right, bottom = crop_box_pixels(1000, 800, BBox(x=0.5, y=0.5, w=0.02, h=0.02))
    assert right - left >= CROP_MIN_SIDE
    assert bottom - top >= CROP_MIN_SIDE


def test_box_at_the_edge_is_shifted_inside_the_photo() -> None:
    left, top, right, bottom = crop_box_pixels(1000, 800, BBox(x=0.0, y=0.9, w=0.05, h=0.1))
    assert left == 0 and bottom == 800
    assert right - left >= CROP_MIN_SIDE and bottom - top >= CROP_MIN_SIDE
