// Shared data and fakes for the scan, results and idea screen tests: scan
// sessions built from the contract fixtures and the real test photos, a
// session notifier that records what the screens ask of it, the provider
// scope the screens need, and a second capture after an interaction.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/app/routes.dart';
import 'package:kanz/core/design/design.dart' show KanzTheme;
import 'package:kanz/core/data/db/database.dart' show ImpactKind;
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/location_resolver.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/idea/idea_screen.dart';
import 'package:kanz/features/results/results_screen.dart';
import 'package:kanz/features/scan/scan_screen.dart';
import 'package:kanz/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/support/fixtures.dart';
import '../../screenshots/harness.dart';

// ------------------------------------------------------------------ photos

/// Absolute path of a test photo in backend/eval/photos.
String photoPath(String name) =>
    File('../backend/eval/photos/$name.jpg').absolute.path;

/// The provider the screens build for [photoPath] (same key, so a precached
/// photo is found in the image cache).
ImageProvider photoImage(String name) => FileImage(File(photoPath(name)));

Vocab? _vocab;

/// The app's vocabulary, read once.
Vocab testVocab() => _vocab ??= Vocab.fromJson(
  jsonDecode(File('assets/config/vocab.json').readAsStringSync())
      as Map<String, dynamic>,
);

// --------------------------------------------------------------- fixtures

/// Contract fixtures in English or Arabic, with boxes that sit on the real
/// test photos (the fixtures' boxes are placeholders).
abstract final class ScanFixtures {
  static AnalyzeResponse jarAnalysis({bool arabic = false}) {
    final response = AnalyzeResponse.fromJson(
      fixture(arabic ? 'analyze_glass_jar_ar.json' : 'analyze_glass_jar.json'),
    );
    return response.copyWith(
      imageWidth: 1600,
      imageHeight: 1067,
      analysis: response.analysis.copyWith(
        items: [
          for (final item in response.analysis.items)
            item.copyWith(
              bbox: item.id == 'item_1'
                  ? const BBox(x: 0.33, y: 0.205, w: 0.335, h: 0.735)
                  : const BBox(x: 0.33, y: 0.205, w: 0.337, h: 0.13),
            ),
        ],
      ),
    );
  }

  static RecommendResponse jarRecommendation({bool arabic = false}) =>
      RecommendResponse.fromJson(
        fixture(
          arabic ? 'recommend_glass_jar_ar.json' : 'recommend_glass_jar.json',
        ),
      );

  static AnalyzeResponse batteryAnalysis() {
    final response = AnalyzeResponse.fromJson(fixture('analyze_battery.json'));
    return response.copyWith(
      analysis: response.analysis.copyWith(
        items: [
          response.analysis.items.single.copyWith(
            bbox: const BBox(x: 0.25, y: 0.07, w: 0.62, h: 0.82),
          ),
        ],
      ),
    );
  }

  static RecommendResponse batteryRecommendation() =>
      RecommendResponse.fromJson(fixture('recommend_battery.json'));

  static AnalyzeResponse unclearAnalysis() =>
      AnalyzeResponse.fromJson(fixture('analyze_unclear.json'));

  static AnalyzeResponse textCapsAnalysis() =>
      AnalyzeResponse.fromJson(fixture('analyze_text_caps.json'));

  /// The fixture places with names that read like real ones.
  static FacilitiesResponse places({bool arabic = false}) {
    final response = FacilitiesResponse.fromJson(
      fixture('facilities_glass.json'),
    );
    final names = arabic
        ? const [
            'حاوية الزجاج في حديقة الخالدية',
            'مركز إعادة التدوير في مصفح',
            'نقطة تجميع البطين',
          ]
        : const [
            'Khalidiyah Park glass bank',
            'Musaffah recycling centre',
            'Al Bateen collection point',
          ];
    final addresses = arabic
        ? const ['شارع الخليج العربي', 'المنطقة الصناعية 12', null]
        : const ['Arabian Gulf Street', 'Industrial area M12', null];
    return response.copyWith(
      centerLabel: arabic ? 'أبوظبي' : 'Abu Dhabi',
      places: [
        for (var i = 0; i < response.places.length; i++)
          response.places[i].copyWith(name: names[i], address: addresses[i]),
      ],
    );
  }

