# UI review, round 1

Reviewer: UI Critic. Scope: every screen and state the screenshot suites render, at 360 and 412 dp, light and dark, English and Arabic, plus the 130 % text variants.

## How this round was run

- `flutter test test/screens test/screenshots`: 1114 tests, all green. PNGs regenerated in `app/test/screenshots/_out/` (1098 files).
- Every state group was reviewed side by side as (light EN | dark AR) and (dark EN | light AR) at 360 dp, the 130 % variants as (EN | AR), tall "full" captures in 800 dp slices, and a 412 dp pass on Home, Results, Idea, Tutorial and Onboarding.
- Alignment was also checked by pixel: for every Arabic capture, the start edge of the body content must reach the 340 dp gutter; for every English capture, it must start at 20 dp. Two screens fail (X-01).
- `qa/screens/` does not exist yet, so there were no emulator captures to review this round.
- The design gallery (`/gallery`) is debug-only and was not reviewed as a judge-facing surface.

## Verdict

The system holds together well. Paper and ink, one clay accent, Fraunces used sparingly, mono data labels and hairline grids give the app a calm, editorial voice. None of the hard bans show up anywhere: no gradients, glow, glassmorphism, emojis, sparkle or robot icons, stock art, default purple, Roboto or Inter, shadows on every card, nested cards, confetti, lorem ipsum or hype copy. Dark mode is carefully tuned, and Arabic has real typography, not a mirror.

What keeps it below studio quality is a set of state and edge-case problems, several of them on the signature moments judges will see first:

1. **Two RTL alignment bugs** (X-01, B-02). Arabic judges will see state blocks off the start gutter and "Hanging jar lantern01".
2. **The makeover-rendering state** on the idea screen (B-01) hides half the photo behind a flat panel. It looks broken on the before/after moment, which is scored under display of recommendations.
3. **States look generic.** Empty and error states use two different anatomies, buttons that hug their labels, repeated "Try again" copy and raw error codes (X-03, X-04, X-10).
4. **Controls are too faint.** Chip and outlined icon-button borders are about 1.2:1, below the 3:1 that DESIGN.md requires (X-02).
5. **Arabic polish.** Latin commas, three different words for "scan", a missing plural, and AI text shown in the wrong direction (X-05, X-06, X-07, A-04).

### Signature moments

| Moment | State today | What would make it exceptional |
|---|---|---|
| Viewfinder | Clean brackets, clay shutter, quiet controls | Camera chrome should not change color with the theme (B-12) |
| Analysis reveal + pipeline | Honest stages with real durations; folds into one summary line | The summary line wraps with a dangling "·" (B-06); the restoring skeleton does not match the 4:3 photo (B-04) |
| Specimen cards | Strong: mono labels over plain values, quality segments, index LTR | The carousel peek shows cut glyphs (B-03) |
| Idea cards with after image + inset | Strong, and the inset reads well | Paused state repeats the same grey tile 3 times (B-07); the text-scan entries break in Arabic (B-02) |
| Before/after slider | Strong when both images exist | Rendering state (B-01) |
| Tutorial pager | Big numerals, segmented progress, callouts: very good | Faint prev/next controls (X-02); the redraw disc sits on the hero image (C-07) |
| Drop-off | The radial plot is a distinctive idea | Unknown-material places in solid ink swamp the colored dots (D-01) |
| Impact numerals | Very good | Small copy issues only (D-09, D-10) |

## Counts

| Area | High | Medium | Low | Total |
|---|---|---|---|---|
| A. Shell, onboarding, home, history, settings, permissions | 0 | 4 | 7 | 11 |
| B. Scan, results, idea | 2 | 3 | 7 | 12 |
| C. Tutorial and completion | 0 | 5 | 5 | 10 |
| D. Drop-off, swaps, impact | 0 | 3 | 7 | 10 |
| X. Shared design system | 1 | 7 | 3 | 11 |
| **All** | **3** | **22** | **29** | **54** |

Fix order for round 2: X-01, B-02 and B-01 first (the three highs), then X-02, X-03 and X-04 together (they change the state components every screen uses), then the Arabic set (X-05, X-06, X-07, A-04), then the rest by area.

## Severity key

- **high**: broken, banned, unreadable, overflow, wrong direction, or looks unfinished or generic.
- **medium**: clearly below studio quality.
- **low**: polish.

---

## A. Shell, onboarding, home, history, settings, permissions

