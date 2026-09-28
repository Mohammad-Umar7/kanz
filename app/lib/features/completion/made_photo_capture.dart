import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/state/core_providers.dart';
import '../../l10n/l10n.dart';

/// Opens the camera to photograph a finished project and returns the path
/// of the photo taken (or picked from the gallery), or null when the user
/// closed it. The caller saves it with `MadePhotoStore`.
Future<String?> captureMadePhoto(BuildContext context) =>
    Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const MadePhotoCaptureScreen(),
      ),
    );

/// Where the camera is in its setup.
enum MadePhotoCameraPhase {
  /// Reading or asking for the camera permission.
  checking,

  /// Permission granted, the camera is opening.
  starting,

  /// The preview is live.
  live,

  /// Not granted; asking again shows the system dialog.
  denied,

  /// Only Settings can grant it (or a policy blocks it).
  blocked,

  /// No usable camera, or it failed to open.
  unavailable,
}

/// The camera for "Add a photo of what you made": the preview, a shutter and
/// the gallery as the alternative. The user asked for the camera by tapping
/// the button, so the system permission dialog comes straight away; without
/// a camera the gallery still works.
class MadePhotoCaptureScreen extends ConsumerStatefulWidget {
  const MadePhotoCaptureScreen({super.key});

  @override
  ConsumerState<MadePhotoCaptureScreen> createState() =>
      _MadePhotoCaptureScreenState();
}

