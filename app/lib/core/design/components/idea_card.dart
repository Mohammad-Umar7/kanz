import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'chips.dart';
import 'data.dart';
import 'motion.dart';

/// An upcycling idea: the generated "after" image large at 4:3 with the
/// user's original photo inset in the corner, a Fraunces title, a short
/// pitch and a meta row (difficulty, time, tool match).
///
/// The after image may not exist yet: pass [after] as null while it is
/// being generated (a skeleton with [pendingLabel] shows), and when the
/// image fails to load, or [failed] says it could not be generated, the
/// card falls back to the original photo with [errorLabel]. The image fades
/// in once decoded. Text scans have no photo: pass [original] as null and
/// the card shows no inset.
class IdeaCard extends StatelessWidget {
  const IdeaCard({
    super.key,
    required this.title,
    required this.pitch,
    required this.original,
    required this.after,
    required this.pendingLabel,
    required this.errorLabel,
    required this.beforeLabel,
    required this.meta,
    this.toolMatch,
    this.heroTag,
    this.onTap,
    this.semanticsLabel,
    this.failed = false,
  });

  final String title;
  final String pitch;

  /// The user's photo, or null when there is none (a text scan).
  final ImageProvider? original;

  /// The generated makeover, or null while it is being rendered.
  final ImageProvider? after;

  /// Shown on the skeleton, for example "Rendering the makeover".
  final String pendingLabel;

  /// Shown when the after image fails, for example "Preview unavailable".
  final String errorLabel;

  /// Mono tag on the inset photo, for example "Before".
  final String beforeLabel;

  /// Mono meta items, for example ["Easy", "35 min"].
  final List<String> meta;
  final ToolMatchBadge? toolMatch;

  /// Hero tag for the after image, shared with the idea detail screen.
  final Object? heroTag;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  /// The makeover could not be generated: show the failure state with
  /// [errorLabel] (no [after] image is needed).
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    const shape = RoundedRectangleBorder(borderRadius: KanzRadii.cardAll);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        color: c.surface,
        shape: shape.copyWith(side: BorderSide(color: c.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: _Visual(
                  original: original,
                  after: after,
                  failed: failed,
                  pendingLabel: pendingLabel,
                  errorLabel: errorLabel,
                  beforeLabel: beforeLabel,
                  heroTag: heroTag,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  KanzSpace.s16,
                  KanzSpace.s16,
                  KanzSpace.s16,
                  KanzSpace.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.headlineSmall),
                    const SizedBox(height: KanzSpace.s4),
                    Text(
                      pitch,
                      style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: KanzSpace.s12),
                    Wrap(
                      spacing: KanzSpace.s16,
                      runSpacing: KanzSpace.s8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (meta.isNotEmpty)
                          MonoLabel(meta.join('  ·  '), color: c.ink),
                        ?toolMatch,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Visual extends StatelessWidget {
  const _Visual({
    required this.original,
    required this.after,
    required this.failed,
    required this.pendingLabel,
    required this.errorLabel,
    required this.beforeLabel,
    required this.heroTag,
  });

  final ImageProvider? original;
  final ImageProvider? after;
  final bool failed;
  final String pendingLabel;
  final String errorLabel;
  final String beforeLabel;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final after = this.after;
    final original = this.original;
    // The failure state: the original photo, desaturated and dimmed, with the
    // note; without a photo (a text scan) a quiet sunken panel.
    Widget failure() => original == null
        ? _Placeholder(label: errorLabel, pending: false)
        : Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(_desaturate),
                child: Image(
                  image: original,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              ColoredBox(color: c.photoBackdrop.withValues(alpha: 0.35)),
              _Placeholder(label: errorLabel, pending: false, onPhoto: true),
            ],
          );
    Widget main;
    if (failed) {
      main = failure();
    } else if (after == null) {
      main = _Placeholder(label: pendingLabel, pending: true);
    } else {
      main = Image(
        image: after,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, sync) {
          if (sync) return child;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (frame == null)
                _Placeholder(label: pendingLabel, pending: true),
              AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: KanzMotion.of(context, KanzMotion.slow),
                curve: KanzMotion.standard,
                child: child,
              ),
            ],
          );
        },
        errorBuilder: (context, error, stack) => failure(),
      );
      if (heroTag != null) main = Hero(tag: heroTag!, child: main);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        main,
        if (original != null)
          PositionedDirectional(
            start: KanzSpace.s12,
            bottom: KanzSpace.s12,
            child: _Inset(image: original, label: beforeLabel),
          ),
      ],
    );
  }

  static const List<double> _desaturate = [
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.label,
    required this.pending,
    this.onPhoto = false,
  });

  final String label;
  final bool pending;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final color = onPhoto ? KanzPhotoColors.ink : c.inkSecondary;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!onPhoto && pending)
          const Skeleton(
            height: double.infinity,
            borderRadius: BorderRadius.zero,
          )
        else if (!onPhoto)
          ColoredBox(color: c.surfaceSunken),
        PositionedDirectional(
          top: KanzSpace.s16,
          start: KanzSpace.s16,
          end: KanzSpace.s16,
          child: Row(
            children: [
              if (pending)
                SizedBox.square(
                  dimension: 12,
                  child: context.reduceMotion
                      ? Icon(KanzIcons.clock, size: 12, color: color)
                      : CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: color,
                        ),
                )
              else
                Icon(KanzIcons.gallery, size: 14, color: color),
              const SizedBox(width: KanzSpace.s8),
              Flexible(child: MonoLabel(label, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Inset extends StatelessWidget {
  const _Inset({required this.image, required this.label});

  final ImageProvider image;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    // Sits on imagery in both themes, so the frame is always warm white.
    return ExcludeSemantics(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: KanzPhotoColors.ink, width: 2),
          boxShadow: KanzElevation.floating(c),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    ColoredBox(color: c.photoBackdrop),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  color: KanzPhotoColors.tag,
                  child: Text(
                    context.kanzType.uppercaseData
                        ? label.toUpperCase()
                        : label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textScaler: TextScaler.noScaling,
                    style: context.kanzType.data.copyWith(
                      color: KanzPhotoColors.ink,
                      fontSize: 9,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
