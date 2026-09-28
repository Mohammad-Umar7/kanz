"""Static serving for uploaded photos and generated images, with cache headers.

Uploads are content-addressed (``img_<sha256>.jpg``): the bytes behind a URL never
change, so phones may cache them for a year without revalidating. Generated images are
keyed by request (``after_<idea_id>.jpg``) and can be regenerated in place, so they get a
long max-age but keep ETag revalidation instead of ``immutable``.

Only image files are served: text scans (``txt_<hash>.txt``) share the uploads folder
and stay private.
"""

from __future__ import annotations

from pathlib import PurePath

from starlette.exceptions import HTTPException
from starlette.responses import Response
from starlette.staticfiles import StaticFiles
from starlette.types import Scope

IMMUTABLE = "public, max-age=31536000, immutable"
REVALIDATE_DAILY = "public, max-age=86400, must-revalidate"
IMAGE_SUFFIXES = frozenset({".jpg", ".jpeg", ".png", ".webp"})


class CachedStaticFiles(StaticFiles):
    """``StaticFiles`` restricted to image files, adding a ``Cache-Control`` header."""

    def __init__(self, *, directory: str | PurePath, cache_control: str) -> None:
        super().__init__(directory=directory)
        self.cache_control = cache_control

    async def get_response(self, path: str, scope: Scope) -> Response:
        if PurePath(path).suffix.lower() not in IMAGE_SUFFIXES:
            raise HTTPException(status_code=404)
        response = await super().get_response(path, scope)
        if response.status_code in (200, 304):
            response.headers["Cache-Control"] = self.cache_control
        return response
