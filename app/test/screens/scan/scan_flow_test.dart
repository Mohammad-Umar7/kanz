// What the scan screen does with each path: describe, gallery and the
// camera's permission and fallback handling.
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kanz/core/services/camera_service.dart';
import 'package:kanz/core/services/gallery_picker.dart';
import 'package:kanz/core/services/permission_service.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import '../results/results_test_support.dart';

/// A camera that is never there: every start fails with [failure].
class _Camera extends CameraService {
  _Camera([this.failure = CameraFailure.noCamera]);

  final CameraFailure failure;
  int starts = 0;

  @override
  Future<CameraController> start() async {
    starts++;
    throw CameraUnavailable(failure);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> handleLifecycle(AppLifecycleState state) async {}
}

class _Permissions implements PermissionService {
  _Permissions(this.camera, {this.afterRequest});

  PermissionState camera;

  /// What a request turns [camera] into.
  final PermissionState? afterRequest;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<PermissionState> status(AppPermission permission) async => camera;

  @override
  Future<PermissionState> request(AppPermission permission) async {
    requests++;
    camera = afterRequest ?? camera;
    return camera;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

class _Picker extends GalleryPicker {
  _Picker(this.result);

  final XFile? result;

  @override
  Future<XFile?> pick() async => result;

  @override
  Future<XFile?> recoverLost() async => null;
}

void main() {
  setUpAll(loadKanzFonts);

  late AppLocalizations l10n;
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<(SessionLog, GoRouter)> open(
    WidgetTester tester,
    String location, {
    PermissionService? permissions,
    CameraService? camera,
    GalleryPicker? picker,
  }) async {
    final log = SessionLog();
    final router = coreFlowRouter(location);
    final preferences = await testPreferences();
    await tester.pumpWidget(
      coreFlowApp(
        router: router,
        overrides: screenOverrides(
          preferences: preferences,
          log: log,
          extra: [
            permissionServiceProvider.overrideWithValue(
              permissions ?? _Permissions(PermissionState.granted),
            ),
            cameraServiceProvider.overrideWithValue(camera ?? _Camera()),
            if (picker != null) galleryPickerProvider.overrideWithValue(picker),
          ],
        ),
      ),
    );
    await pumpFrames(tester);
    return (log, router);
  }

  testWidgets('a description starts a text scan and opens its results', (
    tester,
  ) async {
    final (log, router) = await open(tester, '/scan?mode=text');
    final start = find.widgetWithText(FilledButton, l10n.scanDescribeStart);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  two old cotton shirts ');
    await tester.pump();
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);

    await tester.tap(start);
    await pumpFrames(tester, 4);
    final id = log.sessions.keys.single;
    expect(log[id].calls, ['text:two old cotton shirts']);
    expect(router.state.matchedLocation, '/results/$id');
  });

  testWidgets('an example fills the description', (tester) async {
    await open(tester, '/scan?mode=text');
    await tester.tap(find.text(l10n.scanExampleJeans));
    await tester.pump();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, l10n.scanExampleJeans);
  });

  testWidgets('a picked photo starts a photo scan and opens its results', (
    tester,
  ) async {
    final path = photoPath('glass_jar');
    final (log, router) = await open(
      tester,
      '/scan?mode=gallery',
      picker: _Picker(XFile(path)),
    );
    await pumpFrames(tester, 4);
    final id = log.sessions.keys.single;
    expect(log[id].calls, ['photo:$path']);
    expect(router.state.matchedLocation, '/results/$id');
  });

  testWidgets('cancelling the gallery closes the scan', (tester) async {
    final (log, router) = await open(
      tester,
      '/scan?mode=gallery',
      picker: _Picker(null),
    );
    await pumpFrames(tester, 4);
    expect(log.sessions, isEmpty);
    expect(router.state.matchedLocation, '/');
  });

  testWidgets('camera turned off in Settings: open Settings or describe', (
    tester,
  ) async {
    final permissions = _Permissions(PermissionState.permanentlyDenied);
    final camera = _Camera();
    await open(
      tester,
      '/scan?mode=camera',
      permissions: permissions,
      camera: camera,
    );
    expect(find.text(l10n.scanCameraBlockedBody), findsOneWidget);
    expect(camera.starts, 0);

    await tester.tap(find.text(l10n.commonOpenSettings));
    await tester.pump();
    expect(permissions.settingsOpened, 1);

    await tester.tap(find.text(l10n.scanDescribeInstead));
    await pumpFrames(tester, 2);
    expect(find.text(l10n.scanDescribeTitle), findsOneWidget);
    // Opened from the camera, the description can go back to it.
    expect(find.bySemanticsLabel(l10n.scanBackToCamera), findsOneWidget);
  });

  testWidgets('not allowed yet: the rationale first, then Allow camera', (
    tester,
  ) async {
    final permissions = _Permissions(
      PermissionState.denied,
      afterRequest: PermissionState.granted,
    );
    final camera = _Camera(CameraFailure.failed);
    await open(
      tester,
      '/scan?mode=camera',
      permissions: permissions,
      camera: camera,
    );
    // The rationale stand-in popped without granting: the fallback shows.
    expect(find.text(l10n.scanCameraDeniedTitle), findsOneWidget);
    expect(camera.starts, 0);

    await tester.tap(find.text(l10n.scanCameraAllow));
    await pumpFrames(tester, 4);
    expect(permissions.requests, 1);
    // Granted, but this camera cannot open: it says so and offers a retry.
    expect(camera.starts, 1);
    expect(find.text(l10n.scanCameraUnavailableTitle), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsOneWidget);
  });

  testWidgets('no camera on the phone offers the gallery', (tester) async {
    await open(tester, '/scan?mode=camera', camera: _Camera());
    expect(find.text(l10n.scanNoCameraBody), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, l10n.scanChooseFromGallery),
      findsOneWidget,
    );
  });
}
