import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

/// Why the viewfinder cannot show a camera preview.
enum CameraFailure { noCamera, permissionDenied, failed }

class CameraUnavailable implements Exception {
  const CameraUnavailable(this.reason, [this.detail]);

  final CameraFailure reason;
  final String? detail;

  @override
  String toString() => 'CameraUnavailable(${reason.name}): $detail';
}

/// Owns the one back-camera controller the viewfinder uses.
///
/// The scan screen calls [start] in initState, [handleLifecycle] from
/// `didChangeAppLifecycleState` (Android releases the camera when the app is
/// backgrounded, so the controller must be recreated on resume) and [stop] in
/// dispose. Preview with `CameraPreview(service.controller!)`.
class CameraService {
  CameraController? _controller;
  bool _wanted = false;

  /// The start in progress. On Android the resume that follows the camera
  /// permission dialog arrives while the first `initialize()` is still
  /// running; sharing this future stops a second controller from grabbing
  /// the camera and leaking the first.
  Future<CameraController>? _starting;

  CameraController? get controller => _controller;

  bool get isReady => _controller?.value.isInitialized ?? false;

  /// Opens the back camera. Throws [CameraUnavailable].
  Future<CameraController> start() {
    _wanted = true;
    if (isReady) return Future.value(_controller!);
    return _starting ??= _open().whenComplete(() => _starting = null);
  }

  Future<CameraController> _open() async {
    final List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      throw CameraUnavailable(CameraFailure.failed, e.description);
    }
    if (cameras.isEmpty) throw const CameraUnavailable(CameraFailure.noCamera);
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      back,
      // 'veryHigh' (1080p class) is sharp enough for labels and resin codes;
      // the photo is downscaled to 1600 px before upload anyway.
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      await controller.dispose();
      throw CameraUnavailable(
        e.code.startsWith('CameraAccess')
            ? CameraFailure.permissionDenied
            : CameraFailure.failed,
        e.description,
      );
    }
    if (!_wanted) {
      // stop() was called while the camera was opening.
      await controller.dispose();
      throw const CameraUnavailable(CameraFailure.failed, 'stopped');
    }
    _controller = controller;
    return controller;
  }

  /// Releases the camera.
  Future<void> stop() async {
    _wanted = false;
    await _release();
  }

  /// Releases the camera while the app is in the background and reopens it on
  /// resume if the viewfinder still wants it.
  Future<void> handleLifecycle(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await _release();
    } else if (state == AppLifecycleState.resumed && _wanted && !isReady) {
      await start();
    }
  }

  /// Takes a still photo. Throws [CameraUnavailable] if the camera is not ready.
  Future<XFile> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraUnavailable(CameraFailure.failed, 'not initialized');
    }
    if (controller.value.isTakingPicture) {
      throw const CameraUnavailable(CameraFailure.failed, 'busy');
    }
    try {
      return await controller.takePicture();
    } on CameraException catch (e) {
      throw CameraUnavailable(CameraFailure.failed, e.description);
    }
  }

  Future<void> setTorch({required bool on}) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    } on CameraException {
      // Devices without a torch: leave the flash off.
    }
  }

  Future<void> _release() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}
