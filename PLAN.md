# Kanz: build plan

Kanz (Arabic كنز, "treasure") is an AI recycling and upcycling advisor built for the 20th IEEE UAE Student Day SEP competition 2025-26. The user photographs something they would throw away; Kanz identifies the materials and their condition, recommends how to upcycle, recycle or donate it, writes a tutorial adapted to the user's tools and skill with generated step images, and points to nearby drop-off points.

This file is the lead's plan and the brief every workstream builds against. Contracts (schemas, API, vocabularies, routes, providers) change only through the lead.

## 1. Scoring and what it means for the build

| Criterion | Weight | Where it is earned |
| --- | --- | --- |
| Material recognition (camera/image) | 10% | Viewfinder, analysis with boxes, specimen cards (quality, quantity, state), multi-item, raw materials, unclear-photo retake |
| Display of recommendations | 15% | Results screen, idea cards with after images, before/after slider, tutorial pager |
| Recommendations and DIY tutorials | 10% | 3 paths, RAG-grounded ideas, tutorials adapted to skill/tools, step image chain, hazard routing |
| Local recycling center finder | 10% | "Drop-off near you" on results, Drop-off tab (map, list, filters, details) |
| Eco-friendly swaps | 5% | Swaps tab with chips, free text and history-based suggestions |
| Theoretical knowledge | 10% | docs/ARCHITECTURE.md: AI agents (LangGraph), multimodality, RAG, prompt engineering |
| User-friendly interface | 15% | Design system, signature moments, states, RTL, dark mode, accessibility |
| Additional features | 10% | Arabic, hands-free mode, impact dashboard, history/projects, share, themes |
| Poster and user manual | 10% | docs/POSTER_CONTENT.md, docs/USER_MANUAL.md |

The core flow must never break: photo -> analysis -> recommendations load automatically -> drop-off points appear without extra taps -> open an idea -> tutorial with step images.

## 2. Toolchain (checked in Phase 0)