class _MadePhotoCaptureScreenState extends ConsumerState<MadePhotoCaptureScreen>
    with WidgetsBindingObserver {
  // Read once: the services must still be reachable in dispose.
  late final CameraService _camera = ref.read(cameraServiceProvider);
  late final PermissionService _permissions = ref.read(
    permissionServiceProvider,
  );

  MadePhotoCameraPhase _phase = MadePhotoCameraPhase.checking;
  bool _capturing = false;
  String? _captured;

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
      case MadePhotoCameraPhase.live || MadePhotoCameraPhase.starting:
        unawaited(_followLifecycle(state));
      case MadePhotoCameraPhase.denied || MadePhotoCameraPhase.blocked:
        // The user may have allowed the camera in Settings meanwhile. Only
        // look: the system dialog comes back when they ask for it.
        if (state == AppLifecycleState.resumed) unawaited(_recheck());
      case MadePhotoCameraPhase.checking || MadePhotoCameraPhase.unavailable:
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
    var status = await _status();
    if (status == PermissionState.denied) status = await _request();
    if (!mounted) return;
    if (status == PermissionState.granted) {
      await _open();
    } else {
      setState(() => _phase = _phaseForPermission(status));
    }
  }

  Future<void> _recheck() async {
    final status = await _status();
    if (mounted && status == PermissionState.granted) await _open();
  }

  Future<PermissionState> _request() async {
    try {
      return await _permissions.request(AppPermission.camera);
    } on Object {
      return PermissionState.denied;
    }
  }

  Future<void> _allow() async {
    final status = await _request();
    if (!mounted) return;
    if (status == PermissionState.granted) {
      await _open();
    } else {
      setState(() => _phase = _phaseForPermission(status));
    }
  }

  Future<void> _open() async {
    setState(() => _phase = MadePhotoCameraPhase.starting);
    try {
      await _camera.start();
    } on CameraUnavailable catch (e) {
      if (mounted) setState(() => _phase = _phaseFor(e));
      return;
    }
    if (mounted) setState(() => _phase = MadePhotoCameraPhase.live);
  }

  MadePhotoCameraPhase _phaseForPermission(PermissionState status) =>
      switch (status) {
        PermissionState.granted => MadePhotoCameraPhase.starting,
        PermissionState.denied => MadePhotoCameraPhase.denied,
        PermissionState.permanentlyDenied ||
        PermissionState.restricted => MadePhotoCameraPhase.blocked,
      };

  MadePhotoCameraPhase _phaseFor(CameraUnavailable e) => switch (e.reason) {
    CameraFailure.permissionDenied => MadePhotoCameraPhase.denied,
    CameraFailure.noCamera ||
    CameraFailure.failed => MadePhotoCameraPhase.unavailable,
  };

  Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    final XFile file;
    try {
      file = await _camera.capture();
    } on CameraUnavailable {
      if (mounted) setState(() => _capturing = false);
      return;
    }
    if (!mounted) return;
    // Hold the still on screen while the route closes.
    setState(() => _captured = file.path);
    Navigator.of(context).pop(file.path);
  }

  Future<void> _pickFromGallery() async {
    final XFile? file;
    try {
      file = await ref.read(galleryPickerProvider).pick();
    } on Object {
      return;
    }
    if (file == null || !mounted) return;
    Navigator.of(context).pop(file.path);
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keep the camera owner alive while shown.
    ref.watch(cameraServiceProvider);

    final problem = switch (_phase) {
      MadePhotoCameraPhase.denied ||
      MadePhotoCameraPhase.blocked ||
      MadePhotoCameraPhase.unavailable => _phase,
      _ => null,
    };
    if (problem != null) {
      return MadePhotoCameraProblem(
        phase: problem,
        onGallery: () => unawaited(_pickFromGallery()),
        onAllow: () => unawaited(_allow()),
        onOpenSettings: () => unawaited(_permissions.openSettings()),
        onClose: _close,
      );
    }

    final live = _phase == MadePhotoCameraPhase.live && _camera.isReady;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MadePhotoViewfinder(
        preview: _preview(context),
        guidance: live
            ? l10n.completionCaptureGuidance
            : l10n.completionCaptureStarting,
        closeLabel: l10n.commonClose,
        shutterLabel: l10n.completionCaptureShutter,
        galleryLabel: l10n.completionCaptureGallery,
        busy: _capturing,
        onShutter: live && !_capturing ? () => unawaited(_capture()) : null,
        onGallery: () => unawaited(_pickFromGallery()),
        onClose: _close,
      ),
    );
  }

  Widget _preview(BuildContext context) {
    final captured = _captured;
    if (captured != null) {
      return Image.file(
        File(captured),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        excludeFromSemantics: true,
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

/// The camera chrome for the project photo: close at the top, corner
/// brackets, one line of guidance, then the gallery and the clay shutter on
/// a dark band. Pure layout, so screenshot tests render it with a photo in
/// place of the live [preview].
class MadePhotoViewfinder extends StatelessWidget {
  const MadePhotoViewfinder({
    super.key,
    required this.preview,
    required this.guidance,
    required this.closeLabel,
    required this.shutterLabel,
    required this.galleryLabel,
    required this.onShutter,
    required this.onGallery,
    required this.onClose,
    this.busy = false,
  });

  final Widget preview;
  final String guidance;
  final String closeLabel;
  final String shutterLabel;
  final String galleryLabel;

  /// Null while the camera is not ready.
  final VoidCallback? onShutter;
  final VoidCallback onGallery;
  final VoidCallback onClose;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Scaffold(
      backgroundColor: c.photoBackdrop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          preview,
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          KanzSpace.s12,
                          KanzSpace.s8,
                          KanzSpace.s12,
                          0,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: KanzIconButton(
                            icon: KanzIcons.close,
                            semanticsLabel: closeLabel,
                            style: KanzIconButtonStyle.onPhoto,
                            onPressed: onClose,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KanzSpace.s32,
                            vertical: KanzSpace.s24,
                          ),
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: IgnorePointer(
                                child: CornerBrackets(active: busy),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: KanzSpace.page,
                        child: Semantics(
                          liveRegion: true,
                          container: true,
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: KanzSpace.s12,
                              vertical: KanzSpace.s8,
                            ),
                            decoration: const BoxDecoration(
                              color: KanzPhotoColors.control,
                              borderRadius: KanzRadii.chipAll,
                            ),
                            child: Text(
                              guidance,
                              textAlign: TextAlign.center,
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: KanzPhotoColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: KanzSpace.s16),
                    ],
                  ),
                ),
              ),
              // The controls sit on a dark band of the photo tint (never a
              // blur), so their labels read over any scene.
              ColoredBox(
                color: KanzPhotoColors.control,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      KanzSpace.s8,
                      KanzSpace.s16,
                      KanzSpace.s8,
                      KanzSpace.s16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GalleryAction(
                            label: galleryLabel,
                            onPressed: busy ? null : onGallery,
                          ),
                        ),
                        ShutterButton(
                          semanticsLabel: shutterLabel,
                          onPressed: onShutter,
                          busy: busy,
                        ),
                        // Balances the gallery so the shutter stays centred.
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The gallery as a 48 dp ringed control on the band with its label under
/// it; one button for screen readers.
class _GalleryAction extends StatelessWidget {
  const _GalleryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: Center(
        child: InkResponse(
          onTap: onPressed,
          radius: KanzSpace.touchTarget,
          highlightShape: BoxShape.circle,
          child: Padding(
            padding: const EdgeInsets.all(KanzSpace.s4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: KanzSpace.touchTarget,
                  height: KanzSpace.touchTarget,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KanzPhotoColors.ink.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    KanzIcons.gallery,
                    size: 22,
                    color: KanzPhotoColors.ink,
                  ),
                ),
                const SizedBox(height: KanzSpace.s4),
                Text(
                  label,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: KanzPhotoColors.ink,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The camera cannot be used: why, in plain words, with the gallery as the
/// way forward and, when it can help, a way to allow the camera.
class MadePhotoCameraProblem extends StatelessWidget {
  const MadePhotoCameraProblem({
    super.key,
    required this.phase,
    required this.onGallery,
    required this.onAllow,
    required this.onOpenSettings,
    required this.onClose,
  });

  /// [MadePhotoCameraPhase.denied], `blocked` or `unavailable`.
  final MadePhotoCameraPhase phase;
  final VoidCallback onGallery;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final message = switch (phase) {
      MadePhotoCameraPhase.denied => l10n.completionCameraDenied,
      MadePhotoCameraPhase.blocked => l10n.completionCameraBlocked,
      _ => l10n.completionCameraNone,
    };
    return Scaffold(
      appBar: AppBar(
        leading: KanzIconButton(
          icon: KanzIcons.close,
          semanticsLabel: l10n.commonClose,
          onPressed: onClose,
        ),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          KanzSpace.s24,
          KanzSpace.gutter,
          KanzSpace.s32,
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.lineStrong),
              ),
              child: Icon(KanzIcons.camera, size: 24, color: c.ink),
            ),
          ),
          const SizedBox(height: KanzSpace.s20),
          Semantics(
            header: true,
            child: Text(l10n.completionCameraTitle, style: t.headlineSmall),
          ),
          const SizedBox(height: KanzSpace.s8),
          Text(message, style: t.bodyMedium?.copyWith(color: c.inkSecondary)),
          const SizedBox(height: KanzSpace.s24),
          KanzButton(
            key: const ValueKey('made-photo-gallery'),
            label: l10n.completionCaptureGallery,
            icon: KanzIcons.gallery,
            expand: true,
            onPressed: onGallery,
          ),
          if (phase == MadePhotoCameraPhase.denied) ...[
            const SizedBox(height: KanzSpace.s8),
            KanzButton.tertiary(
              label: l10n.completionCameraAllow,
              expand: true,
              onPressed: onAllow,
            ),
          ] else if (phase == MadePhotoCameraPhase.blocked) ...[
            const SizedBox(height: KanzSpace.s8),
            KanzButton.tertiary(
              label: l10n.commonOpenSettings,
              expand: true,
              onPressed: onOpenSettings,
            ),
          ],
        ],
      ),
    );
  }
}
