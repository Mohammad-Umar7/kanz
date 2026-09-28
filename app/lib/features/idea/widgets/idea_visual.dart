import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// Where the idea's makeover image stands.
enum MakeoverState {
  /// Being drawn right now.
  rendering,

  /// Drawn: the before/after slider.
  ready,

  /// This server has no image quota: nothing on the phone can fix it.
  paused,

  /// The drawing failed for a reason another try may fix.
  failed,
}

/// The top of the idea screen, full width. Until the makeover exists it is
/// the user's whole photo with what is happening named on it, in the corner
/// where the "After" tag will be; once the makeover lands the photo turns
/// into the before/after slider, and if the makeover arrived while the
/// screen was open, the handle sweeps in from the end to the middle once.
/// A text scan with no picture at all shows the user's words instead.
class IdeaVisual extends StatefulWidget {
  const IdeaVisual({
    super.key,
    required this.state,
    required this.before,
    required this.after,
    required this.aspectRatio,
    required this.beforeLabel,
    required this.afterLabel,
    required this.compareLabel,
    required this.statusLabel,
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

  /// What is happening to the makeover: "Rendering the makeover", "Makeover
  /// images paused" or "Makeover didn't render". Unused when [state] is
  /// [MakeoverState.ready].
  final String statusLabel;

  /// A text scan's description, shown when there is no picture at all.
  final String? description;
  final String? descriptionLabel;
  final Object? afterHeroTag;

  @override
  State<IdeaVisual> createState() => _IdeaVisualState();
}

enum _Reveal {
  /// Nothing to play: the makeover was there when the screen opened.
  none,

  /// The makeover landed; its image is still being decoded.
  decoding,

  /// The reveal is on screen.
  playing,
}

class _IdeaVisualState extends State<IdeaVisual> {
  _Reveal _reveal = _Reveal.none;

  @override
  void didUpdateWidget(IdeaVisual old) {
    super.didUpdateWidget(old);
    final after = widget.after;
    final landed =
        old.state == MakeoverState.rendering &&
        widget.state == MakeoverState.ready &&
        after != null &&
        widget.before != null;
    if (!landed) {
      if (widget.state != MakeoverState.ready) _reveal = _Reveal.none;
      return;
    }
    // Keep the photo up until the makeover is decoded, so the reveal never
    // uncovers an empty frame.
    _reveal = _Reveal.decoding;
    precacheImage(after, context, onError: (_, _) {}).whenComplete(() {
      if (mounted && _reveal == _Reveal.decoding) {
        setState(() => _reveal = _Reveal.playing);
      }
    });
  }

  Widget _slider(double beforeShare, {Key? key}) => BeforeAfterSlider(
    key: key,
    before: widget.before!,
    after: widget.after!,
    beforeLabel: widget.beforeLabel,
    afterLabel: widget.afterLabel,
    semanticsLabel: widget.compareLabel,
    initialValue: beforeShare,
    aspectRatio: widget.aspectRatio,
    borderRadius: BorderRadius.zero,
    afterHeroTag: widget.afterHeroTag,
  );

  Widget _photo(ImageProvider before, MakeoverState state) => _PhotoFrame(
    aspectRatio: widget.aspectRatio,
    image: before,
    beforeLabel: widget.beforeLabel,
    status: _StatusTag(label: widget.statusLabel, kind: state),
    working: state == MakeoverState.rendering,
  );

  @override
  Widget build(BuildContext context) {
    final before = widget.before;
    final after = widget.after;
    final state = widget.state;
    if (state == MakeoverState.ready && after != null) {
      if (before == null) {
        return _AfterOnly(
          aspectRatio: widget.aspectRatio,
          image: after,
          label: widget.afterLabel,
          heroTag: widget.afterHeroTag,
        );
      }
      switch (_reveal) {
        case _Reveal.decoding:
          return _photo(before, MakeoverState.rendering);
        case _Reveal.playing when !context.reduceMotion:
          return _MakeoverReveal(
            underlay: _photo(before, MakeoverState.rendering),
            slider: _slider,
            onDone: () => setState(() => _reveal = _Reveal.none),
          );
        case _Reveal.playing || _Reveal.none:
          return _slider(0.5);
      }
    }
    if (before == null) {
      return _DescriptionFrame(
        aspectRatio: widget.aspectRatio,
        label: widget.descriptionLabel,
        description: widget.description ?? '',
        status: _StatusTag(
          label: widget.statusLabel,
          kind: state == MakeoverState.ready ? MakeoverState.rendering : state,
          onPhoto: false,
        ),
      );
    }
    return _photo(
      before,
      state == MakeoverState.ready ? MakeoverState.rendering : state,
    );
  }
}

/// The makeover arriving while the user looks: the slider fades in over the
/// photo with its handle at the end edge (so the frame still shows only the
/// photo), then the handle sweeps to the middle and uncovers the makeover.
///
/// [BeforeAfterSlider] owns its value once built, so each frame of the sweep
/// builds it afresh at the animated value; when the sweep ends the screen
/// swaps in a settled slider at the same value, which the user then drags.
class _MakeoverReveal extends StatefulWidget {
  const _MakeoverReveal({
    required this.underlay,
    required this.slider,
    required this.onDone,
  });

  /// The photo as it was while the makeover rendered.
  final Widget underlay;
  final Widget Function(double beforeShare, {Key? key}) slider;
  final VoidCallback onDone;

  @override
  State<_MakeoverReveal> createState() => _MakeoverRevealState();
}

class _MakeoverRevealState extends State<_MakeoverReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: KanzMotion.slow * 2,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.5, curve: KanzMotion.standard),
  );
  late final Animation<double> _sweep = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.5, 1, curve: KanzMotion.emphasized),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      // The handle has arrived: the same tick as reaching an end by hand.
      KanzHaptics.selection();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.underlay,
        Positioned.fill(
          child: FadeTransition(
            opacity: _fade,
            child: AnimatedBuilder(
              animation: _sweep,
              builder: (context, _) {
                final share = 1 - 0.5 * _sweep.value;
                return widget.slider(share, key: ValueKey(share));
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// The user's photo edge to edge, "Before" at the top start and the
/// makeover's status at the top end, where "After" will appear. While the
/// makeover renders a thin progress line runs along the bottom edge.
class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({
    required this.aspectRatio,
    required this.image,
    required this.beforeLabel,
    required this.status,
    required this.working,
  });

  final double aspectRatio;
  final ImageProvider image;
  final String beforeLabel;
  final Widget status;
  final bool working;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ColoredBox(
        color: c.photoBackdrop,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: image,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              gaplessPlayback: true,
              errorBuilder: (context, error, stack) => const SizedBox.expand(),
            ),
            PositionedDirectional(
              top: KanzSpace.s12,
              start: KanzSpace.s12,
              end: KanzSpace.s12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(child: _MonoTag(beforeLabel)),
                  const SizedBox(width: KanzSpace.s12),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: status,
                    ),
                  ),
                ],
              ),
            ),
            if (working && !context.reduceMotion)
              const PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: KanzPhotoColors.ink,
                  backgroundColor: Color(0x3DF2EFE8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A text scan whose described item has no picture but whose makeover
/// exists: the makeover alone, tagged "After".
class _AfterOnly extends StatelessWidget {
  const _AfterOnly({
    required this.aspectRatio,
    required this.image,
    required this.label,
    this.heroTag,
  });

  final double aspectRatio;
  final ImageProvider image;
  final String label;
  final Object? heroTag;

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
      errorBuilder: (context, error, stack) => const SizedBox.expand(),
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
            PositionedDirectional(
              top: KanzSpace.s12,
              start: KanzSpace.s12,
              child: ExcludeSemantics(child: _MonoTag(label)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A text scan with no picture: the description set in Fraunces on the
/// sunken paper, under the frame's label, with the makeover's status.
class _DescriptionFrame extends StatelessWidget {
  const _DescriptionFrame({
    required this.aspectRatio,
    required this.label,
    required this.description,
    required this.status,
  });

  final double aspectRatio;
  final String? label;
  final String description;
  final Widget status;

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
          const SizedBox(height: KanzSpace.s24),
          status,
        ],
      ),
    );
  }
}