### A-01 · medium · History empty and error states float in the middle of the screen
- **Where:** History › Scans empty, My projects empty, error. All themes and languages, 360 and 412.
- **Problem:** The tab body is an `AnimatedSwitcher` (`history_screen.dart:139`). Its default `layoutBuilder` is a `Stack(alignment: Alignment.center)`, which gives loose constraints. The state block shrinks to its content and centers on both axes, leaving a ~140 dp void under the tabs. The same mechanism pulls the Arabic block off the start gutter (X-01).
- **Fix:** `layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, alignment: AlignmentDirectional.topStart, children: [...previous, ?current])`. The state then starts 24 dp under the tabs, on the gutter.

### A-02 · medium · Permission "blocked", "denied" and "restricted" explain themselves below the fold
- **Where:** `/permissions/camera` and `/permissions/location`, blocked, denied and restricted states. All themes and languages, 360.
- **Problem:** The page repeats the first-ask rationale (art, three reasons, buttons). The one line that says what actually happened, the "Turned off in settings" / "Not allowed" callout, sits under the buttons and is cut at the 360 fold. For "restricted" the reasons are irrelevant, since the user cannot grant access.
- **Fix:**
  - Put the state callout (`Callout.warning`, mono title) directly under the title, before the reasons.
  - Blocked: primary "Open settings", tertiary alternative.
  - Restricted: drop the reasons and the settings action. Make the alternative ("Choose from gallery" / "Choose a city") the primary button.

### A-03 · medium · The offline banner is the loudest thing in dark mode
- **Where:** Shell banner (`shell_offline`, `shell_unreachable`, `shell_banner_checking`). Dark, both languages, both widths.
- **Problem:** The banner is an `inverse` slab, so in dark mode it is a full-width `#F2EFE8` bar over every tab. It is brighter than any content, which works against "chrome recedes". The "checking" state keeps the cloud-off glyph, so it still reads as "offline".
- **Fix:**
  - Banner on `surfaceSunken` with ink text, a `caution` glyph and a 1 px `line` bottom border, in both themes. `inverse` is fine for snackbars only.
  - "Checking" shows a 14 dp spinner in place of the glyph and the text "Checking the connection".
  - Keep the status-bar overlay logic in `connection_banner.dart` in step with the new fill.

### A-04 · medium · Arabic tools summary has no plural
- **Where:** Settings › Tools row, Arabic ("مقص، خيط قنّب، كماشة و2 أخرى").
- **Problem:** `settingsToolsMore` is `"{names} و{count} أخرى"`, which is unnatural for 1 or 2 and wrong for 3 to 10.
- **Fix:** Make it ICU plural:

  ```
  "{names} {count, plural, =1{وأداة أخرى} =2{وأداتان أخريان} few{و{count} أدوات أخرى} many{و{count} أداة أخرى} other{و{count} أداة أخرى}}"
  ```

  English stays "and {count} more".

### A-05 · low · Home: the two secondary ways in are the only centered row on a start-aligned page
- **Where:** Home › first run and content. All themes and languages. At 130 % they stack, still centered.
- **Problem:** `_Actions` uses `Wrap(alignment: WrapAlignment.center)` under a full-width CTA with a centered label, so the page's top block reads as a centered cluster.
- **Fix:** Use a `Row` of two `Expanded` `KanzButton.secondary` (48 dp, gallery and describe glyphs), 8 dp apart. At 130 % use a `Wrap` with `WrapAlignment.start`.

### A-06 · low · Onboarding copy
- **Where:** Onboarding skill and tools steps, English.
- **Problem:**
  - "How much have you made before?" is ambiguous. The Arabic "ما مدى خبرتك في الأعمال اليدوية؟" is better.
  - "No tools is fine: Kanz puts ideas that need none first." is ungrammatical.
- **Fix:** `onboardingSkillTitle`: "How handy are you?". `onboardingToolsNone`: "No tools? That's fine. Ideas that need none come first."

### A-07 · low · Onboarding: progress bar off the gutter and no edge on the pinned bar at 130 %
- **Where:** Onboarding step 1 (all), and skill and tools at 130 % EN and AR.
- **Problem:**
  - On step 1 the progress bar starts after an empty 48 dp back slot, so it does not sit on the 20 dp gutter like everything below it.
  - At 130 %, content scrolls under the pinned Continue bar with no hairline or fade, and the third option card is cut mid-card.
- **Fix:**
  - On step 1, start the progress bar at the gutter. From step 2 keep the back button slot.
  - Give the pinned bar a 1 px `line` top border that appears once content is scrolled under it (listen to `ScrollMetrics.extentAfter > 0`).

