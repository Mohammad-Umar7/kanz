"""The single gateway between Kanz and Google Gemini (official google-genai SDK).

Every agent node calls Gemini through ``GeminiGateway`` so that all LLM calls share
the same rules:

* **Structured output.** Calls pass a Pydantic model; its JSON Schema is sent as
  ``response_json_schema`` and the reply is validated with Pydantic.
* **One repair round.** If the JSON fails validation, or a node's own ``validator``
  reports problems (e.g. a safety rule was broken), the model gets its previous answer
  plus the list of problems and must return corrected JSON. A second failure raises
  ``AiInvalidOutput``.
* **Few-shot examples** are sent as prior user/model turns.
* **Resilience.** Per-call timeouts, exponential backoff with jitter on 429/5xx, then
  fallback models from config. Quota exhaustion ("limit: 0") skips straight to the
  next model.
* **Observability.** Every attempt logs stage, model, latency and outcome.
"""

from __future__ import annotations

import asyncio
import logging
import random
import time
from collections.abc import Callable, Sequence
from dataclasses import dataclass
from functools import lru_cache
from typing import Any, TypeVar

from google import genai
from google.genai import errors as genai_errors
from google.genai import types
from pydantic import BaseModel, ValidationError

from app.config import Settings, get_settings
from app.core.errors import AiInvalidOutput, AiQuotaExhausted, AiTimeout, AiUnavailable, KanzError

log = logging.getLogger("kanz.gemini")

T = TypeVar("T", bound=BaseModel)
# A validator returns human-readable problems; an empty list means the output is acceptable.
Validator = Callable[[Any], list[str]]

RETRYABLE_STATUS = {429, 500, 502, 503, 504}


@dataclass(frozen=True)
class FewShot:
    """One worked example: a user turn and the ideal JSON answer."""

    user: str
    answer: BaseModel | str

    def answer_json(self) -> str:
        return self.answer if isinstance(self.answer, str) else self.answer.model_dump_json(exclude_none=True)


@dataclass
class GeneratedImage:
    data: bytes
    mime_type: str
    model: str


class _AttemptError(Exception):
    """Internal: classifies one failed attempt."""

    def __init__(self, kind: str, detail: str) -> None:
        # kind: "retry" (transient), "quota" (skip model), "fatal" (skip model), "timeout"
        self.kind = kind
        self.detail = detail
        super().__init__(detail)


def _classify(exc: Exception) -> _AttemptError:
    if isinstance(exc, asyncio.TimeoutError | TimeoutError):
        return _AttemptError("timeout", "timed out")
    if isinstance(exc, genai_errors.APIError):
        code = getattr(exc, "code", None) or 0
        text = str(exc)
        if code == 429 and ("limit: 0" in text or "PerDay" in text):
            return _AttemptError("quota", text[:300])
        if code in RETRYABLE_STATUS:
            return _AttemptError("retry", text[:300])
        return _AttemptError("fatal", text[:300])
    name = type(exc).__name__.lower()
    if "timeout" in name:
        return _AttemptError("timeout", str(exc)[:300])
    if "connect" in name or "network" in name or "remoteprotocol" in name:
        return _AttemptError("retry", str(exc)[:300])
    return _AttemptError("fatal", f"{type(exc).__name__}: {str(exc)[:280]}")


def _validation_problems(err: ValidationError) -> list[str]:
    problems = []
    for e in err.errors()[:12]:
        loc = ".".join(str(p) for p in e.get("loc", ()))
        problems.append(f"{loc or '(root)'}: {e.get('msg')}")
    return problems


def llm_json_schema(schema: type[BaseModel]) -> dict[str, Any]:
    """JSON Schema for Gemini's ``response_json_schema`` (Pydantic's schema, $defs included)."""
    return schema.model_json_schema()


def sniff_mime(data: bytes) -> str:
    if data[:3] == b"\xff\xd8\xff":
        return "image/jpeg"
    if data[:8] == b"\x89PNG\r\n\x1a\n":
        return "image/png"
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp"
    return "image/jpeg"


