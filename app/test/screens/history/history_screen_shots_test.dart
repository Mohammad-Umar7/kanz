// History: scans grouped by day, projects, both empty states, loading,
// error, the row menu and the delete confirmation, across the matrix.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/features/history/history_screen.dart';

import '../../screenshots/harness.dart';
import '../shell/foundation_support.dart';

void main() {
  setUpAll(loadKanzFonts);

  Future<void> shot(
    WidgetTester tester,
    ShotConfig config,
    String name, {
    int tab = 0,
    bool empty = false,
    AsyncValue<Object>? state,
    Future<void> Function()? interact,
  }) async {
    final arabic = config.isArabic;
    final scans = empty ? const <Never>[] : sampleScans(arabic: arabic);
    final projects = empty ? const <Never>[] : sampleProjects(arabic: arabic);
    final overrides = await foundationOverrides(
      tester,
      scans: switch (state) {
        AsyncLoading() => const AsyncLoading(),
        AsyncError(:final error) => AsyncError(error, StackTrace.empty),
        _ => AsyncData(scans),
      },
      projects: switch (state) {
        AsyncLoading() => const AsyncLoading(),
        AsyncError(:final error) => AsyncError(error, StackTrace.empty),
        _ => AsyncData(projects),
      },
    );
    final router = screenRouter(
      path: '/history',
      builder: (_) => HistoryScreen(initialTab: tab),
    );
    addTearDown(router.dispose);
    Future<void> capture() => takeShot(
      tester,
      name: 'history_$name',
      config: config,
      wrap: scoped(overrides),
      routerConfig: router,
      precache: samplePhotos(),
      localizationsDelegates: l10nDelegates,
    );
    await capture();
    // Empty and error blocks start on the gutter in both directions.
    if (empty || state is AsyncError) expectStatesOnGutter(tester);
    if (interact != null) {
      await interact();
      await capture();
    }
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('history scans ${config.id}', (tester) async {
      await shot(tester, config, 'scans');
    });
    testWidgets('history projects ${config.id}', (tester) async {
      await shot(tester, config, 'projects', tab: 1);
    });
  }

  for (final config in shotConfigs()) {
    testWidgets('history scans empty ${config.id}', (tester) async {
      await shot(tester, config, 'scans_empty', empty: true);
    });
    testWidgets('history projects empty ${config.id}', (tester) async {
      await shot(tester, config, 'projects_empty', tab: 1, empty: true);
    });
    testWidgets('history loading ${config.id}', (tester) async {
      await shot(tester, config, 'loading', state: const AsyncLoading());
    });
    testWidgets('history error ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'error',
        state: AsyncError(StateError('db'), StackTrace.empty),
      );
    });
  }

  for (final config in [
    const ShotConfig(),
    const ShotConfig(locale: Locale('ar'), brightness: Brightness.dark),
    const ShotConfig(size: ShotConfig.large, brightness: Brightness.dark),
  ]) {
    testWidgets('history row menu ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'row_menu',
        interact: () async {
          await tester.tap(find.byIcon(KanzIcons.more).first);
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
        },
      );
    });
    testWidgets('history delete dialog ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'delete_dialog',
        interact: () async {
          await tester.drag(
            find.byType(Dismissible).first,
            Offset(config.isArabic ? 300 : -300, 0),
          );
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
        },
      );
    });
  }
}
