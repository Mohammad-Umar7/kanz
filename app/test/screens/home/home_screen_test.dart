import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/data/insights/impact.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/features/home/home_screen.dart';

import '../shell/foundation_support.dart';

void main() {
  Future<List<String>> pumpHome(
    WidgetTester tester, {
    bool empty = false,
  }) async {
    final log = <String>[];
    final overrides = await foundationOverrides(
      tester,
      scans: AsyncData(empty ? const [] : sampleScans()),
      projects: AsyncData(empty ? const [] : sampleProjects()),
      impact: AsyncData(empty ? ImpactSummary.empty : sampleImpact),
    );
    tester.view
      ..physicalSize = const Size(412, 1600) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await pumpRouted(
      tester,
      shellRouter(home: const HomeScreen(), log: log),
      overrides,
    );
    return log;
  }

  testWidgets('the three ways to scan open the scan screen in their mode', (
    tester,
  ) async {
    final log = await pumpHome(tester);

    await tester.tap(find.text('Scan an item').first);
    await settle(tester);
    expect(log.last, AppRoutes.scan(ScanMode.camera));
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.text('From gallery'));
    await settle(tester);
    expect(log.last, AppRoutes.scan(ScanMode.gallery));
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.text('Describe it'));
    await settle(tester);
    expect(log.last, AppRoutes.scan(ScanMode.text));
  });

  testWidgets('history and settings open from the app bar', (tester) async {
    final log = await pumpHome(tester);

    await tester.tap(find.byIcon(KanzIcons.history));
    await settle(tester);
    expect(log.last, AppRoutes.history);
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.byIcon(KanzIcons.settings));
    await settle(tester);
    expect(log.last, AppRoutes.settings);
  });

  testWidgets('a recent scan opens its results; see all opens history', (
    tester,
  ) async {
    final log = await pumpHome(tester);

    await tester.tap(find.text('Glass jam jar'));
    await settle(tester);
    expect(log.last, AppRoutes.results('scan-jar'));
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.text('See all'));
    await settle(tester);
    expect(log.last, AppRoutes.history);
  });

  testWidgets('the resume card continues the tutorial in progress', (
    tester,
  ) async {
    final log = await pumpHome(tester);

    expect(find.text('Hanging jar lantern'), findsOneWidget);
    expect(find.text('Step 3 of 6'), findsOneWidget);
    await tester.tap(find.text('Hanging jar lantern'));
    await settle(tester);
    expect(log.last, AppRoutes.tutorial('scan-jar', 'idea_9f2c41aa'));
  });

  testWidgets('the impact glance switches to the Impact tab', (tester) async {
    await pumpHome(tester);

    expect(find.text('12'), findsOneWidget);
    await tester.ensureVisible(find.text('items out of the bin'));
    await tester.tap(find.text('items out of the bin'));
    await settle(tester);
    expect(find.text(AppRoutes.impact), findsOneWidget);
  });

  testWidgets('first run teaches what to photograph, with no resume card', (
    tester,
  ) async {
    await pumpHome(tester, empty: true);

    expect(find.text('What to photograph'.toUpperCase()), findsOneWidget);
    expect(find.text('Jars and bottles'), findsOneWidget);
    expect(find.text('Continue your project'.toUpperCase()), findsNothing);
    expect(find.text('Recent scans'), findsNothing);
    expect(find.text('Your impact'.toUpperCase()), findsNothing);
  });
}
