import 'package:flutter/material.dart';

import '../../core/design/design.dart';

/// The viewfinder chrome around a camera preview: close and flashlight at the
/// top, corner brackets framing the item, one line of guidance, and the clay
/// shutter between the gallery and "Describe".
///
/// Pure layout: the camera, the permission flow and the capture live in
/// `CameraScanView`, so this also renders in screenshot tests with a photo
/// standing in for [preview].
class Viewfinder extends StatelessWidget {
  const Viewfinder({
    super.key,
    required this.preview,
    required this.guidance,
    required this.closeLabel,
    required this.shutterLabel,
    required this.galleryLabel,
    required this.gallerySemantics,
    required this.describeLabel,
    required this.describeSemantics,
    required this.onClose,
    required this.onShutter,
    required this.onGallery,
    required this.onDescribe,
    this.torchLabel,
    this.torchOn = false,
    this.onTorch,
    this.busy = false,
    this.notice,
  });

  /// The live preview, or the captured still while the results open.
  final Widget preview;
  final String guidance;
  final String closeLabel;
  final String shutterLabel;
  final String galleryLabel;
  final String gallerySemantics;
  final String describeLabel;
  final String describeSemantics;
  final VoidCallback onClose;

  /// Null while the camera is not ready.
  final VoidCallback? onShutter;
  final VoidCallback onGallery;
  final VoidCallback onDescribe;

  /// Flashlight toggle; hidden when [onTorch] is null.
  final String? torchLabel;
  final bool torchOn;
  final VoidCallback? onTorch;

  /// A capture is in progress: the shutter spins and the brackets turn clay.
  final bool busy;

  /// A short notice under the top bar, for example that the phone is offline.
  final String? notice;

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
                        child: Row(
                          children: [
                            KanzIconButton(
                              icon: KanzIcons.close,
                              semanticsLabel: closeLabel,
                              style: KanzIconButtonStyle.onPhoto,
                              onPressed: onClose,
                            ),
                            const Spacer(),
                            if (onTorch != null && torchLabel != null)
                              KanzIconButton(
                                icon: torchOn
                                    ? KanzIcons.flashOn
                                    : KanzIcons.flashOff,
                                semanticsLabel: torchLabel!,
                                style: KanzIconButtonStyle.onPhoto,
                                selected: torchOn,
                                onPressed: onTorch,
                              ),
                          ],
                        ),
                      ),
                      if (notice != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            KanzSpace.gutter,
                            KanzSpace.s12,
                            KanzSpace.gutter,
                            0,
                          ),
                          child: _PhotoNote(
                            text: notice!,
                            icon: KanzIcons.noWifi,
                            liveRegion: true,
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
                        child: _PhotoNote(text: guidance),
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
                          child: _SideAction(
                            icon: KanzIcons.gallery,
                            label: galleryLabel,
                            semanticsLabel: gallerySemantics,
                            onPressed: busy ? null : onGallery,
                          ),
                        ),
                        ShutterButton(
                          semanticsLabel: shutterLabel,
                          onPressed: onShutter,
                          busy: busy,
                        ),
                        Expanded(
                          child: _SideAction(
                            icon: KanzIcons.describe,
                            label: describeLabel,
                            semanticsLabel: describeSemantics,
                            onPressed: busy ? null : onDescribe,
                          ),
                        ),
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

/// A 48 dp ringed control on the band with a short label under it. One control for
/// screen readers: the disc and the label share a single button node.
class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.labelSmall?.copyWith(
      color: KanzPhotoColors.ink,
    );
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel,
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
                  child: Icon(icon, size: 22, color: KanzPhotoColors.ink),
                ),
                const SizedBox(height: KanzSpace.s4),
                Text(
                  label,
                  style: style,
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

/// A line of text on the preview, on the dark photo tint so it reads over
/// any scene. Never a blur.
class _PhotoNote extends StatelessWidget {
  const _PhotoNote({required this.text, this.icon, this.liveRegion = false});

  final String text;
  final IconData? icon;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: liveRegion,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: KanzPhotoColors.ink),
              const SizedBox(width: KanzSpace.s8),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: KanzPhotoColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