/// The makeover's status in one line: a spinner while it renders, a pause
/// glyph when the server's image quota is spent, an info glyph when the
/// drawing failed. A solid dark chip on a photo; plain secondary text on
/// paper.
class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.kind,
    this.onPhoto = true,
  });

  final String label;
  final MakeoverState kind;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final ink = onPhoto ? KanzPhotoColors.ink : c.inkSecondary;
    final Widget glyph = switch (kind) {
      MakeoverState.rendering when !context.reduceMotion =>
        CircularProgressIndicator(strokeWidth: 1.5, color: ink),
      MakeoverState.rendering => Icon(KanzIcons.clock, size: 14, color: ink),
      MakeoverState.paused => Icon(KanzIcons.pause, size: 14, color: ink),
      MakeoverState.failed ||
      MakeoverState.ready => Icon(KanzIcons.info, size: 14, color: ink),
    };
    final text = Text(
      label,
      style:
          (onPhoto
                  ? context.textStyles.labelMedium
                  : context.textStyles.bodySmall)
              ?.copyWith(color: ink),
    );
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(dimension: 14, child: glyph),
        const SizedBox(width: KanzSpace.s8),
        Flexible(child: text),
      ],
    );
    return Semantics(
      liveRegion: true,
      container: true,
      child: onPhoto
          ? Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: KanzSpace.s8,
                vertical: KanzSpace.s4,
              ),
              decoration: const BoxDecoration(
                color: KanzPhotoColors.tag,
                borderRadius: KanzRadii.tagAll,
              ),
              child: row,
            )
          : row,
    );
  }
}

/// A mono tag on a photo, drawn like the slider's own "Before" and "After"
/// tags so nothing shifts when the photo becomes the slider.
class _MonoTag extends StatelessWidget {
  const _MonoTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: KanzPhotoColors.tag,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: MonoLabel(label, color: KanzPhotoColors.ink),
    );
  }
}
