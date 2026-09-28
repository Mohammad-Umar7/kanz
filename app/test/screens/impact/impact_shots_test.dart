// Renders every Impact state at 360 and 412 dp, light and dark, English and
// Arabic (plus 130 % text for the numbers) into test/screenshots/_out/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/impact_providers.dart';
import 'package:kanz/features/impact/impact_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import '../dropoff/tab_test_support.dart';
import 'impact_fixtures.dart';

Future<void> _shot(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  required AsyncValue<ImpactSummary> value,
}) async {
  await takeShot(
    tester,
    name: name,
    config: config,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    wrap: (app) => withCaptureBoundary(
      ProviderScope(
        overrides: [
          vocabProvider.overrideWithValue(testVocab()),
          impactProvider.overrideWithValue(value),
        ],
        child: app,
      ),
    ),
    child: inShell(const ImpactScreen(), tab: 3, arabic: config.isArabic),
  );
}

void main() {
  setUpAll(loadKanzFonts);

  for (final config in contentConfigs) {
    testWidgets('impact content ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'impact_content',
        config: config,
        value: AsyncData(richSummary()),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -560));
      await tester.pump();
      await captureAgain(tester, name: 'impact_content_more', config: config);
    });
  }

  for (final config in stateConfigs) {
    testWidgets('impact nudge ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'impact_nudge',
        config: config,
        value: AsyncData(richSummary(activeToday: false)),
      );
    });

    testWidgets('impact new user ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'impact_empty',
        config: config,
        value: AsyncData(newSummary()),
      );
    });

    testWidgets('impact loading ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'impact_loading',
        config: config,
        value: const AsyncLoading(),
      );
    });
  }

  for (final config in compactConfigs) {
    testWidgets('impact scanned only ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'impact_scanned_only',
        config: config,
        value: AsyncData(scannedOnlySummary()),
      );
    });

    testWidgets('impact error ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'impact_error',
        config: config,
        value: AsyncError(StateError('database closed'), StackTrace.empty),
      );
    });
  }
}
