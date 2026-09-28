// Interaction tests for the Swaps tab.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/network/api_exception.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/swaps_controller.dart';
import 'package:kanz/features/swaps/swaps_screen.dart';

import '../dropoff/tab_test_support.dart';
import 'swaps_fixtures.dart';

void main() {
  late FakeSwapsController controller;

  Future<void> pump(
    WidgetTester tester,
    SwapsState state, {
    Locale locale = const Locale('en'),
  }) async {
    controller = FakeSwapsController(state);
    await pumpTab(
      tester,
      locale: locale,
      overrides: [
        vocabProvider.overrideWithValue(testVocab()),
        swapsControllerProvider.overrideWith(() => controller),
      ],
      child: const SwapsScreen(),
    );
  }

  KanzButton submitButton(WidgetTester tester) =>
      tester.widget<KanzButton>(find.byType(KanzButton).first);

  testWidgets('nothing picked: the button waits and says why', (tester) async {
    await pump(tester, emptyForm);
    expect(submitButton(tester).onPressed, isNull);
    expect(
      find.text('Pick at least one item, or type your own.'),
      findsOneWidget,
    );
    expect(find.text('WHAT YOU GET'), findsOneWidget);
    // No history yet, so no history switch.
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('chips and free text build the request', (tester) async {
    await pump(tester, emptyForm);
    await tester.tap(find.text('Plastic bags'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'straws, foil trays');
    await tester.pump();
    expect(controller.calls, [
      'toggleChip:plastic_bags',
      'setFreeText:straws, foil trays',
    ]);

    await tester.ensureVisible(find.text('Find swaps'));
    await tester.tap(find.text('Find swaps'));
    await tester.pump();
    expect(controller.calls.last, 'submit:plastic_bags|straws|foil trays');
  });

  testWidgets('the keyboard action submits too', (tester) async {
    await pump(tester, filledForm());
    await tester.enterText(find.byType(TextField), 'razors');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(controller.calls.last, 'submit:plastic_bags|cling_film|razors');
  });

  testWidgets('the history switch shows what was scanned and toggles', (
    tester,
  ) async {
    await pump(tester, filledForm());
    expect(find.text('Use my scan history'), findsOneWidget);
    expect(find.text('Plastic'), findsOneWidget);
    await tester.tap(find.text('Use my scan history'));
    await tester.pump();
    expect(controller.calls, contains('setUseHistory:false'));
  });

  testWidgets('loading names what it is looking for', (tester) async {
    await pump(tester, loadingState());
    // A sentence, not a shouted list.
    await tester.scrollUntilVisible(
      find.text('Finding swaps for plastic bags and cling film'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Finding swaps for plastic bags and cling film'),
      findsOneWidget,
    );
  });

  testWidgets('results show every swap with its sources and the insight', (
    tester,
  ) async {
    await pump(tester, resultsState(ar: false));
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('You scanned 6 plastic bottles this month.'),
      300,
      scrollable: list,
    );
    for (final to in [
      'A folding cotton or canvas tote',
      'Beeswax wraps or a plate over the bowl',
      'A filter jug and a steel bottle',
    ]) {
      await tester.scrollUntilVisible(find.text(to), 300, scrollable: list);
      expect(find.text(to), findsOneWidget);
    }
    // The history swap is marked, quietly.
    expect(find.text('FROM YOUR SCANS'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Refillable water'),
      300,
      scrollable: list,
    );
    expect(find.text('Refillable water'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Start over'),
      300,
      scrollable: list,
    );
    await tester.tap(find.text('Start over'));
    await tester.pump();
    expect(controller.calls, contains('clear'));
  });

  testWidgets('after new picks the button offers to update', (tester) async {
    await pump(tester, filledForm());
    await tester.ensureVisible(find.text('Find swaps'));
    await tester.tap(find.text('Find swaps'));
    await tester.pump();
    controller.emit(resultsState(ar: false));
    await tester.pump();
    expect(find.text('Find swaps'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Batteries'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Batteries'));
    await tester.pump();
    expect(find.text('Update swaps'), findsOneWidget);
  });

  testWidgets('a failed request retries', (tester) async {
    await pump(tester, errorState(aiUnavailable));
    await tester.scrollUntilVisible(
      find.text('Try again'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Swaps didn\'t load'), findsOneWidget);
    // The request id for support (with the wire code in debug builds).
    expect(find.text('ai_unavailable · req_5f3c2a1b'), findsOneWidget);
    await tester.ensureVisible(find.text('Try again'));
    await tester.pump();
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(controller.calls.last, startsWith('submit:'));
  });

  testWidgets('offline says so without a support code', (tester) async {
    await pump(tester, errorState(const ApiException.offline()));
    await tester.scrollUntilVisible(
      find.text('Swaps need a connection'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('req_'), findsNothing);
  });

  testWidgets('no match explains what to try', (tester) async {
    await pump(tester, noMatchState());
    await tester.scrollUntilVisible(
      find.text('No swaps for that yet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No swaps for that yet'), findsOneWidget);
  });

  testWidgets('Arabic chips send the same ids', (tester) async {
    await pump(tester, emptyForm, locale: const Locale('ar'));
    await tester.tap(find.text('غلاف بلاستيكي للطعام'));
    await tester.pump();
    expect(controller.calls, ['toggleChip:cling_film']);
  });
}