### A-08 · low · Settings location: radio and chevron on the same row
- **Where:** Settings › Location, "A fixed city" row. All.
- **Problem:** The row carries both a radio (a choice) and a chevron (navigation), so it is unclear what a tap does.
- **Fix:** Make the two location modes radio rows only. When city mode is on, add a separate `KanzListTile` "City" with a mono value ("ABU DHABI") and a chevron that opens `/city`.

### A-09 · low · Settings diagnostics: model ids break mid-token; the save action uses a save glyph
- **Where:** Settings › Server (tall captures, online, unreachable, invalid). 360, EN and AR.
- **Problem:**
  - Values such as `gemini-3.1-flash-image` wrap at the hyphen inside a two-column grid.
  - "96 documents" is set in sans next to mono values.
  - "Save and test" leads with `KanzIcons.save`, a storage metaphor for an action that tests a URL.
- **Fix:**
  - List model rows single-column (mono label above, value below, no uppercase) so ids fit on one line at 360.
  - Set counts in `KanzType.dataStrong`.
  - Use no glyph (or `KanzIcons.check`) on "Save and test".

### A-10 · low · History row menu shows a different time than its row
- **Where:** History › row menu sheet (360 light EN, 360 dark EN, 412 dark EN).
- **Problem:** The row shows "04:00" but the sheet subtitle shows "Just now".
- **Fix:** Use the same `formatRelative` output in both places.

### A-11 · low · City picker coordinates in Arabic use Latin N/E
- **Where:** `/city`, Arabic, both themes.
- **Problem:** `city_picker_screen.dart:128-130` hardcodes `'N'`, `'S'`, `'E'`, `'W'`.
- **Fix:** Localize the compass letters (ش / ج / ق / غ), or drop the hemisphere letter and show "25.20°, 55.27°" in an LTR-wrapped mono label.

---

## B. Scan, results, idea

### B-01 · high · Idea detail while the makeover renders: half the photo is hidden behind a flat panel
- **Where:** Idea › `rendering`. All themes and languages, 360 and 412.
- **Problem:** `BeforeAfterSlider` is drawn with the before half and a `surfaceSunken` panel for the after half. There is no handle. The mono label "RENDERING THE / MAKEOVER" wraps inside the half-width. This is the before/after signature moment, and it reads as a broken image.
- **Fix:** In `features/idea/widgets/idea_visual.dart`, while the after image is `loading`:
  - Show the full before photo with no split and no handle.
  - Add an on-photo tag at the top end in `KanzPhotoColors.tag`: a 14 dp spinner plus "Rendering the makeover" (`labelMedium`, one line).
  - Draw a 2 px indeterminate progress hairline along the photo's bottom edge in `KanzPhotoColors.ink`.
  - When the image lands, cross-fade it in (`KanzMotion.slow`), then move the handle once from the end to 50 % (350 ms, `KanzMotion.emphasized`), with a selection haptic. The skipped paused state can reuse the tag without the spinner.

### B-02 · high · Text-scan ideas in Arabic: the numeral is glued to the title
- **Where:** Results › text scan whose makeovers failed (`_IdeaEntry`, `features/results/widgets/upcycle_ideas.dart:265-280`). Arabic, both themes, both widths.
- **Problem:** The Fraunces index is `Text(number, textDirection: ltr)` inside a bare `SizedBox(width: 40)`. In RTL the box sits at the start (right), but the LTR numeral is laid out at the box's left edge. It touches the title ("Hanging jar lantern01", "Kitchen herb jar02"), and a 30 dp hole opens at the card's start edge.
- **Fix:** Replace the `SizedBox` with `Padding(padding: EdgeInsetsDirectional.only(end: KanzSpace.s12), child: Text(number, ...))` so the numeral hugs the start edge in both directions. Align it on the title baseline with `Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic)`.

### B-03 · medium · Specimen carousel: the peeking card shows cut glyphs
- **Where:** Results › specimen carousel (`results_content`, `results_full`). All. 360 and 412.
- **Problem:** The next card peeks by about 24 dp, which is more than its 16 dp inner padding. The first letters of its content are sliced: "M", "Me", "1 p", "Slig", and in Arabic "غ", "الما". This reads as clipped text, not as "there is more".
- **Fix:** Keep the peek at 12 dp so only the neighbour's border and padding show. Keep "01 / 02" as the pager cue. Alternatively, peek ≥ 56 dp so at least the dot and a whole word of the name are visible.

