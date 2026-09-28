# App Core: state and data API for the screens

Screens read state from the providers below and call controller methods. They
never use dio, drift, shared preferences or platform plugins directly. Every
provider is a plain Riverpod 3 provider (no code generation).

```dart
final session = ref.watch(scanSessionProvider(scanId));          // rebuild on change
ref.read(scanSessionProvider(scanId).notifier).retry(stage);      // call an action
```

| Folder | What lives there |
| --- | --- |
| `config/` | `kAppName`, `Env.apiBase` (`--dart-define=KANZ_API_BASE`), `Env.mapsEnabled` (`KANZ_MAPS=1`) |
| `data/models/` | Freezed mirror of `backend/app/schemas` (import `models.dart`); tested against every fixture |
| `data/vocab/` | `Vocab`: localized labels, material colors, tools, cities, quality labels |
| `data/db/`, `data/repositories/` | drift database (scans, projects, impact events, image cache) and settings |
| `data/insights/` | `computeImpact` and `buildHistorySummary` (pure functions) |
| `network/` | `ApiClient` and `ApiException` |
| `services/` | camera, gallery, compressor, permissions, location, connectivity, TTS, voice, share |
| `state/` | the providers documented here |

Localization helpers live in `lib/l10n/l10n.dart`: `context.l10n`,
`apiErrorMessage(l10n, error)`, `stageLabel`, `skillLabel`, `difficultyLabel`,
`levelLabel`, `recyclabilityLabel`, `photoIssueLabel`, `backendStatusLabel`,
`formatDistance`, `formatKg`, `formatCo2e`, `formatRelative`. Data keeps
Western digits in Arabic. Haptics come from the design system (`KanzHaptics`).

## Errors

Every failure is an `ApiException` with `code` (`ApiErrorCode`), `retryable`
and `requestId`. Show `apiErrorMessage(context.l10n, error)`; offer a retry
button when `error.retryable`. Client-side codes: `offline` (the server could
not be reached: no network, wrong URL or server down; `backendStatusProvider`
tells these apart), `timeout`, `cancelled` (ignore it), `badResponse`,
`interrupted` (a stage that was running when the app closed, restored from
history). `aiQuotaExhausted` is not retryable: on a free-tier key every
generated image fails with it, so hide "Try another image" for it.

## Navigation (`lib/app/router.dart`)

Use `AppRoutes` helpers: `context.push(AppRoutes.results(scanId))`,
`AppRoutes.idea(scanId, ideaId)`, `AppRoutes.tutorial(scanId, ideaId)`,
`AppRoutes.completion(projectId)`, `AppRoutes.scan(ScanMode.gallery)`.
`/city` pops with a city id string: `final id = await context.push<String>(AppRoutes.cityPicker)`,
then `CityId.tryFromId(id)`. Until `settingsProvider.onboardingDone` is true,
every route except onboarding, the rationales and `/city` redirects to
`/onboarding`.

## Settings and profile

| Provider | Type | Notes |
| --- | --- | --- |
| `settingsProvider` | `AppSettings` | `locale` (`LocalePref.system/en/ar`), `themeMode`, `skill`, `tools`, `onboardingDone`, `locationMode` (`gps`/`city`, null = undecided), `city`, `apiBaseUrl`, `handsFree` |
| `settingsProvider.notifier` | `SettingsController` | `setLocale`, `setThemeMode`, `setSkill`, `setTools`, `toggleTool`, `completeOnboarding`, `setLocationMode`, `setCity`, `useCity(city)` (also sets city mode), `setApiBaseUrl(url or null)`, `setHandsFree(enabled:)` |
| `appLocaleProvider` | `Locale?` | null follows the phone |
| `contentLangProvider` | `Lang` | language sent to the AI; with "Phone language" it follows the phone's languages like MaterialApp does, and changes with them |
| `systemLocalesProvider` | `List<Locale>` | the phone's preferred languages, kept current by `KanzApp` |
| `profileProvider` | `Profile` | skill, tools, lang for requests |
| `vocabProvider` | `Vocab` | `material(id).label.forLocale(locale)`, `.color`, `realTools`, `safetyGear`, `cities`, `qualityLabel(score)`, `nearestCity(lat, lng)` |

Tools never include protective gear (`gloves`, `safety_glasses`, `dust_mask`);
show those from `vocab.safetyGear` in safety sections.

## Backend status

