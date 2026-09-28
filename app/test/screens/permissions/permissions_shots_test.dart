// Location and camera rationales (first ask, refused, blocked in Settings)
// and the city picker, across the screenshot matrix.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/features/permissions/camera_rationale_screen.dart';
import 'package:kanz/features/permissions/city_picker_screen.dart';
import 'package:kanz/features/permissions/location_rationale_screen.dart';

import '../../screenshots/harness.dart';
import '../shell/foundation_support.dart';

void main() {
  setUpAll(loadKanzFonts);

  Future<void> shot(
    WidgetTester tester,
    ShotConfig config,
    String name,
    Widget screen, {
    ScreenPermissions? permissions,
    Map<String, Object> prefs = onboarded,
    Future<void> Function()? interact,
  }) async {
    final overrides = await foundationOverrides(
      tester,
      prefs: prefs,
      permissions: permissions,
    );
    Future<void> capture() => takeShot(
      tester,
      name: 'permissions_$name',
      config: config,
      wrap: scoped(overrides),
      localizationsDelegates: l10nDelegates,
      child: screen,
    );
    await capture();
    if (interact != null) {
      await interact();
      await capture();
    }
  }

  for (final config in shotConfigs(largeText: true)) {
    testWidgets('location rationale ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'location',
        const LocationRationaleScreen(fromCityPicker: false),
      );
    });
    testWidgets('camera rationale ${config.id}', (tester) async {
      await shot(tester, config, 'camera', const CameraRationaleScreen());
    });
    testWidgets('city picker ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'city_picker',
        const CityPickerScreen(offerMyLocation: true),
        prefs: {...onboarded, 'settings.city': 'dubai'},
      );
    });
  }

  for (final config in shotConfigs()) {
    testWidgets('location blocked ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'location_blocked',
        const LocationRationaleScreen(fromCityPicker: false),
        permissions: ScreenPermissions(
          location: PermissionState.permanentlyDenied,
        ),
      );
    });
    testWidgets('camera blocked ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'camera_blocked',
        const CameraRationaleScreen(),
        permissions: ScreenPermissions(
          camera: PermissionState.permanentlyDenied,
        ),
      );
    });
  }

  for (final config in [
    const ShotConfig(),
    const ShotConfig(locale: Locale('ar'), brightness: Brightness.dark),
  ]) {
    testWidgets('location refused once ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'location_denied',
        const LocationRationaleScreen(fromCityPicker: false),
        interact: () async {
          await tester.tap(find.byType(FilledButton));
          await tester.pump();
        },
      );
    });
    testWidgets('camera restricted ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'camera_restricted',
        const CameraRationaleScreen(),
        permissions: ScreenPermissions(camera: PermissionState.restricted),
      );
    });
    testWidgets('city picker from the rationale ${config.id}', (tester) async {
      await shot(
        tester,
        config,
        'city_picker_no_location',
        const CityPickerScreen(offerMyLocation: false),
      );
    });
  }
}
