# Kanz AI eval

Measures how well the live pipeline recognises real household items, flags hazards and asks
for a retake when a photo is unusable, and how long each stage takes.

## What it runs

`run_eval.py` sends every photo listed in `manifest.json` through `app.ai.pipeline.analyze`
(the same code path as `POST /v1/analyze`), and optionally `recommend`, with real Gemini calls.

Per photo it records the expected and predicted category, the items found, the hazards
flagged, the top confidence, whether the photo was judged usable, per-stage latency, the model
that actually answered (the gateway may fall back), and any error. The summary gives:

| Metric | Meaning |
| --- | --- |
| category accuracy | the focus item's category matches the label (for hazardous photos, the hazardous item counts) |
| category any item | the labelled category appears among the detected items |
| hazard accuracy | a disposal-only hazard is flagged exactly when one is expected |
| item count ok | at least `expected_items_min` items were found |
| unclear detected | the deliberately blurred photo is reported as unusable with a retake tip |
| p50 / p90 latency | analysis stage and total request time |

## Running it

```
cd backend
.venv/Scripts/python eval/run_eval.py                                     # analyze all photos
.venv/Scripts/python eval/run_eval.py --recommend glass_jar,aa_batteries,old_tshirt
.venv/Scripts/python eval/run_eval.py --only aerosol_can,light_bulb --tag rerun
```

Options: `--limit N`, `--lang ar`, `--pause S` (seconds between live calls; free-tier keys have
small per-minute and per-day limits), `--resume REPORT.json` (re-run only the photos that
errored in that report and merge the results), `--tag NAME`, `--out DIR`.

Reports are written to `reports/eval_<date>[_<tag>].md` (readable) and `.json` (raw rows).
The photos themselves are not committed; see `photos/README.md` and `photos/CREDITS.md`.
