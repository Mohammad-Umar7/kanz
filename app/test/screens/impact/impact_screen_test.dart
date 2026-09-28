// Interaction tests for the Impact tab, driven through the real provider
// chain (events, projects and scans computed into the summary).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/core/data/db/database.dart';
import 'package:kanz/core/data/insights/impact.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/core/state/history_providers.dart';
import 'package:kanz/core/state/impact_providers.dart';
import 'package:kanz/features/impact/impact_screen.dart';

import '../dropoff/tab_test_support.dart';

ImpactEvent _event(int id, ImpactKind kind, String material) => ImpactEvent(
  id: id,
  dedupeKey: 'e$id',
  kind: kind,
  material: material,
  itemName: material,
  quantity: 1,
  unit: 'pcs',
  createdAt: DateTime.now(),
);

void main() {
  late int eventLoads;

  ImpactFactors factors() => ImpactFactors.fromJson(
    jsonDecode(File('assets/config/impact_factors.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  GoRouter router() => GoRouter(
    initialLocation: '/impact',
    routes: [
      GoRoute(path: '/impact', builder: (_, _) => const ImpactScreen()),
      GoRoute(
        path: '/scan',
        builder: (_, state) =>
            Scaffold(body: Text('scan ${state.uri.queryParameters['mode']}')),
      ),
    ],
  );

  Future<void> pump(
    WidgetTester tester, {
    Stream<List<ImpactEvent>> Function()? events,
    List<ScanSummary> scans = const [],
  }) async {
    eventLoads = 0;
    final r = router();
    addTearDown(r.dispose);
    await pumpTab(
      tester,
      router: r,
      overrides: [
        vocabProvider.overrideWithValue(testVocab()),
        impactFactorsProvider.overrideWithValue(factors()),
        impactEventsProvider.overrideWith((ref) {
          eventLoads++;
          return events == null ? Stream.value(const []) : events();
        }),
        projectsProvider.overrideWith(
          (ref) => Stream.value(const <ProjectRecord>[]),
        ),
        scanHistoryProvider.overrideWith((ref) => Stream.value(scans)),
      ],
    );
  }

  testWidgets('a new user sees what counts and the way to scan', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Your impact starts with one scan'), findsOneWidget);
    expect(find.text('WHAT COUNTS HERE'), findsOneWidget);
    await tester.tap(find.text('Scan an item'));
    await settle(tester);
    expect(find.text('scan camera'), findsOneWidget);
  });

  testWidgets('numbers come from the events, with the estimate labelled', (
    tester,
  ) async {
    await pump(
      tester,
      events: () => Stream.value([
        _event(1, ImpactKind.recycled, 'glass'),
        _event(2, ImpactKind.recycled, 'plastic'),
        _event(3, ImpactKind.donated, 'textile'),
      ]),
    );
    expect(find.text('3'), findsWidgets);
    expect(find.text('Items kept out of the bin'), findsOneWidget);
    expect(find.text('Active today'), findsOneWidget);
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Estimate, verify before quoting.'),
      300,
      scrollable: list,
    );
    expect(find.textContaining('kg CO2e'), findsOneWidget);
    expect(find.text('Estimate, verify before quoting.'), findsOneWidget);
  });

  testWidgets('a failed load retries by reading the events again', (
    tester,
  ) async {
    var fail = true;
    await pump(
      tester,
      events: () => fail
          ? Stream.error(StateError('database closed'))
          : Stream.value(const []),
    );
    expect(find.text('Your impact didn\'t load'), findsOneWidget);
    final before = eventLoads;
    fail = false;
    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(eventLoads, greaterThan(before));
    expect(find.text('Your impact starts with one scan'), findsOneWidget);
  });
}
