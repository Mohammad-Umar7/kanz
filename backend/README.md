# Kanz backend

FastAPI service behind the Kanz app. It holds every API key; the phone only talks to this server.

- **Recognition**: Gemini vision with structured output identifies each item's material, quantity, quality, state, recyclability, hazards and bounding box.
- **Recommendations and tutorials**: a LangGraph agent graph (Safety Router, Knowledge Retriever over ChromaDB, Upcycle Designer, Recycling and Donation Advisors, Tutorial Writer).
- **Images**: Gemini image editing turns the user's own photo into the finished project and into each tutorial step.
- **Drop-off points**: Google Places API (New), with OpenStreetMap Overpass as the fallback, plus a team-verified list.

The HTTP contract is in [`docs/API.md`](../docs/API.md); request and response shapes live in `app/schemas/`.

## Layout

| Path | What it holds |
| --- | --- |
| `app/main.py` | `create_app()`: middleware, error handlers, routers, static files, startup |
| `app/api/` | Thin routers: validate, call one module seam, return the response model |
| `app/core/` | Errors and their handlers, logging, request ids, rate limit, uploads, storage, timing |
| `app/ai/` | Gemini gateway, LangGraph pipeline and agent nodes, RAG |
| `app/images/` | After, step-chain and bin image generation |
| `app/places/`, `app/swaps/` | Drop-off search and eco swaps |
| `app/schemas/` | The API contract (Pydantic) |
| `prompts/`, `knowledge/`, `config/` | Agent prompts, RAG documents, facility categories and curated places |
| `tests/` | Unit tests (default) and live tests (`-m live`) |
| `eval/` | Recognition eval on real photos |

## Setup

Requires Python 3.11.

```powershell
cd backend
py -3.11 -m venv .venv
.venv\Scripts\python -m pip install -r requirements-dev.txt   # runtime + test tools
copy .env.example .env                                         # then edit .env
```

On macOS or Linux: `python3.11 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt && cp .env.example .env`.

Keys in `.env` (never commit it):