### B-04 · medium · Results restoring skeleton does not mirror the photo
- **Where:** Results › `restoring`. All.
- **Problem:** The photo skeleton is portrait (~310 dp tall at 360), but the photo renders 4:3 (~240 dp). The whole page jumps when the scan restores, which breaks the "skeletons mirror content" principle.
- **Fix:** Use `AspectRatio(4 / 3)` with `KanzRadii.card` for the photo skeleton, or the stored image's aspect ratio when known. Use the same 4:3 in `idea_loading` and `completion_loading`.

### B-05 · medium · Upcycle / Recycle / Donate counts read as belonging to the next tab
- **Where:** Results › `SegmentedTabs`. 360 EN (worst), AR.
- **Problem:** Each segment packs glyph, label and a small mono count into ~100 dp. The count sits flush against the next segment's glyph ("Recycle 2 [hand] Donate 1"), so "2" reads as Donate's.
- **Fix:** Put the count directly after the label with 4 dp spacing, `KanzType.dataStrong`, in a 20 dp `surfaceSunken` pill (`raised` on the selected thumb). Drop the glyphs below 380 dp so labels and counts have room.

### B-06 · low · Pipeline summary wraps with a dangling separator
- **Where:** Results summary line, text scans (`results_text_full`), and 130 % EN/AR ("Done in 12.5 s · 3 ideas ·" / "3 places").
- **Problem:** The summary is one string, so line breaks fall after the separators.
- **Fix:** Build it as a `Wrap` of segments where each separator sits with the segment that follows it (non-breaking space before "·"). Put "images paused" on its own line in `inkSecondary`.

### B-07 · low · Paused makeovers repeat the same grey tile three times
- **Where:** Results › `paused` (image generation off). All.
- **Problem:** Every idea card shows a desaturated original with "IMAGE GENERATION PAUSED", so three identical grey tiles lead the ideas. The pipeline row already says it once.
- **Fix:** When paused, show the original photo at full saturation with the "Before" inset hidden. Keep the note only in the pipeline row and in a single `Callout` above the first idea.

### B-08 · low · Focused-item note is a shouted sentence with a big gap after it
- **Where:** Results › under the specimen carousel ("IDEAS BELOW ARE FOR THIS ITEM"). All.
- **Problem:** A full sentence in mono uppercase, followed by about 60 dp of air before "What it can become".
- **Fix:** Use `bodySmall` in `inkSecondary`, sentence case, naming the item: "Ideas below are for the glass jam jar". Leave 32 dp to the section header.

### B-09 · low · Missing scan: the only way forward is a quiet button
- **Where:** Results › `missing`. All.
- **Problem:** The only way out is the `EmptyState` "New scan" button, set as a secondary button that hugs its label.
- **Fix:** Make it a primary full-width button. See X-03 for the state anatomy.

### B-10 · low · Idea: failed-image row and tool duplication
- **Where:** Idea › `failed` and `ready`. All; 130 %.
- **Problem:**
  - When the image failed, "Try another image" floats alone at the end of the row.
  - At 130 %, "DRAG TO COMPARE" wraps to two lines next to it.
  - The data grid cell "Tools: You have 3 of 4 tools" repeats the "Tools needed" list directly below.
- **Fix:**
  - Build the row as a `Wrap` (spacing 16, run spacing 4). When failed, the start label becomes "Makeover unavailable".
  - Replace the tools cell with the missing tool by name ("Missing: glue gun"), or drop it.

### B-11 · low · Gallery failure uses a different layout from camera failure
- **Where:** Scan › `gallery_failed`. All.
- **Problem:** The failure uses `ErrorState` (bare icon, sans title, two hugging outlined buttons of different widths). The camera-denied state uses a Fraunces title and full-width stacked buttons. The copy "Check that Kanz may read your photos" is stiff.
- **Fix:** Use the camera-denied anatomy: primary "Try again", tertiary "Use the camera". Copy: "Allow Kanz to see your photos, then try again." AR: "اسمح لكنز بالوصول إلى صورك ثم حاول مجدداً."

### B-12 · low · Camera chrome changes color with the app theme
- **Where:** Scan › viewfinder, capturing. Light vs dark.
- **Problem:** The shutter disc (`buttons.dart:387`) and the framed corner brackets (`viewfinder.dart:34`) read `context.kanzColors.accent`, so they are `#C65026` in light and `#F07A4F` in dark over the same camera preview. DESIGN.md says photo chrome is theme-independent.
- **Fix:** Use `KanzPhotoColors.accent` for both.

