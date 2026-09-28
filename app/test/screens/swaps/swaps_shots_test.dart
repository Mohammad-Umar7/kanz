// Renders every Swaps state at 360 and 412 dp, light and dark, English and
// Arabic (plus 130 % text for the results) into test/screenshots/_out/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/swaps_controller.dart';
import 'package:kanz/features/swaps/swap_results.dart';
import 'package:kanz/features/swaps/swaps_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import '../dropoff/tab_test_support.dart';
import 'swaps_fixtures.dart';

Future<void> _shot(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  required SwapsState Function(bool ar) state,
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
          swapsControllerProvider.overrideWith(
            () => FakeSwapsController(state(config.isArabic)),
          ),
        ],
        child: app,
      ),
    ),
    child: inShell(const SwapsScreen(), tab: 2, arabic: config.isArabic),
  );
}

/// Scrolls the tab by [dy] and captures it again as `<name>`.
Future<void> _scrolled(
  WidgetTester tester,
  String name,
  ShotConfig config,
  double dy,
) async {
  await tester.drag(find.byType(ListView), Offset(0, -dy));
  await tester.pump();
  await captureAgain(tester, name: name, config: config, frames: 12);
}

/// Scrolls until [finder] sits near the top of the tab, then captures.
Future<void> _reveal(
  WidgetTester tester,
  Finder finder,
  String name,
  ShotConfig config,
) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.drag(find.byType(ListView), const Offset(0, 48));
  await tester.pump();
  await captureAgain(tester, name: name, config: config, frames: 12);
}

void main() {
  setUpAll(loadKanzFonts);

  for (final config in contentConfigs) {
    testWidgets('swaps results ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_form',
        config: config,
        state: (ar) => resultsState(ar: ar),
      );
      final title = config.isArabic ? 'بدائل مقترحة لك' : 'Swaps for you';
      await _reveal(tester, find.text(title), 'swaps_results', config);
      await _scrolled(tester, 'swaps_results_more', config, 640);
    });
  }

  for (final config in stateConfigs) {
    testWidgets('swaps empty form ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_empty',
        config: config,
        state: (_) => emptyForm,
      );
    });

    testWidgets('swaps loading ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_loading_top',
        config: config,
        state: (_) => loadingState(),
      );
      await _reveal(tester, find.byType(SwapsLoading), 'swaps_loading', config);
    });

    testWidgets('swaps error ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_error_top',
        config: config,
        state: (_) => errorState(aiUnavailable),
      );
      await _reveal(tester, find.byType(ErrorState), 'swaps_error', config);
    });
  }

  for (final config in compactConfigs) {
    testWidgets('swaps offline ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_offline_top',
        config: config,
        state: (_) => errorState(const ApiException.offline()),
      );
      await _reveal(tester, find.byType(ErrorState), 'swaps_offline', config);
    });

    testWidgets('swaps no match ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_no_match_top',
        config: config,
        state: (_) => noMatchState(),
      );
      await _reveal(tester, find.byType(EmptyState), 'swaps_no_match', config);
    });

    testWidgets('swaps filled form ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'swaps_filled',
        config: config,
        state: (_) => filledForm(),
      );
    });
  }
}
