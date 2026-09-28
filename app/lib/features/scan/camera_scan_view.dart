import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/design/design.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/state/connectivity_providers.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/scan_session.dart';
import '../../l10n/l10n.dart';
import 'camera_fallback.dart';
import 'scan_screen.dart';
import 'viewfinder.dart';

/// Where the viewfinder is in its setup.
enum CameraPhase {
  /// Reading the camera permission.
  checking,

  /// Permission granted, the camera is opening.
  starting,

  /// The preview is live.
  live,

  /// Not granted; asking again shows the system dialog.
  denied,

  /// Only Settings can grant it (or a policy blocks it).
  blocked,

  /// The camera exists but could not open (busy, failed).
  unavailable,

  /// The phone has no usable camera.
  noCamera,
}

/// The camera path of the scan screen: permission (through the camera
/// rationale the first time), the preview and its lifecycle, the flashlight
/// and the capture. Without a camera it offers the gallery and a description.
class CameraScanView extends ConsumerStatefulWidget {
  const CameraScanView({
    super.key,
    required this.onPhoto,
    required this.onUseGallery,
    required this.onDescribe,
    required this.onClose,
  });

  /// A photo was taken; [scanId] is already shown under [scanPhotoHeroTag].
  final void Function(String path, String scanId) onPhoto;
  final VoidCallback onUseGallery;
  final VoidCallback onDescribe;
  final VoidCallback onClose;

  @override
  ConsumerState<CameraScanView> createState() => _CameraScanViewState();
}

