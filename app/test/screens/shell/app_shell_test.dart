import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/features/home/home_screen.dart';

import 'foundation_support.dart';

/// A backend status the test can change while the shell is on screen.
final _status = NotifierProvider<_Status, BackendStatus>(_Status.new);

class _Status extends Notifier<BackendStatus> {
  @override
  BackendStatus build() => BackendStatus.online;

  void set(BackendStatus value) => state = value;
}

void main() {
  Future<(ProviderContainer, List<String>, List<int>)> pumpShell(
    WidgetTester tester, {
    BackendStatus status = BackendStatus.online,
  }) async {
    final log = <String>[];
    final healthCalls = <int>[0];
    final overrides = await foundationOverrides(
      tester,
      connection: [
        // Like the real provider, the status depends on the health check.
        backendStatusProvider.overrideWith((ref) {
          ref.watch(healthProvider);
          return ref.watch(_status);
        }),
        healthProvider.overrideWith((ref) async {
          healthCalls[0]++;
          return healthFixture();
        }),
      ],
    );
    final container = await pumpRouted(
      tester,
      shellRouter(home: const HomeScreen(), log: log),
      overrides,
    );
    container.read(_status.notifier).set(status);
    await settle(tester);
    return (container, log, healthCalls);
  }

  testWidgets('the scan action opens the camera from any tab', (tester) async {
    final (_, log, _) = await pumpShell(tester);

    await tester.tap(find.text('Drop-off'));
    await settle(tester);
    expect(find.text('/dropoff'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Scan an item').last);
    await settle(tester);
    expect(log, contains('/scan?mode=${ScanMode.camera.name}'));
  });

  testWidgets('tabs keep their place and Home comes back', (tester) async {
    await pumpShell(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.text('Swaps'));
    await settle(tester);
    expect(find.text('/swaps'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('offline and unreachable read differently; retry re-checks', (
    tester,
  ) async {
    final (container, _, healthCalls) = await pumpShell(
      tester,
      status: BackendStatus.offline,
    );
    expect(find.text("You're offline. Saved scans still open."), findsOne);

    container.read(_status.notifier).set(BackendStatus.unreachable);
    await settle(tester);
    expect(
      find.text("Can't reach the Kanz server. Saved scans still open."),
      findsOne,
    );

    final before = healthCalls[0];
    await tester.tap(find.text('Retry'));
    await settle(tester);
    expect(healthCalls[0], greaterThan(before));
  });

  testWidgets('the banner stays while a re-check runs, then leaves', (
    tester,
  ) async {
    final (container, _, _) = await pumpShell(
      tester,
      status: BackendStatus.unreachable,
    );

    container.read(_status.notifier).set(BackendStatus.checking);
    await settle(tester);
    expect(find.text('Checking the connection'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    container.read(_status.notifier).set(BackendStatus.online);
    await settle(tester);
    expect(find.text('Checking the connection'), findsNothing);
  });

  testWidgets('no banner while the first check runs', (tester) async {
    await pumpShell(tester, status: BackendStatus.checking);
    expect(find.text('Checking the connection'), findsNothing);
  });
}