---

## C. Tutorial and completion

### C-01 · low · "Idea not available" copy contradicts its own button
- **Where:** Tutorial › `missing`. All. The layout bug on this screen is X-01.
- **Problem:** The title says "This idea isn't available", but the button says "Back to the idea".
- **Fix:** Button "Back to the ideas" / AR "العودة إلى الأفكار", popping to Results.

### C-02 · medium · Adapt sheet is a wall of chips
- **Where:** Tutorial › `adapt_sheet`. All. Worst at 360 AR.
- **Problem:** All 26 tool chips form one ungrouped wall. The sheet body is cut at the bottom with no cue, and the action sits below the fold.
- **Fix:**
  - Put the selected tools first under `MonoLabel` "YOU HAVE", then the rest under "ADD A TOOL". The vocab has no tool categories, so this split is the grouping.
  - Title: "Tools · 7 selected".
  - Use `KanzSheet` pinned actions for "Update tutorial", with a 1 px `line` top border.

### C-03 · medium · Adapt failure has no way forward
- **Where:** Tutorial › `adapt_failed`. All.
- **Problem:** The banner says the adaptation failed, but offers only a close button. DESIGN §9 requires errors to always offer the next step.
- **Fix:** Add a tertiary "Try again" that re-runs `adapt(skill:, tools:)` with the pending choice. Keep the previous tutorial visible underneath, as it is now.

### C-04 · medium · Offline tutorial gives two different reasons for missing pictures
- **Where:** Tutorial › `offline`. All.
- **Problem:** The top banner says "You're offline… new images and adapting need a connection", while the step image says "Image generation is paused on this server".
- **Fix:** Map `ApiErrorCode.offline` on step images to "Pictures need a connection" with `KanzIcons.noWifi`. Reserve `tutorialImagePaused` for `aiQuotaExhausted`.

### C-05 · medium · Completion "What changed" shows lifetime totals
- **Where:** Completion (`completion`, `completion_full`, `completion_text_scan`). All.
- **Problem:** The header "What changed" sits over 7 / 2 / 3 (items, projects, days, all time). The only number about this project is a sentence below it ("This project kept 1 item out of the bin"). It reads as if this project changed 7 items.
- **Fix:**
  - Lead with this project: `StatNumeral` "1" plus "item kept out of the bin".
  - Then `MonoLabel` "ALL TIME" over the three totals at `KanzType.numeral` (40) instead of `numeralLarge`.
  - Header: "What this project changed" / AR "ما الذي غيّره هذا المشروع".

### C-06 · medium · Completion without a makeover image is anticlimactic
- **Where:** Completion › `photo_only`. All.
- **Problem:** The hero is the unchanged original photo under "Project finished", with a note that the makeover image is unavailable.
- **Fix:** Add `KanzButton.secondary` "Add a photo of what you made" (camera glyph) under the note. The captured photo becomes the after side of the slider and the share card, and the note disappears once a photo exists. This also gives judges a real before/after on a free-tier key.

### C-07 · low · The redraw control sits on every good step picture
- **Where:** Tutorial › `step`, `step_done`. All.
- **Problem:** A 48 dp dark disc with a retry glyph is permanently on the top-end corner of the step image, competing with the hero picture.
- **Fix:** Show the on-photo control only in `failed`. Otherwise offer "Redraw picture" as a tertiary text button (retry glyph) under the image, start-aligned.

### C-08 · low · Dark mode: finished step segments outshine the current one
- **Where:** Tutorial progress bar; Home resume card. Dark.
- **Problem:** Done segments are `ink` (`#F2EFE8`), the brightest element on screen, so the clay current segment reads second.
- **Fix:** In dark, done = `inkSecondary` (`#A8A59C`); keep current clay and upcoming `track`. Light mode is fine.

### C-09 · low · Adapting removes the row that started it
- **Where:** Tutorial › `adapting`. All.
- **Problem:** The "Change skill or tools" row disappears while the tutorial adapts, and the content jumps up about 56 dp.
- **Fix:** Keep the row, disabled, with a 14 dp spinner and "Adapting to your tools".

### C-10 · low · "Finish project" loses its glyph at 130 %
- **Where:** Tutorial › `finish` at 130 %, EN.
- **Problem:** The check glyph disappears at 130 % text, so the button changes shape from 100 %.
- **Fix:** Keep the leading icon; let the label wrap or reduce horizontal padding to 16.

