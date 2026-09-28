import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/state/history_providers.dart';
import 'package:kanz/features/history/history_screen.dart';

import '../shell/foundation_support.dart';

void main() {
  late ProviderContainer container;
  RecordingHistoryActions actions() =>
      container.read(historyActionsProvider) as RecordingHistoryActions;

  Future<List<String>> pumpHistory(WidgetTester tester, {int tab = 0}) async {
    final log = <String>[];
    final overrides = await foundationOverrides(
      tester,
      scans: AsyncData(sampleScans()),
      projects: AsyncData(sampleProjects()),
      extra: [historyActionsProvider.overrideWith(RecordingHistoryActions.new)],
    );
    tester.view
      ..physicalSize = const Size(412, 1400) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    container = await pumpRouted(
      tester,
      screenRouter(
        path: AppRoutes.history,
        builder: (_) => HistoryScreen(initialTab: tab),
        log: log,
      ),
      overrides,
    );
    return log;
  }

  testWidgets('scans are grouped by day and open their results', (
    tester,
  ) async {
    final log = await pumpHistory(tester);

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    await tester.tap(find.text('Glass jam jar'));
    await settle(tester);
    expect(log.last, AppRoutes.results('scan-jar'));
  });

  testWidgets('a swipe asks first, and deletes only when confirmed', (
    tester,
  ) async {
    await pumpHistory(tester);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await settle(tester);
    expect(find.text('Delete this scan?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(actions().deleted, isEmpty);
    expect(find.text('Glass jam jar'), findsOneWidget);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);
    expect(actions().deleted, ['scan-jar']);
    expect(find.text('Glass jam jar'), findsNothing);
    expect(find.text('Scan deleted'), findsOneWidget);
  });

  testWidgets('the row menu opens or deletes a scan', (tester) async {
    final log = await pumpHistory(tester);

    await tester.tap(find.byIcon(KanzIcons.more).at(1));
    await settle(tester);
    await tester.tap(find.text('Open scan'));
    await settle(tester);
    expect(log.last, AppRoutes.results('scan-caps'));
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.byIcon(KanzIcons.more).first);
    await settle(tester);
    await tester.tap(find.text('Delete scan'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);
    expect(actions().deleted, ['scan-jar']);
  });

  testWidgets('projects resume the tutorial or open the finished project', (
    tester,
  ) async {
    final log = await pumpHistory(tester, tab: 1);

    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('2 of 6 steps done'), findsOneWidget);
    await tester.tap(find.text('Hanging jar lantern'));
    await settle(tester);
    expect(log.last, AppRoutes.tutorial('scan-jar', 'idea_9f2c41aa'));
    await tester.binding.handlePopRoute();
    await settle(tester);

    await tester.tap(find.text('No-sew t-shirt tote bag'));
    await settle(tester);
    expect(log.last, AppRoutes.completion('project-tote'));
  });

  testWidgets('the tabs switch between scans and projects', (tester) async {
    await pumpHistory(tester);
    expect(find.text('Glass jam jar'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('My projects, 3'));
    await settle(tester);
    expect(find.text('Hanging jar lantern'), findsOneWidget);
    expect(find.text('Glass jam jar'), findsNothing);
  });
}
