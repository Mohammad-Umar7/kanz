"""Gateway behaviour the AI pipeline relies on: a fallback model that rejects MINIMAL thinking still answers."""

from types import SimpleNamespace

from google.genai import errors as genai_errors
from pydantic import BaseModel

from app.ai.gemini import GeminiGateway
from app.config import Settings


class Answer(BaseModel):
    ok: bool


class ThinkingPickyClient:
    """Fake genai client: the primary is out of quota, the fallback rejects MINIMAL but accepts LOW."""

    def __init__(self) -> None:
        self.calls: list[tuple[str, str | None]] = []
        self.aio = SimpleNamespace(models=SimpleNamespace(generate_content=self.generate_content))

    async def generate_content(self, *, model, contents, config):
        level = config.thinking_config.thinking_level if config.thinking_config else None
        level = getattr(level, "value", level)
        self.calls.append((model, level))
        if model == "primary":
            raise genai_errors.APIError(
                429, {"error": {"message": "quota GenerateRequestsPerDayPerProjectPerModel-FreeTier limit: 0"}}
            )
        if level == "MINIMAL":
            raise genai_errors.APIError(
                400, {"error": {"message": "Thinking level MINIMAL is not supported for this model."}}
            )
        return SimpleNamespace(text='{"ok": true}')


async def test_rejected_thinking_level_is_retried_at_low_and_remembered():
    settings = Settings(_env_file=None, gemini_api_key="k", model_fallbacks=["fallback"], llm_retries=0)
    client = ThinkingPickyClient()
    gateway = GeminiGateway(settings, client=client)

    for _ in range(2):
        out = await gateway.structured(
            stage="t", system="s", contents=["x"], schema=Answer, model="primary", thinking_level="minimal"
        )
        assert out.ok

    assert client.calls == [
        ("primary", "MINIMAL"),
        ("fallback", "MINIMAL"),
        ("fallback", "LOW"),
        # The primary is cooling down after its quota error, and the fallback's LOW level is
        # remembered: the second call wastes no attempt at all.
        ("fallback", "LOW"),
    ]
