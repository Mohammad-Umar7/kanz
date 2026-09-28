import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/state/scan_session.dart';
import 'camera_scan_view.dart';
import 'describe_view.dart';
import 'gallery_pick_view.dart';

/// Scan (`/scan?mode=camera|gallery|text`): the viewfinder, a gallery pick or
/// a typed description. Every path ends the same way: a new scan id, the
/// session started, and `/results/:scanId`.
///
/// The viewfinder can hand over to the gallery or the description in place,
/// so the mode is local state that starts from the route.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, this.mode = ScanMode.camera});

  final ScanMode mode;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  late ScanMode _mode = widget.mode;

  /// The description was opened from the viewfinder: its back button returns
  /// to the camera instead of closing the scan.
  bool _describeFromCamera = false;

  void _setMode(ScanMode mode) => setState(() {
    _describeFromCamera = _mode == ScanMode.camera && mode == ScanMode.text;
    _mode = mode;
  });

  @override
  Widget build(BuildContext context) {
    return switch (_mode) {
      ScanMode.camera => CameraScanView(
        onPhoto: (path, scanId) =>
            unawaited(startPhotoScan(context, ref, path: path, scanId: scanId)),
        onUseGallery: () => _setMode(ScanMode.gallery),
        onDescribe: () => _setMode(ScanMode.text),
        onClose: () => closeScan(context),
      ),
      ScanMode.gallery => GalleryPickView(
        onPhoto: (path) => unawaited(startPhotoScan(context, ref, path: path)),
        // Cancelling a pick started from the viewfinder goes back to it.
        onCancel: widget.mode == ScanMode.camera
            ? () => _setMode(ScanMode.camera)
            : () => closeScan(context),
        onCamera: () => _setMode(ScanMode.camera),
        onDescribe: () => _setMode(ScanMode.text),
      ),
      ScanMode.text => DescribeView(
        onSubmit: (text) => startTextScan(context, ref, text),
        onClose: _describeFromCamera
            ? () => _setMode(ScanMode.camera)
            : () => closeScan(context),
        backToCamera: _describeFromCamera,
      ),
    };
  }
}

/// Hero tag shared by the captured photo on the viewfinder and the photo at
/// the top of the results screen.
Object scanPhotoHeroTag(String scanId) => 'scan-photo-$scanId';

/// Starts a photo scan and opens its results. The session runs on its own
/// (compress, analyze, recommend, drop-off, makeovers); this only waits for
/// the compressed photo to be on the device (a fraction of a second), so
/// the results open with the photo already in place for the Hero to land
/// on. Pass [scanId] when the caller already shows the photo under
/// [scanPhotoHeroTag].
Future<void> startPhotoScan(
  BuildContext context,
  WidgetRef ref, {
  required String path,
  String? scanId,
}) async {
  final id = scanId ?? newScanId();
  final provider = scanSessionProvider(id);
  final photoReady = Completer<void>();
  final subscription = ref.listenManual(provider, (_, next) {
    final settled =
        next.localImagePath != null ||
        next.stage(PipelineStage.identifying).isFailed;
    if (settled && !photoReady.isCompleted) photoReady.complete();
  });
  unawaited(ref.read(provider.notifier).startFromPhoto(path: path));
  await photoReady.future.timeout(const Duration(seconds: 3), onTimeout: () {});
  // Closed with the screen if the user left meanwhile; the scan goes on and
  // waits in History.
  if (!context.mounted) return;
  subscription.close();
  // Decode it too, so the results paint the photo on their first frame
  // instead of an empty frame while it loads.
  final photo = ref.read(provider).localImagePath;
  if (photo != null) {
    await precacheImage(
      FileImage(File(photo)),
      context,
    ).timeout(const Duration(seconds: 1), onTimeout: () {});
  }
  if (context.mounted) context.go(AppRoutes.results(id));
}

/// Starts a scan from a description and opens its results.
void startTextScan(BuildContext context, WidgetRef ref, String text) {
  final id = newScanId();
  unawaited(ref.read(scanSessionProvider(id).notifier).startFromText(text));
  context.go(AppRoutes.results(id));
}

/// Leaves the scan flow: back to where it was opened, or Home when the scan
/// screen is the only page (it was opened with `context.go`).
void closeScan(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}
