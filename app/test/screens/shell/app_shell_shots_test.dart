// The shell: navigation bar with the scan action, and the connection banner
// (offline, server unreachable, re-checking) over the Home tab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/features/home/home_screen.dart';
import 'package:kanz/features/shell/connection_banner.dart';

import '../../screenshots/harness.dart';
import 'foundation_support.dart';

void main() {
  setUpAll(loadKanzFonts);

  Future<void> shot(
    WidgetTester tester,
    ShotConfig config,
    String name,
    BackendStatus status,
  ) async {
    final arabic = config.isArabic;
    final overrides = await foundationOverrides(
      tester,
      status: status,
      scans: AsyncData(sampleScans(arabic: arabic)),
      projects: AsyncData(sampleProjects(arabic: arabic)),
      impact: const AsyncData(sampleImpact),
    );
    final router = shellRouter(home: HomeScreen(today: DateTime(2026, 9, 28)));
    addTearDown(router.dispose);
    await takeShot(
      tester,
      name: 'shell_$name',
      config: config,
      wrap: scoped(overrides),
      routerConfig: router,
      precache: samplePhotos(),
      localizationsDelegates: l10nDelegates,
    );
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('shell offline ${config.id}', (tester) async {
      await shot(tester, config, 'offline', BackendStatus.offline);
    });
  }

  for (final config in shotConfigs()) {
    testWidgets('shell unreachable ${config.id}', (tester) async {
      await shot(tester, config, 'unreachable', BackendStatus.unreachable);
    });
  }

  for (final config in [
    const ShotConfig(),
    const ShotConfig(locale: Locale('ar'), brightness: Brightness.dark),
  ]) {
    testWidgets('connection banner re-checking ${config.id}', (tester) async {
      final overrides = await foundationOverrides(tester);
      await takeShot(
        tester,
        name: 'shell_banner_checking',
        config: config,
        wrap: scoped(overrides),
        localizationsDelegates: l10nDelegates,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: ConnectionBanner(
              problem: BackendStatus.unreachable,
              checking: true,
              onRetry: () {},
            ),
          ),
        ),
      );
    });
  }
}
