"""Evaluate the analyze (and optionally recommend) pipeline on the labelled eval photos.

Runs the real pipeline (live Gemini calls) on every photo in ``eval/manifest.json`` and
writes ``eval/reports/eval_<date>[_<tag>].md`` and ``.json`` with, per photo: expected vs
predicted category, whether hazards were flagged correctly, item count, top confidence,
whether the photo was judged usable, per-stage latency and any error; plus summary
accuracy and p50/p90 latency.

    cd backend
    .venv/Scripts/python eval/run_eval.py                                   # analyze all photos
    .venv/Scripts/python eval/run_eval.py --recommend glass_jar,aa_batteries,old_tshirt
    .venv/Scripts/python eval/run_eval.py --only aerosol_can,light_bulb --tag rerun
    .venv/Scripts/python eval/run_eval.py --resume eval/reports/eval_2026-09-28.json   # re-run errored photos

Free-tier keys have low per-minute limits, so calls are paced with ``--pause``.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import sys
import time
from dataclasses import asdict, dataclass, field
from datetime import date
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.ai import pipeline, rag
from app.ai.prompts import prompt_versions
from app.ai.safety import disposal_hazards
from app.config import get_settings
from app.core.errors import AiTimeout, AiUnavailable, KanzError
from app.schemas.analysis import AnalyzeResponse
from app.schemas.common import Profile
from app.schemas.recommend import RecommendRequest

EVAL_DIR = Path(__file__).resolve().parent
# The agents this eval exercises; other prompts in backend/prompts (swaps, images) are not run here.
EVAL_AGENTS = (
    "material_analyst",
    "upcycle_designer",
    "recycling_advisor",
    "donation_advisor",
    "disposal_advisor",
    "tutorial_writer",
)
# A typical beginner's kit, so tools_have / tools_missing are exercised.
EVAL_PROFILE_TOOLS = ["scissors", "twine", "pliers", "strong_glue", "acrylic_paint", "paintbrush", "masking_tape"]

log = logging.getLogger("kanz.eval")


class ModelLog(logging.Handler):
    """Collects which model answered each stage, and which branches used their deterministic fallback."""

    def __init__(self) -> None:
        super().__init__(logging.INFO)
        self.answers: list[str] = []

    def emit(self, record: logging.LogRecord) -> None:
        msg = record.getMessage()
        if record.name == "kanz.pipeline" and " failed, " in msg:
            self.answers.append(f"fallback: {msg.split(' failed, ', 1)[0]}")
        elif msg.startswith("gemini stage=") and "ok=True" in msg:
            fields = dict(part.split("=", 1) for part in msg.split()[1:] if "=" in part)
            self.answers.append(f"{fields.get('stage', '?')}: {fields.get('model', '?')}")

    def take(self) -> list[str]:
        out, self.answers = self.answers, []
        return out


@dataclass
class Row:
    file: str
    expected_category: str
    expected_hazard: bool
    expected_items_min: int
    expected_unclear: bool = False
    predicted_category: str | None = None
    categories: list[str] = field(default_factory=list)
    items: list[str] = field(default_factory=list)
    hazards: list[str] = field(default_factory=list)
    top_confidence: float | None = None
    usable: bool | None = None
    retake_tip: str | None = None
    category_ok: bool = False
    category_any_ok: bool = False
    hazard_ok: bool = False
    items_ok: bool = False
    timings_ms: dict[str, int] = field(default_factory=dict)
    models: list[str] = field(default_factory=list)
    run: str = "first"
    error: str | None = None
    recommend: dict[str, Any] | None = None

    @property
    def passed(self) -> bool:
        if self.error:
            return False
        if self.expected_unclear:
            return self.usable is False
        return self.category_ok and self.hazard_ok and self.items_ok


def score(row: Row, res: AnalyzeResponse) -> None:
    a = res.analysis
    primary = next((it for it in a.items if it.id == a.primary_item_id), a.items[0] if a.items else None)
    row.predicted_category = primary.category if primary else None
    row.categories = [it.category for it in a.items]
    row.items = [it.name for it in a.items]
    row.hazards = sorted({h for it in a.items for h in it.hazards})
    row.top_confidence = max((it.confidence for it in a.items), default=None)
    row.usable = a.photo.usable
    row.retake_tip = a.photo.retake_tip
    row.timings_ms = res.timings_ms
    flagged = any(disposal_hazards(it) for it in a.items)
    # A hazardous photo is judged on its most hazardous item, since the focus item is chosen
    # among the safe ones on purpose.
    row.category_ok = row.predicted_category == row.expected_category or (
        row.expected_hazard and row.expected_category in row.categories
    )
    row.category_any_ok = row.expected_category in row.categories
    row.hazard_ok = flagged == row.expected_hazard
    row.items_ok = len(a.items) >= row.expected_items_min


async def run_recommend(res: AnalyzeResponse, lang: str) -> dict[str, Any]:
    profile = Profile(skill="beginner", tools=EVAL_PROFILE_TOOLS, lang=lang)
    start = time.perf_counter()
    try:
        rec = await pipeline.recommend(RecommendRequest(image_id=res.image_id, analysis=res.analysis, profile=profile))
    except KanzError as exc:
        return {
            "error": f"{exc.code}: {exc.detail or exc.message}",
            "wall_ms": int((time.perf_counter() - start) * 1000),
        }
    return {
        "mode": rec.routing.mode,
        "ideas": [
            f"{i.title} ({i.difficulty}; sources: {', '.join(s.id for s in i.sources) or 'none'})" for i in rec.upcycle
        ],
        "recycle_streams": [i.stream for i in rec.recycle.instructions],
        "donate_available": rec.donate.available,
        "disposal": [f"{d.hazard}: {d.headline}" for d in rec.disposal],
        "facility_categories": [c.key for c in rec.facility_categories],
        "timings_ms": rec.timings_ms,
    }


def percentile(values: list[int], pct: float) -> int | None:
    if not values:
        return None
    ordered = sorted(values)
    rank = max(0, min(len(ordered) - 1, round(pct / 100 * (len(ordered) - 1))))
    return ordered[rank]


def summarize(rows: list[Row]) -> dict[str, Any]:
    labelled = [r for r in rows if not r.expected_unclear and not r.error]
    unclear = [r for r in rows if r.expected_unclear and not r.error]
    analysis_ms = [r.timings_ms.get("analysis", 0) for r in rows if not r.error]
    total_ms = [r.timings_ms.get("total", 0) for r in rows if not r.error]
    recs = [r.recommend for r in rows if r.recommend and "timings_ms" in r.recommend]

    def rate(ok: int, n: int) -> str:
        return f"{ok}/{n} ({100 * ok / n:.0f}%)" if n else "n/a"

    return {
        "photos": len(rows),
        "errors": sum(1 for r in rows if r.error),
        "passed": rate(sum(r.passed for r in rows), len(rows)),
        "category_accuracy": rate(sum(r.category_ok for r in labelled), len(labelled)),
        "category_any_item": rate(sum(r.category_any_ok for r in labelled), len(labelled)),
        "hazard_accuracy": rate(sum(r.hazard_ok for r in labelled), len(labelled)),
        "item_count_ok": rate(sum(r.items_ok for r in labelled), len(labelled)),
        "unclear_detected": rate(sum(r.usable is False for r in unclear), len(unclear)),
        "analysis_ms_p50": percentile(analysis_ms, 50),
        "analysis_ms_p90": percentile(analysis_ms, 90),
        "total_ms_p50": percentile(total_ms, 50),
        "total_ms_p90": percentile(total_ms, 90),
        "recommend_total_ms": [r["timings_ms"]["total"] for r in recs],
    }


def yes(flag: bool) -> str:
    return "yes" if flag else "**no**"


def markdown(rows: list[Row], summary: dict[str, Any], meta: dict[str, Any]) -> str:
    lines = [
        f"# Kanz eval: {meta['date']}{' (' + meta['tag'] + ')' if meta['tag'] else ''}",
        "",
        f"Models: vision `{meta['models']['vision']}`, text `{meta['models']['text']}`, embeddings "
        f"`{meta['models']['embed']}`. Prompts: {', '.join(f'{k} v{v}' for k, v in meta['prompts'].items())}. "
        f"Language: {meta['lang']}. Knowledge index: {meta['knowledge']}.",
        "",
        "## Summary",
        "",
        "| Metric | Value |",
        "| --- | --- |",
        *(f"| {k.replace('_', ' ')} | {v} |" for k, v in summary.items()),
        "",
        "Category accuracy uses the focus (primary) item; for hazardous photos the hazardous item counts, because",
        "the focus item is deliberately chosen among the safe ones. Hazard accuracy asks whether a disposal-only",
        "hazard was flagged exactly when one was expected.",
        "",
        "## Per photo",
        "",
        "| Photo | Expected | Predicted | Items | Hazards flagged | Category | Hazard | Top conf. | Usable | Analysis ms | Total ms | Model | Run |",
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for r in rows:
        if r.error:
            lines.append(f"| {r.file} | {r.expected_category} | error: {r.error[:120]} | | | | | | | | | | {r.run} |")
            continue
        exp = (
            r.expected_category
            + (" (unclear)" if r.expected_unclear else "")
            + (" + hazard" if r.expected_hazard else "")
        )
        lines.append(
            f"| {r.file} | {exp} | {r.predicted_category or '-'} | {'; '.join(r.items) or '-'} | "
            f"{', '.join(r.hazards) or '-'} | {yes(r.category_ok) if not r.expected_unclear else '-'} | "
            f"{yes(r.hazard_ok) if not r.expected_unclear else '-'} | {r.top_confidence if r.top_confidence is not None else '-'} | "
            f"{'yes' if r.usable else 'no'} | {r.timings_ms.get('analysis', '-')} | {r.timings_ms.get('total', '-')} | "
            f"{', '.join(m.split(': ', 1)[-1] for m in r.models) or '-'} | {r.run} |"
        )
    recs = [r for r in rows if r.recommend]
    if recs:
        lines += ["", "## Recommend", ""]
        for r in recs:
            rec = r.recommend or {}
            lines.append(f"### {r.file}")
            lines.append("")
            if "error" in rec:
                lines.append(f"Error: {rec['error']}")
            else:
                lines += [
                    f"- Mode: `{rec['mode']}`; donate available: {rec['donate_available']}",
                    f"- Ideas: {'; '.join(rec['ideas']) or 'none'}",
                    f"- Recycle streams: {'; '.join(rec['recycle_streams'])}",
                    f"- Disposal: {'; '.join(rec['disposal']) or 'none'}",
                    f"- Facility categories: {', '.join(rec['facility_categories']) or 'none'}",
                    f"- Timings (ms): {json.dumps(rec['timings_ms'])}",
                    f"- Models: {'; '.join(rec.get('models', [])) or '-'}",
                ]
            lines.append("")
    return "\n".join(lines).rstrip() + "\n"


async def analyze_with_retries(data: bytes, args: argparse.Namespace) -> AnalyzeResponse:
    """Transient overload (503) and time-outs are retried after a pause; other errors are final."""
    for attempt in range(args.retries + 1):
        try:
            return await pipeline.analyze(image=data, text=None, lang=args.lang)
        except (AiUnavailable, AiTimeout):
            if attempt == args.retries:
                raise
            log.info("AI busy, retrying in %.0f s", args.retry_wait)
            await asyncio.sleep(args.retry_wait)
    raise AssertionError("unreachable")


async def evaluate(entries: list[dict[str, Any]], args: argparse.Namespace) -> tuple[list[Row], str]:
    """Run the live pipeline on each photo, pacing calls for free-tier rate limits."""
    wanted_rec = set() if args.recommend is None else {s.strip() for s in args.recommend.split(",")}
    count = await rag.seed_knowledge()
    docs, ready = rag.status()
    knowledge = f"{docs} documents, {'vector (Chroma)' if ready else 'keyword fallback'}"
    log.info("seeded %d documents, vector=%s", count, ready)

    models = ModelLog()
    logging.getLogger("kanz.gemini").addHandler(models)
    logging.getLogger("kanz.pipeline").addHandler(models)
    rows: list[Row] = []
    for n, entry in enumerate(entries):
        row = Row(
            file=entry["file"],
            expected_category=entry["expected_category"],
            expected_hazard=bool(entry["expected_hazard"]),
            expected_items_min=int(entry.get("expected_items_min", 1)),
            expected_unclear=bool(entry.get("expected_unclear", False)),
            run=args.run_label,
        )
        rows.append(row)
        if n:
            await asyncio.sleep(args.pause)
        try:
            data = await asyncio.to_thread((Path(args.photos) / entry["file"]).read_bytes)
            res = await analyze_with_retries(data, args)
        except (KanzError, OSError) as exc:
            row.error = f"{getattr(exc, 'code', type(exc).__name__)}: {getattr(exc, 'detail', None) or exc}"
            models.take()
            log.warning("%s failed: %s", entry["file"], row.error)
            continue
        score(row, res)
        row.models = models.take()
        log.info("%s -> %s %s ok=%s %s", row.file, row.predicted_category, row.hazards, row.passed, row.timings_ms)
        if "all" in wanted_rec or Path(entry["file"]).stem in wanted_rec:
            await asyncio.sleep(args.pause)
            row.recommend = await run_recommend(res, args.lang)
            row.recommend["models"] = models.take()
            log.info("%s recommend -> %s", row.file, row.recommend.get("mode", row.recommend.get("error")))
    return rows, knowledge


def main(args: argparse.Namespace) -> Path:
    settings = get_settings()
    settings.step_images_autostart = False  # the eval measures text pipelines only
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    only = {s.strip() for s in args.only.split(",")} if args.only else None
    entries = [e for e in manifest if only is None or Path(e["file"]).stem in only][: args.limit]

    previous: list[Row] = []
    args.run_label = "first"
    if args.resume:
        # Keep the rows that succeeded; re-run the errored ones (or --only), then merge in manifest order.
        old = json.loads(Path(args.resume).read_text(encoding="utf-8"))["rows"]
        previous = [Row(**{k: v for k, v in r.items() if k != "passed"}) for r in old]
        redo = {r.file for r in previous if r.error or (only is not None and Path(r.file).stem in only)}
        entries = [e for e in manifest if e["file"] in redo]
        args.run_label = "rerun"
        args.tag = args.tag or "combined"

    rows, knowledge = asyncio.run(evaluate(entries, args))
    if previous:
        fresh = {r.file: r for r in rows}
        rows = [fresh.get(r.file, r) for r in previous]

    summary = summarize(rows)
    meta = {
        "date": date.today().isoformat(),
        "tag": args.tag,
        "lang": args.lang,
        "models": {"vision": settings.model_vision, "text": settings.model_text, "embed": settings.model_embed},
        "prompts": {name: v for name, v in prompt_versions().items() if name in EVAL_AGENTS},
        "knowledge": knowledge,
    }
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    stem = f"eval_{meta['date']}" + (f"_{args.tag}" if args.tag else "")
    payload = {"meta": meta, "summary": summary, "rows": [asdict(r) | {"passed": r.passed} for r in rows]}
    (out_dir / f"{stem}.json").write_text(
        json.dumps(payload, indent=1, ensure_ascii=False), encoding="utf-8", newline="\n"
    )
    report = out_dir / f"{stem}.md"
    report.write_text(markdown(rows, summary, meta), encoding="utf-8", newline="\n")
    return report


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("--photos", default=str(EVAL_DIR / "photos"), help="folder with the eval photos")
    p.add_argument("--manifest", default=str(EVAL_DIR / "manifest.json"), help="expected labels per photo")
    p.add_argument("--limit", type=int, default=None, help="evaluate at most this many photos")
    p.add_argument("--only", default=None, help="comma-separated photo names (without .jpg) to evaluate")
    p.add_argument(
        "--recommend", nargs="?", const="all", default=None, help="also run recommend: 'all' or comma-separated names"
    )
    p.add_argument("--lang", choices=["en", "ar"], default="en")
    p.add_argument("--pause", type=float, default=6.0, help="seconds between live calls (free-tier rate limits)")
    p.add_argument("--retries", type=int, default=2, help="retries per photo when the AI service is busy")
    p.add_argument("--retry-wait", type=float, default=20.0, help="seconds to wait before such a retry")
    p.add_argument("--resume", default=None, help="previous report .json: re-run only its errored photos and merge")
    p.add_argument("--tag", default="", help="suffix for the report name, e.g. 'rerun'")
    p.add_argument("--out", default=str(EVAL_DIR / "reports"), help="report folder")
    return p.parse_args(argv)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(name)s %(message)s")
    for noisy in ("httpx", "chromadb", "google_genai"):
        logging.getLogger(noisy).setLevel(logging.WARNING)
    print(f"report written to {main(parse_args())}")
