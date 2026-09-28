// Shared fixtures and overrides for the foundation screens' tests (shell,
// onboarding, home, history, settings, permissions).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/data/db/database.dart' show ImpactKind, ProjectStatus;
import 'package:kanz/core/data/insights/impact.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/history_providers.dart';
import 'package:kanz/core/state/impact_providers.dart';
import 'package:kanz/features/history/scan_thumbnail.dart';
import 'package:kanz/features/shell/app_shell.dart';
import 'package:kanz/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screenshots/harness.dart';

/// App localizations for `takeShot`.
const l10nDelegates = [AppLocalizations.delegate];

/// Onboarding finished, so routes are not redirected.
const onboarded = <String, Object>{'settings.onboarding_done': true};

Vocab loadVocab() => Vocab.fromJson(
  jsonDecode(File('assets/config/vocab.json').readAsStringSync())
      as Map<String, dynamic>,
);

ImpactFactors loadImpactFactors() => ImpactFactors.fromJson(
  jsonDecode(File('assets/config/impact_factors.json').readAsStringSync())
      as Map<String, dynamic>,
);

/// A backend health answer from the contract fixture.
HealthResponse healthFixture() => HealthResponse.fromJson(
  jsonDecode(File('../contracts/fixtures/health.json').readAsStringSync())
      as Map<String, dynamic>,
);

/// Absolute path of a test photo in backend/eval/photos.
String photoPath(String name) {
  final candidates = [
    File('../backend/eval/photos/$name.jpg'),
    File('test/screenshots/fixtures/$name.jpg'),
  ];
  return candidates.firstWhere((f) => f.existsSync()).absolute.path;
}

/// Permission answers for screen tests, per permission, with a record of
/// what the screen asked.
class ScreenPermissions implements PermissionService {
  ScreenPermissions({
    this.camera = PermissionState.denied,
    this.location = PermissionState.denied,
    PermissionState? cameraAnswer,
    PermissionState? locationAnswer,
  }) : cameraAnswer = cameraAnswer ?? camera,
       locationAnswer = locationAnswer ?? location;

  PermissionState camera;
  PermissionState location;

  /// What the system dialog answers when asked.
  PermissionState cameraAnswer;
  PermissionState locationAnswer;

  final List<AppPermission> requests = [];
  int settingsOpened = 0;

  @override
  Future<PermissionState> status(AppPermission permission) async =>
      switch (permission) {
        AppPermission.camera => camera,
        AppPermission.location => location,
        AppPermission.microphone => PermissionState.granted,
      };

