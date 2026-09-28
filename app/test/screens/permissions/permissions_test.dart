import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/app/router.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/design/design.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/settings_providers.dart';
import 'package:kanz/features/permissions/camera_rationale_screen.dart';
import 'package:kanz/features/permissions/city_picker_screen.dart';
import 'package:kanz/features/permissions/location_rationale_screen.dart';

import '../shell/foundation_support.dart';

void main() {
  late ProviderContainer container;
  late GoRouter router;
  late List<String> log;

  AppSettings settings() => container.read(settingsProvider);

  /// Opens the app at '/', then pushes [path] so its result can be read.
  Future<Future<T?>> open<T>(
    WidgetTester tester,
    String path, {
    required ScreenPermissions permissions,
    Map<String, Object> prefs = onboarded,
    Map<String, WidgetBuilder> extraRoutes = const {},
  }) async {
    log = [];
    final overrides = await foundationOverrides(
      tester,
      prefs: prefs,
      permissions: permissions,
    );
    final routes = <String, WidgetBuilder>{
      AppRoutes.locationRationale: (_) => const LocationRationaleScreen(),
      AppRoutes.cameraRationale: (_) => const CameraRationaleScreen(),
      AppRoutes.cityPicker: (_) => const CityPickerScreen(),
      ...extraRoutes,
    };
    router = screenRouter(
      path: '/unused',
      builder: (_) => const SizedBox(),
      initialLocation: AppRoutes.home,
      log: log,
      extraRoutes: routes,
    );
    tester.view
      ..physicalSize = const Size(412, 1400) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    container = await pumpRouted(tester, router, overrides);
    final result = router.push<T>(path);
    await settle(tester);
    return result;
  }

  group('location rationale', () {
    testWidgets('granted: switches to GPS and pops true', (tester) async {
      final permissions = ScreenPermissions(
        locationAnswer: PermissionState.granted,
      );
      final result = await open<bool>(
        tester,
        AppRoutes.locationRationale,
        permissions: permissions,
      );

      await tester.tap(find.text('Use my location'));
      await settle(tester);

      expect(permissions.requests, [AppPermission.location]);
      expect(settings().locationMode, LocationMode.gps);
      expect(await result, isTrue);
    });

    testWidgets('refused: says so and stays', (tester) async {
      await open<bool>(
        tester,
        AppRoutes.locationRationale,
        permissions: ScreenPermissions(),
      );

      await tester.tap(find.text('Use my location'));
      await settle(tester);

      expect(
        find.text('Location wasn\'t allowed. Ask again, or choose a city.'),
        findsOneWidget,
      );
      expect(settings().locationMode, isNull);
    });

    testWidgets('blocked: opens the phone settings', (tester) async {
      final permissions = ScreenPermissions(
        location: PermissionState.permanentlyDenied,
      );
      await open<bool>(
        tester,
        AppRoutes.locationRationale,
        permissions: permissions,
      );

      await tester.tap(find.text('Open settings'));
      await settle(tester);
      expect(permissions.settingsOpened, 1);
      expect(permissions.requests, isEmpty);
    });

    testWidgets('a city instead: saves it and pops true', (tester) async {
      final result = await open<bool>(
        tester,
        AppRoutes.locationRationale,
        permissions: ScreenPermissions(),
      );

      await tester.tap(find.text('Choose a city instead'));
      await settle(tester);
      // The picker opened from here hides its own "use my location".
      expect(find.text('Use my location instead'), findsNothing);
      await tester.tap(find.text('Ajman'));
      await settle(tester);

      expect(settings().locationMode, LocationMode.city);
      expect(settings().city, CityId.ajman);
      expect(await result, isTrue);
    });
  });

  group('camera rationale', () {
    testWidgets('granted pops true', (tester) async {
      final result = await open<bool>(
        tester,
        AppRoutes.cameraRationale,
        permissions: ScreenPermissions(cameraAnswer: PermissionState.granted),
      );
      await tester.tap(find.text('Allow camera'));
      await settle(tester);
      expect(await result, isTrue);
    });

    testWidgets('the gallery instead pops false', (tester) async {
      final result = await open<bool>(
        tester,
        AppRoutes.cameraRationale,
        permissions: ScreenPermissions(),
      );
      await tester.tap(find.text('Pick from gallery instead'));
      await settle(tester);
      expect(await result, isFalse);
    });

    testWidgets('close pops null', (tester) async {
      final result = await open<bool>(
        tester,
        AppRoutes.cameraRationale,
        permissions: ScreenPermissions(),
      );
      await tester.tap(find.bySemanticsLabel('Close'));
      await settle(tester);
      expect(await result, isNull);
    });
  });

  group('city picker', () {
    testWidgets('marks the current city and pops the chosen id', (
      tester,
    ) async {
      final result = await open<String>(
        tester,
        AppRoutes.cityPicker,
        permissions: ScreenPermissions(),
        prefs: {...onboarded, 'settings.city': 'dubai'},
      );

      expect(find.byIcon(KanzIcons.check), findsOneWidget);
      expect(find.text('Umm Al Quwain'), findsOneWidget);
      expect(find.text('أم القيوين'), findsOneWidget);
      await tester.tap(find.text('Fujairah'));
      await settle(tester);
      expect(await result, 'fujairah');
    });

    testWidgets('my location, already allowed: GPS mode and "gps"', (
      tester,
    ) async {
      final result = await open<String>(
        tester,
        AppRoutes.cityPicker,
        permissions: ScreenPermissions(location: PermissionState.granted),
      );
      await tester.tap(find.text('Use my location instead'));
      await settle(tester);
      expect(settings().locationMode, LocationMode.gps);
      expect(await result, CityPickerScreen.myLocation);
    });

    testWidgets('my location, not allowed yet: asks through the rationale', (
      tester,
    ) async {
      await open<String>(
        tester,
        AppRoutes.cityPicker,
        permissions: ScreenPermissions(),
      );
      await tester.tap(find.text('Use my location instead'));
      await settle(tester);
      expect(find.text('Find drop-off points near you'), findsOneWidget);

      // From the picker, "choose a city" just goes back to it.
      await tester.tap(find.text('Choose a city instead'));
      await settle(tester);
      expect(find.text('Choose your city'), findsOneWidget);
    });
  });
}
