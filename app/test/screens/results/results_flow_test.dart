// What the results screen asks of the scan session and the router when the
// user acts: marks, retries, corrections, focus, location, drop-off and
// navigation to an idea.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/dropoff_controller.dart';
import 'package:kanz/core/state/scan_session.dart';
import 'package:kanz/core/state/settings_providers.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import 'results_test_support.dart';

/// Records the categories "See all" asks the Drop-off tab to show.
class _Dropoff extends DropoffController {
  final List<List<String>> shown = [];

  @override
  DropoffState build() => const DropoffState();

  @override
  Future<void> showCategories(Iterable<String> keys) async =>
      shown.add(keys.toList());
}

void main() {
  setUpAll(loadKanzFonts);

  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<(SessionLog, GoRouter)> open(
    WidgetTester tester,
    ScanSessionState session, {
    String? location,
    _Dropoff? dropoff,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(412, 2400);
    addTearDown(tester.view.reset);
    final log = SessionLog();
    final router = coreFlowRouter(location ?? '/results/${session.scanId}');
    final preferences = await testPreferences();
    await tester.pumpWidget(
      coreFlowApp(
        router: router,
        overrides: screenOverrides(
          preferences: preferences,
          sessions: {session.scanId: session},
          log: log,
          extra: [
            if (dropoff != null)
              dropoffControllerProvider.overrideWith(() => dropoff),
          ],
        ),
      ),
    );
    await pumpFrames(tester);
    return (log, router);
  }

  testWidgets('Mark as recycled records the item', (tester) async {
    final (log, _) = await open(tester, ScanFixtures.jar());
    await tester.tap(find.textContaining(l10n.resultsTabRecycle).first);
    await pumpFrames(tester, 4);
    final mark = find.text(l10n.resultsMarkRecycled).first;
    await tester.ensureVisible(mark);
    await tester.tap(mark);
    await pumpFrames(tester, 2);
    expect(log['scan_jar'].calls, contains('recycled:item_1'));
  });

  testWidgets('a failed ideas stage retries from its error', (tester) async {
    final (log, _) = await open(
      tester,
      ScanFixtures.jar(
        stages: ScanFixtures.stages(
          ideas: StageStatus.failed,
          dropoff: StageStatus.pending,
          makeovers: StageStatus.pending,
          ideasError: const ApiException(
            code: ApiErrorCode.aiUnavailable,
            message: 'busy',
            retryable: true,
            requestId: 'req_1',
          ),
        ),
        recommendation: false,
        facilities: false,
      ),
    );
    expect(find.text(l10n.resultsIdeasErrorTitle), findsOneWidget);
    final retries = find.text(l10n.commonRetry);
    // One on the pipeline row, one in the paths section.
    expect(retries, findsNWidgets(2));
    await tester.tap(retries.last);
    await pumpFrames(tester, 2);
    expect(log['scan_jar'].calls, ['retry:ideas']);
  });

  testWidgets('correcting an item re-runs recommendations', (tester) async {
    final (log, _) = await open(tester, ScanFixtures.jar());
    final edit = find.bySemanticsLabel(l10n.resultsEditItem).first;
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await pumpFrames(tester, 6);
    expect(find.text(l10n.resultsEditSave), findsOneWidget);

    final quantity = find.widgetWithText(TextField, '1');
    await tester.enterText(quantity, '3');
    await pumpFrames(tester, 2);
    await tester.tap(find.text(l10n.resultsEditSave));
    await pumpFrames(tester, 6);

    final session = log['scan_jar'];
    expect(session.calls, ['correct:item_1']);
    expect(session.lastCorrection?.quantityValue, 3);
    expect(session.lastCorrection?.name, isNull);
  });

  testWidgets('choosing the lid focuses the ideas on it', (tester) async {
    final (log, _) = await open(tester, ScanFixtures.jar());
    final lid = find.text('Metal jar lid').first;
    await tester.ensureVisible(lid);
    await tester.tap(lid);
    await pumpFrames(tester, 4);
    final focus = find.text(l10n.resultsFocusItem);
    await tester.ensureVisible(focus);
    await tester.tap(focus);
    await pumpFrames(tester, 2);
    expect(log['scan_jar'].calls, ['focus:item_2']);
  });

  testWidgets('choosing a city resumes the drop-off search', (tester) async {
    final (log, _) = await open(
      tester,
      ScanFixtures.jar(
        stages: ScanFixtures.stages(dropoff: StageStatus.needsLocation),
        facilities: false,
        location: null,
      ),
    );
    final city = find.text(l10n.resultsChooseCity);
    await scrollTo(tester, city);
    await tester.tap(city);
    await pumpFrames(tester, 6);
    await settleAsync(tester);
    await pumpFrames(tester, 2);

    expect(log['scan_jar'].calls, ['resumeDropoff']);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(container.read(settingsProvider).city, CityId.dubai);
    expect(container.read(settingsProvider).locationMode, LocationMode.city);
  });

  testWidgets('See all opens the Drop-off tab on this scan\'s categories', (
    tester,
  ) async {
    final dropoff = _Dropoff();
    final (_, router) = await open(
      tester,
      ScanFixtures.jar(),
      dropoff: dropoff,
    );
    final seeAll = find.text(l10n.resultsSeeAll);
    await scrollTo(tester, seeAll);
    await tester.tap(seeAll);
    await pumpFrames(tester, 4);
    expect(dropoff.shown, [
      ['glass', 'metal'],
    ]);
    expect(router.state.matchedLocation, '/dropoff');
  });

  testWidgets('an idea card opens the idea', (tester) async {
    final (_, router) = await open(tester, ScanFixtures.jar());
    final idea = find.text('Kitchen herb jar');
    await tester.ensureVisible(idea);
    await tester.tap(idea);
    await pumpFrames(tester, 6);
    expect(router.state.uri.path, '/results/scan_jar/idea/idea_1b7e03d5');
  });

  testWidgets('back from results opened on their own goes Home', (
    tester,
  ) async {
    final (_, router) = await open(tester, ScanFixtures.jar());
    await tester.tap(find.bySemanticsLabel(l10n.commonBack));
    await pumpFrames(tester, 6);
    expect(router.state.matchedLocation, '/');
  });

  testWidgets('a rejected photo offers a retake', (tester) async {
    final (_, router) = await open(tester, ScanFixtures.rejected());
    expect(find.text(l10n.commonPhotoTooDark), findsOneWidget);
    expect(find.text(l10n.resultsStageImagesPaused), findsNothing);
    await tester.tap(find.text(l10n.resultsChooseFromGallery));
    await pumpFrames(tester, 2);
    expect(router.state.uri.toString(), '/scan?mode=gallery');
  });

  testWidgets('images paused on the quota never offer a retry', (tester) async {
    final rec = ScanFixtures.jarRecommendation();
    await open(
      tester,
      ScanFixtures.jar(
        stages: ScanFixtures.stages(
          makeovers: StageStatus.failed,
          makeoversError: ScanFixtures.quotaError,
        ),
        images: ScanFixtures.pausedImages(rec),
      ),
    );
    // Mono labels are set in capitals.
    expect(
      find.text(l10n.resultsIdeaImagePaused.toUpperCase()),
      findsNWidgets(3),
    );
    expect(find.text(l10n.resultsIdeaImageRetry), findsNothing);
    expect(find.text(l10n.commonRetry), findsNothing);
  });
}