| Tool | Version | Notes |
| --- | --- | --- |
| Flutter | 3.41.7 stable (Dart 3.11.5) | `flutter upgrade` refused: the SDK checkout has local changes. Packages pinned to versions compatible with this SDK (Riverpod 3.3, drift 2.34) |
| Android SDK | platforms 33-36, build-tools 35/36.1, NDK 28.2 | adb at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe` (not on PATH) |
| Emulator | AVD `Medium_Phone_API_36.1` (Google Play image), WHPX acceleration | Used for testing until the user's phone is connected |
| JDK | Microsoft OpenJDK 21 | |
| Python | 3.11.9, venv in `backend/.venv` | FastAPI 0.141, LangGraph 1.2, ChromaDB 1.5.9, google-genai 2.25 |
| Gemini key | works; free tier | Text/vision/embeddings OK. Image models have quota 0 on the free tier: billing must be enabled before image generation can be verified |
| Maps key | not yet provided | Places falls back to OpenStreetMap Overpass; the map view needs the Android Maps key |

## 3. Architecture

```
app/ (Flutter, Riverpod, go_router, dio, drift)          backend/ (FastAPI)
  Scan -> compress (1600 px, q85) --multipart-->  /v1/analyze    Material Analyst (Gemini vision, structured) + MaterialClassifier hook
  Results controller ---------------------------> /v1/recommend  LangGraph: Safety Router -> Knowledge Retriever (Chroma)
                                                                   -> Upcycle Designer || Recycling Advisor || Donation Advisor || Drop-off Locator
                     --------------------------> /v1/facilities Places API (New) -> Overpass fallback -> curated merge
                     --------------------------> /v1/images/*   Image Director -> Gemini image editing (after, step chain, bin)
  Tutorial controller --------------------------> /v1/tutorial   Retriever -> Tutorial Writer (image_prompt per step)
  Swaps --------------------------------------> /v1/swaps      Retriever -> Swap Advisor
```

AI rules for every LLM call: structured output (JSON Schema from Pydantic) with validation and one repair round; few-shot examples where they help; safety validators (never melt/burn plastic, never reuse chemical containers for food, protective gear for cutting/sanding/painting, no DIY on hazardous items); timeouts, backoff on 429/5xx, fallback models; per-stage latency logs. Targets: analysis < 6 s, ideas < 8 s, tutorial < 10 s; images never block text.

The shared Gemini gateway is `backend/app/ai/gemini.py` (`GeminiGateway.structured / image / embed`). All model ids are in `backend/app/config.py` and overridable from `.env`.

## 4. Contracts (lead-owned)

| Contract | Location |
| --- | --- |
| API shapes (Pydantic) | `backend/app/schemas/` |
| API spec | `docs/API.md` |
| JSON fixtures (valid by construction) | `contracts/fixtures/*.json`, built by `backend/scripts/make_fixtures.py` |
| Vocabularies (materials + colors, tools, state tags, hazards, facility types, cities, quality labels) | `contracts/vocab.json`; Python Literals in `backend/app/schemas/vocab.py`; app copy `app/assets/config/vocab.json` |
| Errors | `backend/app/core/errors.py` (codes in `ErrorCode`) |
| Storage | `backend/app/core/storage.py` (`ImageStore`), `backend/app/core/tutorials.py` (`TutorialStore`, `tutorial_id_for`) |
| Latency | `backend/app/core/timing.py` (`stage_timer`) |
| Dart models | `app/lib/core/data/models/` (App Core mirrors the Pydantic schemas exactly; tests parse every fixture) |
| App routes and providers | Section 6 below |

### Backend module seams (keep signatures; owners in section 5)

```python
# app/ai/pipeline.py                 (AI Pipeline)
async def analyze(*, image: bytes | None, text: str | None, lang: str) -> AnalyzeResponse
async def recommend(req: RecommendRequest) -> RecommendResponse
async def tutorial(req: TutorialRequest) -> TutorialResponse     # calls images.service.start_step_chain(tutorial)

# app/ai/rag/__init__.py             (AI Pipeline)
@dataclass class KnowledgeHit: id, kind, title, title_ar, text, metadata, score
async def retrieve(query, *, kinds, materials=None, k=6) -> list[KnowledgeHit]
def source_ref(hit, lang) -> SourceRef
async def seed_knowledge() -> int        # idempotent, at startup; falls back to keyword search if embeddings fail
def status() -> tuple[int, bool]

# app/ai/classifier.py               (AI Pipeline)  MaterialClassifier protocol + NoOpClassifier

# app/images/service.py              (Image Generation)
async def after_image(req: AfterImageRequest) -> ImageResponse
async def step_image(req: StepImageRequest) -> ImageResponse
async def bin_image(req: BinImageRequest) -> ImageResponse
def start_step_chain(tutorial: Tutorial) -> None

# app/places/categories.py           (Places & Swaps)
def catalog(lang) -> list[FacilityCategory]
def categories_for_items(items: list[Item], lang) -> list[FacilityCategory]

# app/places/service.py              (Places & Swaps)
async def search(req: FacilitiesRequest) -> FacilitiesResponse

# app/swaps/service.py               (Places & Swaps)
async def suggest(req: SwapsRequest) -> SwapsResponse
```

## 5. Workstreams and ownership

Each workstream owns its directories; nobody edits another's files. Everyone commits small, logical commits through the shared commit helper (never `git add .`).

| # | Workstream | Phase | Owns |
| --- | --- | --- | --- |
| 1 | Backend & API | 1 | `backend/app/main.py`, `backend/app/api/`, `backend/app/core/` (except errors/timing/storage/tutorials contracts, which it may extend compatibly), `backend/tests/api/`, `backend/README` section, `backend/Dockerfile`, `backend/run.ps1` |
| 2 | AI Pipeline | 1 | `backend/app/ai/` (except `gemini.py` interface), `backend/prompts/` (agent prompts), `backend/knowledge/` (except `swaps.json`), `backend/eval/`, `backend/tests/ai/` |
| 3 | Image Generation | 1 | `backend/app/images/`, `backend/prompts/image_*.md`, `backend/tests/images/` |
| 4 | Places & Swaps | 1 | `backend/app/places/`, `backend/app/swaps/`, `backend/config/`, `backend/knowledge/swaps.json`, `backend/prompts/swap_advisor.md`, `backend/tests/places/`, `backend/tests/swaps/` |
| 5 | Design System | 1 | `DESIGN.md`, `app/lib/core/design/`, `app/lib/features/gallery/`, `app/test/design/`, `app/test/screenshots/` harness, `app/assets/brand/`, `app/assets/map_styles/`, launcher icon + splash config files |
| 6 | App Core | 1 | `app/lib/main.dart`, `app/lib/app/`, `app/lib/core/{config,network,data,services,state}/`, `app/lib/l10n/`, `app/tool/`, `app/assets/config/`, `app/test/core/`, Android/iOS platform config |
| 7a-d | Screens | 2 | `app/lib/features/<feature>/` split across four agents (see section 6) |
| 8 | QA & Integration | 3 | `qa/`, fixes anywhere with a note in the commit |
| 9 | UI Critic | 3 | `qa/ui-review/`, drives Screens fixes |
| 10 | Docs | 4 | `README.md`, `docs/` (except `API.md`), `LICENSES.md` |

## 6. App architecture (contract for Screens)

- `lib/core/design/`: tokens, `KanzTheme.light()/dark()`, typography, motion, and components. Screens use only these components and tokens (no raw colors, font sizes or durations).
- `lib/core/state/`: Riverpod providers and controllers. Screens read state and call controller methods; they never call dio or drift directly. App Core documents the API in `app/lib/core/README.md`.
- Localization: per-feature ARB fragments in `lib/l10n/src/<feature>_{en,ar}.arb`, merged by `dart run tool/merge_arb.dart` into `lib/l10n/app_{en,ar}.arb`, then `flutter gen-l10n`. Keys are prefixed with the feature name.

Routes (go_router):

| Path | Screen | Owner |
| --- | --- | --- |
| `/onboarding` | Onboarding (language, skill, tools; skippable) | Screens A |
| `/` `/dropoff` `/swaps` `/impact` | Shell tabs: Home, Drop-off, Swaps, Impact (bottom nav + scan action) | A (shell, Home), D (Drop-off, Swaps, Impact) |
| `/history` | History and My Projects | A |
| `/settings` | Settings (language, theme, skill, tools, location mode, backend URL + status) | A |
| `/permissions/location`, `/permissions/camera`, `/city` | Rationale screens, city picker | A |
| `/scan` (`?mode=camera|gallery|text`) | Viewfinder, gallery, describe-in-text | B |
| `/results/:scanId` | Results | B |
| `/results/:scanId/idea/:ideaId` | Idea detail | B |
| `/results/:scanId/idea/:ideaId/tutorial` | Tutorial pager, hands-free | C |
| `/projects/:projectId/done` | Completion | C |
| `/gallery` | Component gallery (debug builds only) | Design System |

Build config through `--dart-define`: `KANZ_API_BASE` (default `http://10.0.2.2:8000`), `KANZ_MAPS` (`1` when the Android Maps key is configured). The backend URL can also be changed at runtime in Settings.

## 7. Phases

| Phase | Work | Exit criteria |
| --- | --- | --- |
| 0 (lead) | Toolchain, repo, contracts, fixtures, gateway, scaffolds, this plan | Committed and pushed |
| 1 (parallel) | Backend & API, AI Pipeline, Image Generation, Places & Swaps, Design System, App Core | Each: tests + lint green, own DoD met. Lead: backend runs end to end with real Gemini calls on real photos |
| 2 (parallel) | Screens A-D wired to the real API | `flutter analyze` clean, screenshot tests render every screen (light/dark, EN/AR) |
| 3 | QA & Integration on the emulator (then the phone), UI Critic (2+ rounds) | Acceptance checklist passes, no high-severity UI issues |
| 4 | Docs, release APK, final report | README, ARCHITECTURE, USER_MANUAL, POSTER_CONTENT, DEMO_SCRIPT |

## 8. Acceptance checklist

1. Fresh install -> onboarding -> Home.
2. Glass jar photo: boxes and specimen card (material, quality, quantity, state), then 3 ideas with after images, Recycle and Donate paths, Drop-off near you with real places.
3. Idea -> before/after slider -> tutorial. Switch to Beginner and remove a tool: the tutorial adapts. Step images arrive in order and show the same jar progressing.
4. Finish all steps: completion screen, impact updates, share works.
5. Battery photo: disposal-only path with hazardous drop-off points, no DIY.
6. Old t-shirt photo: Donate and Upcycle paths, donation points listed.
7. Gallery upload and text description both work.
8. Swaps: "plastic bags, cling film" gives sensible swap cards.
9. Arabic: full RTL, AI content in Arabic, no overflow.
10. Dark mode correct on every screen.
11. Airplane mode: graceful errors, history still opens.
12. Location denied: city picker fallback works.
13. Release APK builds and installs; no crashes in the whole run.

## 9. Cut order (only if forced)

Voice mode, then streak, then share. Never the four required features, the core flow or image generation.

## 10. Status

- [x] Phase 0: toolchain, repo, contracts, fixtures, gateway, scaffolds
- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3
- [ ] Phase 4