class _CameraScanViewState extends ConsumerState<CameraScanView>
    with WidgetsBindingObserver {
  // Read once: the services must still be reachable in dispose, where ref
  // can no longer be used.
  late final CameraService _camera = ref.read(cameraServiceProvider);
  late final PermissionService _permissions = ref.read(
    permissionServiceProvider,
  );

  CameraPhase _phase = CameraPhase.checking;
  bool _torch = false;
  bool _capturing = false;
  bool _askedWithRationale = false;

  /// The captured still and its scan id, shown while the results open.
  String? _capturedPath;
  String? _capturedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_prepare());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_camera.stop());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (_phase) {
      case CameraPhase.live || CameraPhase.starting:
        // Android releases the camera in the background: drop the preview
        // now and rebuild once the service reopened it.
        if (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused) {
          _torch = false;
        }
        unawaited(_followLifecycle(state));
      case CameraPhase.denied || CameraPhase.blocked:
        // The user may have allowed the camera in Settings meanwhile.
        if (state == AppLifecycleState.resumed) unawaited(_recheck());
      case CameraPhase.checking ||
          CameraPhase.unavailable ||
          CameraPhase.noCamera:
        break;
    }
  }

  Future<void> _followLifecycle(AppLifecycleState state) async {
    final pending = _camera.handleLifecycle(state);
    if (mounted) setState(() {});
    try {
      await pending;
    } on CameraUnavailable catch (e) {
      if (mounted) setState(() => _phase = _phaseFor(e));
      return;
    }
    if (mounted) setState(() {});
  }

  Future<PermissionState> _status() async {
    try {
      return await _permissions.status(AppPermission.camera);
    } on Object {
      // A plugin failure: let the camera itself report what is wrong.
      return PermissionState.granted;
    }
  }

  Future<void> _prepare() async {
    final status = await _status();
    if (!mounted) return;
    switch (status) {
      case PermissionState.granted:
        await _open();
      case PermissionState.permanentlyDenied || PermissionState.restricted:
        setState(() => _phase = CameraPhase.blocked);
      case PermissionState.denied:
        if (_askedWithRationale) {
          setState(() => _phase = CameraPhase.denied);
          return;
        }
        // First time: explain why before the system dialog. The rationale
        // screen asks; whatever it returns, the permission itself decides.
        _askedWithRationale = true;
        await context.push<Object?>(AppRoutes.cameraRationale);
        if (!mounted) return;
        final after = await _status();
        if (!mounted) return;
        if (after == PermissionState.granted) {
          await _open();
        } else {
          setState(() => _phase = _phaseForPermission(after));
        }
    }
  }

  Future<void> _recheck() async {
    final status = await _status();
    if (!mounted) return;
    if (status == PermissionState.granted) {
      await _open();
    } else {
      setState(() => _phase = _phaseForPermission(status));
    }
  }

  Future<void> _allowCamera() async {
    final PermissionState status;
    try {
      status = await _permissions.request(AppPermission.camera);
    } on Object {
      return;
    }
    if (!mounted) return;
    if (status == PermissionState.granted) {
      await _open();
    } else {
      setState(() => _phase = _phaseForPermission(status));
    }
  }

  Future<void> _open() async {
    setState(() => _phase = CameraPhase.starting);
    try {
      await _camera.start();
    } on CameraUnavailable catch (e) {
      if (mounted) setState(() => _phase = _phaseFor(e));
      return;
    }
    if (mounted) setState(() => _phase = CameraPhase.live);
  }

  CameraPhase _phaseForPermission(PermissionState status) => switch (status) {
    PermissionState.granted => CameraPhase.starting,
    PermissionState.denied => CameraPhase.denied,
    PermissionState.permanentlyDenied ||
    PermissionState.restricted => CameraPhase.blocked,
  };

  CameraPhase _phaseFor(CameraUnavailable e) => switch (e.reason) {
    CameraFailure.permissionDenied => CameraPhase.denied,
    CameraFailure.noCamera => CameraPhase.noCamera,
    CameraFailure.failed => CameraPhase.unavailable,
  };

  Future<void> _toggleTorch() async {
    final next = !_torch;
    setState(() => _torch = next);
    await _camera.setTorch(on: next);
  }

  Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    final XFile file;
    try {
      file = await _camera.capture();
    } on CameraUnavailable {
      if (!mounted) return;
      setState(() => _capturing = false);
      return;
    }
    if (!mounted) return;
    if (_torch) unawaited(_camera.setTorch(on: false));
    // Show the still under the shared Hero tag for one frame, so it can fly
    // into the results screen.
    setState(() {
      _capturedPath = file.path;
      _capturedId = newScanId();
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    widget.onPhoto(file.path, _capturedId!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keep the camera owner and the connection status alive while shown.
    ref.watch(cameraServiceProvider);
    final offline = ref.watch(backendStatusProvider) == BackendStatus.offline;

    final fallback = switch (_phase) {
      CameraPhase.denied => CameraFallbackKind.denied,
      CameraPhase.blocked => CameraFallbackKind.blocked,
      CameraPhase.unavailable => CameraFallbackKind.unavailable,
      CameraPhase.noCamera => CameraFallbackKind.noCamera,
      _ => null,
    };
    if (fallback != null) {
      return CameraFallback(
        kind: fallback,
        onAllow: () => unawaited(_allowCamera()),
        onOpenSettings: () => unawaited(_permissions.openSettings()),
        onRetry: () => unawaited(_open()),
        onGallery: widget.onUseGallery,
        onDescribe: widget.onDescribe,
        onClose: widget.onClose,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Viewfinder(
        preview: _preview(context),
        guidance: _phase == CameraPhase.live
            ? l10n.scanGuidance
            : l10n.scanStartingCamera,
        notice: offline ? l10n.scanOffline : null,
        closeLabel: l10n.commonClose,
        shutterLabel: l10n.scanShutter,
        galleryLabel: l10n.scanGallery,
        gallerySemantics: l10n.scanGallerySemantics,
        describeLabel: l10n.scanDescribe,
        describeSemantics: l10n.scanDescribeSemantics,
        torchLabel: l10n.scanTorch,
        torchOn: _torch,
        onTorch: _camera.isReady ? () => unawaited(_toggleTorch()) : null,
        busy: _capturing,
        onShutter: _camera.isReady && !_capturing
            ? () => unawaited(_capture())
            : null,
        onClose: widget.onClose,
        onGallery: widget.onUseGallery,
        onDescribe: widget.onDescribe,
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final captured = _capturedPath;
    if (captured != null) {
      return Hero(
        tag: scanPhotoHeroTag(_capturedId!),
        child: Image.file(
          File(captured),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          excludeFromSemantics: true,
        ),
      );
    }
    final controller = _camera.controller;
    if (!_camera.isReady || controller == null) {
      return ColoredBox(color: context.kanzColors.photoBackdrop);
    }
    // Fill the screen: the preview keeps its aspect ratio and is cropped,
    // like the system camera.
    final size = controller.value.previewSize;
    if (size == null) return Center(child: CameraPreview(controller));
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          // The sensor reports landscape; the phone is held upright.
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
