// The idea screen's actions: the tutorial, another take of the makeover
// (never offered on the image quota) and a missing idea.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import '../results/results_test_support.dart';

const _lantern = 'idea_9f2c41aa';

void main() {
  setUpAll(loadKanzFonts);

  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<(SessionLog, GoRouter)> open(
    WidgetTester tester,
    ScanSessionState session, {
    String ideaId = _lantern,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(412, 1400);
    addTearDown(tester.view.reset);
    final log = SessionLog();
    final router = coreFlowRouter('/results/${session.scanId}/idea/$ideaId');
    final preferences = await testPreferences();
    await tester.pumpWidget(
      coreFlowApp(
        router: router,
        overrides: screenOverrides(
          preferences: preferences,
          sessions: {session.scanId: session},
          log: log,
        ),
      ),
    );
    await pumpFrames(tester);
    return (log, router);
  }

  ScanSessionState withImage(GeneratedImageState image) {
    final session = ScanFixtures.jar();
    return session.copyWith(
      afterImages: {...session.afterImages, _lantern: image},
    );
  }

  testWidgets('See the tutorial opens the tutorial', (tester) async {
    final (_, router) = await open(tester, ScanFixtures.jar());
    expect(find.text('Hanging jar lantern'), findsOneWidget);
    await tester.tap(find.text(l10n.ideaSeeTutorial));
    await pumpFrames(tester, 4);
    expect(router.state.uri.path, '/results/scan_jar/idea/$_lantern/tutorial');
  });

  testWidgets('a failed makeover can be tried again', (tester) async {
    final (log, _) = await open(
      tester,
      withImage(
        const GeneratedImageState(
          status: ImageStatus.failed,
          error: ScanFixtures.offlineError,
        ),
      ),
    );
    await tester.tap(find.text(l10n.commonRegenerate));
    await tester.pump();
    expect(log['scan_jar'].calls, ['regenerate:$_lantern']);
  });

  testWidgets('the image quota never offers another take', (tester) async {
    await open(
      tester,
      withImage(
        const GeneratedImageState(
          status: ImageStatus.failed,
          error: ScanFixtures.quotaError,
        ),
      ),
    );
    expect(find.text(l10n.ideaImagePaused), findsOneWidget);
    expect(find.text(l10n.commonRegenerate), findsNothing);
  });

  testWidgets('a makeover that lands while open sweeps in once', (
    tester,
  ) async {
    // Earlier tests left the photo half-loaded in the image cache (files
    // never finish reading inside the test clock): load it again for real.
    imageCache
      ..clear()
      ..clearLiveImages();
    await precacheFiles(tester, [photoPath('glass_jar')]);
    final (log, _) = await open(
      tester,
      withImage(const GeneratedImageState(status: ImageStatus.loading)),
    );
    final slider = find.byType(BeforeAfterSlider);
    // While it renders: the whole photo with the stage named on it.
    expect(slider, findsNothing);
    expect(find.text(l10n.ideaRendering), findsOneWidget);

    log['scan_jar'].emit(ScanFixtures.jar());
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    // The slider fades in with its handle at the end edge: the frame still
    // shows only the photo.
    expect(slider, findsOneWidget);
    expect(tester.widget<BeforeAfterSlider>(slider).initialValue, 1);

    // Halfway through the sweep the handle is on its way to the middle.
    await tester.pump(KanzMotion.slow + KanzMotion.slow ~/ 2);
    final moving = tester.widget<BeforeAfterSlider>(slider).initialValue;
    expect(moving, lessThan(1));
    expect(moving, greaterThan(0.5));

    // Then it settles in the middle and stays there for the user to drag.
    await pumpFrames(tester, 6);
    expect(find.text(l10n.ideaRendering), findsNothing);
    expect(tester.widget<BeforeAfterSlider>(slider).initialValue, 0.5);
    expect(find.text(l10n.ideaDragHint.toUpperCase()), findsOneWidget);
  });

  testWidgets('an idea that is gone leads back to the results', (tester) async {
    final (_, router) = await open(
      tester,
      ScanFixtures.jar(),
      ideaId: 'idea_gone',
    );
    expect(find.text(l10n.ideaMissingTitle), findsOneWidget);
    await tester.tap(find.text(l10n.ideaBackToResults));
    await pumpFrames(tester, 4);
    expect(router.state.matchedLocation, '/results/scan_jar');
  });
}
