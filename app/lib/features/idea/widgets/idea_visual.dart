import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// Where the idea's makeover image stands.
enum MakeoverState { rendering, ready, failed }

/// The top of the idea screen, full width: the before/after slider once the
/// makeover exists; until then the user's photo with the stage named on it;
/// and if the makeover cannot be made, the photo alone with a quiet note.
/// A text scan with no photo at all shows the user's words instead.
class IdeaVisual extends StatelessWidget {
  const IdeaVisual({
    super.key,
    required this.state,
    required this.before,
    required this.after,
    required this.aspectRatio,
    required this.beforeLabel,
    required this.afterLabel,
    required this.compareLabel,
    required this.pendingLabel,
    required this.note,
    this.description,
    this.descriptionLabel,
    this.afterHeroTag,
  });

  final MakeoverState state;

  /// The user's photo (or the generated photo of a described item).
  final ImageProvider? before;
  final ImageProvider? after;
  final double aspectRatio;
  final String beforeLabel;
  final String afterLabel;
  final String compareLabel;
  final String pendingLabel;

  /// Why there is no makeover, shown on the failed state.
  final String note;

  /// A text scan's description, shown when there is no picture at all.
  final String? description;
  final String? descriptionLabel;
  final Object? afterHeroTag;

  @override
  Widget build(BuildContext context) {
    final before = this.before;
    final after = this.after;
    if (state == MakeoverState.ready && after != null) {
      if (before != null) {
        return BeforeAfterSlider(
          before: before,
          after: after,
          beforeLabel: beforeLabel,
          afterLabel: afterLabel,
          semanticsLabel: compareLabel,
          aspectRatio: aspectRatio,
          borderRadius: BorderRadius.zero,
          afterHeroTag: afterHeroTag,
        );
      }
      return _Frame(
        aspectRatio: aspectRatio,
        image: after,
        heroTag: afterHeroTag,
        tagTop: afterLabel,
      );
    }
    if (before == null) {
      return _DescriptionFrame(
        aspectRatio: aspectRatio,
        label: descriptionLabel,
        description: description ?? '',
        note: state == MakeoverState.failed ? note : null,
        pendingLabel: state == MakeoverState.rendering ? pendingLabel : null,
      );
    }
    if (state == MakeoverState.rendering) {
      return _Pending(
        aspectRatio: aspectRatio,
        before: before,
        beforeLabel: beforeLabel,
        pendingLabel: pendingLabel,
      );
    }
    return _Frame(
      aspectRatio: aspectRatio,
      image: before,
      tagTop: beforeLabel,
      note: note,
    );
  }
}

/// The slider's layout before the makeover exists: the photo on the start
/// half, a skeleton on the other half naming what is being rendered, and
/// the divider where the handle will be. When the image lands, the slider
/// takes its place with the photo exactly where it was.
class _Pending extends StatelessWidget {
  const _Pending({
    required this.aspectRatio,
    required this.before,
    required this.beforeLabel,
    required this.pendingLabel,
  });

