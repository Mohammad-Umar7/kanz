// Renders every Idea state (makeover ready, rendering, paused, failed, text
// scan, missing) at 360 and 412 dp, light and dark, English and Arabic, plus
// 130 % text and whole-page renders, into test/screenshots/_out/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/features/idea/idea_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import '../results/results_test_support.dart';

const _lantern = 'idea_9f2c41aa';

Future<void> _shot(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  required ScanSessionState Function(bool arabic) session,
  String ideaId = _lantern,
}) async {
  final preferences = await testPreferences();
  final state = session(config.isArabic);
  await precacheFiles(tester, [
    ?state.localImagePath,
    for (final image in state.afterImages.values) ?image.localPath,
  ]);
  await takeShot(
    tester,
    name: name,
    config: config,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    wrap: (app) => ProviderScope(
      overrides: screenOverrides(
        preferences: preferences,
        sessions: {state.scanId: state},
      ),
      child: app,
    ),
    child: IdeaScreen(scanId: state.scanId, ideaId: ideaId),
  );
}

ScanSessionState _withImage(bool arabic, GeneratedImageState image) {
  final session = ScanFixtures.jar(arabic: arabic);
  return session.copyWith(
    afterImages: {...session.afterImages, _lantern: image},
  );
}

void main() {
  setUpAll(loadKanzFonts);

  for (final config in [
    ...ShotConfig.matrix(),
    const ShotConfig(textScale: 1.3),
    const ShotConfig(locale: Locale('ar'), textScale: 1.3),
  ]) {
    testWidgets('idea ready ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_ready',
        config: config,
        session: (ar) => ScanFixtures.jar(arabic: ar),
      );
    });
  }

  for (final config in ShotConfig.matrix()) {
    testWidgets('idea rendering ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_rendering',
        config: config,
        session: (ar) => _withImage(
          ar,
          const GeneratedImageState(status: ImageStatus.loading),
        ),
      );
    });

    testWidgets('idea paused ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_paused',
        config: config,
        session: (ar) => _withImage(
          ar,
          const GeneratedImageState(
            status: ImageStatus.failed,
            error: ScanFixtures.quotaError,
          ),
        ),
      );
    });
  }

  for (final config in compactMatrix()) {
    testWidgets('idea whole page ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_full',
        config: tall(config, height: 1900),
        session: (ar) => ScanFixtures.jar(arabic: ar),
      );
    });

    testWidgets('idea failed ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_failed',
        config: config,
        session: (ar) => _withImage(
          ar,
          const GeneratedImageState(
            status: ImageStatus.failed,
            error: ScanFixtures.offlineError,
          ),
        ),
      );
    });

    testWidgets('idea text scan ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_text_scan',
        config: config,
        session: (_) => ScanFixtures.textScan(),
      );
    });

    testWidgets('idea loading ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_loading',
        config: config,
        session: (_) => const ScanSessionState(scanId: 'scan_old'),
      );
    });

    testWidgets('idea missing ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'idea_missing',
        config: config,
        ideaId: 'idea_gone',
        session: (ar) => ScanFixtures.jar(arabic: ar),
      );
    });
  }
}
