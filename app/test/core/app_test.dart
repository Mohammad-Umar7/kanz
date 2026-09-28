import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/app/app.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/settings_providers.dart';
import 'package:kanz/features/home/home_screen.dart';
import 'package:kanz/features/onboarding/onboarding_screen.dart';
import 'package:kanz/features/results/results_screen.dart';
import 'package:kanz/features/tutorial/tutorial_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late TestHarness h;

  tearDown(() => h.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(container: h.container, child: const KanzApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding comes first, then the home tab', (tester) async {
    h = await tester.runAsync(TestHarness.create) as TestHarness;
    await pumpApp(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(h.container.read(settingsProvider).onboardingDone, isTrue);
    expect(h.api.calls, contains('health'), reason: 'backend warm-up');
  });

  testWidgets('deep links resolve every path parameter', (tester) async {
    h =
        await tester.runAsync(
              () =>
                  TestHarness.create(prefs: {'settings.onboarding_done': true}),
            )
            as TestHarness;
    await pumpApp(tester);
    final router = h.container.read(routerProvider);

    router.go(AppRoutes.results('scan-1'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ResultsScreen>(find.byType(ResultsScreen)).scanId,
      'scan-1',
    );

    router.go(AppRoutes.tutorial('scan-1', 'idea_1'));
    await tester.pumpAndSettle();
    final tutorial = tester.widget<TutorialScreen>(find.byType(TutorialScreen));
    expect((tutorial.scanId, tutorial.ideaId), ('scan-1', 'idea_1'));
    expect(
      router.routeInformationProvider.value.uri.path,
      '/results/scan-1/idea/idea_1/tutorial',
    );
  });

  testWidgets('Arabic switches the app to right-to-left', (tester) async {
    h =
        await tester.runAsync(
              () => TestHarness.create(
                prefs: {
                  'settings.onboarding_done': true,
                  'settings.locale': 'ar',
                },
              ),
            )
            as TestHarness;
    await pumpApp(tester);

    final context = tester.element(find.byType(HomeScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(context.l10n.commonAppName, 'كنز');
    expect(GoRouter.of(context).state.matchedLocation, AppRoutes.home);
    expect(h.container.read(contentLangProvider).id, 'ar');
    expect(h.container.read(apiBaseUrlProvider), isNotEmpty);
  });

  testWidgets('phone language drives AI content and follows changes', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    h =
        await tester.runAsync(
              () =>
                  TestHarness.create(prefs: {'settings.onboarding_done': true}),
            )
            as TestHarness;
    await pumpApp(tester);

    // French is not supported, so like MaterialApp the next preference wins.
    tester.platformDispatcher.localesTestValue = const [
      Locale('fr'),
      Locale('ar', 'AE'),
    ];
    await tester.pumpAndSettle();
    expect(h.container.read(contentLangProvider), Lang.ar);
    expect(
      Directionality.of(tester.element(find.byType(HomeScreen))),
      TextDirection.rtl,
    );

    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    await tester.pumpAndSettle();
    expect(h.container.read(contentLangProvider), Lang.en);
    expect(
      Directionality.of(tester.element(find.byType(HomeScreen))),
      TextDirection.ltr,
    );
  });

  testWidgets('the launch health check retries while the backend starts', (
    tester,
  ) async {
    h =
        await tester.runAsync(
              () =>
                  TestHarness.create(prefs: {'settings.onboarding_done': true}),
            )
            as TestHarness;
    var attempts = 0;
    h.api.onHealth = () async {
      if (++attempts == 1) throw const ApiException.timeout();
      return HealthResponse.fromJson(fixture('health.json'));
    };
    await pumpApp(tester);
    expect(attempts, 1);

    // The provider's own retry policy: once more after two seconds.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(h.container.read(backendStatusProvider), BackendStatus.online);
  });
}
