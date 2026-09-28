# Kanz acceptance run (Phase 3, round 1)

Run on 29 September 2026 by QA & Integration against PLAN.md section 8.

| | |
| --- | --- |
| Device | Android emulator `emulator-5554` (AVD Medium_Phone_API_36.1, 1080 x 2400, 420 dpi) |
| App | debug APK (`flutter build apk --debug --target-platform android-x64`), then release APK (`flutter build apk --release`, 68.5 MB) |
| Backend | `uvicorn app.main:app` on the host, reached at `http://10.0.2.2:8000`; models gemini-3.6-flash (vision, text), gemini-3.1-flash-image, gemini-embedding-001; 128 knowledge docs; Places from OpenStreetMap only |
| Test photos | `backend/eval/photos/{glass_jar,aa_batteries,old_tshirt,wooden_crate}.jpg` pushed to the gallery; one camera shot of the emulator's virtual scene |
| Live budget | 6 analyses used (jar, batteries, t-shirt, text, Arabic crates, camera); every other check reopened scans from History |

Screenshots are in [`qa/screens/`](screens/) (540 px wide).

## Results

| # | Check | Status | Evidence | Notes |
| --- | --- | --- | --- | --- |
| 1 | Fresh install, onboarding, Home | pass | `01_home_after_onboarding.png` | Four steps (welcome, language, skill, tools); Skip works; lands on Home. |
| 2 | Glass jar: boxes, specimen card, ideas, recycle and donate, drop-off near you | pass with limits | `02a_jar_boxes_pipeline.png`, `02b_jar_specimen_card.png`, `02c_jar_ideas_images_paused.png`, `02d_jar_dropoff_near_you.png` | Box with label and confidence; card shows material, type, quantity, quality bar, recyclability, state tags. 3 ideas, Recycle 1, Donate 1, sources listed. After images fail on the free key and every card says "Image generation paused" over the photo. Drop-off needed two retries (Overpass 504), then 20 real OpenStreetMap points, labelled "Around Abu Dhabi, since your location was approximate" (emulator GPS fix was stale). |
| 3 | Idea, before/after, tutorial; Beginner without a tool adapts; step images in order | pass with limits | `03a_tutorial_adapted_beginner_no_glue.png` | Idea screen shows the photo as "Before" with an honest note (no after image). Tutorial in 6.0 s. Adapt sheet: Beginner, hot glue gun removed, rewritten in 7.8 s: "Adapted for Beginner: used a secure knotting method instead of a hot glue gun", tools list shows the glue gun as missing with "Use extra knots and masking tape". Step images: the chain requests step 1 only and stops on `ai_quota_exhausted` (one failed call, no retry storm); every step shows the photo with "Image generation is paused on this server". Image order and continuity cannot be verified without image quota. |
| 4 | Finish all steps: completion, impact updates, share | pass | `04a_completion.png`, `04b_share_sheet.png`, `04c_impact_updated.png` | Completion shows the original photo with a note, steps 5 of 5, 1 item kept out of the bin. Impact: 1 item, 1 project, 1-day streak, Glass 1, Upcycled 1, 0.3 kg with the estimate disclaimer. The Android share sheet opens with a share card image and caption (not sent). |
| 5 | Batteries: disposal only, no DIY, hazardous drop-off | pass | `05a_battery_disposal_only.png`, `05b_battery_hazardous_dropoff.png` | Hazardous box and "Battery: safe disposal only, no DIY". Tabs Dispose, Recycle, Donate ("Hazardous items can't be donated"); makeovers skipped ("Nothing to render"). Drop-off with Battery collection: 1 OpenStreetMap e-waste point in Dubai (14 km); OSM coverage is thin. |
| 6 | T-shirt: donate and upcycle, donation points | pass | `06_tshirt_donate.png` | Upcycle 3, Recycle 1, Donate 1 ("Good to donate", where, prep). Clothes donation points at 540 m, 5.9 km and 13 km in Dubai. "Mark as donated" feeds Impact. |
| 7 | Gallery upload and text description | pass | `07_text_scan.png` | Gallery picker (Android photo picker) used for all photo scans. Text scan "an old wooden crate with two loose slats" read as 1 pine crate, quality 2 of 5, three ideas; idea cards drop the image area when there is no photo. |
| 8 | Swaps "plastic bags, cling film" | pass | `08_swaps_bags_cling_film.png` | 4 cards in 6.0 s: plastic bags to a folding tote, cling film to beeswax wraps or a plate, plus two from scan history (paper towels to cloths, plastic tubs to glass jars), each with why, tip, effort, cost and sources. |
| 9 | Arabic: full RTL, AI content in Arabic, no overflow | pass (1 fix) | `09a_arabic_results.png`, `09b_arabic_settings_phone_language.png` | Home, Settings, Results, Idea, Tutorial, Drop-off, Swaps, Impact, History checked in Arabic; analysis, ideas and tutorial came back in Arabic; chevrons and step navigation mirror; the drop-off plot keeps north up. No overflow in any screen (no RenderFlex errors in logcat for the whole run). Fixed: Settings said "Phone language, currently Arabic" on an English phone. |
| 10 | Dark mode on every screen | pass | `10_dark_results.png` | Checked on device: Home, History, My projects, Results, Tutorial overview and step, Completion, Drop-off, Swaps, Impact, Settings, camera rationale, viewfinder. Onboarding, rationales and city picker in dark are covered by the screenshot harness (`app/test/screenshots/_out/*_dark_*`), not re-checked on device. |
| 11 | Airplane mode: graceful errors, history opens | pass (1 fix) | `11_offline_home.png` | Offline banners on Home, Scan and Results; a text scan fails with "Can't reach Kanz" and Try again; History, saved scans and saved tutorials open; a tutorial never downloaded says so; Drop-off and Swaps show offline errors and recover after the network returns. Fixed: a reopened scan lost why a stage failed and said "Something went wrong. Try again." |
| 12 | Location denied: city picker fallback | pass (1 fix) | `12_location_denied_city_fallback.png` | "Don't allow" (after an `adb` revoke, so Android counted a second denial) leads to "Turned off in Settings" with Open settings and Choose a city instead; Sharjah picked, Settings and the Drop-off tab follow it, with an honest empty state for wood. Fixed: declining Google's Location Accuracy prompt after granting location sent the user back to "Where should Kanz look?" every time. |
| 13 | Release APK builds, installs and runs; no crashes | pass | `13_camera_unclear_retake.png` | Release APK built (second attempt; the first failed because another agent's `flutter test` rewrote `GeneratedPluginRegistrant.java` mid-build), installed as a fresh app, onboarding, Home, Settings (connected to `http://10.0.2.2:8000`) and Drop-off ran. No crash or Flutter error in logcat across the debug and release runs. Debug APK reinstalled afterwards. The camera shot of the emulator's rendered room was rejected with a retake tip ("appears to be a 3D rendering"). |

## Fixes made during the run

| Fix | Files | Commit |
| --- | --- | --- |
| Overpass searches also hedge on the second overpass-api.de server (`lz4.overpass-api.de`), so a busy machine is an independent coin flip, not the same queue. A local trial of the hedge: 5 of 6 searches answered, against 3 of 6 before. Takes effect when the backend restarts | `backend/app/places/overpass.py` | `8fa72cd` |
| A stage's failure reason is saved with the scan, so History reopens it with the real message ("Image generation is paused", "Drop-off points can't be loaded") and the right retry, instead of "Something went wrong" | `app/lib/core/state/scan_session.dart`, test in `app/test/core/scan_session_test.dart` | `8fa72cd` |
| Declining the Location Accuracy prompt falls back to the last known position (or the nearest emirate) instead of asking for a location again. Verified in the release APK | `app/lib/core/services/location_service.dart` | `8fa72cd` |
| "Phone language" in Settings names the phone's language, not the app's (`systemLangProvider`). Verified on device | `app/lib/core/state/settings_providers.dart`, `app/lib/features/settings/settings_screen.dart`, test in `app/test/core/app_test.dart` | batched commit that carries this report |

## Latency

From `backend/data/server.log` for this run (`stage=` and `gemini stage=` lines) and the app's pipeline timeline.

| Call | Backend, median (range) | App timeline per scan | Target |
| --- | --- | --- | --- |
| analyze | 8.7 s (4.8 to 18.5 s), n=6 | jar 5.0 s, batteries 6.6 s, t-shirt 10.7 s, text 18.6 s, Arabic crates 12.3 s | < 6 s |
| recommend | 14.7 s (5.5 to 20.4 s), n=5 | jar 12.8 s, batteries 5.5 s (disposal only), t-shirt 17.7 s, text 20.5 s, Arabic 14.7 s | < 8 s |
| facilities, answered | 2.3 s (cached to 7.3 s), n=6 | 1.4 to 7.3 s; cached repeats about 60 ms | |
| facilities, failed | 12.0 s (the Overpass budget), n=13 | 12.0 to 13.4 s, plus up to 8 s waiting for a GPS fix | |
| tutorial | 7.7 s (5.9 to 9.0 s), n=3 | first 6.0 s, adapted 7.8 s, Arabic 9.0 s | < 10 s |
| swaps | 7.1 s (6.0 to 8.2 s), n=2 | 6.1 s, 8.2 s | |
| images (after, step, reference) | fail in 0 to 2.2 s with `ai_quota_exhausted` | makeovers never block ideas or drop-off | |

Inside recommend: upcycle designer 15.6 s median (12.2 to 20.0 s), recycle 8.9 s, donate 5.2 s, disposal 5.5 s, retrieval 0.5 s (embedding 0.6 s). The primary model (gemini-3.6-flash) answered one call in the whole run; 18 text attempts failed with 429 quota or 503 before a lite fallback (gemini-3.1-flash-lite, gemini-3.5-flash-lite) answered, and the text scan's recycle and donate branches hit their 12 s timeout and used the knowledge base. While the primary model still had quota it analysed the jar in 4.6 s, so the misses against the targets come mostly from quota fallbacks, not the pipeline.

## Environment limits

- **Gemini free tier.** About 20 requests per model per day; the primary model was exhausted early, so most calls ran on lite fallbacks after a 429 or 503. Image models have no quota: every after, step and reference image failed with `ai_quota_exhausted`. The app handled it everywhere: "Image generation paused" on idea cards and steps, the original photo on completion, one failed call per step chain, no retry offered for a quota error.
- **No Google Maps key.** The Drop-off tab shows the plot (rings every 5 km, north up) and the list; places come from OpenStreetMap only, and the curated file is empty.
- **Public Overpass instance.** At the time of the run overpass-api.de answered 504 to about half of all searches after ~10 s; `overpass.kumi.systems`, `overpass.private.coffee` and `maps.mail.ru` did not answer from this network. The app shows "Drop-off points can't be loaded right now" with Try again, and retries succeeded. The hedge fix above needs a backend restart to apply (the backend was left running as instructed).
- **Emulator location.** `adb emu geo fix` was not delivered to the location providers, so the last fix was a stale Northern California one; the app searched around the nearest emirate and said so. Google's Location Accuracy prompt appears on every GPS search because Location Accuracy is off on this image; it was declined (system setting left unchanged).
- **Emulator camera.** The virtual scene is a 3D render, so the camera path was verified up to analysis and the retake tip, not with a real object.

## Observations for the owning teams (not fixed here)

- Arabic copy uses two names for upcycling: "تدوير إبداعي" on the results tabs and "إعادة ابتكار" on Impact (`results_ar.arb` `resultsTabUpcycle`, `impact_ar.arb` `impactKindUpcycled`).
- Hands-free with the microphone denied says "Voice commands aren't available on this phone"; the phone is fine, the permission is off.
- AI content: for one scanned crate the designer proposed "Two crates joined by a board" and "Three sanded crates"; ideas should respect the scanned quantity. The swaps history insight named only the jar although four materials were in history.
- Arabic AI text shown in an English UI (a scan made in Arabic, reopened after switching to English) is laid out left to right, so sentence-final punctuation lands on the wrong side. The tutorial now sets content direction (`content_direction.dart`); results, idea and history still use the UI direction.
- Release builds print "Expected to find fonts for CupertinoIcons"; nothing in `lib/` uses them, so it is a framework reference and harmless.
- Running `flutter build apk --release` while another `flutter test` or `flutter run` is active in `app/` can fail on `GeneratedPluginRegistrant.java` (dev-only plugins). Build the release APK when no other Flutter command is running.
