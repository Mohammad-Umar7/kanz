"""The eval script's scoring and report rendering (no live calls)."""

import importlib.util

from app.config import BACKEND_DIR
from app.schemas.analysis import AnalyzeResponse

from .conftest import fixture_json

# eval/ is a scripts folder, not a package: load run_eval.py by path.
_spec = importlib.util.spec_from_file_location("run_eval", BACKEND_DIR / "eval" / "run_eval.py")
run_eval = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(run_eval)


def row(file: str, category: str, hazard: bool, **kw) -> run_eval.Row:
    return run_eval.Row(file=file, expected_category=category, expected_hazard=hazard, expected_items_min=1, **kw)


def test_glass_jar_is_scored_correct():
    r = row("glass_jar.jpg", "glass", False)
    run_eval.score(r, AnalyzeResponse.model_validate(fixture_json("analyze_glass_jar.json")))
    assert r.passed and r.predicted_category == "glass" and r.items_ok


def test_battery_photo_counts_the_hazardous_item():
    r = row("aa_batteries.jpg", "hazardous", True)
    run_eval.score(r, AnalyzeResponse.model_validate(fixture_json("analyze_battery.json")))
    assert r.hazard_ok and r.category_ok and r.passed


def test_unclear_photo_passes_only_when_flagged_unusable():
    r = row("unclear_blurry.jpg", "glass", False, expected_unclear=True)
    run_eval.score(r, AnalyzeResponse.model_validate(fixture_json("analyze_unclear.json")))
    assert r.passed
    r2 = row("unclear_blurry.jpg", "glass", False, expected_unclear=True)
    run_eval.score(r2, AnalyzeResponse.model_validate(fixture_json("analyze_glass_jar.json")))
    assert not r2.passed


def test_summary_and_markdown():
    ok = row("glass_jar.jpg", "glass", False)
    run_eval.score(ok, AnalyzeResponse.model_validate(fixture_json("analyze_glass_jar.json")))
    failed = row("tin_can.jpg", "metal", False, error="ai_unavailable: busy")
    summary = run_eval.summarize([ok, failed])
    assert summary["errors"] == 1 and summary["category_accuracy"] == "1/1 (100%)"
    assert summary["analysis_ms_p50"] == 4180
    meta = {
        "date": "2026-09-28",
        "tag": "",
        "lang": "en",
        "models": {"vision": "v", "text": "t", "embed": "e"},
        "prompts": {"material_analyst": "2"},
        "knowledge": "128 documents",
    }
    text = run_eval.markdown([ok, failed], summary, meta)
    assert "| glass_jar.jpg | glass | glass |" in text and "error: ai_unavailable" in text


def test_percentiles():
    assert run_eval.percentile([], 50) is None
    assert run_eval.percentile([100, 200, 300, 400, 500], 50) == 300
    assert run_eval.percentile([100, 200, 300, 400, 500], 90) == 500
