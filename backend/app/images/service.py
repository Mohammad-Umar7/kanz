"""Image pipeline: after images, the tutorial step chain and bin images.

Public seam (used by the API routes and by the AI pipeline):

    async def after_image(req: AfterImageRequest) -> ImageResponse
    async def step_image(req: StepImageRequest) -> ImageResponse
    async def bin_image(req: BinImageRequest) -> ImageResponse
    def start_step_chain(tutorial: Tutorial, idea: UpcycleIdea | None = None) -> None  # fire-and-forget

Also available (not yet routed): ``async def reference_image(image_id)`` returns a text
scan's rendered base photo, the natural "before" picture for scans that have no upload.

How it works
------------
* **Every picture edits a real photo.** The base is the user's upload or, for a text
  scan (``txt_...``), a reference photo rendered once from the description
  (``generated/<txt_id>/reference.jpg``). Keeping the user's own object in every frame
  is what makes the reveal and the tutorial believable. Prompts come from the
  ``ImageDirector`` (``director.py``); the output aspect ratio matches the photo, so
  the before/after slider lines up (``framing.py``).
* **After image**, keyed ``(image_id, idea.id)``: ``generated/<image_id>/after_<idea_id>.jpg``.
  The idea is saved next to it as ``idea_<idea_id>.json`` so a later step request can
  rebuild the after image from the tutorial alone.
* **Step chain**, keyed ``(image_id, idea_id, skill, step)``:
  ``step_<idea_id>_<skill>_<n>.jpg``. Step 1 edits the original photo; step N edits
  step N-1 with the original photo as a second reference (it pulls back drift in color
  and shape); the last step also sees the after image, so the ending matches the reveal
  the user already saw. Missing earlier steps are rendered first, in order.
* **Bin image**, keyed ``(image_id, item.id)``: ``bin_<item_id>.jpg``, the item shown
  prepared for its stream, edited from the photo cropped to the item's box.
* **Caching and de-duplication.** Files on disk are the cache (``cached: true``).
  Concurrent requests for the same key share one in-flight render (``SingleFlight``),
  so the background chain and the tutorial screen never render the same step twice.
  ``regenerate`` bypasses the cache for that one picture and overwrites it.
* **Background chain.** ``start_step_chain`` renders steps 1..n in order as soon as a
  tutorial exists, one chain per tutorial, kept in a registry so the task is not
  garbage-collected. Failures are logged and stop the chain; they never propagate.
* **Resilience.** A semaphore caps concurrent renders at ``MAX_CONCURRENT_RENDERS``;
  dependencies (the previous step, the after image) are awaited outside it, so a chain
  can never deadlock waiting for its own slot. Timeouts, retries and fallback models
  live in ``GeminiGateway.image``. Errors reach the API as ``KanzError`` (for example
  ``AiQuotaExhausted``), and the app shows its fallback visual with a retry button.
  After a quota error, renders fail fast for ``QUOTA_COOLDOWN_S`` instead of spending
  more calls on an exhausted key. Each render logs its latency, model and prompt version.
"""

from __future__ import annotations

import asyncio
import logging
import re
import time
from collections.abc import Awaitable, Callable, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Literal, Protocol

from PIL import UnidentifiedImageError
from pydantic import ValidationError

from app.ai.gemini import GeneratedImage, get_gateway
from app.config import Settings, get_settings
from app.core.errors import AiInvalidOutput, AiQuotaExhausted, BadRequest, KanzError, NotFound
from app.core.storage import ImageStore, StoredImage, get_store
from app.core.timing import stage_timer
from app.core.tutorials import TutorialStore, get_tutorial_store
from app.images.director import ImageDirector, ImagePrompt
from app.images.flights import SingleFlight
from app.images.framing import closest_aspect_ratio, crop_to_box, image_size
from app.schemas.images import AfterImageRequest, BinImageRequest, ImageResponse, StepImageRequest
from app.schemas.recommend import UpcycleIdea
from app.schemas.tutorial import Tutorial

log = logging.getLogger("kanz.images")

MAX_CONCURRENT_RENDERS = 3
QUOTA_COOLDOWN_S = 60.0
REFERENCE_NAME = "reference"

Kind = Literal["after", "step", "bin", "reference"]
Timings = dict[str, int]

_SAFE_ID = re.compile(r"^[A-Za-z0-9_\-]{1,80}$")


