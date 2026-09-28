import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/config/env.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/settings_providers.dart';
import 'package:kanz/features/settings/server_section.dart';
import 'package:kanz/features/settings/settings_screen.dart';

import '../shell/foundation_support.dart';

void main() {
  late ProviderContainer container;
  late List<String> log;
  late ScreenPermissions permissions;
  var healthCalls = 0;

  AppSettings settings() => container.read(settingsProvider);

  Future<void> pumpSettings(
    WidgetTester tester, {
    Map<String, Object> prefs = onboarded,
    Map<String, WidgetBuilder> extraRoutes = const {},
    PermissionState location = PermissionState.denied,
  }) async {
    log = [];
    healthCalls = 0;
    permissions = ScreenPermissions(location: location);
    final overrides = await foundationOverrides(
      tester,
      prefs: prefs,
      permissions: permissions,
      connection: [
        healthProvider.overrideWith((ref) async {
          healthCalls++;
          return healthFixture();
        }),
        // Like the real provider: online once health answers.
        backendStatusProvider.overrideWith(
          (ref) => ref.watch(healthProvider).hasValue
              ? BackendStatus.online
              : BackendStatus.checking,
        ),
      ],
    );
    tester.view
      ..physicalSize = const Size(412, 3200) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    container = await pumpRouted(
      tester,
      screenRouter(
        path: AppRoutes.settings,
        builder: (_) => const SettingsScreen(),
        log: log,
        extraRoutes: extraRoutes,
      ),
      overrides,
    );
  }

  testWidgets('language, theme, skill and hands-free save at once', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('العربية'));
    await settle(tester);
    expect(settings().locale, LocalePref.ar);
    await tester.tap(find.text('Phone language'));
    await settle(tester);
    expect(settings().locale, LocalePref.system);

    await tester.tap(find.bySemanticsLabel('Dark'));
    await settle(tester);
    expect(settings().themeMode, ThemeMode.dark);

    await tester.tap(find.bySemanticsLabel('Advanced'));
    await settle(tester);
    expect(settings().skill, SkillLevel.advanced);
    expect(find.text('You measure, saw, sew and finish with care.'), findsOne);

    await tester.tap(find.text('Hands-free by default'));
    await settle(tester);
    expect(settings().handsFree, isTrue);
  });

  testWidgets('tools are edited in a sheet and summarised in the row', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(
      find.text('None yet. Ideas that need no tools come first.'),
      findsOneWidget,
    );

    await tester.tap(find.text('My tools'));
    await settle(tester);
    await tester.tap(find.text('Scissors'));
    await tester.tap(find.text('Craft knife'));
    await settle(tester);
    expect(settings().tools, [ToolId.scissors, ToolId.craftKnife]);
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('Scissors, Craft knife'), findsOneWidget);
  });

  testWidgets('a bad server address is refused, a good one is saved', (
    tester,
  ) async {
    await pumpSettings(tester);
    final field = find.descendant(
      of: find.byType(ServerSection),
      matching: find.byType(TextField),
    );

    await tester.enterText(field, '192.168.1.20:8000');
    await tester.pump();
    await tester.tap(find.text('Save and test'));
    await settle(tester);
    expect(
      find.text('Enter a full address that starts with http:// or https://'),
      findsOneWidget,
    );
    expect(settings().apiBaseUrl, isNull);

    await tester.enterText(field, 'http://192.168.1.20:8000');
    await tester.pump();
    await tester.tap(find.text('Save and test'));
    await settle(tester);
    expect(settings().apiBaseUrl, 'http://192.168.1.20:8000');

    await tester.tap(find.text('Use default'));
    await settle(tester);
    expect(settings().apiBaseUrl, isNull);
    expect(find.text(Env.apiBase), findsWidgets);
  });

  testWidgets('test connection re-runs the health check and shows details', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('gemini-3.6-flash'), findsWidgets);
    expect(find.text('96 documents'), findsOneWidget);

    final before = healthCalls;
    await tester.tap(find.text('Test connection'));
    await settle(tester);
    expect(healthCalls, greaterThan(before));
  });

  testWidgets('location: GPS when allowed, the rationale when not', (
    tester,
  ) async {
    await pumpSettings(tester, location: PermissionState.granted);
    await tester.tap(find.text('Use my location'));
    await settle(tester);
    expect(settings().locationMode, LocationMode.gps);
    expect(log, isEmpty);
  });

  testWidgets('location without permission opens the rationale', (
    tester,
  ) async {
    await pumpSettings(tester);
    await tester.tap(find.text('Use my location'));
    await settle(tester);
    expect(log.last, AppRoutes.locationRationale);
  });

  testWidgets('a city from the picker switches to city mode', (tester) async {
    await pumpSettings(
      tester,
      extraRoutes: {
        AppRoutes.cityPicker: (context) => Scaffold(
          body: KanzButton(
            label: 'Pick Sharjah',
            onPressed: () => context.pop('sharjah'),
          ),
        ),
      },
    );
    await tester.tap(find.text('A fixed city'));
    await settle(tester);
    await tester.tap(find.text('Pick Sharjah'));
    await settle(tester);

    expect(settings().locationMode, LocationMode.city);
    expect(settings().city, CityId.sharjah);
    // The mode is a radio; the city itself is its own row (mono value).
    expect(find.text('City'), findsOneWidget);
    expect(find.text('SHARJAH'), findsOneWidget);
    expect(find.text('Search around Sharjah'), findsNothing);

    // That row changes the city.
    await tester.tap(find.text('City'));
    await settle(tester);
    expect(find.text('Pick Sharjah'), findsOneWidget);
  });
}
