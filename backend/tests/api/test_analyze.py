"""POST /v1/analyze: multipart handling, size limits, type sniffing and validation."""

from __future__ import annotations

import io
from collections.abc import AsyncIterator, Callable
from typing import Any

import httpx
import pytest
from fastapi import FastAPI
from PIL import Image

from app.config import Settings
from app.main import FORM_OVERHEAD_BYTES, create_app
from app.schemas.analysis import AnalyzeResponse
from tests.api.helpers import Seams, assert_error
from tests.conftest import load_fixture

ANALYZE = "app.ai.pipeline.analyze"
MIB = 1024 * 1024


def photo(fmt: str = "JPEG") -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (32, 24), (180, 200, 190)).save(buffer, fmt)
    return buffer.getvalue()


@pytest.fixture
def glass_jar(seams: Seams) -> tuple[dict[str, Any], list[Any]]:
    fixture = load_fixture("analyze_glass_jar")
    calls = seams.returns(ANALYZE, AnalyzeResponse.model_validate(fixture))
    return fixture, calls


async def test_photo_is_analyzed(client: httpx.AsyncClient, glass_jar: tuple[dict[str, Any], list[Any]]) -> None:
    fixture, calls = glass_jar
    jpeg = photo()
    response = await client.post("/v1/analyze", files={"image": ("jar.jpg", jpeg, "image/jpeg")}, data={"lang": "en"})

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].kwargs == {"image": jpeg, "text": None, "lang": "en"}


async def test_text_only_scan_is_trimmed(client: httpx.AsyncClient, seams: Seams) -> None:
    fixture = load_fixture("analyze_text_caps")
    calls = seams.returns(ANALYZE, AnalyzeResponse.model_validate(fixture))
    response = await client.post("/v1/analyze", data={"text": "  a jar of bottle caps \n", "lang": "ar"})

    assert response.status_code == 200, response.text
    assert response.json() == fixture
    assert calls[0].kwargs == {"image": None, "text": "a jar of bottle caps", "lang": "ar"}


async def test_photo_and_text_are_both_forwarded(
    client: httpx.AsyncClient, glass_jar: tuple[dict[str, Any], list[Any]]
) -> None:
    _, calls = glass_jar
    png = photo("PNG")
    response = await client.post(
        "/v1/analyze", files={"image": ("jar.png", png, "image/png")}, data={"text": "jam jar, lid on"}
    )
    assert response.status_code == 200
    assert calls[0].kwargs == {"image": png, "text": "jam jar, lid on", "lang": "en"}


async def test_webp_is_accepted(client: httpx.AsyncClient, glass_jar: tuple[dict[str, Any], list[Any]]) -> None:
    response = await client.post("/v1/analyze", files={"image": ("jar.webp", photo("WEBP"), "image/webp")})
    assert response.status_code == 200


async def test_neither_photo_nor_text_is_400(client: httpx.AsyncClient, seams: Seams) -> None:
    calls = seams.returns(ANALYZE, None)
    response = await client.post("/v1/analyze", data={"lang": "en"})
    error = assert_error(response, 400, "bad_request", retryable=False)
    assert "photo" in error["message"]
    assert calls == []


async def test_empty_file_and_blank_text_count_as_missing(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns(ANALYZE, None)
    response = await client.post(
        "/v1/analyze", files={"image": ("", b"", "application/octet-stream")}, data={"text": "   "}
    )
    assert_error(response, 400, "bad_request")


async def test_non_image_file_is_image_invalid(client: httpx.AsyncClient, seams: Seams) -> None:
    calls = seams.returns(ANALYZE, None)
    response = await client.post(
        "/v1/analyze", files={"image": ("notes.jpg", b"%PDF-1.7 definitely not a photo", "image/jpeg")}
    )
    assert_error(response, 400, "image_invalid", retryable=False)
    assert calls == []


async def test_invalid_lang_is_422_naming_the_field(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns(ANALYZE, None)
    response = await client.post("/v1/analyze", data={"text": "glass jar", "lang": "fr"})
    error = assert_error(response, 422, "bad_request")
    assert error["message"].startswith("'lang' is invalid")


async def test_overlong_text_is_422(client: httpx.AsyncClient, seams: Seams) -> None:
    seams.returns(ANALYZE, None)
    response = await client.post("/v1/analyze", data={"text": "x" * 2001})
    assert assert_error(response, 422, "bad_request")["message"].startswith("'text' is invalid")


# ------------------------------------------------------------------------------ size limits
@pytest.fixture
async def small_limit_client(
    settings: Settings, make_client: Callable[[FastAPI], httpx.AsyncClient]
) -> AsyncIterator[httpx.AsyncClient]:
    async with make_client(create_app(settings.model_copy(update={"max_upload_mb": 1}))) as client:
        yield client


async def test_photo_over_the_limit_is_413(small_limit_client: httpx.AsyncClient, seams: Seams) -> None:
    calls = seams.returns(ANALYZE, None)
    oversized = b"\xff\xd8\xff" + b"\0" * MIB  # a JPEG header followed by just over 1 MiB
    response = await small_limit_client.post("/v1/analyze", files={"image": ("big.jpg", oversized, "image/jpeg")})
    assert_error(response, 413, "image_too_large", retryable=False)
    assert calls == []


async def test_huge_body_is_rejected_before_parsing(small_limit_client: httpx.AsyncClient, seams: Seams) -> None:
    calls = seams.returns(ANALYZE, None)
    huge = b"\xff\xd8\xff" + b"\0" * (MIB + FORM_OVERHEAD_BYTES)
    response = await small_limit_client.post("/v1/analyze", files={"image": ("huge.jpg", huge, "image/jpeg")})
    assert_error(response, 413, "image_too_large")
    assert calls == []


async def test_streamed_upload_is_cut_off_at_the_limit(small_limit_client: httpx.AsyncClient, seams: Seams) -> None:
    """A chunked body has no Content-Length; the middleware counts bytes as they arrive."""
    seams.returns(ANALYZE, None)
    boundary = "kanzboundary"

    async def body() -> AsyncIterator[bytes]:
        yield (
            f'--{boundary}\r\nContent-Disposition: form-data; name="image"; filename="a.jpg"\r\n'
            "Content-Type: image/jpeg\r\n\r\n"
        ).encode()
        for _ in range(3):
            yield b"\0" * MIB
        yield f"\r\n--{boundary}--\r\n".encode()

    response = await small_limit_client.post(
        "/v1/analyze", content=body(), headers={"Content-Type": f"multipart/form-data; boundary={boundary}"}
    )
    assert "content-length" not in response.request.headers
    assert_error(response, 413, "image_too_large")


async def test_oversized_json_body_is_413_bad_request(small_limit_client: httpx.AsyncClient) -> None:
    response = await small_limit_client.post(
        "/v1/swaps", content=b" " * (2 * MIB), headers={"Content-Type": "application/json"}
    )
    assert_error(response, 413, "bad_request")