  static Map<PipelineStage, StageState> stages({
    StageStatus identifying = StageStatus.done,
    StageStatus ideas = StageStatus.done,
    StageStatus dropoff = StageStatus.done,
    StageStatus makeovers = StageStatus.done,
    ApiException? ideasError,
    ApiException? dropoffError,
    ApiException? makeoversError,
  }) => {
    PipelineStage.identifying: StageState(status: identifying),
    PipelineStage.ideas: StageState(status: ideas, error: ideasError),
    PipelineStage.dropoff: StageState(status: dropoff, error: dropoffError),
    PipelineStage.makeovers: StageState(
      status: makeovers,
      error: makeoversError,
    ),
  };

  /// Every idea's after image ready, the photo standing in for the makeover
  /// (image generation needs a billed key).
  static Map<String, GeneratedImageState> readyImages(
    RecommendResponse recommendation, {
    String photo = 'glass_jar',
  }) => {
    for (final idea in recommendation.upcycle)
      idea.id: GeneratedImageState(
        status: ImageStatus.ready,
        url: 'http://kanz.test/static/generated/${idea.id}.jpg?v=1',
        localPath: photoPath(photo),
      ),
  };

  /// What this server does today: every image fails on the free-tier quota.
  static Map<String, GeneratedImageState> pausedImages(
    RecommendResponse recommendation,
  ) => {
    for (final idea in recommendation.upcycle)
      idea.id: const GeneratedImageState(
        status: ImageStatus.failed,
        error: quotaError,
      ),
  };

  static const quotaError = ApiException(
    code: ApiErrorCode.aiQuotaExhausted,
    message: 'Image quota exhausted.',
    retryable: false,
    requestId: 'req_7c1e0a44',
  );

  static const offlineError = ApiException.offline();

  /// A photo scan of the glass jar at any point of its pipeline.
  static ScanSessionState jar({
    bool arabic = false,
    String scanId = 'scan_jar',
    Map<PipelineStage, StageState>? stages,
    bool analysis = true,
    bool recommendation = true,
    bool facilities = true,
    Map<String, GeneratedImageState>? images,
    SearchLocation? location = const SearchLocation.city(CityId.abuDhabi),
    String? focusItemId,
  }) {
    final rec = jarRecommendation(arabic: arabic);
    return ScanSessionState(
      scanId: scanId,
      origin: ScanOrigin.live,
      lang: arabic ? Lang.ar : Lang.en,
      localImagePath: photoPath('glass_jar'),
      stages: stages ?? ScanFixtures.stages(),
      analysis: analysis ? jarAnalysis(arabic: arabic) : null,
      recommendation: recommendation ? rec : null,
      facilities: facilities ? places(arabic: arabic) : null,
      dropoffLocation: location,
      afterImages: images ?? (recommendation ? readyImages(rec) : const {}),
      focusItemId: focusItemId,
    );
  }

  /// Four used batteries: disposal only, hazardous drop-off points.
  static ScanSessionState battery({String scanId = 'scan_battery'}) =>
      ScanSessionState(
        scanId: scanId,
        origin: ScanOrigin.restored,
        localImagePath: photoPath('aa_batteries'),
        stages: stages(makeovers: StageStatus.skipped),
        analysis: batteryAnalysis(),
        recommendation: batteryRecommendation(),
        facilities: places(),
        dropoffLocation: const SearchLocation.city(CityId.abuDhabi),
      );

  static ScanSessionState rejected({String scanId = 'scan_unclear'}) {
    final analysis = unclearAnalysis();
    return ScanSessionState(
      scanId: scanId,
      origin: ScanOrigin.live,
      localImagePath: photoPath('unclear_blurry'),
      stages: {
        PipelineStage.identifying: const StageState(status: StageStatus.failed),
      },
      analysis: analysis,
      rejectedPhoto: analysis.analysis.photo,
    );
  }

