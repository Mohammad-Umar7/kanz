"""Gateway cooldowns: models out of quota, rate limited or overloaded are skipped for a while."""

from types import SimpleNamespace

import pytest
from google.genai import errors as genai_errors
from pydantic import BaseModel

from app.ai.gemini import GeminiGateway
from app.config import Settings
from app.core.errors import AiQuotaExhausted, AiUnavailable


class Answer(BaseModel):
    ok: bool


class ScriptedClient:
    """Fake genai client: each model answers with the next scripted outcome (an int status or 'ok')."""

    def __init__(self, script: dict[str, list]) -> None:
        self.script = script
        self.calls: list[str] = []
        self.aio = SimpleNamespace(models=SimpleNamespace(generate_content=self.generate_content))

    async def generate_content(self, *, model, contents, config):
        self.calls.append(model)
        outcome = self.script[model].pop(0) if len(self.script[model]) > 1 else self.script[model][0]
        if outcome == "ok":
            return SimpleNamespace(text='{"ok": true}')
        message = {
            429: "Quota exceeded. Please retry in 7.5s.",
            "daily": "quota GenerateRequestsPerDayPerProjectPerModel-FreeTier",
            503: "This model is currently experiencing high demand.",
        }[outcome]
        raise genai_errors.APIError(429 if outcome == "daily" else outcome, {"error": {"message": message}})


def gateway(client: ScriptedClient, fallbacks: list[str]) -> GeminiGateway:
    settings = Settings(_env_file=None, gemini_api_key="k", model_fallbacks=fallbacks, llm_retries=2)
    return GeminiGateway(settings, client=client)


async def ask(gw: GeminiGateway) -> Answer:
    return await gw.structured(stage="t", system="s", contents=["x"], schema=Answer, model="a")


async def test_per_minute_limit_moves_on_without_waiting_and_skips_the_model_next_time():
    client = ScriptedClient({"a": [429], "b": ["ok"]})
    gw = gateway(client, ["b"])
    assert (await ask(gw)).ok
    assert (await ask(gw)).ok
    assert client.calls == ["a", "b", "b"]


async def test_daily_quota_on_every_model_fails_fast_with_quota_error():
    client = ScriptedClient({"a": ["daily"], "b": ["daily"]})
    gw = gateway(client, ["b"])
    with pytest.raises(AiQuotaExhausted):
        await ask(gw)
    with pytest.raises(AiQuotaExhausted):
        await ask(gw)  # both models cooling down: no network call at all
    assert client.calls == ["a", "b"]


async def test_overloaded_model_gets_one_retry_then_is_parked(monkeypatch):
    monkeypatch.setattr("app.ai.gemini.asyncio.sleep", _no_sleep)
    client = ScriptedClient({"a": [503], "b": ["ok"]})
    gw = gateway(client, ["b"])
    assert (await ask(gw)).ok
    assert client.calls == ["a", "a", "b"]
    gw.reset_cooldowns()
    client.calls.clear()
    assert (await ask(gw)).ok
    assert client.calls[0] == "a"


async def test_all_models_overloaded_is_retryable_unavailable(monkeypatch):
    monkeypatch.setattr("app.ai.gemini.asyncio.sleep", _no_sleep)
    client = ScriptedClient({"a": [503], "b": [503]})
    gw = gateway(client, ["b"])
    with pytest.raises(AiUnavailable):
        await ask(gw)


async def _no_sleep(_seconds: float) -> None:
    return None
