import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../l10n/l10n.dart';

/// Why the viewfinder cannot show the camera.
enum CameraFallbackKind {
  /// Not allowed yet: asking again shows the system dialog.
  denied,

  /// Turned off in Settings (or blocked by a policy).
  blocked,

  /// The camera exists but did not open.
  unavailable,

  /// No usable camera on this phone.
  noCamera,
}

/// Shown instead of the viewfinder when there is no camera to use. It never
/// dead-ends: a photo from the gallery or a typed description still starts a
/// scan, and the camera itself stays one tap away when it can come back.
class CameraFallback extends StatelessWidget {
  const CameraFallback({
    super.key,
    required this.kind,
    required this.onAllow,
    required this.onOpenSettings,
    required this.onRetry,
    required this.onGallery,
    required this.onDescribe,
    required this.onClose,
  });

  final CameraFallbackKind kind;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;
  final VoidCallback onGallery;
  final VoidCallback onDescribe;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final (title, body) = switch (kind) {
      CameraFallbackKind.denied => (
        l10n.scanCameraDeniedTitle,
        l10n.scanCameraDeniedBody,
      ),
      CameraFallbackKind.blocked => (
        l10n.scanCameraDeniedTitle,
        l10n.scanCameraBlockedBody,
      ),
      CameraFallbackKind.unavailable => (
        l10n.scanCameraUnavailableTitle,
        l10n.scanCameraUnavailableBody,
      ),
      CameraFallbackKind.noCamera => (
        l10n.scanCameraUnavailableTitle,
        l10n.scanNoCameraBody,
      ),
    };

    // One primary action: allowing the camera when a tap can still do it,
    // otherwise the gallery, which always works.
    final gallery = KanzButton(
      label: l10n.scanChooseFromGallery,
      icon: KanzIcons.gallery,
      onPressed: onGallery,
      expand: true,
    );
    final actions = <Widget>[
      if (kind == CameraFallbackKind.denied) ...[
        KanzButton(
          label: l10n.scanCameraAllow,
          icon: KanzIcons.camera,
          onPressed: onAllow,
          expand: true,
        ),
        KanzButton.secondary(
          label: l10n.scanChooseFromGallery,
          icon: KanzIcons.gallery,
          onPressed: onGallery,
          expand: true,
        ),
      ] else
        gallery,
      KanzButton.secondary(
        label: l10n.scanDescribeInstead,
        icon: KanzIcons.describe,
        onPressed: onDescribe,
        expand: true,
      ),
      if (kind == CameraFallbackKind.blocked)
        KanzButton.tertiary(
          label: l10n.commonOpenSettings,
          onPressed: onOpenSettings,
          expand: true,
        ),
      if (kind == CameraFallbackKind.unavailable)
        KanzButton.tertiary(
          label: l10n.commonRetry,
          icon: KanzIcons.retry,
          onPressed: onRetry,
          expand: true,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: KanzIconButton(
          icon: KanzIcons.close,
          semanticsLabel: l10n.commonClose,
          onPressed: onClose,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
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
            const SizedBox(height: KanzSpace.s24),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(title, style: t.headlineMedium),
            ),
            const SizedBox(height: KanzSpace.s8),
            Text(body, style: t.bodyLarge?.copyWith(color: c.inkSecondary)),
            const SizedBox(height: KanzSpace.s32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: KanzSpace.s8,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