---

## D. Drop-off, swaps, impact

### D-01 · medium · Drop-off plot: ink dots swamp the material colors and nothing explains them
- **Where:** Drop-off list header plot and map view (`dropoff_results`, `dropoff_osm`, `dropoff_catalog_error`). All.
- **Problem:**
  - Places with no accepted-material list are painted solid `ink` (`place_info.dart:82`). In the OSM capture, 9 of 12 dots are ink.
  - Overlapping pins make crescent artifacts and cover the centre cross.
  - There is no key, so the color meaning is invisible.
- **Fix:**
  - Draw unknown-material places as hollow rings (1.5 px `lineStrong` stroke on `surface`) so colored dots lead.
  - Paint the centre cross last.
  - Separate pins closer than 10 dp with a simple collision pass (shift along the bearing).
  - Add one `bodySmall` line under the plot: "Filled dot: accepts your materials · Ring: materials not listed".

### D-02 · medium · Place details in Arabic: Call and Website buttons differ in height
- **Where:** Drop-off › `details`. AR 360, both themes.
- **Problem:** "الموقع الإلكتروني" wraps to two lines, so Website is taller than Call.
- **Fix:** Use the label "الموقع". Also wrap the row in `IntrinsicHeight` with `CrossAxisAlignment.stretch`, so a future long label keeps the buttons equal.

### D-03 · medium · Swap cards: too many mono labels, and sources that belong to no card
- **Where:** Swaps › `results`, `results_more`. All.
- **Problem:**
  - Each card stacks four mono labels (category, INSTEAD OF, TRY, "EFFORT: LOW · COST: LOW"), which flattens the hierarchy.
  - "SOURCES" and its chip sit between cards, indented 36 dp to the card's inner padding, so they belong to neither card.
- **Fix:**
  - Merge the from-line into one `bodyMedium` `inkSecondary` line: "Instead of single-use plastic bags".
  - Keep "→ Try" as the only mono cue before the Fraunces title.
  - Meta as "Low effort · Low cost" in `KanzType.data`, without colons.
  - Move `SourceChips` inside the card, under the meta hairline.

### D-04 · low · Place rows: a lone dot after "Hours not listed" looks like a status light
- **Where:** Drop-off list and Results › Drop-off near you. All.
- **Problem:** The accepted-material dot sits alone at the end of the hours line.
- **Fix:** Move the dots to the end of the type and address line, or print names: "Glass · Plastic" in `bodySmall` with the dots.

### D-05 · low · Map-view north label and 130 % wraps
- **Where:** Drop-off › map view (AR), and list at 130 % EN.
- **Problem:**
  - The map view keeps "N" in Arabic, although the plot uses "ش".
  - At 130 % the count wraps "6 PLACES · WITHIN / 15 KM" and the plot footer stacks.
- **Fix:** Localize the north label. Join "15 km" with a non-breaking space. Let the footer wrap as two start-aligned lines by design (Wrap, spacing 16).

### D-06 · low · Location ask footer hidden by the nav bar
- **Where:** Drop-off › `needs_location`, `location_blocked`. 360, EN.
- **Problem:** "You can change this at any time from the top of this tab." is cut by the nav bar.
- **Fix:** Bottom padding = nav bar height + `MediaQuery.paddingOf(context).bottom` + 24.

### D-07 · low · Swaps loading label shouts the user's list
- **Where:** Swaps › `loading`. EN (wraps to two lines), AR.
- **Problem:** The label shows the user's entries in mono uppercase: "FINDING SWAPS FOR PLASTIC BAGS, CLING FILM".
- **Fix:** `bodySmall` `inkSecondary`, sentence case: "Finding swaps for plastic bags and cling film", with the spinner. Use the list join from X-05.

### D-08 · low · Swaps field helper is indented off the gutter
- **Where:** Swaps form, "Separate items with commas". All.
- **Problem:** The helper sits 15 dp inside the field and its label.
- **Fix:** Set `KanzTextField`'s helper padding to 0 at the start so helper, label and field share the gutter.

### D-09 · low · CO2e typography and disclaimer tone
- **Where:** Impact › estimate callout; Settings note.
- **Problem:** "6.5 kg CO2e" has no subscript, and "Estimate, verify before quoting." reads like a legal note to a consumer.
- **Fix:** Use "CO₂e" (U+2082) in `commonCo2eKg` and `settingsCo2eNote`. `commonCo2eDisclaimer`: "Rough estimate from average factors." AR: "تقدير تقريبي من متوسطات عامة."