  @override
  Future<PermissionState> request(AppPermission permission) async {
    requests.add(permission);
    switch (permission) {
      case AppPermission.camera:
        camera = cameraAnswer;
      case AppPermission.location:
        location = locationAnswer;
      case AppPermission.microphone:
        break;
    }
    return status(permission);
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

/// Records deletions instead of touching a database.
class RecordingHistoryActions extends HistoryActions {
  RecordingHistoryActions(super.ref);

  final List<String> deleted = [];

  @override
  Future<void> deleteScan(String scanId) async => deleted.add(scanId);
}

Stream<T> _stream<T>(AsyncValue<T> value) => switch (value) {
  AsyncData(:final value) => Stream.value(value),
  AsyncError(:final error, :final stackTrace) => Stream.error(
    error,
    stackTrace,
  ),
  // Loading: a stream that never emits.
  _ => StreamController<T>().stream,
};

Future<T> _future<T>(AsyncValue<T> value) => switch (value) {
  AsyncData(:final value) => Future.value(value),
  AsyncError(:final error, :final stackTrace) => Future.error(
    error,
    stackTrace,
  ),
  _ => Completer<T>().future,
};

/// Everything the foundation screens read, overridden with fixture data.
/// [connection] replaces the backend status and health overrides.
Future<List<Override>> foundationOverrides(
  WidgetTester tester, {
  Map<String, Object> prefs = onboarded,
  AsyncValue<List<ScanSummary>> scans = const AsyncData([]),
  AsyncValue<List<ProjectRecord>> projects = const AsyncData([]),
  AsyncValue<ImpactSummary> impact = const AsyncData(ImpactSummary.empty),
  BackendStatus status = BackendStatus.online,
  AsyncValue<HealthResponse>? health,
  PermissionService? permissions,
  List<Override>? connection,
  List<Override> extra = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final preferences = (await tester.runAsync(SharedPreferences.getInstance))!;
  return [
    sharedPreferencesProvider.overrideWithValue(preferences),
    vocabProvider.overrideWithValue(loadVocab()),
    impactFactorsProvider.overrideWithValue(loadImpactFactors()),
    scanHistoryProvider.overrideWith((ref) => _stream(scans)),
    projectsProvider.overrideWith((ref) => _stream(projects)),
    impactProvider.overrideWithValue(impact),
    ...connection ??
        [
          backendStatusProvider.overrideWithValue(status),
          healthProvider.overrideWith(
            (ref) => _future(health ?? AsyncData(healthFixture())),
          ),
        ],
    permissionServiceProvider.overrideWithValue(
      permissions ?? ScreenPermissions(),
    ),
    ...extra,
  ];
}

/// A provider scope with no retries (a failing fixture must not leave
/// timers behind).
Widget Function(Widget app) scoped(List<Override> overrides) =>
    (app) => ProviderScope(
      overrides: overrides,
      retry: (count, error) => null,
      child: app,
    );

/// Scans for the Home strip and History, in the config's language, spread
/// over the last days.
List<ScanSummary> sampleScans({bool arabic = false, DateTime? now}) {
  final t = now ?? DateTime.now();
  String pick(String en, String ar) => arabic ? ar : en;
  return [
    ScanSummary(
      id: 'scan-jar',
      createdAt: t.subtract(const Duration(hours: 2)),
      source: AnalysisSource.image,
      title: pick('Glass jam jar', 'برطمان مربى زجاجي'),
      primaryCategory: MaterialCategory.glass,
      itemCount: 2,
      localImagePath: photoPath('glass_jar'),
      hasRecommendation: true,
    ),
    ScanSummary(
      id: 'scan-caps',
      createdAt: t.subtract(const Duration(hours: 5)),
      source: AnalysisSource.text,
      title: pick('Plastic bottle caps', 'أغطية قوارير بلاستيكية'),
      primaryCategory: MaterialCategory.plastic,
      itemCount: 1,
      inputText: pick(
        'A bag of plastic bottle caps from juice and water bottles',
        'كيس من أغطية قوارير العصير والماء البلاستيكية',
      ),
      hasRecommendation: true,
    ),
    ScanSummary(
      id: 'scan-shirt',
      createdAt: t.subtract(const Duration(days: 1, hours: 3)),
      source: AnalysisSource.image,
      title: pick('Cotton t-shirt', 'قميص قطني'),
      primaryCategory: MaterialCategory.textile,
      itemCount: 1,
      localImagePath: photoPath('old_tshirt'),
      hasRecommendation: true,
    ),
    ScanSummary(
      id: 'scan-batteries',
      createdAt: t.subtract(const Duration(days: 4)),
      source: AnalysisSource.image,
      title: pick('AA alkaline batteries', 'بطاريات قلوية AA'),
      primaryCategory: MaterialCategory.hazardous,
      itemCount: 4,
      localImagePath: photoPath('aa_batteries'),
      hasRecommendation: true,
    ),
    ScanSummary(
      id: 'scan-box',
      createdAt: t.subtract(const Duration(days: 9)),
      source: AnalysisSource.image,
      title: pick('Cardboard shipping box', 'صندوق شحن كرتوني'),
      primaryCategory: MaterialCategory.paper,
      itemCount: 1,
      localImagePath: photoPath('cardboard_box'),
      hasRecommendation: true,
    ),
    ScanSummary(
      id: 'scan-unfinished',
      createdAt: t.subtract(const Duration(days: 9, hours: 2)),
      source: AnalysisSource.image,
      itemCount: 0,
      localImagePath: photoPath('unclear_blurry'),
      hasRecommendation: false,
    ),
  ];
}

/// Every photo [sampleScans] shows, for `precache`.
List<ImageProvider> samplePhotos() => [
  for (final name in [
    'glass_jar',
    'old_tshirt',
    'aa_batteries',
    'cardboard_box',
    'unclear_blurry',
  ])
    scanPhotoImage(photoPath(name)),
];

List<ProjectRecord> sampleProjects({bool arabic = false, DateTime? now}) {
  final t = now ?? DateTime.now();
  String pick(String en, String ar) => arabic ? ar : en;
  return [
    ProjectRecord(
      id: 'project-lantern',
      scanId: 'scan-jar',
      ideaId: 'idea_9f2c41aa',
      title: pick('Hanging jar lantern', 'فانوس برطمان معلّق'),
      idea: null,
      status: ProjectStatus.inProgress,
      currentStep: 3,
      completedSteps: const {1, 2},
      totalSteps: 6,
      createdAt: t.subtract(const Duration(hours: 1)),
      updatedAt: t.subtract(const Duration(minutes: 20)),
    ),
    ProjectRecord(
      id: 'project-caps',
      scanId: 'scan-caps',
      ideaId: 'idea_caps',
      title: pick('Bottle cap mosaic coaster', 'قاعدة أكواب من أغطية القوارير'),
      idea: null,
      status: ProjectStatus.inProgress,
      currentStep: 1,
      completedSteps: const {},
      totalSteps: 0,
      createdAt: t.subtract(const Duration(hours: 4)),
      updatedAt: t.subtract(const Duration(hours: 4)),
    ),
    ProjectRecord(
      id: 'project-tote',
      scanId: 'scan-shirt',
      ideaId: 'idea_tote',
      title: pick('No-sew t-shirt tote bag', 'حقيبة من قميص قديم دون خياطة'),
      idea: null,
      status: ProjectStatus.completed,
      currentStep: 5,
      completedSteps: const {1, 2, 3, 4, 5},
      totalSteps: 5,
      createdAt: t.subtract(const Duration(days: 1)),
      updatedAt: t.subtract(const Duration(days: 1)),
      completedAt: DateTime(2026, 9, 27, 18, 40),
    ),
  ];
}

const sampleImpact = ImpactSummary(
  itemsByMaterial: {
    MaterialCategory.glass: 5,
    MaterialCategory.textile: 3,
    MaterialCategory.hazardous: 4,
  },
  itemsByKind: {
    ImpactKind.recycled: 7,
    ImpactKind.donated: 1,
    ImpactKind.disposed: 4,
  },
  projectsCompleted: 1,
  streakDays: 4,
  activeToday: true,
  estimatedMassKg: 3.2,
  co2eKgEstimate: 1.4,
  co2eDisclaimer: 'Estimate, verify before quoting.',
);

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(name, style: Theme.of(context).textTheme.headlineLarge),
      ),
    ),
  );
}