class ImageGateway(Protocol):
    """The part of ``GeminiGateway`` this module needs (tests pass a fake)."""

    async def image(
        self,
        *,
        stage: str,
        prompt: str,
        references: Sequence[bytes] = (),
        aspect_ratio: str | None = None,
        image_size: str | None = None,
        timeout: float | None = None,
    ) -> GeneratedImage: ...


@dataclass(frozen=True)
class Rendered:
    """A stored picture and whether it was served from the cache."""

    image: StoredImage
    cached: bool

    def read(self) -> bytes:
        return self.image.path.read_bytes()


# ---------------------------------------------------------------- cache keys
def after_key(image_id: str, idea_id: str) -> str:
    return f"{image_id}:after:{idea_id}"


def step_key(image_id: str, idea_id: str, skill: str, step: int) -> str:
    return f"{image_id}:step:{idea_id}:{skill}:{step}"


def bin_key(image_id: str, item_id: str) -> str:
    return f"{image_id}:bin:{item_id}"


def reference_key(image_id: str) -> str:
    return f"{image_id}:reference"


def step_name(idea_id: str, skill: str, step: int) -> str:
    return f"step_{idea_id}_{skill}_{step}"


def _safe_id(value: str, field: str) -> str:
    """Ids become file names: accept only the characters the store accepts."""
    if not _SAFE_ID.match(value or ""):
        raise BadRequest(f"The {field} in this request is not valid.", detail=f"{field}={value!r}")
    return value


