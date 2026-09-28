// Home tab inside the real shell: content (resume card, recent scans,
// impact), first run, loading and error, across the screenshot matrix.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/insights/impact.dart';
import 'package:kanz/features/home/home_screen.dart';

import '../../screenshots/harness.dart';
import '../shell/foundation_support.dart';

void main() {
  setUpAll(loadKanzFonts);

  // A Monday, so the eyebrow reads the same in every run.
  final today = DateTime(2026, 9, 28);

  Future<void> shot(
    WidgetTester tester,
    ShotConfig config,
    String state, {
    required AsyncValue<List<Object>> scansState,
    bool withProjects = false,
  }) async {
    final arabic = config.isArabic;
    final overrides = await foundationOverrides(
      tester,
      scans: switch (scansState) {
        AsyncData() => AsyncData(
          scansState.value.isEmpty ? const [] : sampleScans(arabic: arabic),
        ),
        AsyncError(:final error) => AsyncError(error, StackTrace.empty),
        _ => const AsyncLoading(),
      },
      projects: AsyncData(
        withProjects ? sampleProjects(arabic: arabic) : const [],
      ),
      impact: AsyncData(withProjects ? sampleImpact : ImpactSummary.empty),
    );
    final router = shellRouter(home: HomeScreen(today: today));
    addTearDown(router.dispose);
    await takeShot(
      tester,
      name: 'home_$state',
      config: config,
      wrap: scoped(overrides),
      routerConfig: router,
      precache: samplePhotos(),
      localizationsDelegates: l10nDelegates,
    );
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('home content ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'content',
        scansState: const AsyncData([Object()]),
        withProjects: true,
      );
    });
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('home first run ${config.id}', (tester) async {
      await shot(tester, config, 'first_run', scansState: const AsyncData([]));
    });
  }

  // The whole page in one tall frame, for reviewing the lower sections.
  for (final config in tallConfigs) {
    testWidgets('home content tall ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'content_tall',
        scansState: const AsyncData([Object()]),
        withProjects: true,
      );
    });
    testWidgets('home first run tall ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'first_run_tall',
        scansState: const AsyncData([]),
      );
    });
  }

  for (final config in shotConfigs()) {
    testWidgets('home loading ${config.id}', (tester) async {
      await shot(tester, config, 'loading', scansState: const AsyncLoading());
    });
    testWidgets('home error ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'error',
        scansState: AsyncError(StateError('db'), StackTrace.empty),
      );
    });
  }
}
