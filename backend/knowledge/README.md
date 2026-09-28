# Kanz knowledge base

The documents the Knowledge Retriever (RAG) grounds every recommendation in. Agents receive
retrieved documents with their ids and may only cite those ids, so each idea, recycling
instruction and disposal rule in the app can show the source it came from.

All content here is **original writing by the Kanz team**. Nothing is copied from websites,
books or other apps. Guidance for the UAE is kept general (bin labels vary by emirate,
retailers host battery and e-waste boxes, pharmacies take back medicines); no facility names,
addresses or statistics are invented. Place data comes only from the live facility search.

## Files

| File | Kind | Count | Owner |
| --- | --- | --- | --- |
| `projects/glass.json` ... `projects/wood.json` | `project` | 52 (8-9 per material) | AI Pipeline |
| `materials.json` | `material_guide` | 10 (one per material category) | AI Pipeline |
| `resin_codes.json` | `material_guide` | 7 (plastic resin codes 1-7) | AI Pipeline |
| `safety.json` | `safety` | 17 | AI Pipeline |
| `swaps.json` | `swap` | 30+ | Places & Swaps |

Each file is a JSON list. `app/ai/rag/documents.py` validates every document with Pydantic;
`tests/ai/test_knowledge.py` fails on an unknown tool id, a missing Arabic title, a duplicate
id or a project count below the minimum.

## Common fields (every document)

| Field | Type | Notes |
| --- | --- | --- |
| `id` | string | Lowercase snake case, prefixed by kind: `proj_`, `mat_`, `resin_`, `safety_`, `swap_` |
| `kind` | `project` \| `material_guide` \| `safety` \| `swap` | |
| `title` | string | English |
| `title_ar` | string | Modern Standard Arabic; used for source chips when `lang=ar` |
| `materials` | list of MaterialCategory | Ids from `contracts/vocab.json`; drives the `m_<material>` retrieval filters |

## `project`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | `proj_<material>_<slug>` | |
| `items` | list of strings | Household items it suits: "glass jar", "PET bottle" |
| `summary`, `summary_ar` | string | One-sentence pitch in each language |
| `result` | string | English description of the finished object; grounds the idea's `after_visual` |
| `difficulty` | `easy` \| `medium` \| `hard` | |
| `time_minutes` | int | Realistic active time |
| `tools` | list of ToolId | Tools only; protective gear goes in `safety` |
| `extra_materials` | list of strings | Things that are not tools: "tea light", "potting mix" |
| `steps_outline` | 4-8 strings | The method, in order |
| `safety` | list of strings | Gear and precautions |
| `techniques` | list of technique ids | `cutting`, `blade_cutting`, `sawing`, `drilling`, `sanding`, `painting`, `spray_painting`, `varnishing`, `gluing`, `hot_glue`, `sewing`, `knotting`, `weaving`, `wiring`, `hammering`, `planting`, `folding`, `candles`, `glass_work`, `sharp_metal`; used to pull the matching safety documents into tutorials |
| `tags` | list of strings | Free tags: "garden", "gift", "beginner" |

## `material_guide`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | `mat_<category>` or `resin_<n>_<name>` | |
| `identification` | list of strings | How to recognise the material |
| `cleaning_prep` | list of strings | How to prepare it for recycling |
| `recycling` | `{stream, accepted[], not_accepted[]}` | |
| `notes` | list of strings | Context, including general UAE guidance |
| `donation` | list of strings | When it can be donated or passed on (used by the Donation Advisor) |
| `resin_code`, `common_items`, `recyclability` | int, list, `yes`\|`conditional`\|`no` | Required for `resin_` documents |

## `safety`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | `safety_<topic>` | |
| `applies_to` | `{hazards[], materials[], techniques[]}` | HazardFlag, MaterialCategory and technique ids |
| `rules` | list of strings | What to do |
| `never` | list of strings | What never to do |
| `gear` | list of ToolId | Protective gear only: `gloves`, `safety_glasses`, `dust_mask` |

## `swap` (written by Places & Swaps)

`from_item`, `to_item`, `replaces_category`, `keywords`, `why`, `tip`, `effort`, `cost`
(`low`\|`medium`\|`high`), `impact_note`, `impact_source` (null unless a citable source backs a
number). The RAG loader validates the common fields strictly and accepts these loosely.

## How it is indexed

`seed_knowledge()` renders each document to compact text (`render_text`), embeds it with
`gemini-embedding-001` (task type `RETRIEVAL_DOCUMENT`, 768 dimensions) and upserts it into a
ChromaDB collection with metadata `kind` plus one boolean per material (`m_glass`, `m_metal`...).
A manifest hash makes seeding idempotent: unchanged documents are never re-embedded. If
embeddings are unavailable, retrieval falls back to BM25 over the same texts.
