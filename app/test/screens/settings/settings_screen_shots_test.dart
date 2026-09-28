// Settings: the first screen in every config, the whole page (tall frame)
// connected, unreachable, offline and checking, the tools sheet, a bad
// server address, and GPS mode with location turned off.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/features/settings/settings_screen.dart';

import '../../screenshots/harness.dart';
import '../shell/foundation_support.dart';

void main() {
  setUpAll(loadKanzFonts);

  const prefs = <String, Object>{
    ...onboarded,
    'settings.skill': 'intermediate',
    'settings.tools': ['scissors', 'twine', 'pliers', 'paintbrush', 'drill'],
    'settings.location_mode': 'city',
    'settings.city': 'abu_dhabi',
  };

  Future<void> shot(
    WidgetTester tester,
    ShotConfig config,
    String name, {
    Map<String, Object> prefs = prefs,
    BackendStatus status = BackendStatus.online,
    ScreenPermissions? permissions,
    Future<void> Function()? interact,
  }) async {
    final overrides = await foundationOverrides(
      tester,
      prefs: prefs,
      status: status,
      health: status == BackendStatus.online ? null : const AsyncLoading(),
      permissions: permissions,
    );
    final router = screenRouter(
      path: '/settings',
      builder: (_) => const SettingsScreen(),
    );
    addTearDown(router.dispose);
    Future<void> capture() => takeShot(
      tester,
      name: 'settings_$name',
      config: config,
      wrap: scoped(overrides),
      routerConfig: router,
      localizationsDelegates: l10nDelegates,
    );
    await capture();
    if (interact != null) {
      await interact();
      await capture();
    }
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('settings top ${config.id}', (tester) async {
      await shot(tester, config, 'top');
    });
  }

  for (final config in tallFrames(height: 2600)) {
    testWidgets('settings whole page online ${config.id}', (tester) async {
      await shot(tester, config, 'tall_online');
    });
    testWidgets('settings whole page unreachable ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'tall_unreachable',
        status: BackendStatus.unreachable,
      );
    });
  }

  for (final config in [
    const ShotConfig(size: Size(360, 2600), textScale: 1.3),
    const ShotConfig(
      size: Size(360, 2600),
      locale: Locale('ar'),
      textScale: 1.3,
    ),
  ]) {
    testWidgets('settings whole page at 130 % ${config.id}', (tester) async {
      await shot(tester, config, 'tall_online');
    });
  }

  for (final config in shotConfigs()) {
    testWidgets('settings tools sheet ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'tools_sheet',
        interact: () async {
          await tester.tap(find.byIcon(KanzIcons.tools));
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
        },
      );
    });
  }

  for (final config in [
    const ShotConfig(size: Size(360, 2600)),
    const ShotConfig(
      size: Size(360, 2600),
      brightness: Brightness.dark,
      locale: Locale('ar'),
    ),
  ]) {
    testWidgets('settings offline and gps off ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'tall_offline_gps_off',
        status: BackendStatus.offline,
        prefs: {...prefs, 'settings.location_mode': 'gps'},
        permissions: ScreenPermissions(
          location: PermissionState.permanentlyDenied,
        ),
      );
    });
    testWidgets('settings checking and bad address ${config.id}', (
      tester,
    ) async {
      await shot(
        tester,
        config,
        'tall_checking_invalid',
        status: BackendStatus.checking,
        prefs: {...onboarded, 'settings.locale': config.isArabic ? 'ar' : 'en'},
        interact: () async {
          await tester.enterText(find.byType(TextField), '10.0.2.2:8000');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
        },
      );
    });
  }
}
