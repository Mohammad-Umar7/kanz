import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';

/// A low-contrast placeholder block with a slow, subtle pulse. Static when
/// motion is reduced. Skeletons mirror the shape of the content they stand
/// in for; they are not spinners.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = KanzRadii.tagAll,
  });

  /// A block of [lines] text lines, the last one shorter.
  static Widget text({Key? key, int lines = 3, double lineHeight = 14}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) const SizedBox(height: KanzSpace.s8),
          FractionallySizedBox(
            widthFactor: i == lines - 1 && lines > 1 ? 0.6 : 1,
            child: Skeleton(height: lineHeight),
          ),
        ],
      ],
    );
  }

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _opacity = _controller.drive(
    Tween<double>(
      begin: 1,
      end: 0.55,
    ).chain(CurveTween(curve: KanzMotion.standard)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: c.surfaceSunken,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}

/// Fades its child in while it rises 8 px, once, after [delay].
///
/// Use [FadeUp.staggered] for lists: each item waits a little longer than
/// the one before, up to [KanzMotion.maxStaggered] items.
class FadeUp extends StatefulWidget {
  const FadeUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = KanzMotion.slow,
    this.offset = 8,
  });

  /// Wraps the [index]th item of a list with a staggered delay.
  factory FadeUp.staggered({
    Key? key,
    required int index,
    required Widget child,
  }) {
    final steps = index.clamp(0, KanzMotion.maxStaggered);
    return FadeUp(key: key, delay: KanzMotion.stagger * steps, child: child);
  }

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Rise distance in logical pixels.
  final double offset;

  @override
  State<FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<FadeUp> with SingleTickerProviderStateMixin {
  // The delay is part of the animation (an Interval) rather than a timer, so
  // nothing is left pending when the widget is disposed early.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
  );
  late final Animation<double> _curve = _controller.drive(
    CurveTween(
      curve: Interval(
        widget.delay.inMicroseconds /
            (widget.delay + widget.duration).inMicroseconds,
        1,
        curve: KanzMotion.enter,
      ),
    ),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// A column whose children enter with [FadeUp.staggered].
class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.spacing = KanzSpace.s12,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        for (var i = 0; i < children.length; i++)
          FadeUp.staggered(index: i, child: children[i]),
      ],
    );
  }
}
