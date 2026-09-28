// Renders every Results state at 360 and 412 dp, light and dark, English
// and Arabic (plus 130 % text for the main state), and whole-page renders
// of the long states, into test/screenshots/_out/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/db/database.dart' show ImpactKind;
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/results/results_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import 'results_test_support.dart';

Future<void> _shot(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  required ScanSessionState Function(bool arabic) session,
  BackendStatus status = BackendStatus.online,
  Map<ImpactKind, Set<String>> marked = const {},
  Future<void> Function(WidgetTester tester, AppLocalizations l10n)? then,
}) async {
  final preferences = await testPreferences();
  final state = session(config.isArabic);
  await precacheFiles(tester, [
    ?state.localImagePath,
    for (final image in state.afterImages.values) ?image.localPath,
  ]);
  await takeShot(
    tester,
    name: then == null ? name : '${name}_before',
    config: config,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    wrap: (app) => withBoundary(
      ProviderScope(
        overrides: screenOverrides(
          preferences: preferences,
          sessions: {state.scanId: state},
          status: status,
          marked: marked,
        ),
        child: app,
      ),
    ),
    child: ResultsScreen(scanId: state.scanId),
  );
  if (then != null) {
    final l10n = await AppLocalizations.delegate.load(config.locale);
    await then(tester, l10n);
    await captureAgain(tester, name: name, config: config);
  }
}

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.textContaining(label).first);
  await tester.pump();
}

void main() {
  setUpAll(loadKanzFonts);

  final matrix = ShotConfig.matrix();
  final wholePage = [for (final c in compactMatrix()) tall(c)];

  for (final config in matrix) {
    testWidgets('results identifying ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_identifying',
        config: config,
        session: (ar) => ScanFixtures.jar(
          arabic: ar,
          stages: ScanFixtures.stages(
            identifying: StageStatus.running,
            ideas: StageStatus.pending,
            dropoff: StageStatus.pending,
            makeovers: StageStatus.pending,
          ),
          analysis: false,
          recommendation: false,
          facilities: false,
        ),
      );
    });

    testWidgets('results finding ideas ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_ideas_loading',
        config: config,
        session: (ar) => ScanFixtures.jar(
          arabic: ar,
          stages: ScanFixtures.stages(
            ideas: StageStatus.running,
            dropoff: StageStatus.pending,
            makeovers: StageStatus.pending,
          ),
          recommendation: false,
          facilities: false,
        ),
      );
    });

    testWidgets('results rejected photo ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_rejected',
        config: config,
        session: (_) => ScanFixtures.rejected(),
      );
    });
  }

  for (final config in [
    ...matrix,
    const ShotConfig(textScale: 1.3),
    const ShotConfig(locale: Locale('ar'), textScale: 1.3),
  ]) {
    testWidgets('results content ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_content',
        config: config,
        session: (ar) => ScanFixtures.jar(arabic: ar),
      );
    });
  }

  for (final config in wholePage) {
    testWidgets('results whole page ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_full',
        config: config,
        session: (ar) => ScanFixtures.jar(arabic: ar),
      );
    });

    testWidgets('results images paused ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_paused_full',
        config: config,
        session: (ar) {
          final rec = ScanFixtures.jarRecommendation(arabic: ar);
          return ScanFixtures.jar(
            arabic: ar,
            stages: ScanFixtures.stages(
              makeovers: StageStatus.failed,
              makeoversError: ScanFixtures.quotaError,
            ),
            images: ScanFixtures.pausedImages(rec),
          );
        },
      );
    });

    testWidgets('results recycle ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_recycle_full',
        config: config,
        session: (ar) => ScanFixtures.jar(arabic: ar),
        marked: const {
          ImpactKind.recycled: {'item_2'},
        },
        then: (tester, l10n) => _tapTab(tester, l10n.resultsTabRecycle),
      );
    });

    testWidgets('results donate ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_donate_full',
        config: config,
        session: (ar) => ScanFixtures.jar(arabic: ar),
        then: (tester, l10n) => _tapTab(tester, l10n.resultsTabDonate),
      );
    });

    testWidgets('results battery ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_battery_full',
        config: config,
        session: (_) => ScanFixtures.battery(),
      );
    });

    testWidgets('results text scan ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_text_full',
        config: config,
        session: (_) => ScanFixtures.textScan(),
      );
    });

    testWidgets('results needs location ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_needs_location_full',
        config: config,
        session: (ar) => ScanFixtures.jar(
          arabic: ar,
          stages: ScanFixtures.stages(dropoff: StageStatus.needsLocation),
          facilities: false,
          location: null,
        ),
      );
    });
  }

  for (final config in compactMatrix()) {
    testWidgets('results restoring ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_restoring',
        config: config,
        session: (_) => const ScanSessionState(scanId: 'scan_old'),
      );
    });

    testWidgets('results missing ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_missing',
        config: config,
        session: (_) => const ScanSessionState(
          scanId: 'scan_gone',
          origin: ScanOrigin.missing,
        ),
      );
    });

    testWidgets('results offline error ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_offline',
        config: config,
        status: BackendStatus.offline,
        session: (ar) => ScanFixtures.jar(
          arabic: ar,
          stages: {
            PipelineStage.identifying: const StageState(
              status: StageStatus.failed,
              error: ScanFixtures.offlineError,
            ),
          },
          analysis: false,
          recommendation: false,
          facilities: false,
        ),
      );
    });

    testWidgets('results mixed makeovers ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_makeovers_full',
        config: tall(config, height: 2200),
        session: (ar) {
          final rec = ScanFixtures.jarRecommendation(arabic: ar);
          final ready = ScanFixtures.readyImages(rec);
          final ids = [for (final i in rec.upcycle) i.id];
          return ScanFixtures.jar(
            arabic: ar,
            stages: ScanFixtures.stages(makeovers: StageStatus.running),
            images: {
              ids[0]: ready[ids[0]]!,
              ids[1]: const GeneratedImageState(status: ImageStatus.loading),
              ids[2]: const GeneratedImageState(
                status: ImageStatus.failed,
                error: ScanFixtures.offlineError,
              ),
            },
          );
        },
      );
    });

    testWidgets('results edit sheet ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_edit_sheet',
        config: config,
        session: (ar) => ScanFixtures.jar(arabic: ar),
        then: (tester, l10n) async {
          await tester.ensureVisible(
            find.bySemanticsLabel(l10n.resultsEditItem).first,
          );
          await tester.pump();
          await tester.tap(find.bySemanticsLabel(l10n.resultsEditItem).first);
          await tester.pump();
        },
      );
    });

    testWidgets('results ideas for the lid ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_focus_lid',
        config: tall(config, height: 1800),
        session: (ar) => ScanFixtures.jar(arabic: ar, focusItemId: 'item_2'),
      );
    });

    testWidgets('results lid selected ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'results_lid_full',
        config: tall(config, height: 1800),
        session: (ar) => ScanFixtures.jar(arabic: ar),
        then: (tester, l10n) async {
          final lid = ScanFixtures.jarAnalysis(
            arabic: config.isArabic,
          ).analysis.items[1].name;
          await tester.tap(find.text(lid).first);
          await tester.pump();
        },
      );
    });
  }
}