| Provider | Type | Notes |
| --- | --- | --- |
| `healthProvider` | `AsyncValue<HealthResponse>` | read once at launch to warm the backend; refresh with `ref.invalidate(healthProvider)` |
| `networkAvailableProvider` | `AsyncValue<bool>` | any network interface up |
| `backendStatusProvider` | `BackendStatus` | `checking`, `online`, `offline` (airplane mode), `unreachable` (wrong URL or server down); label with `backendStatusLabel` |
| `apiBaseUrlProvider` | `String` | the URL in use (Settings override or build default) |

## Scan pipeline: `scanSessionProvider(scanId)`

Start a scan on the scan screen, then navigate:

```dart
final scanId = newScanId();
ref.read(scanSessionProvider(scanId).notifier).startFromPhoto(path: file.path); // or bytes:
// or .startFromText('a pile of old denim jeans')
context.go(AppRoutes.results(scanId));
```

Give the description field `maxLength: ScanSession.maxDescriptionLength` (600,
what the Material Analyst reads); longer text is cut there.

The session compresses the photo (1600 px, JPEG q85, EXIF applied then
removed), runs `analyze`, then `recommend` automatically, then drop-off and
the three after images in parallel, and saves every stage to the database.
Opening an id that is not running restores it from History (offline).

`ScanSessionState`:

| Field | Meaning |
| --- | --- |
| `origin` | `loading` (looking up history), `live`, `restored`, `missing` (unknown id) |
| `stage(PipelineStage.x)` | `StageState {status, error}` for `identifying`, `ideas`, `dropoff`, `makeovers`; label with `stageLabel` |
| `StageStatus` | `pending`, `running`, `done`, `failed`, `skipped` (disposal only / nothing to search), `needsLocation` |
| `rejectedPhoto` | set when the photo is unusable: show `retakeTip` (and `photoIssueLabel(l10n, issue)`) with a retake button; `identifying` is `failed` with no error |
| `analysis` | `AnalyzeResponse` (`analysis.analysis.items`, `imageWidth/Height` for boxes); shortcuts `items`, `itemById`, `focusItem` |
| `localImagePath` | the photo on the device (use `Image.file`) |
| `recommendation` | `RecommendResponse`; shortcuts `ideas`, `isDisposalOnly` |
| `facilities`, `dropoffLocation` | places and where they were searched (`SearchLocationSource.gps/city/nearestCity`) |
| `afterImage(ideaId)` | `GeneratedImageState {status idle/loading/ready/failed, url, localPath, error}`; prefer `localPath`, fall back to `url` |
| `referenceImage` | text scans only: a generated photo of the described item, the "before" side of the before/after slider (photo scans use `localImagePath`); may stay `failed` (e.g. no image quota), then show the description instead |
| `isBusy` | any stage running |

Actions on `scanSessionProvider(scanId).notifier`:

| Method | Effect |
| --- | --- |
| `retry(PipelineStage stage)` | re-runs that stage and what depends on it (`makeovers` retries only failed images). Each stage fails on its own: a drop-off or image failure never marks the ideas as failed |
| `resumeDropoff()` | after `needsLocation`: call once the user granted location (`settings.setLocationMode(LocationMode.gps)`) or picked a city (`settings.useCity(city)`) |
| `correctItem(itemId, ItemCorrection(name:, category:, material:, quantityValue:, quantityUnit:, qualityScore:, state:, hazards:))` | marks `user_corrected`, rebuilds the quantity and quality labels in the scan language, re-runs recommend, drop-off and images |
| `focusItem(itemId)` | ideas for another item of a multi-item photo |
| `regenerateAfterImage(ideaId)` | asks for a new after image |
| `markRecycled(ids)`, `markDonated(ids)`, `markDisposed(ids)` | impact events (idempotent per item) |

`markedItemsProvider((scanId: id, kind: ImpactKind.recycled))` streams the item
ids already marked, for checked states.

## Tutorial: `tutorialControllerProvider((scanId: s, ideaId: i))`

Loads or creates the project, fetches the tutorial for the profile (or reuses
the stored one offline), then step images in order: step 1 first, the rest one
by one in the background. A failed step stops the chain (no wasted calls);
`regenerateStep(n)` retries it and continues.

`TutorialState`: `phase` (`loading`, `ready`, `failed` + `error`), `tutorial`,
`idea`, `project`, `skill`, `tools`, `adapting`, `adaptError`, `adaptedNote`,
`currentStep` (1-based), `completedSteps`, `completed`, `steps`, `stepCount`,
`isFirstStep`, `isLastStep`, `allStepsDone`, `step(n)`, `stepImage(n)`
(`GeneratedImageState`).

