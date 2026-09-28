import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// A wide picture at the top of a tutorial page (3:2, card radius). The
/// photo backdrop shows while it decodes; a picture that fails to load
/// leaves the backdrop rather than an error box. With [inset] (the user's
/// photo under a makeover) the original sits in the corner, as on idea cards.
class HeroPicture extends StatelessWidget {
  const HeroPicture({
    super.key,
    required this.image,
    this.aspectRatio = 3 / 2,
    this.semanticsLabel,
    this.inset,
    this.insetLabel,
  });

  final ImageProvider image;
  final double aspectRatio;
  final String? semanticsLabel;
  final ImageProvider? inset;

  /// Tag on the inset, for example "Before".
  final String? insetLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final inset = this.inset;
    return Semantics(
      image: semanticsLabel != null,
      label: semanticsLabel,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: KanzRadii.cardAll,
              child: ColoredBox(
                color: c.photoBackdrop,
                child: Image(
                  image: image,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  frameBuilder: (context, child, frame, sync) {
                    if (sync) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: KanzMotion.of(context, KanzMotion.slow),
                      curve: KanzMotion.standard,
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stack) =>
                      const SizedBox.expand(),
                ),
              ),
            ),
            if (inset != null)
              PositionedDirectional(
                start: KanzSpace.s12,
                bottom: KanzSpace.s12,
                child: _PhotoInset(image: inset, label: insetLabel),
              ),
          ],
        ),
      ),
    );
  }
}

/// The user's original photo in a warm-white frame, floating over a
/// makeover (the one place a shadow is allowed on a picture).
class _PhotoInset extends StatelessWidget {
  const _PhotoInset({required this.image, this.label});

  static const double size = 72;

  final ImageProvider image;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: KanzRadii.chipAll,
        border: Border.all(color: KanzPhotoColors.ink, width: 2),
        boxShadow: KanzElevation.floating(c),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(KanzRadii.chip - 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: c.photoBackdrop),
            Image(
              image: image,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stack) => const SizedBox.expand(),
            ),
            if (label != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: KanzPhotoColors.tag,
                  padding: const EdgeInsets.symmetric(vertical: KanzSpace.s2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    // Tags are anchored to the picture: they keep their size.
                    child: MediaQuery.withNoTextScaling(
                      child: MonoLabel(label!, color: KanzPhotoColors.ink),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A section title inside a page: sans title, start-aligned, with room
/// below for the first hairline row.
class PageSectionTitle extends StatelessWidget {
  const PageSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s4),
      child: Semantics(
        header: true,
        child: Text(title, style: context.textStyles.titleLarge),
      ),
    );
  }
}

/// A list row separated from the one above by a hairline.
class HairlineRow extends StatelessWidget {
  const HairlineRow({super.key, required this.child, this.divider = true});

  final Widget child;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(top: BorderSide(color: context.kanzColors.line))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: KanzSpace.s12),
        child: child,
      ),
    );
  }
}

/// A small ink tag with paper text ("Updated").
class InverseTag extends StatelessWidget {
  const InverseTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: KanzSpace.s8,
        vertical: KanzSpace.s2,
      ),
      decoration: BoxDecoration(
        color: c.inverse,
        borderRadius: KanzRadii.tagAll,
      ),
      child: MonoLabel(label, color: c.onInverse),
    );
  }
}

/// A numbered hairline list ("01  Hang it from a hook ..."), used for the
/// finishing and care notes.
class NumberedList extends StatelessWidget {
  const NumberedList({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          HairlineRow(
            divider: i > 0,
            child: MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: KanzSpace.s4,
                    ),
                    child: MonoLabel(
                      StepNumeral.pad(i + 1),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  const SizedBox(width: KanzSpace.s16),
                  Expanded(
                    child: Text(items[i], style: context.textStyles.bodyLarge),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
