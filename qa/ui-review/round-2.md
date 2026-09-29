# UI review, round 2

Reviewer: UI Critic. Scope: the screens and states the screenshot suites render after the round-1 fixes (commits `8fa72cd`, `99dd961`), at 360 and 412 dp, light and dark, English and Arabic, plus the 130 % variants.

## How this round was run

- `flutter test test/screens test/screenshots`: 1167 tests, all green. 1134 PNGs regenerated in `app/test/screenshots/_out/` (all dated after the last fix commit).
- Each state was reviewed as a contact sheet of 360 light EN, 360 dark EN, 360 light AR and 360 dark AR, with 412 and 130 % sheets for Home, Results, Idea, Tutorial and Drop-off. Bidi, numerals and chip glyph order were checked on 2x crops.
- Covered: Home (content, offline, 130 %), onboarding (welcome, language, tools), permissions (camera, camera blocked, location blocked, city picker), Settings (top, tall online, tools), History (scans, projects, row menu, error), Scan (viewfinder, describe, gallery failed), Results (identifying, ideas loading, full, paused, rejected, 412, 130 %), Idea (ready, rendering, paused, 412), Tutorial (overview, step, step failed, hands-free, adapt sheet, missing, 130 %), Completion (full, photo only, own photo, made-photo camera), Drop-off (map, needs location, empty, details), Swaps (form, results, loading, error), Impact (content, more, nudge).
- Not re-inspected this round, queued for round 3: Impact empty and error, Drop-off OSM, type sheet, location sheet, offline and catalog error, Swaps no-match and offline, Completion loading and error, Tutorial offline, loading and finish, Results restoring and missing, History empty and loading. None of these were high in round 1.
- `qa/screens/` holds emulator captures from 01:57, before the round-1 fixes landed (02:22). They were used only to check real photos (box tags on a real scene); everything else in this report comes from the fresh harness renders.

## Verdict

Round 1 did its job. All three highs are fixed and most mediums are fixed well:

- Arabic state blocks sit on the start gutter (X-01).
- The paused idea list keeps its numerals on the start edge (B-02).
- The idea screen shows the whole photo with a "Rendering the makeover" tag and a progress hairline (B-01).
- Chips and outlined icon buttons now have 3:1 borders (X-02).
- Empty and error states share one anatomy with full-width actions and a labelled support code (X-03, X-10).
- The offline banner is a quiet sunken strip (A-03).
- Section titles are set in Fraunces (X-11).
- Completion leads with this project's number (C-05) and offers "Add a photo of what you made" (C-06).
- Swap cards are simpler (D-03).
- Arabic uses one word for scan (X-06) and isolates AI text in its own direction (X-07).

No hard ban appears anywhere. There is no overflow or clipped text at 360 dp or at 130 %. Nothing in this round is high.

What still separates this from studio quality:

1. **Words that change between screens in Arabic** (X-12, X-13). Upcycle and tutorial each have two names. A judge taps "اعرض الدرس" and lands on a screen titled "الدليل".
2. **Two tool pickers for the same data** (C-12). Onboarding has a fine grouped picker. The adapt sheet and Settings still show a flat wall of chips.
3. **Camera chrome that follows the theme again** (C-11). The new made-photo camera re-introduces the bug that round 1 fixed in the scan viewfinder.
4. **Dark-mode progress** (C-08, carried over). Done segments are still the brightest thing on the tutorial's signature bar.
5. **The free-tier reality** (B-13). With no image quota, the paused idea list is what judges will see on every scan. It reads as static text with no cue that an entry opens.

### Signature moments

| Moment | State now | What would make it exceptional |
|---|---|---|
| Viewfinder | Clean, theme-independent, clay shutter the same in both themes | Apply the same to the made-photo camera (C-11) |
| Analysis reveal + pipeline | Honest stages with real durations; the summary folds cleanly and wraps well at 130 % | No change needed |
| Specimen cards | Strong; the peek now shows only the neighbour's border | The recyclable value wraps with a dangling "·" (B-14) |
| Idea cards with after image + inset | Strong when images exist; the paused list is calm and honest | Give paused entries a visible "opens" cue (B-13) |
| Before/after slider | Rendering state fixed; a real slider on Completion once the user adds a photo | No change needed |
| Tutorial pager | Big numerals, segmented bar, "Redraw picture" link under the image | Dark-mode done segments (C-08) |
| Drop-off | Rings for unlisted places and a key in the list view | The map view has no key, and multi-material places are the heaviest marks (D-11) |
| Impact numerals | Very good in both languages | No change needed |