| Variable | Needed for | Notes |
| --- | --- | --- |
| `GEMINI_API_KEY` | Recognition, ideas, tutorials, swaps, images | From [Google AI Studio](https://aistudio.google.com/apikey). Without it `/health` reports `degraded` and AI routes return `503 ai_unavailable` |
| `GOOGLE_MAPS_API_KEY` | Google Places results | Optional. Without it drop-off points come from OpenStreetMap |

**Image generation needs billing.** On a free-tier key the image models have a quota of zero, so `/v1/images/*` answers `503 ai_quota_exhausted` (not retryable). Enable billing on the Google Cloud project behind the key (Tier 1) and restart; text, vision and embeddings work on the free tier.

Every other setting (model ids, timeouts, rate limit, upload size) has a default in `app/config.py` and can be overridden in `.env`; `.env.example` lists the common ones.

## Run locally

```powershell
./run.ps1            # Windows PowerShell; -Reload to restart on code changes, -Port 8100 for another port
bash run.sh          # macOS, Linux or Git Bash; --reload, PORT=8100
```

Both scripts create `.venv` on first run, reinstall `requirements.txt` when it changes, create `.env` from the example if missing, and print the URLs to use. Or run uvicorn yourself:

```powershell
.venv\Scripts\python -m uvicorn app.main:app --reload --port 8000
```

Open <http://127.0.0.1:8000/docs> for the interactive API. On startup the knowledge base is indexed in the background (existing documents are skipped); until it finishes, `/health` shows `rag_ready: false` and the API still serves requests.

### From a phone on the same Wi-Fi

1. Start the server with `run.ps1` or `run.sh`. It listens on all interfaces and prints lines such as `Phone on same Wi-Fi  http://192.168.0.144:8000`.
2. In the app, open **Settings > Backend** and enter that URL (or build with `--dart-define=KANZ_API_BASE=http://192.168.0.144:8000`). The Android emulator uses `http://10.0.2.2:8000`, the app's default.
3. If the phone can't connect, allow inbound connections on the port. On Windows, in an administrator PowerShell:

   ```powershell
   New-NetFirewallRule -DisplayName "Kanz API" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow -Profile Private
   ```

Plain HTTP is allowed only in debug builds of the app; a release APK needs the HTTPS deployment below.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/health` | Warm-up and configuration status |
| POST | `/v1/analyze` | Photo and/or text (multipart) to material analysis |
| POST | `/v1/recommend` | Safety routing, 3 upcycle ideas, recycle, donate, drop-off categories |
| POST | `/v1/tutorial` | Tutorial adapted to skill and tools |
| POST | `/v1/images/after` · `/step` · `/bin` | Generated images, returned as `/static/generated/...` URLs |
| POST | `/v1/facilities` | Drop-off points near a location or city |
| GET | `/v1/facilities/categories` | Category catalog for the Drop-off filters |
| POST | `/v1/swaps` | Eco-friendly swaps |
| GET | `/static/uploads/...`, `/static/generated/...` | Stored photos and generated images |

Full request and response details: [`docs/API.md`](../docs/API.md). Example bodies for every endpoint: `contracts/fixtures/`.

### Errors, request ids and logs

- Every non-2xx response is an `ErrorResponse`: `{"error": {"code", "message", "retryable", "request_id"}}`. Codes and statuses are listed in `docs/API.md`; validation errors are `422 bad_request` with a message naming the field (`'profile.skill' is invalid: ...`).
- Every response carries `X-Request-ID`. The app may send its own (6-64 characters of `A-Z a-z 0-9 _ -`); otherwise the server makes one such as `req_5f3c2a1b`.
- Logs are one `key=value` line per event, each with the request id, so an error on the phone can be found in the log:

  ```text
  ts=2026-09-28T10:15:02.114Z level=info logger=kanz.timing request_id=req_5f3c2a1b stage=analysis ms=4120 ok=True
  ts=2026-09-28T10:15:02.120Z level=info logger=kanz.access request_id=req_5f3c2a1b method=POST path=/v1/analyze status=200 ms=4133
  ```

- `/v1/*` is rate limited per client IP (`RATE_LIMIT_PER_MINUTE`, default 90, sliding 60-second window); over the limit the answer is `429 rate_limited` with `Retry-After`. Uploads over `MAX_UPLOAD_MB` (default 10) get `413 image_too_large` before the body is read.

## Tests and lint

```powershell
.venv\Scripts\python -m pytest              # unit tests; no network, no keys, temporary data folders
.venv\Scripts\python -m pytest -m live      # live tests against Gemini, Places and Overpass (spend quota)
.venv\Scripts\ruff check .
.venv\Scripts\ruff format --check .
```

- `tests/api/` exercises the HTTP layer with every module seam replaced by a stub that returns the contract fixtures.
- `tests/test_contracts.py` fails if `app/schemas/vocab.py`, `contracts/vocab.json`, the app's copy of it (`app/assets/config/vocab.json`) or any fixture in `contracts/fixtures/` drift apart.

**Evaluation.** `eval/run_eval.py` (maintained with the AI pipeline) runs recognition on the real photos listed in `eval/manifest.json`; see its docstring for options. It makes live Gemini calls, so it spends quota.

## Deploy

The image in `Dockerfile` runs as a non-root user and serves on `$PORT` (default 8000):

```bash
docker build -t kanz-api backend
docker run -p 8000:8000 --env-file backend/.env -v kanz-data:/srv/kanz/data kanz-api
```

In production:

- **HTTPS only.** Run behind a managed certificate, for example Google Cloud Run, Render or Fly.io, and point the app at the `https://` URL. Set `PUBLIC_BASE_URL` if image URLs should be absolute.
- **One worker, one instance.** The rate limiter, the image and tutorial caches and the background image chain live in process memory, so run a single uvicorn worker (the image's default). Scale up the machine rather than out.
- **Persistent data.** Mount a volume at `/srv/kanz/data` so uploads, generated images, tutorials and the Chroma index survive restarts.
- **Secrets** go into the platform's secret store as environment variables (`GEMINI_API_KEY`, `GOOGLE_MAPS_API_KEY`), never into the image.
- Uvicorn runs with `--proxy-headers`, so the rate limit sees each phone's IP rather than the proxy's.
