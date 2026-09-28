"""Static serving of uploads and generated images."""

from __future__ import annotations

import httpx

from app.config import Settings
from tests.api.helpers import assert_error

JPEG = b"\xff\xd8\xff\xe0 fake but served as bytes"


async def test_uploads_are_served_as_immutable(client: httpx.AsyncClient, settings: Settings) -> None:
    (settings.uploads_dir / "img_0123456789abcdef.jpg").write_bytes(JPEG)
    response = await client.get("/static/uploads/img_0123456789abcdef.jpg")
    assert response.status_code == 200
    assert response.content == JPEG
    assert response.headers["content-type"] == "image/jpeg"
    assert response.headers["cache-control"] == "public, max-age=31536000, immutable"
    assert response.headers["X-Request-ID"]


async def test_generated_images_revalidate(client: httpx.AsyncClient, settings: Settings) -> None:
    folder = settings.generated_dir / "img_0123456789abcdef"
    folder.mkdir(parents=True)
    (folder / "after_idea_9f2c41aa.jpg").write_bytes(JPEG)
    url = "/static/generated/img_0123456789abcdef/after_idea_9f2c41aa.jpg"

    first = await client.get(url)
    assert first.status_code == 200
    assert first.headers["cache-control"] == "public, max-age=86400, must-revalidate"

    again = await client.get(url, headers={"If-None-Match": first.headers["etag"]})
    assert again.status_code == 304
    assert again.headers["cache-control"] == "public, max-age=86400, must-revalidate"


async def test_text_scans_are_not_served(client: httpx.AsyncClient, settings: Settings) -> None:
    (settings.uploads_dir / "txt_0123456789abcdef.txt").write_text("my old jeans", encoding="utf-8")
    response = await client.get("/static/uploads/txt_0123456789abcdef.txt")
    assert_error(response, 404, "not_found")
    assert "jeans" not in response.text


async def test_missing_image_is_404_envelope(client: httpx.AsyncClient) -> None:
    assert_error(await client.get("/static/generated/img_nope/after_idea_x.jpg"), 404, "not_found")


async def test_path_traversal_is_refused(client: httpx.AsyncClient, settings: Settings) -> None:
    (settings.data_dir / "secret.jpg").write_bytes(JPEG)
    response = await client.get("/static/uploads/%2e%2e/secret.jpg")
    assert response.status_code == 404


async def test_static_files_reject_writes(client: httpx.AsyncClient) -> None:
    assert_error(await client.post("/static/uploads/img_x.jpg", content=b"x"), 405, "bad_request")