  /// A text scan whose generated images all fail on the quota.
  static ScanSessionState textScan({String scanId = 'scan_text'}) {
    final rec = jarRecommendation();
    return ScanSessionState(
      scanId: scanId,
      origin: ScanOrigin.live,
      source: AnalysisSource.text,
      inputText: 'About thirty plastic bottle caps in mixed colours',
      stages: stages(makeovers: StageStatus.failed, makeoversError: quotaError),
      analysis: textCapsAnalysis(),
      recommendation: rec,
      facilities: places(),
      dropoffLocation: const SearchLocation.city(CityId.dubai),
      afterImages: pausedImages(rec),
      referenceImage: const GeneratedImageState(
        status: ImageStatus.failed,
        error: quotaError,
      ),
    );
  }
}

// ------------------------------------------------------------------ fakes

/// A scan session that shows a fixed state and records every action.
class FixedScanSession extends ScanSession {
  FixedScanSession(super.scanId, this.initial);

  final ScanSessionState initial;
  final List<String> calls = [];
  ItemCorrection? lastCorrection;

  @override
  ScanSessionState build() => initial;

  /// Moves the session to [next], as the real pipeline would.
  void emit(ScanSessionState next) => state = next;

  @override
  Future<void> startFromPhoto({String? path, Uint8List? bytes}) async {
    calls.add('photo:$path');
    state = state.copyWith(
      origin: ScanOrigin.live,
      localImagePath: path,
      stages: const {
        PipelineStage.identifying: StageState(status: StageStatus.running),
      },
    );
  }

  @override
  Future<void> startFromText(String text) async {
    calls.add('text:$text');
    state = state.copyWith(
      origin: ScanOrigin.live,
      source: AnalysisSource.text,
      inputText: text,
    );
  }

  @override
  Future<void> retry(PipelineStage stage) async =>
      calls.add('retry:${stage.name}');

  @override
  Future<void> resumeDropoff() async => calls.add('resumeDropoff');

  @override
  Future<void> correctItem(String itemId, ItemCorrection changes) async {
    calls.add('correct:$itemId');
    lastCorrection = changes;
  }

  @override
  Future<void> focusItem(String itemId) async => calls.add('focus:$itemId');

  @override
  Future<void> regenerateAfterImage(String ideaId) async =>
      calls.add('regenerate:$ideaId');

  @override
  Future<void> markRecycled(Iterable<String> itemIds) async =>
      calls.add('recycled:${itemIds.join(',')}');

  @override
  Future<void> markDonated(Iterable<String> itemIds) async =>
      calls.add('donated:${itemIds.join(',')}');

  @override
  Future<void> markDisposed(Iterable<String> itemIds) async =>
      calls.add('disposed:${itemIds.join(',')}');
}

/// Sessions created by a scope, by scan id, so tests can inspect them.
class SessionLog {
  final Map<String, FixedScanSession> sessions = {};

  FixedScanSession operator [](String id) => sessions[id]!;
}

/// Shared preferences with onboarding done, a few tools and Abu Dhabi.
Future<SharedPreferences> testPreferences({
  Map<String, Object> extra = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    'settings.onboarding_done': true,
    'settings.tools': ['scissors', 'pliers', 'twine'],
    'settings.location_mode': 'city',
    'settings.city': 'abu_dhabi',
    ...extra,
  });
  return SharedPreferences.getInstance();
}

/// The overrides the scan, results and idea screens need: [sessions] by scan
/// id (unknown ids start empty), the vocabulary, settings, backend status
/// and the marked-items streams.
List<Override> screenOverrides({
  required SharedPreferences preferences,
  Map<String, ScanSessionState> sessions = const {},
  SessionLog? log,
  BackendStatus status = BackendStatus.online,
  Map<ImpactKind, Set<String>> marked = const {},
  List<Override> extra = const [],
}) => [
  sharedPreferencesProvider.overrideWithValue(preferences),
  vocabProvider.overrideWithValue(testVocab()),
  backendStatusProvider.overrideWithValue(status),
  scanSessionProvider.overrideWith2((id) {
    final session = FixedScanSession(
      id,
      sessions[id] ?? ScanSessionState(scanId: id, origin: ScanOrigin.live),
    );
    log?.sessions[id] = session;
    return session;
  }),
  markedItemsProvider.overrideWith(
    (ref, key) => Stream.value(marked[key.kind] ?? const <String>{}),
  ),
  ...extra,
];

// ---------------------------------------------------------------- capture

