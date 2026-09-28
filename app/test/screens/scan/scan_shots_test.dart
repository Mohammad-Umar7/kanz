// Renders every Scan state (viewfinder chrome, camera fallbacks, gallery,
// describe) at 360 and 412 dp, light and dark, English and Arabic, plus
// 130 % text for the describe screen, into test/screenshots/_out/.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kanz/core/services/gallery_picker.dart';
import 'package:kanz/core/state/connectivity_providers.dart';
import 'package:kanz/core/state/core_providers.dart';
import 'package:kanz/features/scan/camera_fallback.dart';
import 'package:kanz/features/scan/describe_view.dart';
import 'package:kanz/features/scan/gallery_pick_view.dart';
import 'package:kanz/features/scan/viewfinder.dart';
import 'package:kanz/l10n/l10n.dart';

import '../../screenshots/harness.dart';
import '../results/results_test_support.dart';

/// A picker that stays open (the system picker is on screen) or fails.
class _Picker extends GalleryPicker {
  _Picker({this.fail = false});

  final bool fail;

  @override
  Future<XFile?> pick() =>
      fail ? Future.error(Exception('denied')) : Completer<XFile?>().future;

  @override
  Future<XFile?> recoverLost() async => null;
}

Future<void> _shot(
  WidgetTester tester, {
  required String name,
  required ShotConfig config,
  required Widget child,
  BackendStatus status = BackendStatus.online,
  GalleryPicker? picker,
  Future<void> Function(WidgetTester tester)? then,
}) async {
  final preferences = await testPreferences();
  await precacheFiles(tester, [photoPath('glass_jar')]);
  await takeShot(
    tester,
    name: then == null ? name : '${name}_before',
    config: config,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    wrap: (app) => withBoundary(
      ProviderScope(
        overrides: screenOverrides(
          preferences: preferences,
          status: status,
          extra: [
            if (picker != null) galleryPickerProvider.overrideWithValue(picker),
          ],
        ),
        child: app,
      ),
    ),
    child: child,
  );
  if (then != null) {
    await then(tester);
    await captureAgain(tester, name: name, config: config);
  }
}

/// The viewfinder chrome over the jar photo, standing in for the live
/// camera preview (platform textures do not render in tests).
Widget _viewfinder({
  bool busy = false,
  bool torch = false,
  bool offline = false,
}) => Builder(
  builder: (context) {
    final l10n = context.l10n;
    return Viewfinder(
      preview: Image(
        image: photoImage('glass_jar'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
      guidance: l10n.scanGuidance,
      notice: offline ? l10n.scanOffline : null,
      closeLabel: l10n.commonClose,
      shutterLabel: l10n.scanShutter,
      galleryLabel: l10n.scanGallery,
      gallerySemantics: l10n.scanGallerySemantics,
      describeLabel: l10n.scanDescribe,
      describeSemantics: l10n.scanDescribeSemantics,
      torchLabel: l10n.scanTorch,
      torchOn: torch,
      onTorch: () {},
      busy: busy,
      onShutter: busy ? null : () {},
      onClose: () {},
      onGallery: () {},
      onDescribe: () {},
    );
  },
);

Widget _fallback(CameraFallbackKind kind) => CameraFallback(
  kind: kind,
  onAllow: () {},
  onOpenSettings: () {},
  onRetry: () {},
  onGallery: () {},
  onDescribe: () {},
  onClose: () {},
);

void main() {
  setUpAll(loadKanzFonts);

  for (final config in ShotConfig.matrix()) {
    testWidgets('scan viewfinder ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_viewfinder',
        config: config,
        child: _viewfinder(),
      );
    });

    testWidgets('scan camera denied ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_camera_denied',
        config: config,
        child: _fallback(CameraFallbackKind.denied),
      );
    });
  }

  for (final config in [
    ...ShotConfig.matrix(),
    const ShotConfig(textScale: 1.3),
    const ShotConfig(locale: Locale('ar'), textScale: 1.3),
  ]) {
    testWidgets('scan describe ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_describe',
        config: config,
        child: DescribeView(onSubmit: (_) {}, onClose: () {}),
      );
    });
  }

  for (final config in compactMatrix()) {
    testWidgets('scan capturing ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_capturing',
        config: config,
        child: _viewfinder(busy: true, torch: true),
      );
    });

    testWidgets('scan offline ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_viewfinder_offline',
        config: config,
        status: BackendStatus.offline,
        child: _viewfinder(offline: true),
      );
    });

    testWidgets('scan camera blocked ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_camera_blocked',
        config: config,
        child: _fallback(CameraFallbackKind.blocked),
      );
    });

    testWidgets('scan camera unavailable ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_camera_unavailable',
        config: config,
        child: _fallback(CameraFallbackKind.unavailable),
      );
    });

    testWidgets('scan describe filled offline ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_describe_filled',
        config: config,
        status: BackendStatus.offline,
        child: DescribeView(
          onSubmit: (_) {},
          onClose: () {},
          backToCamera: true,
        ),
        then: (tester) async {
          final l10n = await AppLocalizations.delegate.load(config.locale);
          await tester.tap(find.text(l10n.scanExampleBatteries).first);
          await tester.pump();
        },
      );
    });

    testWidgets('scan gallery opening ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_gallery_opening',
        config: config,
        picker: _Picker(),
        child: GalleryPickView(
          onPhoto: (_) {},
          onCancel: () {},
          onCamera: () {},
          onDescribe: () {},
        ),
      );
    });

    testWidgets('scan gallery failed ${config.id}', (tester) async {
      await _shot(
        tester,
        name: 'scan_gallery_failed',
        config: config,
        picker: _Picker(fail: true),
        child: GalleryPickView(
          onPhoto: (_) {},
          onCancel: () {},
          onCamera: () {},
          onDescribe: () {},
        ),
      );
    });
  }
}
