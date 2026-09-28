import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/state/generated_image.dart';
import '../../../l10n/l10n.dart';
import 'image_sources.dart';

/// Why a step's picture has not started: an earlier step's picture failed,
/// and the chain stops there (each step is an edit of the previous one).
typedef StepImageBlock = ({int step, bool quotaPaused});

/// The 4:3 picture of one tutorial step, finished in every state:
///
/// - ready: the generated image fades in, clean (the step page offers the
///   redraw under it, so nothing sits on a good picture);
/// - loading: a skeleton that says which step is being drawn;
/// - idle: waiting in line behind the previous step, or blocked by an
///   earlier failure;
/// - failed: the user's photo, desaturated, with the step number and a retry
///   (or, when the server has no image quota, a quiet note and no retry);
/// - offline: any picture still to come says it needs a connection, the same
///   reason the banner above gives.
class StepImage extends StatelessWidget {
  const StepImage({
    super.key,
    required this.number,
    required this.title,
    required this.image,
    required this.onRegenerate,
    this.blockedBy,
    this.fallbackPhoto,
    this.offline = false,
  });

  final int number;

  /// Step title, for the image's accessible name.
  final String title;
  final GeneratedImageState image;

  /// Asks for a new picture of this step (also the retry after a failure).
  final VoidCallback? onRegenerate;

  /// Set when this step waits on an earlier step whose picture failed.
  final StepImageBlock? blockedBy;

  /// The user's photo (or a text scan's reference picture), shown
  /// desaturated behind failure notes so the page still carries their item.
  final ImageProvider? fallbackPhoto;

  /// The phone has no connection: pictures that are not here yet cannot
  /// arrive until it is back.
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = generatedImageProvider(image);
    final Widget content;
    String status;
    final noConnection =
        (offline && provider == null) ||
        (image.status == ImageStatus.failed &&
            image.error?.code == ApiErrorCode.offline);
    switch (image.status) {
      case ImageStatus.ready when provider != null:
        status = l10n.tutorialImageLabel(number, title);
        content = _Ready(
          image: provider,
          fallback: _Fallback(
            number: number,
            photo: fallbackPhoto,
            message: l10n.tutorialImageFailed,
            icon: KanzIcons.gallery,
            retryLabel: l10n.commonRetry,
            onRetry: onRegenerate,
          ),
        );
      case _ when noConnection:
        status = l10n.tutorialImageOffline;
        content = _Fallback(
          number: number,
          photo: fallbackPhoto,
          message: status,
          icon: KanzIcons.noWifi,
          retryLabel: l10n.commonRetry,
          onRetry: offline ? null : onRegenerate,
        );
      case ImageStatus.loading:
        status = l10n.tutorialImageDrawing(number);
        content = _Pending(label: status, active: true);
      case ImageStatus.failed:
        final paused = isQuotaPaused(image);
        final retryable = !paused && (image.error?.retryable ?? true);
        status = paused ? l10n.tutorialImagePaused : l10n.tutorialImageFailed;
        content = _Fallback(
          number: number,
          photo: fallbackPhoto,
          message: status,
          icon: paused ? KanzIcons.pause : KanzIcons.gallery,
          retryLabel: l10n.commonRetry,
          onRetry: retryable ? onRegenerate : null,
        );
      case ImageStatus.idle || ImageStatus.ready:
        final block = blockedBy;
        if (block != null) {
          status = block.quotaPaused
              ? l10n.tutorialImagePaused
              : l10n.tutorialImageBlocked(block.step);
          content = _Fallback(
            number: number,
            photo: fallbackPhoto,
            message: status,
            icon: block.quotaPaused ? KanzIcons.pause : KanzIcons.clock,
            retryLabel: l10n.commonRetry,
            onRetry: null,
          );
        } else if (number <= 1) {
          status = l10n.tutorialImageDrawing(number);
          content = _Pending(label: status, active: true);
        } else {
          status = l10n.tutorialImageQueued(number - 1);
          content = _Pending(label: status, active: false);
        }
    }

    return Semantics(
      container: true,
      image: image.isReady,
      liveRegion: !image.isReady,
      label: status,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: KanzRadii.cardAll,
          child: AnimatedSwitcher(
            duration: KanzMotion.of(context, KanzMotion.slow),
            switchInCurve: KanzMotion.enter,
            switchOutCurve: KanzMotion.exit,
            child: KeyedSubtree(
              key: ValueKey('${image.status}-${provider.hashCode}'),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.image, required this.fallback});

  final ImageProvider image;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image(
        image: image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, sync) {
          if (sync) return child;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (frame == null)
                const Skeleton(
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: KanzMotion.of(context, KanzMotion.slow),
                curve: KanzMotion.standard,
                child: child,
              ),
            ],
          );
        },
        errorBuilder: (context, error, stack) => fallback,
      ),
    );
  }
}