/// Key of a boundary around the whole app (use [withBoundary] as the
/// outermost `wrap`), so the screen can be captured again after a tap.
final GlobalKey shotBoundaryKey = GlobalKey(debugLabel: 'core-flow-capture');

Widget withBoundary(Widget app) =>
    RepaintBoundary(key: shotBoundaryKey, child: app);

/// Pumps [frames] 100 ms frames and writes `_out/<name>_<config.id>.png`.
Future<void> captureAgain(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  int frames = 10,
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(shotBoundaryKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  final out = File('test/screenshots/_out/${name}_${config.id}.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(bytes!);
}

/// A tall phone viewport that shows a whole scrolling screen at once, for
/// reviewing everything below the fold.
ShotConfig tall(ShotConfig config, {double height = 3200}) => ShotConfig(
  size: Size(config.size.width, height),
  brightness: config.brightness,
  locale: config.locale,
  textScale: config.textScale,
);

/// Light and dark, English and Arabic, at 360 dp.
List<ShotConfig> compactMatrix() =>
    ShotConfig.matrix(sizes: const [ShotConfig.compact]);

/// Lets pending microtasks and stream events land.
Future<void> settleAsync(WidgetTester tester) => tester.runAsync(
  () => Future<void>.delayed(const Duration(milliseconds: 20)),
);

/// Decodes local photos into the image cache before a screen asks for them.
///
/// A `FileImage` first resolved inside the test's fake-async zone never
/// finishes reading its file, so the photos are loaded here, for real,
/// before the screen is pumped; the screen then finds them in the cache.
Future<void> precacheFiles(WidgetTester tester, Iterable<String> paths) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final context = tester.element(find.byType(SizedBox));
  await tester.runAsync(
    () => Future.wait([
      for (final path in paths.toSet())
        precacheImage(FileImage(File(path)), context),
    ]),
  );
}

// ------------------------------------------------------------ interactions

/// A page that pops with [value] as soon as it opens, standing in for the
/// city picker and the permission rationales (built by another team).
class PopWith extends StatefulWidget {
  const PopWith(this.value, {super.key});

  final Object? value;

  @override
  State<PopWith> createState() => _PopWithState();
}

class _PopWithState extends State<PopWith> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Navigator.of(context).pop(widget.value),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// The app's routes for the core flow, with stand-ins for the screens other
/// teams build: Home, Drop-off, the tutorial, the city picker ([city] is
/// what it answers) and the rationales.
GoRouter coreFlowRouter(String initialLocation, {String? city = 'dubai'}) =>
    GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/dropoff', builder: (_, _) => const Text('dropoff')),
        GoRoute(path: '/city', builder: (_, _) => PopWith(city)),
        GoRoute(
          path: '/permissions/camera',
          builder: (_, _) => const PopWith(null),
        ),
        GoRoute(
          path: '/permissions/location',
          builder: (_, _) => const PopWith(null),
        ),
        GoRoute(
          path: '/scan',
          builder: (_, state) => ScanScreen(
            mode: ScanMode.parse(state.uri.queryParameters['mode']),
          ),
        ),
        GoRoute(
          path: '/results/:scanId',
          builder: (_, state) =>
              ResultsScreen(scanId: state.pathParameters['scanId']!),
          routes: [
            GoRoute(
              path: 'idea/:ideaId',
              builder: (_, state) => IdeaScreen(
                scanId: state.pathParameters['scanId']!,
                ideaId: state.pathParameters['ideaId']!,
              ),
              routes: [
                GoRoute(
                  path: 'tutorial',
                  builder: (_, _) => const Text('tutorial'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

/// The app shell for interaction tests: theme, both languages, a router and
/// the provider overrides.
Widget coreFlowApp({
  required GoRouter router,
  required List<Override> overrides,
  Locale locale = const Locale('en'),
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(
    theme: KanzTheme.light(locale: locale),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    routerConfig: router,
  ),
);

/// Pumps frames until nothing is scheduled, without waiting on the spinners
/// and skeletons that animate forever.
Future<void> pumpFrames(WidgetTester tester, [int count = 10]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls the screen's main (vertical) list until [finder] is built and on
/// screen. Long screens build their lower sections lazily.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    400,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first,
  );
  await tester.pump();
}
