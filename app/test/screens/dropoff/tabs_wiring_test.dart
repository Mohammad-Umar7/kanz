// The three tabs on the real App Core controllers (fake API from the
// contract fixtures, in-memory database): the screens keep the controllers
// alive and their background work reaches the UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/features/dropoff/dropoff_screen.dart';
import 'package:kanz/features/impact/impact_screen.dart';
import 'package:kanz/features/swaps/swaps_screen.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../core/support/fakes.dart';
import 'tab_test_support.dart';

void main() {
  late TestHarness h;

  tearDown(() async {
    await h.dispose();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view
      ..devicePixelRatio = 2
      ..physicalSize = const Size(412, 915) * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: MaterialApp(
          theme: KanzTheme.light(locale: const Locale('en')),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: screen,
        ),
      ),
    );
  }

  /// Lets the database and the fake API answer, then draws the result.
  Future<void> until(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 100 && !done(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await settle(tester, ms: 600);
  }

  testWidgets('drop-off loads the chips and places for the saved city', (
    tester,
  ) async {
    h =
        await tester.runAsync(
              () => TestHarness.create(
                prefs: {
                  'settings.location_mode': 'city',
                  'settings.city': 'sharjah',
                },
              ),
            )
            as TestHarness;
    await pump(tester, const DropoffScreen());
    await until(tester, () => h.api.calls.contains('facilities'));

    expect(h.api.calls, containsAll(['categories', 'facilities']));
    expect(find.text('Near Sharjah'), findsOneWidget);
    expect(find.text('Glass recycling'), findsOneWidget);
    expect(find.text('Fixture glass bank A'), findsOneWidget);
  });

  testWidgets('drop-off asks where to search when nothing was chosen', (
    tester,
  ) async {
    h = await tester.runAsync(TestHarness.create) as TestHarness;
    await pump(tester, const DropoffScreen());
    await until(
      tester,
      () => find.text('Find drop-off points near you').evaluate().isNotEmpty,
    );
    expect(find.text('Find drop-off points near you'), findsOneWidget);
    expect(h.api.calls, isNot(contains('facilities')));
  });

  testWidgets('swaps sends the picks and shows the answer', (tester) async {
    h = await tester.runAsync(TestHarness.create) as TestHarness;
    await pump(tester, const SwapsScreen());
    await tester.tap(find.text('Plastic bags'));
    await tester.pump();
    await tester.ensureVisible(find.text('Find swaps'));
    await tester.tap(find.text('Find swaps'));
    await until(tester, () => h.api.calls.contains('swaps'));

    await tester.scrollUntilVisible(
      find.text('A folding cotton or canvas tote'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('A folding cotton or canvas tote'), findsOneWidget);
  });

  testWidgets('impact starts empty on a fresh install', (tester) async {
    h = await tester.runAsync(TestHarness.create) as TestHarness;
    await pump(tester, const ImpactScreen());
    await until(
      tester,
      () => find.text('Your impact starts with one scan').evaluate().isNotEmpty,
    );
    expect(find.text('Your impact starts with one scan'), findsOneWidget);
  });
}
