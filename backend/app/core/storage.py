"""File storage for uploads and generated images, served as static files.

Layout under ``settings.data_dir`` (git-ignored):

    uploads/<image_id>.jpg                 the user's photo, re-encoded as JPEG
    generated/<image_id>/<name>.jpg        after / step / bin / reference images
    tutorials/<tutorial_id>.json           tutorials, so step images can be rebuilt later

``/static/uploads`` and ``/static/generated`` are mounted in ``app.main``. URLs are
returned as paths (``/static/...``) unless ``PUBLIC_BASE_URL`` is set.
"""

from __future__ import annotations

import hashlib
import io
import re
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps, UnidentifiedImageError

from app.config import Settings, get_settings
from app.core.errors import ImageInvalid, ImageTooLarge, NotFound

_SAFE = re.compile(r"^[A-Za-z0-9_\-]+$")
MAX_EDGE = 1600  # the app already compresses; this guards direct API use
JPEG_QUALITY = 88


@dataclass(frozen=True)
class StoredImage:
    image_id: str
    path: Path
    url: str
    width: int
    height: int


def _check_id(value: str) -> str:
    if not _SAFE.match(value or ""):
        raise NotFound(detail=f"unsafe id {value!r}")
    return value


class ImageStore:
    def __init__(self, settings: Settings | None = None) -> None:
        self.s = settings or get_settings()
        for d in (self.s.uploads_dir, self.s.generated_dir, self.s.tutorials_dir):
            d.mkdir(parents=True, exist_ok=True)

    # ---------------------------------------------------------------- urls
    def _url(self, rel: str) -> str:
        return f"{self.s.public_base_url.rstrip('/')}{rel}" if self.s.public_base_url else rel

    # ------------------------------------------------------------- uploads
    def save_upload(self, data: bytes) -> StoredImage:
        """Validate, orient, downscale and store a user photo. Id is content-addressed."""
        if len(data) > self.s.max_upload_mb * 1024 * 1024:
            raise ImageTooLarge()
        try:
            img = Image.open(io.BytesIO(data))
            img = ImageOps.exif_transpose(img).convert("RGB")
        except (UnidentifiedImageError, OSError) as exc:
            raise ImageInvalid(detail=str(exc)) from exc
        img.thumbnail((MAX_EDGE, MAX_EDGE))
        buf = io.BytesIO()
        img.save(buf, "JPEG", quality=JPEG_QUALITY, optimize=True)
        jpeg = buf.getvalue()
        image_id = "img_" + hashlib.sha256(jpeg).hexdigest()[:16]
        path = self.s.uploads_dir / f"{image_id}.jpg"
        if not path.exists():
            path.write_bytes(jpeg)
        return StoredImage(image_id, path, self._url(f"/static/uploads/{image_id}.jpg"), img.width, img.height)

    def load_upload(self, image_id: str) -> bytes:
        """Bytes of the original photo. Text scans ('txt_...') use their generated reference image."""
        _check_id(image_id)
        if image_id.startswith("txt_"):
            ref = self.generated_path(image_id, "reference")
            if ref.exists():
                return ref.read_bytes()
            raise NotFound(detail=f"no reference image yet for {image_id}")
        path = self.s.uploads_dir / f"{image_id}.jpg"
        if not path.exists():
            raise NotFound(detail=f"upload {image_id} missing")
        return path.read_bytes()

    def upload_exists(self, image_id: str) -> bool:
        _check_id(image_id)
        return (self.s.uploads_dir / f"{image_id}.jpg").exists()

    # ---------------------------------------------------------- text scans
    def save_text_scan(self, text: str) -> str:
        """Text input has no photo: store the description and return a 'txt_' id.

        The image pipeline later renders a realistic reference photo from it
        (``generated/<txt_id>/reference.jpg``) so after/step images still have a
        base image to edit.
        """
        clean = text.strip()
        image_id = "txt_" + hashlib.sha256(clean.encode("utf-8")).hexdigest()[:16]
        path = self.s.uploads_dir / f"{image_id}.txt"
        if not path.exists():
            path.write_text(clean, encoding="utf-8")
        return image_id

    def load_text_scan(self, image_id: str) -> str:
        _check_id(image_id)
        path = self.s.uploads_dir / f"{image_id}.txt"
        if not path.exists():
            raise NotFound(detail=f"text scan {image_id} missing")
        return path.read_text(encoding="utf-8")

    # ----------------------------------------------------------- generated
    def generated_path(self, image_id: str, name: str) -> Path:
        _check_id(image_id)
        _check_id(name)
        return self.s.generated_dir / image_id / f"{name}.jpg"

    def generated_url(self, image_id: str, name: str) -> str:
        return self._url(f"/static/generated/{_check_id(image_id)}/{_check_id(name)}.jpg")

    def save_generated(self, image_id: str, name: str, data: bytes) -> StoredImage:
        """Store a generated image as JPEG (Gemini may return PNG)."""
        img = Image.open(io.BytesIO(data)).convert("RGB")
        buf = io.BytesIO()
        img.save(buf, "JPEG", quality=JPEG_QUALITY, optimize=True)
        path = self.generated_path(image_id, name)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(buf.getvalue())
        return StoredImage(image_id, path, self.generated_url(image_id, name), img.width, img.height)

    def read_generated(self, image_id: str, name: str) -> StoredImage | None:
        path = self.generated_path(image_id, name)
        if not path.exists():
            return None
        with Image.open(path) as img:
            w, h = img.size
        return StoredImage(image_id, path, self.generated_url(image_id, name), w, h)


_store: ImageStore | None = None


def get_store() -> ImageStore:
    global _store
    if _store is None:
        _store = ImageStore()
    return _store
