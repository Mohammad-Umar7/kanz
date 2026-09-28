"""Reading photo uploads safely: bounded reads and image-type sniffing.

The type is decided from the file's first bytes, not from the client's ``Content-Type``
or file name (both are easy to get wrong on a phone). Full decoding, EXIF orientation
and re-encoding happen later in ``ImageStore.save_upload``.
"""

from __future__ import annotations

from fastapi import UploadFile

from app.core.errors import ImageInvalid, ImageTooLarge

MIB = 1024 * 1024
_CHUNK = MIB


def sniff_image_type(data: bytes) -> str | None:
    """MIME type for JPEG, PNG or WebP bytes; ``None`` for anything else."""
    if data.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp"
    return None


async def read_image_upload(upload: UploadFile, *, max_bytes: int) -> bytes | None:
    """Read an uploaded photo without ever holding more than ``max_bytes`` + one chunk.

    Returns ``None`` for an empty file part (some HTTP clients send one when no photo was
    chosen). Raises ``ImageTooLarge`` over the limit and ``ImageInvalid`` for non-images.
    """
    if upload.size is not None and upload.size > max_bytes:
        raise ImageTooLarge(detail=f"declared size {upload.size} > {max_bytes}")
    buffer = bytearray()
    while chunk := await upload.read(_CHUNK):
        buffer.extend(chunk)
        if len(buffer) > max_bytes:
            raise ImageTooLarge(detail=f"read more than {max_bytes} bytes")
    if not buffer:
        return None
    if sniff_image_type(bytes(buffer[:16])) is None:
        raise ImageInvalid(detail=f"unrecognized image bytes, content_type={upload.content_type!r}")
    return bytes(buffer)