class ImageService:
    """Renders, caches and serves every generated picture. One instance per process."""

    def __init__(
        self,
        *,
        gateway: ImageGateway,
        store: ImageStore,
        tutorials: TutorialStore,
        settings: Settings,
        director: ImageDirector | None = None,
        max_concurrent: int = MAX_CONCURRENT_RENDERS,
    ) -> None:
        self.gateway = gateway
        self.store = store
        self.tutorials = tutorials
        self.settings = settings
        self.director = director or ImageDirector(settings.prompts_dir)
        self._slots = asyncio.Semaphore(max_concurrent)
        self._flights: SingleFlight[StoredImage] = SingleFlight()
        self._chains: dict[str, asyncio.Task[None]] = {}
        self._quota_blocked_until = 0.0

    # ============================================================ public API
    async def after_image(self, req: AfterImageRequest) -> ImageResponse:
        """The finished project, edited from the user's photo. Cached per (image_id, idea.id)."""
        image_id, idea = req.image_id, req.idea
        _safe_id(idea.id, "idea id")
        self._require_source(image_id)
        timings: Timings = {}
        with stage_timer(timings, "image_after"):
            self.save_idea(image_id, idea)
            result = await self._after(image_id, idea, regenerate=req.regenerate, timings=timings)
        return self._response(result, kind="after", key=after_key(image_id, idea.id), timings=timings)

    async def step_image(self, req: StepImageRequest) -> ImageResponse:
        """One tutorial step. Cached per (image_id, idea_id, skill, step); missing earlier steps render first."""
        tutorial = self.tutorials.get(req.tutorial_id)
        if tutorial is None:
            raise NotFound(detail=f"tutorial {req.tutorial_id} unknown")
        if tutorial.image_id != req.image_id:
            raise BadRequest(
                "This tutorial belongs to a different photo.",
                detail=f"tutorial {tutorial.tutorial_id} is for {tutorial.image_id}, not {req.image_id}",
            )
        if req.step > len(tutorial.steps):
            raise BadRequest(f"This tutorial has {len(tutorial.steps)} steps.", detail=f"step {req.step} requested")
        _safe_id(tutorial.idea_id, "idea id")
        self._require_source(tutorial.image_id)
        idea = self.load_idea(tutorial.image_id, tutorial.idea_id)
        timings: Timings = {}
        with stage_timer(timings, "image_step"):
            result = await self._step(tutorial, req.step, idea, regenerate=req.regenerate, timings=timings)
        key = step_key(tutorial.image_id, tutorial.idea_id, tutorial.skill, req.step)
        return self._response(result, kind="step", key=key, timings=timings, step=req.step, skill=tutorial.skill)

    async def bin_image(self, req: BinImageRequest) -> ImageResponse:
        """The item prepared for its bin, edited from a crop around the item. Cached per (image_id, item.id)."""
        image_id, item = req.image_id, req.item
        _safe_id(item.id, "item id")
        self._require_source(image_id)
        # The request may carry the localized prep steps from /recommend; the item's own are the fallback.
        prep_steps = req.prep_steps or item.recyclability.prep_steps
        timings: Timings = {}

        async def build() -> StoredImage:
            original = await self._original(image_id, timings)
            focus = await asyncio.to_thread(crop_to_box, original, item.bbox)
            return await self._render(
                kind="bin",
                image_id=image_id,
                name=f"bin_{item.id}",
                prompt=self.director.bin(item, prep_steps),
                references=[focus],
                aspect_ratio=closest_aspect_ratio(*image_size(focus)),
                timings=timings,
                timing_key="render_bin",
            )

        with stage_timer(timings, "image_bin"):
            result = await self._obtain(
                bin_key(image_id, item.id), image_id, f"bin_{item.id}", build, regenerate=req.regenerate
            )
        return self._response(result, kind="bin", key=bin_key(image_id, item.id), timings=timings)

    async def reference_image(self, image_id: str) -> ImageResponse:
        """A text scan's base photo, rendered on first use, so the app has a 'before' picture for it."""
        if not image_id.startswith("txt_"):
            raise BadRequest("Only text scans have a generated reference photo.", detail=image_id)
        self._require_source(image_id)
        timings: Timings = {}
        with stage_timer(timings, "image_reference"):
            result = await self._reference(image_id, timings)
        return self._response(result, kind="reference", key=reference_key(image_id), timings=timings)

    def start_step_chain(self, tutorial: Tutorial, idea: UpcycleIdea | None = None) -> None:
        """Render every step of ``tutorial`` in the background, in order. Never raises.

        The idea is persisted first (even when autostart is off) so that later
        ``/images/step`` calls can build the after image for the final step.
        """
        tutorial_id = tutorial.tutorial_id
        try:
            if idea is not None and idea.id == tutorial.idea_id:
                self.save_idea(tutorial.image_id, idea)
            if not self.settings.step_images_autostart:
                return
            running = self._chains.get(tutorial_id)
            if running is not None and not running.done():
                return  # one chain per tutorial
            task = asyncio.get_running_loop().create_task(
                self._run_chain(tutorial, idea), name=f"step-chain:{tutorial_id}"
            )
            self._chains[tutorial_id] = task
            task.add_done_callback(lambda t: self._chain_finished(tutorial_id, t))
        except Exception:
            log.exception("step chain tutorial=%s could not start", tutorial_id)

    async def wait_for_chains(self) -> None:
        """Wait for the step chains running now."""
        running = [t for t in self._chains.values() if not t.done()]
        if running:
            await asyncio.gather(*running, return_exceptions=True)

    async def aclose(self) -> None:
        """Cancel running chains and renders (server shutdown). Finished pictures stay cached."""
        chains = [t for t in self._chains.values() if not t.done()]
        for task in chains:
            task.cancel()
        pending = chains + self._flights.cancel_all()
        if pending:
            await asyncio.gather(*pending, return_exceptions=True)
            log.info("image pipeline stopped: cancelled %d chain(s) and renders", len(chains))

    # ======================================================= idea hand-off
    def _idea_path(self, image_id: str, idea_id: str) -> Path:
        # generated_path validates both ids; the idea is stored beside its after image.
        return self.store.generated_path(image_id, f"idea_{idea_id}").with_suffix(".json")

    def save_idea(self, image_id: str, idea: UpcycleIdea) -> None:
        """Keep the idea beside its after image; step requests only carry a tutorial id."""
        path = self._idea_path(image_id, idea.id)
        data = idea.model_dump_json(indent=1)
        if path.exists() and path.read_text(encoding="utf-8") == data:
            return
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(data, encoding="utf-8")

    def load_idea(self, image_id: str, idea_id: str) -> UpcycleIdea | None:
        """The saved idea, or None (the final step then renders without the after image)."""
        path = self._idea_path(image_id, idea_id)
        if not path.exists():
            return None
        try:
            return UpcycleIdea.model_validate_json(path.read_text(encoding="utf-8"))
        except (OSError, ValidationError) as exc:
            log.warning("idea file %s unreadable, continuing without it: %s", path.name, exc)
            return None

    # ================================================== pictures by kind
    def _require_source(self, image_id: str) -> None:
        """404 for an unknown photo or text scan, before any work is done or any file written."""
        if image_id.startswith("txt_"):
            self.store.load_text_scan(image_id)
        elif not self.store.upload_exists(image_id):
            raise NotFound(detail=f"upload {image_id} missing")

    async def _original(self, image_id: str, timings: Timings | None) -> bytes:
        """The photo every edit starts from: the upload, or a text scan's reference photo."""
        if image_id.startswith("txt_"):
            await self._reference(image_id, timings)
        return self.store.load_upload(image_id)

    async def _reference(self, image_id: str, timings: Timings | None) -> Rendered:
        async def build() -> StoredImage:
            description = self.store.load_text_scan(image_id)
            return await self._render(
                kind="reference",
                image_id=image_id,
                name=REFERENCE_NAME,
                prompt=self.director.reference(description),
                references=[],
                aspect_ratio=self.settings.image_aspect_ratio,
                timings=timings,
                timing_key="render_reference",
            )

        return await self._obtain(reference_key(image_id), image_id, REFERENCE_NAME, build)

    async def _after(
        self, image_id: str, idea: UpcycleIdea, *, regenerate: bool = False, timings: Timings | None = None
    ) -> Rendered:
        name = f"after_{idea.id}"

        async def build() -> StoredImage:
            original = await self._original(image_id, timings)
            return await self._render(
                kind="after",
                image_id=image_id,
                name=name,
                prompt=self.director.after(idea),
                references=[original],
                aspect_ratio=closest_aspect_ratio(*image_size(original)),
                timings=timings,
                timing_key="render_after",
            )

        return await self._obtain(after_key(image_id, idea.id), image_id, name, build, regenerate=regenerate)

    async def _step(
        self,
        tutorial: Tutorial,
        number: int,
        idea: UpcycleIdea | None,
        *,
        regenerate: bool = False,
        timings: Timings | None = None,
    ) -> Rendered:
        """Step ``number``, rendering any missing earlier steps first (in order)."""
        image_id, idea_id, skill = tutorial.image_id, tutorial.idea_id, tutorial.skill
        name = step_name(idea_id, skill, number)
        final = number == len(tutorial.steps)

        async def build() -> StoredImage:
            original = await self._original(image_id, timings)
            references = [original]
            if number > 1:
                # Recursion walks back to the first missing step, so steps render in order.
                previous = await self._step(tutorial, number - 1, idea, timings=timings)
                references.insert(0, previous.read())
            with_after = final and idea is not None
            if with_after:
                after = await self._after(image_id, idea, timings=timings)
                references.append(after.read())
            return await self._render(
                kind="step",
                image_id=image_id,
                name=name,
                prompt=self.director.step(tutorial, number, idea=idea, with_after=with_after),
                references=references,
                aspect_ratio=closest_aspect_ratio(*image_size(original)),
                timings=timings,
                timing_key=f"render_step_{number}",
            )

        key = step_key(image_id, idea_id, skill, number)
        return await self._obtain(key, image_id, name, build, regenerate=regenerate)

    # ==================================================== cache and render
    async def _obtain(
        self,
        key: str,
        image_id: str,
        name: str,
        build: Callable[[], Awaitable[StoredImage]],
        *,
        regenerate: bool = False,
    ) -> Rendered:
        """Join the in-flight render of ``key``, else serve it from disk, else start rendering it."""
        if not regenerate and not self._flights.running(key):
            hit = self.store.read_generated(image_id, name)
            if hit is not None:
                return Rendered(hit, cached=True)
        return Rendered(await self._flights.run(key, build), cached=False)

    async def _render(
        self,
        *,
        kind: Kind,
        image_id: str,
        name: str,
        prompt: ImagePrompt,
        references: list[bytes],
        aspect_ratio: str,
        timings: Timings | None,
        timing_key: str,
    ) -> StoredImage:
        """One call to the image model, bounded by the semaphore, stored as JPEG."""
        self._check_quota()
        log.debug("image prompt kind=%s name=%s template=%s\n%s", kind, name, prompt.template, prompt.text)
        start = time.perf_counter()
        try:
            async with self._slots:
                generated = await self.gateway.image(
                    stage=f"image_{kind}", prompt=prompt.text, references=references, aspect_ratio=aspect_ratio
                )
            try:
                stored = await asyncio.to_thread(self.store.save_generated, image_id, name, generated.data)
            except (UnidentifiedImageError, OSError, ValueError) as exc:
                raise AiInvalidOutput(
                    "The image model returned a picture we couldn't read. Please try again.",
                    detail=f"{kind} {name}: {exc}",
                ) from exc
        except KanzError as exc:
            if isinstance(exc, AiQuotaExhausted):
                self._quota_blocked_until = time.monotonic() + QUOTA_COOLDOWN_S
            log.warning(
                "image kind=%s image=%s name=%s prompt=%s ms=%d ok=False code=%s detail=%s",
                kind,
                image_id,
                name,
                prompt.template,
                _ms(start),
                exc.code,
                (exc.detail or exc.message)[:200],
            )
            raise
        ms = _ms(start)
        if timings is not None:
            timings[timing_key] = ms
        log.info(
            "image kind=%s image=%s name=%s prompt=%s model=%s refs=%d aspect=%s size=%dx%d ms=%d ok=True",
            kind,
            image_id,
            name,
            prompt.template,
            generated.model,
            len(references),
            aspect_ratio,
            stored.width,
            stored.height,
            ms,
        )
        return stored

    def _check_quota(self) -> None:
        """Fail fast while an exhausted quota cools down, instead of spending another call on it."""
        remaining = self._quota_blocked_until - time.monotonic()
        if remaining > 0:
            log.info("image render skipped: quota cool-down, %d s left", int(remaining))
            raise AiQuotaExhausted(detail=f"image quota exhausted; skipping calls for another {int(remaining)} s")

    # ====================================================== step chain task
    async def _run_chain(self, tutorial: Tutorial, idea: UpcycleIdea | None) -> None:
        tutorial_id, total = tutorial.tutorial_id, len(tutorial.steps)
        if idea is None or idea.id != tutorial.idea_id:
            idea = self.load_idea(tutorial.image_id, tutorial.idea_id)
        start = time.perf_counter()
        number = 1
        try:
            for number in range(1, total + 1):
                await self._step(tutorial, number, idea)
        except KanzError as exc:
            log.warning(
                "step chain tutorial=%s stopped at step %d/%d after %d ms: %s (%s)",
                tutorial_id,
                number,
                total,
                _ms(start),
                exc.code,
                (exc.detail or exc.message)[:200],
            )
            return
        except Exception:
            log.exception("step chain tutorial=%s failed at step %d/%d", tutorial_id, number, total)
            return
        log.info("step chain tutorial=%s done steps=%d ms=%d", tutorial_id, total, _ms(start))

    def _chain_finished(self, tutorial_id: str, task: asyncio.Task[None]) -> None:
        if self._chains.get(tutorial_id) is task:
            del self._chains[tutorial_id]

    # ============================================================= helpers
    @staticmethod
    def _response(
        result: Rendered,
        *,
        kind: Kind,
        key: str,
        timings: Timings,
        step: int | None = None,
        skill: str | None = None,
    ) -> ImageResponse:
        img = result.image
        return ImageResponse(
            url=img.url,
            width=img.width,
            height=img.height,
            kind=kind,
            key=key,
            cached=result.cached,
            step=step,
            skill=skill,
            timings_ms=timings,
        )