## Counts

| Area | High | Medium | Low | Total |
|---|---|---|---|---|
| A. Shell, onboarding, home, history, settings, permissions | 0 | 1 | 3 | 4 |
| B. Scan, results, idea | 0 | 1 | 1 | 2 |
| C. Tutorial and completion | 0 | 3 | 1 | 4 |
| D. Drop-off, swaps, impact | 0 | 1 | 2 | 3 |
| X. Shared design system | 0 | 2 | 3 | 5 |
| **All** | **0** | **8** | **10** | **18** |

Fix order for round 3:

1. X-12 and X-13 together: string changes only, merge the ARB files once.
2. C-11 and C-08: two component-level changes in `core/design`.
3. C-12, B-13, D-11 and A-12.
4. The lows by area.

## Round-1 follow-up

| Round-1 id | Status |
|---|---|
| X-01, B-01, B-02 (highs) | Fixed |
| X-02, X-03, X-04, X-05, X-06, X-07, X-08, X-10, X-11 | Fixed |
| A-01, A-02, A-03, A-04, A-05, A-07, A-08, A-09, A-10, A-11 | Fixed (A-02 moved the notice up, but see A-12) |
| B-03, B-05, B-06, B-07, B-08, B-11, B-12 | Fixed (B-12 regressed in a new screen, see C-11) |
| C-01, C-02, C-05, C-06, C-07, C-09 | Fixed (C-02 grouping is partial, see C-12) |
| C-08 | **Not fixed**, carried over |
| D-01 | Partly fixed: list view done; map view still open (D-11) |
| D-02, D-03, D-04, D-06, D-07, D-08, D-09, D-10 | Fixed |

## Severity key

- **high**: broken, banned, unreadable, overflow, wrong direction, or looks unfinished or generic.
- **medium**: clearly below studio quality.
- **low**: polish.

---

## A. Shell, onboarding, home, history, settings, permissions

### A-12 · medium · Blocked permission pages push the way forward below the fold
- **Where:** `/permissions/camera` and `/permissions/location`, `blocked` state. 360 dp, English, both themes. Arabic fits only because its lines are shorter.
- **Problem:**
  - Round 1 moved the "Turned off in settings" callout under the title, which is right. The page still repeats all three first-ask reasons under it.
  - At 360 × 800 the primary "Open settings" starts at y ≈ 767 and is cut by the screen edge. The alternative ("Choose a city instead" / "Pick from gallery instead") is fully below the fold.
  - The one thing this state is for, getting the user moving again, is off screen. This is the path behind acceptance check 12.
- **Fix:** in `core/design/components/permission_rationale.dart`, when `notice != null`:
  - Pin the actions in a bottom bar, as onboarding does: `surface` background, 1 px `line` top border, 16 dp top and bottom padding plus `MediaQuery.paddingOf(context).bottom`. Stack the primary and tertiary buttons with 8 dp between them.
  - Let the art and the reasons scroll above the bar.
  - Also drop the third reason ("Rather not? …"): it duplicates the tertiary action directly under it.

### A-13 · low · Settings names the phone's language in Latin inside Arabic
- **Where:** Settings › Language › "لغة الهاتف", Arabic, both themes: subtitle "حاليًا: English".
- **Problem:** `settings_screen.dart:105` reuses `commonLanguageEnglish` / `commonLanguageArabic`. Those are endonyms for the radio rows ("English", "العربية"), so the Arabic sentence contains a Latin word. English on an Arabic phone would likewise read "Now العربية".
- **Fix:**
  - Add `settingsLanguageNameEnglish` / `settingsLanguageNameArabic`: EN "English" / "Arabic"; AR "الإنجليزية" / "العربية". Use them in `settingsLanguageSystemDetail`.
  - Change EN "Now {language}" to "Currently {language}", which reads better as a status.

### A-14 · low · Arabic camera rationale title reads stiffly
- **Where:** `/permissions/camera`, all states, Arabic: "أرِ كنز ما توشك على رميه".
- **Problem:** "أرِ" (the imperative of أرى with a kasra) is correct but rare, and on screen it reads like a typo for "أرى".
- **Fix:** `permissionsCameraTitle` AR: "صوّر ما توشك على رميه". This matches Home's "صوّر غرضًا" and the scan verb chosen in round 1 (X-06).