Actions: `adapt(skill:, tools:)` (new tutorial for another skill or tool set;
the previous one stays visible while `adapting`; the same skill and tools do
nothing), `goToStep(n)`, `next()`,
`previous()`, `markStepDone(n, done: true)`, `regenerateStep(n)`, `retry()`,
`complete()` (returns the project id for `AppRoutes.completion`; records one
"upcycled" impact event per scanned item used; calling it again changes
nothing).

### Hands-free: `handsFreeProvider((scanId: s, ideaId: i))`

Auto-disposed with the tutorial screen. `HandsFreeState`: `enabled`,
`listening`, `speaking`, `lastCommand` (`VoiceCommand.next/back/repeat`),
`voiceUnavailable` (no mic or recognizer: buttons still work),
`speechUnavailable` (no voice for the language). Actions: `enable()`,
`disable()`, `toggle()`, `speakCurrentStep()`. Start it when
`settingsProvider.handsFree` is on. Commands: "next", "back"/"previous",
"repeat"/"again", "التالي", "السابق"/"رجوع", "كرر"/"أعد".

## Drop-off tab: `dropoffControllerProvider`

State: `catalog` (filter chips), `catalogLoading`, `catalogError`,
`selectedCategories`, `typeFilter` (empty = all), `location`, `needsLocation`,
`searching`, `results`, `error`, `visiblePlaces` (after the type filter),
`selectedPlace`, `view` (`DropoffView.list/map`), `mapAvailable`.

Actions: `toggleCategory(key)`, `showCategories(keys)` (e.g. from a scan's
`recommendation.facilityCategories`), `toggleType(type)`, `clearTypes()`,
`useCity(city)`, `useMyLocation()` (after permission), `search()`,
`selectPlace(id)`, `setView(view)`, `loadCatalog()` (retry for
`catalogError`; `search()` is the retry for `error`). It starts with the
latest scan's categories, or glass, plastic, paper and metal, and searches
even when the chip catalog could not load. A language switch reloads the
chips and the results.

## Swaps tab: `swapsControllerProvider`

State: `selectedChips`, `freeText`, `useHistory`, `history`
(`HistorySummary` of the last 30 days), `hasHistory`, `loading`, `results`
(`SwapsResponse`), `error`, `canSubmit`. Actions: `toggleChip(id)`,
`setFreeText(text)` (commas split entries), `setUseHistory(enabled:)`,
`submit()`, `clear()`, `refreshHistory()`.

## History, projects and impact

| Provider | Type |
| --- | --- |
| `scanHistoryProvider` | `AsyncValue<List<ScanSummary>>` newest first: `title`, `primaryCategory`, `itemCount`, `localImagePath`, `inputText`, `createdAt`, `hasRecommendation` |
| `projectsProvider` | `AsyncValue<List<ProjectRecord>>`: `title`, `idea`, `tutorial`, `status`, `progress`, `currentStep`, `completedSteps`, `completedAt` |
| `projectProvider(projectId)` | `AsyncValue<ProjectRecord?>` (completion screen) |
| `historyActionsProvider` | `deleteScan(scanId)`: removes the scan, its projects, its photo and its generated images (impact stays) |
| `impactProvider` | `AsyncValue<ImpactSummary>`: `totalItems`, `itemsByMaterial`, `itemsByKind`, `projectsCompleted`, `streakDays`, `activeToday`, `estimatedMassKg`, `co2eKgEstimate` |

The CO2e figure comes from `assets/config/impact_factors.json` and is an
estimate: always show `l10n.commonCo2eDisclaimer` next to `formatCo2e(...)`.

## Services the screens use directly

| Provider | Use |
| --- | --- |
| `cameraServiceProvider` | `start()` in initState, `handleLifecycle(state)` from `didChangeAppLifecycleState`, `capture()`, `setTorch(on:)`, `stop()` in dispose; preview with `CameraPreview(service.controller!)`; errors are `CameraUnavailable(reason)` |
| `galleryPickerProvider` | `pick()`, `recoverLost()` on first build |
| `permissionServiceProvider` | `status(AppPermission.camera/location/microphone)`, `request(...)`, `openSettings()`; `PermissionState.permanentlyDenied` means only Settings can grant it |
| `shareServiceProvider` | `share(text:, imagePath:)` |

## Tests

`flutter test test/core` covers the models against every fixture, the API
client, repositories, the scan pipeline, the tutorial controller, drop-off and
swaps, impact and streak, the ARB merge tool and the router. Fakes for new
tests are in `test/core/support/fakes.dart` (`TestHarness.create()`).