/// A sunken skeleton naming what is happening: "Drawing step 3" with a
/// small spinner, or "In line after step 2" with a clock.
class _Pending extends StatelessWidget {
  const _Pending({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        const Skeleton(
          height: double.infinity,
          borderRadius: BorderRadius.zero,
        ),
        PositionedDirectional(
          top: KanzSpace.s16,
          start: KanzSpace.s16,
          end: KanzSpace.s16,
          child: ExcludeSemantics(
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 14,
                  child: active && !context.reduceMotion
                      ? CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: c.inkSecondary,
                        )
                      : Icon(KanzIcons.clock, size: 14, color: c.inkSecondary),
                ),
                const SizedBox(width: KanzSpace.s8),
                Flexible(child: MonoLabel(label)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The picture could not be made: the user's own photo, desaturated under a
/// dark tint, carries the step number and a plain note. Without a photo the
/// panel is sunken paper with a large step numeral.
class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.number,
    required this.photo,
    required this.message,
    required this.icon,
    required this.retryLabel,
    required this.onRetry,
  });

  final int number;
  final ImageProvider? photo;
  final String message;
  final IconData icon;
  final String retryLabel;
  final VoidCallback? onRetry;

  static const List<double> _desaturate = [
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final photo = this.photo;
    final onPhoto = photo != null;
    final ink = onPhoto ? KanzPhotoColors.ink : c.inkSecondary;
    final numeral = StepNumeral.pad(number);
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (onPhoto) ...[
            ColoredBox(color: c.photoBackdrop),
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(_desaturate),
              child: Image(
                image: photo,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.expand(),
              ),
            ),
            ColoredBox(color: c.photoBackdrop.withValues(alpha: 0.5)),
          ] else
            ColoredBox(color: c.surfaceSunken),
          PositionedDirectional(
            top: KanzSpace.s12,
            start: KanzSpace.s16,
            child: onPhoto
                ? _PhotoTag(label: context.l10n.tutorialImageTag(numeral))
                : Text(
                    numeral,
                    style: context.kanzType.numeralLarge.copyWith(
                      color: c.track,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
          ),
          PositionedDirectional(
            start: KanzSpace.s16,
            end: KanzSpace.s16,
            bottom: KanzSpace.s12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 2),
                      child: Icon(icon, size: 16, color: ink),
                    ),
                    const SizedBox(width: KanzSpace.s8),
                    Expanded(
                      child: Text(
                        message,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: onPhoto ? KanzPhotoColors.ink : c.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: KanzSpace.s4),
                  _RetryPill(
                    label: retryLabel,
                    onPressed: onRetry!,
                    onPhoto: onPhoto,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTag extends StatelessWidget {
  const _PhotoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // Tags are anchored to the picture: they keep their size.
    return MediaQuery.withNoTextScaling(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: KanzPhotoColors.tag,
          borderRadius: KanzRadii.tagAll,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: KanzSpace.s8,
            vertical: KanzSpace.s2,
          ),
          child: MonoLabel(label, color: KanzPhotoColors.ink),
        ),
      ),
    );
  }
}

/// A compact retry for failure panels: a warm-white label on the dark photo
/// control disc (on photos) or an ink label (on paper), 48 dp tall.
class _RetryPill extends StatelessWidget {
  const _RetryPill({
    required this.label,
    required this.onPressed,
    required this.onPhoto,
  });

  final String label;
  final VoidCallback onPressed;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final fg = onPhoto ? KanzPhotoColors.ink : c.ink;
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: SizedBox(
        height: KanzSpace.touchTarget,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 1,
          child: Material(
            color: onPhoto ? KanzPhotoColors.control : c.surface,
            shape: StadiumBorder(
              side: onPhoto ? BorderSide.none : BorderSide(color: c.lineStrong),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  KanzSpace.s12,
                  KanzSpace.s8,
                  KanzSpace.s16,
                  KanzSpace.s8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(KanzIcons.retry, size: 16, color: fg),
                    const SizedBox(width: KanzSpace.s8),
                    Text(
                      label,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