### A-15 · low · "Test connection" is the only hugging button on the page
- **Where:** Settings › Server, online / unreachable / invalid, both languages.
- **Problem:** Every other action in the app is full width after X-03 ("Save and test", state actions, sheets). "Test connection" is a `KanzButton.secondary` that hugs its label, so it floats under the "Connected" line.
- **Fix:** Pass `expand: true`. Alternatively make it a tertiary text button with the retry glyph, start-aligned on the 20 dp gutter, like "Redraw picture" in the tutorial.

---

## B. Scan, results, idea

### B-13 · medium · Paused idea entries do not look tappable
- **Where:** Results › Upcycle tab with makeovers paused (`results_paused_full`, and on device `02c`). All themes and languages. With the free-tier key, this is the state judges will see on every scan.
- **Problem:**
  - Each `_IdeaEntry` (`features/results/widgets/upcycle_ideas.dart:~265`) is a white card holding a numeral, a Fraunces title, a pitch and a meta line. The card is tappable, but nothing says so: no chevron, no action text.
  - Three stacked text cards under a pause callout read as a document, not as three things to open.
  - The display of recommendations is 15 % of the score, and this list is its first impression on a free key.
- **Fix:**
  - Add a trailing `Icon(KanzIcons.chevronForward, size: 20, color: c.inkSecondary)` (it mirrors in Arabic). Put it in a 24 dp end column, centered on the title's first line.
  - Give the card the same pressed state as `IdeaCard`: `surfaceSunken` overlay for `KanzMotion.fast`.
  - Keep the 36 dp numeral column and the Fraunces numeral as they are (B-02 fixed them).
  - Keep one pause callout above the list, as now.

### B-14 · low · The recyclable value wraps with a dangling separator
- **Where:** Results › specimen card, RECYCLABLE cell. All themes. EN "Recyclable ·" / "Glass bottle bank"; AR "قابل لإعادة التدوير ·" / "حاوية الزجاج".
- **Problem:** `resultsRecyclableValue` joins status and stream with " · " in one string. In a half-width grid cell it breaks after the separator, the same defect B-06 fixed for the pipeline summary.
- **Fix:** Render the cell as two lines by design: status with its glyph (`bodyMedium`), then the stream as `bodySmall` in `inkSecondary`, with no separator. Pass the stream as a separate `recyclableDetail` field on `SpecimenCard` rather than formatting one string.

---

## C. Tutorial and completion

### C-08 · medium · Dark mode: finished step segments still outshine the current one (carried over from round 1)
- **Where:**
  - Tutorial step, step failed and hands-free (dark EN and AR, 360 and 412).
  - Home › Continue your project card (dark).
  - History › My projects rows (dark).
- **Problem:** Done segments are still `ink` (`#F2EFE8`), the brightest pixels on screen. The clay current segment reads second, and in Arabic the bright done segment sits at the start edge where the eye lands first. This is the tutorial's signature progress bar, and severity goes up from low because it was not fixed.
- **Fix:**
  - Add a token `KanzColors.progressDone`: light `#161616` (ink), dark `#A8A59C` (inkSecondary, 7.02:1 on surface).
  - Use it in `StepProgressBar` and in the mini progress bars in `home_sections.dart` and `history_screen.dart`.
  - Current stays clay; upcoming stays `track`.
  - Document the token in DESIGN.md §2 and add it to `contrast_test.dart` at 3:1 against `track`.

### C-11 · medium · The made-photo camera changes color with the app theme
- **Where:** Completion › "Add a photo of what you made" › camera (`completion_camera`). Light vs dark, both languages.
- **Problem:**
  - The shutter disc is `#C65026` in light and `#F07A4F` in dark over the same camera image.
  - Round 1 (B-12) fixed this for the scan viewfinder by wrapping it in `KanzTheme.dark` (`features/scan/viewfinder.dart:67`). The new `made_photo_capture.dart` does not do the same.
  - The root cause is in the components: `ShutterButton` reads `context.kanzColors.accent` (`buttons.dart:388`) and `CornerBrackets` reads it when active (`viewfinder.dart:34`).
