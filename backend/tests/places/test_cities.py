"""The backend's city list is an exact copy of the shared contract."""

import json

from app.config import get_settings
from app.places.service import CITIES_FILE
from app.schemas.vocab import CITY_IDS
from tests.conftest import CONTRACTS_DIR


def test_city_centers_match_contracts_vocab():
    backend = json.loads((get_settings().config_dir / CITIES_FILE).read_text(encoding="utf-8"))["cities"]
    contract = json.loads((CONTRACTS_DIR / "vocab.json").read_text(encoding="utf-8"))["cities"]
    assert backend == contract
    assert [c["id"] for c in backend] == list(CITY_IDS)