/// The real shell with [home] in the first tab and plain stand-ins for the
/// other teams' tabs, plus stubs for the routes the foundation screens
/// open. [log] records every stub route that was opened.
GoRouter shellRouter({
  required Widget home,
  String initialLocation = AppRoutes.home,
  List<String>? log,
  Map<String, WidgetBuilder> extraRoutes = const {},
}) {
  Widget stub(String name, GoRouterState state) {
    log?.add(state.uri.toString());
    return _Placeholder(name);
  }

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.home, builder: (c, s) => home)],
          ),
          for (final path in [
            AppRoutes.dropoff,
            AppRoutes.swaps,
            AppRoutes.impact,
          ])
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: (c, s) => stub(path, s))],
            ),
        ],
      ),
      for (final path in [
        '/scan',
        '/results/:scanId',
        '/results/:scanId/idea/:ideaId/tutorial',
        '/projects/:projectId/done',
        AppRoutes.history,
        AppRoutes.settings,
        AppRoutes.locationRationale,
        AppRoutes.cameraRationale,
        AppRoutes.cityPicker,
      ])
        if (!extraRoutes.containsKey(path))
          GoRoute(path: path, builder: (c, s) => stub(path, s)),
      for (final entry in extraRoutes.entries)
        GoRoute(
          path: entry.key,
          builder: (c, s) {
            log?.add(s.uri.toString());
            return entry.value(c);
          },
        ),
    ],
  );
}

/// A plain router around one screen at [path] (opened at [initialLocation],
/// default [path]), with stubs for the routes it can open (recorded in
/// [log]). Push the screen from '/' to test what it pops.
GoRouter screenRouter({
  required String path,
  required WidgetBuilder builder,
  String? initialLocation,
  List<String>? log,
  Map<String, WidgetBuilder> extraRoutes = const {},
}) {
  return GoRouter(
    initialLocation: initialLocation ?? path,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (c, s) => const _Placeholder('home'),
      ),
      GoRoute(path: path, builder: (c, s) => builder(c)),
      for (final entry in extraRoutes.entries)
        GoRoute(
          path: entry.key,
          builder: (c, s) {
            log?.add(s.uri.toString());
            return entry.value(c);
          },
        ),
      for (final stubPath in [
        '/scan',
        '/results/:scanId',
        '/results/:scanId/idea/:ideaId/tutorial',
        '/projects/:projectId/done',
        AppRoutes.history,
        AppRoutes.settings,
        AppRoutes.locationRationale,
        AppRoutes.cameraRationale,
        AppRoutes.cityPicker,
      ])
        if (stubPath != path && !extraRoutes.containsKey(stubPath))
          GoRoute(
            path: stubPath,
            builder: (c, s) {
              log?.add(s.uri.toString());
              return _Placeholder(stubPath);
            },
          ),
    ],
  );
}

/// Screenshot configs: the full matrix, plus 130 % text for the main state.
List<ShotConfig> shotConfigs({bool largeText = false}) => [
  ...ShotConfig.matrix(),
  if (largeText) ...[
    const ShotConfig(textScale: 1.3),
    const ShotConfig(locale: Locale('ar'), textScale: 1.3),
  ],
];

/// Tall frames showing a whole scrolling page, light English and dark
/// Arabic, for reviewing what sits below the fold.
List<ShotConfig> tallFrames({double height = 1800}) => [
  ShotConfig(size: Size(360, height)),
  ShotConfig(
    size: Size(360, height),
    brightness: Brightness.dark,
    locale: const Locale('ar'),
  ),
];

final tallConfigs = tallFrames();

/// Pumps [router] as the app under [overrides] (no screenshot) and returns
/// the provider container, for interaction tests.
Future<ProviderContainer> pumpRouted(
  WidgetTester tester,
  GoRouter router,
  List<Override> overrides, {
  Locale locale = const Locale('en'),
}) async {
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      retry: (count, error) => null,
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        theme: KanzTheme.light(locale: locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ),
  );
  await settle(tester);
  return ProviderScope.containerOf(
    tester.element(find.byType(Navigator).first),
  );
}

/// Pumps enough frames for entrances, page transitions and sheets to finish
/// (skeletons pulse forever, so `pumpAndSettle` is not an option there).
Future<void> settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