### D-10 · low · The same stat has two Arabic names
- **Where:** Impact vs Completion, AR.
- **Problem:** The same number is labelled "أغراض أبعدتها عن سلة المهملات" on Impact and "أغراض أنقذتها من النفايات" on Completion.
- **Fix:** Use one label everywhere, for example "أغراض أبعدتها عن النفايات".

---

## X. Shared design system

### X-01 · high · Empty and error states sit off the Arabic start gutter
- **Where:**
  - Tutorial › `missing`, AR, both widths and themes: content spans 20–287 dp, gutter at 340 dp (412: 392 dp).
  - History › empty and error, AR: content ends at 313 dp.
- **Problem:** `EmptyState` and `ErrorState` (`core/design/components/states.dart`) are `Column(mainAxisSize: min)` blocks that take their content's width. Under a loose parent they shrink.
  - Scaffold's body gives loose width, and `SingleChildScrollView` paints its child at x = 0, so in `TutorialFailedView` the block lands at the physical left.
  - In History, `AnimatedSwitcher`'s centered `Stack` centers the block (A-01).

  In English this is invisible because long messages fill the width. In Arabic the block visibly floats away from the right edge.
- **Fix:**
  - Harden the components: wrap both in `SizedBox(width: double.infinity)` with `Align(alignment: AlignmentDirectional.topStart)`.
  - In `tutorial_states.dart`, give the outer `Column` `crossAxisAlignment: CrossAxisAlignment.stretch`.
  - Add a harness assertion that in every `_ar` capture the body's start edge reaches the gutter (the pixel check used for this review is a few lines of image math).

### X-02 · medium · Chip and outlined icon-button borders are below 3:1
- **Where:**
  - Onboarding tools, Swaps chips, Drop-off filters and type sheet, Adapt sheet (unselected `KanzChip`).
  - Tutorial prev/next (`KanzIconButton.outlined`).
  - Light and dark.
- **Problem:** Unselected chips use `border: c.line` (`chips.dart:69`), and outlined icon buttons use `c.line` (`buttons.dart:210`). That is about 1.2:1 on paper in light and about 1.3:1 in dark. DESIGN.md §10 requires 3:1 for control boundaries, and the white chip fill is only 1.1:1 against paper. The prev/next circles almost disappear.
- **Fix:** Use `lineStrong` (3.25:1 on background, 3.67:1 on surface) for unselected chip borders and the outlined icon button, as `KanzButton.secondary` already does. Add both to `contrast_test.dart`.

### X-03 · medium · Two state anatomies, both generic
- **Where:** Every empty and error state (Home, History, Drop-off, Swaps, Impact, Results, Completion, Tutorial, Scan).
- **Problem:**
  - `EmptyState`: 56 dp outlined circle glyph, Fraunces `headlineSmall` title.
  - `ErrorState`: bare 24 dp danger glyph, Plex `titleLarge` title.
  - Both end in a `KanzButton.secondary` that hugs its label, while permission and location asks use full-width buttons.

  Errors end up looking like a default Material page, and the states do not feel like one family.
- **Fix:** One anatomy for both:
  - 56 dp circle (1 px `lineStrong`; `danger` stroke and glyph for errors).
  - 20 dp gap, Fraunces `headlineSmall` title, 8 dp gap, `bodyMedium` `inkSecondary` message.
  - 24 dp gap, full-width action: secondary by default, primary when it is the only way forward (Results missing, Home error).
  - Support code last (X-10).

### X-04 · medium · Error messages repeat the title and the button
- **Where:**
  - `commonErrorGeneric` "Something went wrong. Try again." (Home, Impact, Completion).
  - `homeErrorMessage`, `historyErrorBody` ("… Try again.").
  - `dropoffErrorTitle` + `commonErrorPlacesUnavailable` ("Drop-off points didn't load" / "Drop-off points can't be loaded right now. Try again soon.").
  - `resultsIdentifyErrorTitle` + `commonErrorOffline`.
- **Problem:** Title, message and button all say the same thing, and nothing says what still works.
- **Fix:** Messages give the cause and what still works; the button alone says "Try again".

  | Key | New message |
  |---|---|
  | `commonErrorGeneric` | "Kanz hit an unexpected error." |
  | `homeErrorMessage` | "Your saved scans couldn't be read from this phone." |
  | `commonErrorPlacesUnavailable` | "The map services didn't answer. Ideas and tutorials still work." |
  | `commonErrorOffline` | "No connection. Saved scans and tutorials still open." |

  Mirror these in Arabic.