- **Fix:**
  - In the components, use `KanzPhotoColors.accent` for the shutter disc and the active brackets, as DESIGN.md §2 "On photos" already specifies. Then no camera screen depends on a theme wrapper.
  - Wrap the made-photo capture chrome in `Theme(data: KanzTheme.dark(locale: …))` like the scan viewfinder, so its icon buttons and hints match too.
  - Rename the gallery control label to "Gallery" / "المعرض" (`commonGallery`) to match the scan viewfinder, instead of "Choose from gallery".

### C-12 · medium · Adapt sheet and Settings use a different tool picker from onboarding
- **Where:** Tutorial › `adapt_sheet` and Settings › `tools_sheet`, all themes and languages.
- **Problem:**
  - Onboarding's tools step (`features/onboarding/tool_picker.dart`) now groups tools by use: Cutting, Measuring, Gluing and fastening, and so on. Each group has a glyph, a mono "2 / 4" count, "+" on unselected chips and "✓" on selected ones.
  - The adapt sheet shows "You have" plus one flat "Add a tool" wall of about 23 chips with no glyphs, cut at the bottom at 360.
  - The same user edits the same list in three places and meets two designs, and the flat wall is the weaker one.
- **Fix:**
  - Move the grouped picker out of `features/onboarding/` into a shared feature widget (for example `lib/features/common/tool_picker.dart`) and use it in the adapt sheet and the Settings tools sheet.
  - Keep the sheet's header line ("Tools · 3 selected / Leave a tool off and Kanz works around it") and the pinned "Rewrite the steps" bar with its 1 px `line` top border.
  - Open the sheet scrolled so the first group with a selected tool is visible.

### C-13 · low · Completion without a makeover: two equal buttons compete
- **Where:** Completion › `photo_only`, all themes and languages.
- **Problem:** "Add a photo of what you made" and "Share this project" are both full-width secondary buttons, stacked 16 dp apart. Adding a photo is the step that turns this page into a before/after and gives the share card its point. Sharing before that shares only the original photo.
- **Fix:** While no after image exists, make "Share this project" a `KanzButton.tertiary` with the share glyph, start-aligned. Once a photo is added, it becomes "Share before and after" as a secondary button, as the `own_photo` state already does.

---

## D. Drop-off, swaps, impact

### D-11 · medium · Drop-off map view: ink dots lead and nothing explains the marks
- **Where:** Drop-off › map view (`dropoff_map`), all themes and languages. The list view's plot is fine after round 1.
- **Problem:**
  - `pinColor` (`features/dropoff/place_info.dart:120`) paints listed places that accept several materials in solid `ink`. They are the heaviest marks on the plot (two of the six marks in the capture), heavier than the material-colored dots the design says should lead.
  - The map view has no key, so the three kinds of mark (colored dot, ink dot, ring) are unexplained there.
  - In dark mode the ink dots are the brightest marks.
- **Fix:**
  - Never paint a pin in ink. For a listed place with several accepted materials, use the color of the first accepted material that matches a selected category chip. If two or more match, draw a split dot: two half-discs in the first two matching material colors, with the 1 px `surface` halo.
  - Show the same `bodySmall` `inkSecondary` key line in the map view, at the top of the places sheet under the handle: "Colored dot: takes your materials · Ring: materials not listed" / AR "نقطة ملوّنة: تستقبل موادك · حلقة: المواد غير مذكورة".

### D-12 · low · Arabic Drop-off header wraps the List/Map toggle under the title
- **Where:** Drop-off tab header, Arabic at 100 % text, 360, both themes (EN keeps one row).
- **Problem:** `_header` (`dropoff_screen.dart:271`) is a `Wrap` with a fixed `_toggleWidth`. In Arabic, `headlineLarge` (Plex Arabic 25/38) plus the fixed-width toggle exceeds 320 dp, so the toggle drops to its own row, end-aligned and hugging. The Arabic header is about 56 dp taller than the English one, and the map is smaller.
- **Fix:** Size the toggle to its content (`IntrinsicWidth` around `SegmentedTabs`, 12 dp horizontal padding per segment) instead of `_toggleWidth`. The Arabic labels "قائمة" and "خريطة" are short and fit beside the title. Keep the `Wrap` only as the 130 % fallback.