def _ms(start: float) -> int:
    return int((time.perf_counter() - start) * 1000)


# ================================================================ module seam
_service: ImageService | None = None


def get_image_service() -> ImageService:
    """The process-wide service, built lazily from the shared gateway, stores and settings."""
    global _service
    if _service is None:
        _service = ImageService(
            gateway=get_gateway(), store=get_store(), tutorials=get_tutorial_store(), settings=get_settings()
        )
    return _service


def set_image_service(service: ImageService | None) -> None:
    """Swap the process-wide service (tests; ``None`` resets to lazy construction)."""
    global _service
    _service = service


async def after_image(req: AfterImageRequest) -> ImageResponse:
    return await get_image_service().after_image(req)


async def step_image(req: StepImageRequest) -> ImageResponse:
    return await get_image_service().step_image(req)


async def bin_image(req: BinImageRequest) -> ImageResponse:
    return await get_image_service().bin_image(req)


async def reference_image(image_id: str) -> ImageResponse:
    return await get_image_service().reference_image(image_id)


def start_step_chain(tutorial: Tutorial, idea: UpcycleIdea | None = None) -> None:
    """Fire-and-forget: start rendering ``tutorial``'s step images. Never raises."""
    try:
        get_image_service().start_step_chain(tutorial, idea)
    except Exception:
        log.exception("step chain tutorial=%s could not start", tutorial.tutorial_id)


async def shutdown() -> None:
    """Stop background work on server shutdown (call from the app lifespan)."""
    if _service is not None:
        await _service.aclose()
