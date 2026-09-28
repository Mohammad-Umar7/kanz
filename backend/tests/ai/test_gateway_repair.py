"""The gateway's repair round with a two-tier validator: soft rules never fail the last attempt."""

from types import SimpleNamespace

import pytest
from pydantic import BaseModel, Field

from app.ai.gemini import GeminiGateway
from app.ai.safety import TwoTierValidator
from app.config import Settings
from app.core.errors import AiInvalidOutput


class Steps(BaseModel):
    steps: list[str] = Field(min_length=5)


class ScriptedClient:
    """Fake genai client that returns the scripted texts in order."""

    def __init__(self, *texts: str) -> None:
        self.texts = list(texts)
        self.prompts: list[str] = []
        self.aio = SimpleNamespace(models=SimpleNamespace(generate_content=self.generate_content))

    async def generate_content(self, *, model, contents, config):
        self.prompts.append(contents[-1].parts[0].text)
        return SimpleNamespace(text=self.texts.pop(0))


def gateway(client: ScriptedClient) -> GeminiGateway:
    return GeminiGateway(Settings(_env_file=None, gemini_api_key="k", model_fallbacks=[], llm_retries=0), client=client)


FOUR = '{"steps": ["a", "b", "c", "d"]}'
FIVE = '{"steps": ["a", "b", "c", "d", "e"]}'


async def test_soft_rules_do_not_fail_a_repair_after_invalid_json():
    # Too few steps (schema error) first; the repair is fine except for a soft rule.
    client = ScriptedClient(FOUR, FIVE)
    validator = TwoTierValidator(hard=lambda _: [], soft=lambda _: ["name the gloves"])
    out = await gateway(client).structured(stage="t", system="s", contents=["x"], schema=Steps, validator=validator)
    assert len(out.steps) == 5
    assert "steps" in client.prompts[-1]  # the model was told what was wrong


async def test_soft_problems_are_sent_in_the_repair_round():
    client = ScriptedClient(FIVE, FIVE)
    validator = TwoTierValidator(hard=lambda _: [], soft=lambda _: ["name the gloves"])
    await gateway(client).structured(stage="t", system="s", contents=["x"], schema=Steps, validator=validator)
    assert "name the gloves" in client.prompts[-1]


async def test_hard_rules_still_fail_the_repair_round():
    client = ScriptedClient(FOUR, FIVE)
    validator = TwoTierValidator(hard=lambda _: ["heats plastic"])
    with pytest.raises(AiInvalidOutput):
        await gateway(client).structured(stage="t", system="s", contents=["x"], schema=Steps, validator=validator)