### D-13 · low · Swaps loading shows two spinners
- **Where:** Swaps › `loading`, all themes and languages.
- **Problem:** "Find swaps" turns into a loading button with a spinner, and the sentence under it ("Finding swaps for plastic bags and cling film") has a second 14 dp spinner. Two spinners 40 dp apart say the same thing.
- **Fix:** Keep the button's `loading` state and drop the glyph from the sentence. Keep the sentence as `bodySmall` in `inkSecondary`, start-aligned on the gutter.

---

## X. Shared design system

### X-12 · medium · Arabic has two names for upcycle
- **Where:**
  - Results › the Upcycle segment: "تدوير إبداعي" (`resultsTabUpcycle`).
  - Everywhere else it is "إعادة ابتكار": Impact "Where they went" (`impactKindUpcycled`), `impactHowProjects`, `impactNoItemsYet`, `impactEmptyMessage`, onboarding welcome step 2, `historyProjectsEmptyBody`, `settingsAboutBody`.
- **Problem:** The one tab that names the path uses a different word from every screen that counts or explains it. Next to "إعادة تدوير", "تدوير إبداعي" also reads as a kind of recycling.
- **Fix:** Use the majority term. `resultsTabUpcycle`: "إعادة ابتكار". Check that the segment still fits at 360 with the count; it is the same length as today. Leave the other strings as they are.

### X-13 · medium · Arabic has two names for tutorial
- **Where:**
  - "الدرس": `ideaSeeTutorial` "اعرض الدرس", `homeResumeNotStarted` and `historyNotStarted` "لم تفتح الدرس بعد", `historyProjectsEmptyBody` "درسها", `onboardingWelcomeStep2Body` "بدرس".
  - "الدليل": the tutorial screen itself (11 strings: the mono label over the title, "عدّل هذا الدليل", offline copy).
- **Problem:** The idea screen's primary button says "اعرض الدرس" and opens a screen whose label says "الدليل". The same class of problem as X-06 in round 1.
- **Fix:** Use "الدليل" everywhere; it fits the field-guide voice and is already used by the screen itself.

  | Key | New Arabic |
  |---|---|
  | `ideaSeeTutorial` | "اعرض الدليل" |
  | `homeResumeNotStarted`, `historyNotStarted` | "لم تفتح الدليل بعد" |
  | `historyProjectsEmptyBody` | "اختر فكرة لإعادة الابتكار من أحد فحوصك وافتح دليلها، وسيُحفظ تقدّمك هنا." |
  | `onboardingWelcomeStep2Body` | "أعد ابتكاره بدليل خطوة بخطوة، أو أرسله للتدوير، أو تبرّع به." |

### X-14 · low · Two spellings of tanween in Arabic
- **Where:** `common_ar.arb` (12 strings), `completion_ar.arb` (6) and `tutorial_ar.arb` (4) put the fathatan after the alif ("مجدداً", "حسناً", "جداً", "قليلاً"). The other ten Arabic files put it on the letter before the alif ("مجددًا", "حاليًا", "غرضًا").
- **Problem:** Both spellings show on the same screen. On Scan › `gallery_failed`, the message says "ثم حاول مجددًا" and the button under it says "حاول مجدداً".
- **Fix:** Standardize on "ًا" (fathatan on the letter before the alif), which most files already use. Replace in the three files and re-run `dart run tool/merge_arb.dart && flutter gen-l10n`.

### X-15 · low · The same source chips are titled two ways
- **Where:** "BASED ON" (`resultsBasedOn`, `ideaBasedOn`, `tutorialSourcesLabel`) vs "SOURCES" (`swapsSources`, `dropoffSourcesLabel`). Arabic uses "المصادر" for both.
- **Problem:** One component (`SourceChips`), one meaning (the knowledge documents an answer used), two English titles.
- **Fix:** Use "Sources" everywhere. It matches Arabic and the mono label style, and "Based on" reads as the start of a sentence.

### X-16 · low · The AI-busy message repeats its own button
- **Where:** `commonErrorAiUnavailable`, shown under "Swaps didn't load" (Swaps error) and in any AI stage failure: "The AI service is busy right now. Try again in a moment." above a "Try again" button.
- **Problem:** The message and the button say the same thing, and nothing says what still works (DESIGN §9 and round-1 X-04).
- **Fix:**
  - EN: "Kanz's AI is busy right now. Saved scans and tutorials still open."
  - AR: "خدمة الذكاء الاصطناعي مشغولة الآن. ما زالت فحوصك وأدلّتك المحفوظة تُفتح."
  - The button alone says "Try again".