class GeminiGateway:
    def __init__(self, settings: Settings | None = None, client: genai.Client | None = None) -> None:
        self.settings = settings or get_settings()
        self._client = client
        # Models that rejected the MINIMAL thinking level (e.g. an older model behind an alias):
        # they are called with LOW from then on instead of being skipped as a fallback.
        self._low_thinking_models: set[str] = set()

    # ------------------------------------------------------------------ client
    @property
    def client(self) -> genai.Client:
        if self._client is None:
            if not self.settings.ai_configured:
                raise AiUnavailable("AI is not configured on this server.", detail="GEMINI_API_KEY is empty")
            # The SDK's own retries are disabled: this class owns retry, fallback and timeouts.
            self._client = genai.Client(
                api_key=self.settings.gemini_api_key,
                http_options=types.HttpOptions(retry_options=types.HttpRetryOptions(attempts=1)),
            )
        return self._client

    def _models(self, primary: str) -> list[str]:
        seen: list[str] = []
        for m in [primary, *self.settings.model_fallbacks]:
            if m and m not in seen:
                seen.append(m)
        return seen

    # ------------------------------------------------------------ core loop
    async def _call_with_fallback(
        self,
        *,
        stage: str,
        models: Sequence[str],
        timeout: float,
        call: Callable[[str], Any],
    ) -> tuple[Any, str]:
        """Run ``call(model)`` with retries/backoff per model, then fall back to the next model."""
        last: _AttemptError | None = None
        saw_quota = saw_timeout = False
        for model in models:
            for attempt in range(self.settings.llm_retries + 1):
                start = time.perf_counter()
                try:
                    result = await asyncio.wait_for(call(model), timeout=timeout)
                    log.info(
                        "gemini stage=%s model=%s attempt=%d ms=%d ok=True",
                        stage,
                        model,
                        attempt + 1,
                        int((time.perf_counter() - start) * 1000),
                    )
                    return result, model
                except KanzError:
                    raise
                except Exception as exc:
                    last = _classify(exc)
                    log.warning(
                        "gemini stage=%s model=%s attempt=%d ms=%d ok=False kind=%s detail=%s",
                        stage,
                        model,
                        attempt + 1,
                        int((time.perf_counter() - start) * 1000),
                        last.kind,
                        last.detail[:160],
                    )
                    if last.kind == "quota":
                        saw_quota = True
                        break  # this model has no quota left; try the next one
                    if last.kind == "fatal":
                        break
                    if last.kind == "timeout":
                        saw_timeout = True
                        break  # a slow model will likely stay slow; fall back instead of waiting again
                    if attempt < self.settings.llm_retries:
                        await asyncio.sleep(min(8.0, 0.8 * (2**attempt)) + random.uniform(0, 0.4))
        detail = last.detail if last else "no models configured"
        if saw_quota and last is not None and last.kind == "quota":
            raise AiQuotaExhausted(detail=detail)
        if saw_timeout and last is not None and last.kind == "timeout":
            raise AiTimeout(detail=detail)
        raise AiUnavailable(detail=detail)

    # ------------------------------------------------------- structured JSON
    async def structured(
        self,
        *,
        stage: str,
        system: str,
        contents: Sequence[str | types.Part],
        schema: type[T],
        model: str | None = None,
        examples: Sequence[FewShot] = (),
        validator: Validator | None = None,
        temperature: float = 0.4,
        timeout: float | None = None,
        media_resolution: str | None = None,
        thinking_level: str | None = None,
    ) -> T:
        """Generate JSON matching ``schema``; validate; repair once; raise ``AiInvalidOutput`` if still bad."""
        primary = model or self.settings.model_text
        timeout = timeout or self.settings.timeout_text_s

        config_kwargs: dict[str, Any] = {
            "system_instruction": system,
            "response_mime_type": "application/json",
            "response_json_schema": llm_json_schema(schema),
            "temperature": temperature,
            "automatic_function_calling": types.AutomaticFunctionCallingConfig(disable=True),
        }
        level = thinking_level or self.settings.thinking_level
        if level:
            config_kwargs["thinking_config"] = types.ThinkingConfig(thinking_level=level.upper())
        if media_resolution:
            config_kwargs["media_resolution"] = f"MEDIA_RESOLUTION_{media_resolution.upper()}"
        config = types.GenerateContentConfig(**config_kwargs)

        turns: list[types.Content] = []
        for ex in examples:
            turns.append(types.Content(role="user", parts=[types.Part.from_text(text=ex.user)]))
            turns.append(types.Content(role="model", parts=[types.Part.from_text(text=ex.answer_json())]))
        user_parts = [types.Part.from_text(text=c) if isinstance(c, str) else c for c in contents]
        turns.append(types.Content(role="user", parts=user_parts))

        async def run(conversation: list[types.Content], tag: str) -> str:
            async def call(m: str) -> str:
                low = config.model_copy(update={"thinking_config": types.ThinkingConfig(thinking_level="LOW")})
                cfg = low if m in self._low_thinking_models and config.thinking_config else config
                try:
                    resp = await self.client.aio.models.generate_content(model=m, contents=conversation, config=cfg)
                except genai_errors.APIError as exc:
                    unsupported = getattr(exc, "code", None) == 400 and "thinking level" in str(exc).lower()
                    if not unsupported or cfg is low:
                        raise
                    self._low_thinking_models.add(m)
                    resp = await self.client.aio.models.generate_content(model=m, contents=conversation, config=low)
                return resp.text or ""

            text, _ = await self._call_with_fallback(
                stage=tag, models=self._models(primary), timeout=timeout, call=call
            )
            return text

        raw = await run(turns, stage)
        obj, problems = self._parse(raw, schema, validator)
        if obj is not None and not problems:
            return obj

        # Repair round: show the model its own answer and exactly what was wrong.
        log.info("gemini stage=%s repair problems=%s", stage, problems[:5])
        repair = list(turns)
        repair.append(types.Content(role="model", parts=[types.Part.from_text(text=raw or "{}")]))
        repair.append(
            types.Content(
                role="user",
                parts=[
                    types.Part.from_text(
                        text=(
                            "Your previous JSON cannot be used. Fix every problem below and return the full "
                            "corrected JSON only, matching the schema exactly.\nProblems:\n- "
                            + "\n- ".join(problems or ["The response was empty or not valid JSON."])
                        )
                    )
                ],
            )
        )
        raw2 = await run(repair, f"{stage}.repair")
        obj2, problems2 = self._parse(raw2, schema, validator)
        if obj2 is not None and not problems2:
            return obj2
        raise AiInvalidOutput(detail=f"{stage}: {'; '.join(problems2[:5])}")

    @staticmethod
    def _parse(raw: str, schema: type[T], validator: Validator | None) -> tuple[T | None, list[str]]:
        if not raw.strip():
            return None, ["The response was empty."]
        try:
            obj = schema.model_validate_json(raw)
        except ValidationError as err:
            return None, _validation_problems(err)
        problems = validator(obj) if validator else []
        return obj, problems

    # ------------------------------------------------------------- images
    async def image(
        self,
        *,
        stage: str,
        prompt: str,
        references: Sequence[bytes] = (),
        aspect_ratio: str | None = None,
        image_size: str | None = None,
        timeout: float | None = None,
    ) -> GeneratedImage:
        """Generate or edit an image. ``references`` are sent in order (first = the image to edit)."""
        s = self.settings
        parts: list[types.Part] = [types.Part.from_text(text=prompt)]
        parts += [types.Part.from_bytes(data=b, mime_type=sniff_mime(b)) for b in references]
        models = [m for m in (s.model_image, s.model_image_fallback) if m]

        async def call(m: str) -> GeneratedImage:
            size = image_size or s.image_size
            if "lite" in m:
                size = "1K"  # the lite image model only renders 1K
            config = types.GenerateContentConfig(
                response_modalities=["IMAGE"],
                automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
                image_config=types.ImageConfig(aspect_ratio=aspect_ratio or s.image_aspect_ratio, image_size=size),
            )
            resp = await self.client.aio.models.generate_content(
                model=m, contents=[types.Content(role="user", parts=parts)], config=config
            )
            for cand in resp.candidates or []:
                for part in (cand.content.parts if cand.content else None) or []:
                    if part.inline_data and part.inline_data.data:
                        return GeneratedImage(
                            data=part.inline_data.data,
                            mime_type=part.inline_data.mime_type or "image/png",
                            model=m,
                        )
            raise RuntimeError("no image in response")

        result, _ = await self._call_with_fallback(
            stage=stage, models=models, timeout=timeout or s.timeout_image_s, call=call
        )
        return result

    # --------------------------------------------------------- embeddings
    async def embed(self, texts: Sequence[str], *, task_type: str = "RETRIEVAL_DOCUMENT") -> list[list[float]]:
        """Embed texts (batched), L2-normalized so cosine distance behaves at reduced dimensions."""
        s = self.settings
        out: list[list[float]] = []
        for i in range(0, len(texts), 100):
            batch = list(texts[i : i + 100])

            async def call(m: str, batch: list[str] = batch) -> list[list[float]]:
                resp = await self.client.aio.models.embed_content(
                    model=m,
                    contents=batch,
                    config=types.EmbedContentConfig(task_type=task_type, output_dimensionality=s.embed_dim),
                )
                return [list(e.values or []) for e in resp.embeddings or []]

            vectors, _ = await self._call_with_fallback(
                stage="embed", models=[s.model_embed], timeout=s.timeout_embed_s, call=call
            )
            for v in vectors:
                norm = sum(x * x for x in v) ** 0.5 or 1.0
                out.append([x / norm for x in v])
        return out


@lru_cache
def get_gateway() -> GeminiGateway:
    return GeminiGateway()
