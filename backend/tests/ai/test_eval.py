"""The eval script's scoring and report rendering (no live calls)."""

import dataclasses
import importlib.util
import json
import logging
import sys

from app.config import BACKEND_DIR, Settings
from app.schemas.analysis import AnalyzeResponse

from .conftest import fixture_json

# eval/ is a scripts folder, not a package: load run_eval.py by path.
_spec = importlib.util.spec_from_file_location("run_eval", BACKEND_DIR / "eval" / "run_eval.py")
run_eval = importlib.util.module_from_spec(_spec)
sys.modules["run_eval"] = run_eval  # dataclasses resolve their module through sys.modules
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


def test_model_log_records_only_the_model_that_answered():
    handler = run_eval.ModelLog()
    fmt = "gemini stage=%s model=%s attempt=%d ms=%d ok=%s"
    for args in [
        ("material_analyst@v2", "gemini-3.6-flash", 1, 300, False),
        ("material_analyst@v2", "gemini-3.5-flash", 1, 4100, True),
    ]:
        handler.emit(logging.LogRecord("kanz.gemini", logging.INFO, "", 0, fmt, args, None))
    assert handler.take() == ["material_analyst@v2: gemini-3.5-flash"]
    assert handler.take() == []


def test_resume_reruns_only_errored_photos_and_merges(tmp_path, monkeypatch):
    manifest = tmp_path / "manifest.json"
    manifest.write_text(
        json.dumps(
            [
                {"file": "a.jpg", "expected_category": "glass", "expected_hazard": False},
                {"file": "b.jpg", "expected_category": "metal", "expected_hazard": False},
            ]
        ),
        encoding="utf-8",
    )
    ok, failed = row("a.jpg", "glass", False), row("b.jpg", "metal", False, error="ai_unavailable: 503")
    ok.category_ok = ok.hazard_ok = ok.items_ok = True
    previous = tmp_path / "prev.json"
    previous.write_text(json.dumps({"rows": [dataclasses.asdict(ok), dataclasses.asdict(failed)]}), encoding="utf-8")

    async def fake_evaluate(entries, args):
        assert [e["file"] for e in entries] == ["b.jpg"]
        fixed = row("b.jpg", "metal", False, run=args.run_label)
        fixed.category_ok = fixed.hazard_ok = fixed.items_ok = True
        return [fixed], "128 documents"

    monkeypatch.setattr(run_eval, "evaluate", fake_evaluate)
    monkeypatch.setattr(run_eval, "get_settings", lambda: Settings(_env_file=None))
    args = run_eval.parse_args(["--manifest", str(manifest), "--resume", str(previous), "--out", str(tmp_path)])
    report = run_eval.main(args)

    assert report.name.endswith("_combined.md")
    rows = json.loads(report.with_suffix(".json").read_text(encoding="utf-8"))["rows"]
    assert [(r["file"], r["run"], r["passed"]) for r in rows] == [("a.jpg", "first", True), ("b.jpg", "rerun", True)]