  final double aspectRatio;
  final ImageProvider before;
  final String beforeLabel;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Stack(
            fit: StackFit.expand,
            children: [
              const Skeleton(
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: size.width / 2,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: AlignmentDirectional.centerStart,
                    maxWidth: size.width,
                    minWidth: size.width,
                    child: Image(
                      image: before,
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height,
                      excludeFromSemantics: true,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stack) =>
                          ColoredBox(color: c.photoBackdrop),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 2,
                  height: double.infinity,
                  color: KanzPhotoColors.ink,
                ),
              ),
              PositionedDirectional(
                top: KanzSpace.s12,
                start: KanzSpace.s12,
                child: PhotoTag(label: beforeLabel),
              ),
              PositionedDirectional(
                top: KanzSpace.s12,
                start: size.width / 2 + KanzSpace.s12,
                end: KanzSpace.s12,
                child: Semantics(
                  liveRegion: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SizedBox.square(
                          dimension: 12,
                          child: context.reduceMotion
                              ? Icon(
                                  KanzIcons.clock,
                                  size: 12,
                                  color: c.inkSecondary,
                                )
                              : CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: c.inkSecondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: KanzSpace.s8),
                      Expanded(child: MonoLabel(pendingLabel)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One picture edge to edge with optional mono tags on the photo.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.aspectRatio,
    required this.image,
    this.heroTag,
    this.tagTop,
    this.note,
  });

  final double aspectRatio;
  final ImageProvider image;
  final Object? heroTag;
  final String? tagTop;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    Widget picture = Image(
      image: image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      excludeFromSemantics: true,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) =>
          ColoredBox(color: c.photoBackdrop),
    );
    if (heroTag != null) picture = Hero(tag: heroTag!, child: picture);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ColoredBox(
        color: c.photoBackdrop,
        child: Stack(
          fit: StackFit.expand,
          children: [
            picture,
            if (tagTop != null)
              PositionedDirectional(
                top: KanzSpace.s12,
                start: KanzSpace.s12,
                child: PhotoTag(label: tagTop!),
              ),
            if (note != null)
              PositionedDirectional(
                start: KanzSpace.s12,
                end: KanzSpace.s12,
                bottom: KanzSpace.s12,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PhotoTag(
                    label: note!,
                    icon: KanzIcons.info,
                    uppercase: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A text scan with no picture: the description set in Fraunces on the
/// sunken paper, under the frame's label.
class _DescriptionFrame extends StatelessWidget {
  const _DescriptionFrame({
    required this.aspectRatio,
    required this.label,
    required this.description,
    this.note,
    this.pendingLabel,
  });

  final double aspectRatio;
  final String? label;
  final String description;
  final String? note;
  final String? pendingLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).width / aspectRatio * 0.6,
      ),
      color: c.surfaceSunken,
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s24,
        KanzSpace.gutter,
        KanzSpace.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Icon(KanzIcons.describe, size: 16, color: c.inkSecondary),
                const SizedBox(width: KanzSpace.s8),
                Flexible(child: MonoLabel(label!)),
              ],
            ),
            const SizedBox(height: KanzSpace.s16),
          ],
          Text(description, style: t.headlineMedium),
          if (pendingLabel != null || note != null) ...[
            const SizedBox(height: KanzSpace.s24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox.square(
                    dimension: 14,
                    child: pendingLabel != null && !context.reduceMotion
                        ? CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: c.inkSecondary,
                          )
                        : Icon(
                            pendingLabel != null
                                ? KanzIcons.clock
                                : KanzIcons.info,
                            size: 14,
                            color: c.inkSecondary,
                          ),
                  ),
                ),
                const SizedBox(width: KanzSpace.s8),
                Expanded(
                  child: Text(pendingLabel ?? note!, style: t.bodySmall),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A solid dark label on a photo (the before/after tag style), optionally
/// with a spinner or a glyph. Solid, not translucent, so it reads on any
/// image.
class PhotoTag extends StatelessWidget {
  const PhotoTag({
    super.key,
    required this.label,
    this.busy = false,
    this.icon,
    this.uppercase = true,
  });

  final String label;
  final bool busy;
  final IconData? icon;

  /// Mono uppercase for short tags; sentence case for a note.
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: busy,
      container: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s8,
          vertical: KanzSpace.s4,
        ),
        decoration: const BoxDecoration(
          color: KanzPhotoColors.tag,
          borderRadius: KanzRadii.tagAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) ...[
              SizedBox.square(
                dimension: 12,
                child: context.reduceMotion
                    ? const Icon(
                        KanzIcons.clock,
                        size: 12,
                        color: KanzPhotoColors.ink,
                      )
                    : const CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: KanzPhotoColors.ink,
                      ),
              ),
              const SizedBox(width: KanzSpace.s8),
            ] else if (icon != null) ...[
              Icon(icon, size: 14, color: KanzPhotoColors.ink),
              const SizedBox(width: KanzSpace.s8),
            ],
            Flexible(
              child: uppercase
                  ? MonoLabel(label, color: KanzPhotoColors.ink)
                  : Text(
                      label,
                      style: context.textStyles.bodySmall?.copyWith(
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