### X-05 · medium · Arabic lists joined with a Latin comma
- **Where:**
  - `swaps_screen.dart:92` (loading label "أكياس بلاستيكية, غلاف بلاستيكي للطعام").
  - `place_info.dart:37` (place types) and `:134` (accepted materials).
  - `completion_screen.dart:175` (made from).
- **Problem:** Lists are joined with `join(', ')`, so Arabic text gets "," instead of "،".
- **Fix:** Add a `formatList(l10n, items)` helper in `lib/l10n/l10n.dart`: "، " (U+060C) in Arabic, ", " in English, and "and" / "و" before the last item where the list is read as a sentence. Use it in all four places.

### X-06 · medium · Arabic uses three words for "scan"
- **Where:** History ("الفحوص", "احذف الفحص"), Impact and Swaps ("فحصته") vs Results, Idea, Tutorial and Completion ("المسح", "مسح جديد", "المسح الخاص بها").
- **Problem:** The noun changes between screens, and the action verb is a third word ("صوّر").
- **Fix:** One noun, "الفحص" (plural "الفحوص"), which fits the field-guide voice, with the verb "صوّر" for the action. Update `results_ar.arb` (5 strings), `idea_ar.arb`, `tutorial_ar.arb`, `completion_ar.arb` and `scan_ar.arb` ("مسح بالوصف" → "فحص بالوصف").

### X-07 · medium · AI text follows the UI's direction, not the content's
- **Where:**
  - Results, Idea, Tutorial, History detail whenever the content language differs from the UI. For example, a scan made in English is reopened after switching to Arabic, as in the `results_text_full` and `results_battery_full` AR captures.
- **Problem:** English paragraphs get RTL punctuation: ".table", ".Four used AA batteries", and a numeral on the wrong side of the title.
- **Fix:** Wrap AI free text (item names, pitches, steps, reasons, tips) in `Directionality(textDirection: lang == Lang.ar ? rtl : ltr)` from `analysis.lang`, `recommendation.lang` or `tutorial.lang`. Keep the surrounding layout in the UI's direction.

### X-08 · low · Double spaces around "·" in mono labels
- **Where:**
  - "6 PLACES  ·  WITHIN 15 KM", "PROJECT FINISHED  ·  JUST NOW", "EFFORT: LOW  ·  COST: LOW".
  - Idea meta: `meta.join('  ·  ')` in `upcycle_ideas.dart`.
- **Problem:** With +1.1 tracking, a double space around the separator opens gaps of about 12 dp, so the labels break into islands.
- **Fix:** Use `' · '` (single spaces) in every `MonoLabel` join.

### X-09 · low · Three hairline treatments
- **Where:**
  - `KanzListTile` dividers are inset only at the start (`layout.dart:266`), so they run to the physical edge at the end (Settings, `/city`).
  - `PlaceRow` lists are full-bleed.
  - `DataGrid`, idea, completion and impact rules are inset 20 dp on both sides.
- **Problem:** Hairlines are treated three different ways.
- **Fix:** Inset list-tile dividers on both sides (`EdgeInsetsDirectional.symmetric(horizontal: KanzSpace.gutter)`). Keep full-bleed only for `PlaceRow` lists.

### X-10 · low · Raw error codes read like debug output
- **Where:** Every `ErrorState` with a code ("ai_unavailable · req_5f3c2a1b", "places_unavailable · req_85b6e682").
- **Problem:** The code is a bare mono line under the button.
- **Fix:** Prefix it with `MonoLabel` "SUPPORT CODE", then the value in `KanzType.data`, `inkSecondary`, at 11/16. Show the wire code only in debug builds and the request id always.

### X-11 · medium · Section headers are sans while the cards inside them are Fraunces
- **Where:** Results ("What it's made of", "What it can become", "Drop-off near you"), Impact ("By material", "Where they went"), Completion ("What changed"), Idea ("Tools needed").
- **Problem:** `SectionHeader` defaults to `titleLarge` (Plex 600 18). DESIGN.md §3 assigns `headlineMedium` (Fraunces 24) to section titles. The cards under these headers have Fraunces `headlineSmall` 20 titles, so a child outranks its parent in character, and the page reads as generic Material.
- **Fix:** Pass `large: true` for top-level page sections on Results, Impact and Completion. Keep sans `titleLarge` for sub-sections within a detail page (Tools needed, Also needed, Safety).
