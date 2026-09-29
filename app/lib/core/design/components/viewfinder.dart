import 'package:flutter/material.dart';

import '../tokens.dart';

/// Four corner brackets framing the camera preview. They turn clay when
/// [active] (an item is framed, or a capture is in progress).
class CornerBrackets extends StatelessWidget {
  const CornerBrackets({
    super.key,
    this.active = false,
    this.color = KanzPhotoColors.ink,
    this.strokeWidth = 3,
    this.length = 28,
    this.radius = 8,
    this.child,
  });

  final bool active;

  /// Idle color. On the camera preview this is warm white.
  final Color color;
  final double strokeWidth;

  /// Length of each bracket arm.
  final double length;

  /// Corner rounding.
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // On the camera picture: the photo clay, the same in both themes.
    final target = active ? KanzPhotoColors.accent : color;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: target),
      duration: KanzMotion.of(context, KanzMotion.medium),
      curve: KanzMotion.standard,
      builder: (context, value, child) => CustomPaint(
        foregroundPainter: _BracketsPainter(
          color: value ?? target,
          strokeWidth: strokeWidth,
          length: length,
          radius: radius,
        ),
        child: child,
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _BracketsPainter extends CustomPainter {
  _BracketsPainter({
    required this.color,
    required this.strokeWidth,
    required this.length,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double length;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final half = strokeWidth / 2;
    final r = Rect.fromLTRB(half, half, size.width - half, size.height - half);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    final l = length;
    final k = radius;
    // Each bracket: a straight arm, a quarter arc, the other arm.
    canvas
      ..drawPath(
        Path()
          ..moveTo(r.left, r.top + l)
          ..lineTo(r.left, r.top + k)
          ..arcToPoint(Offset(r.left + k, r.top), radius: Radius.circular(k))
          ..lineTo(r.left + l, r.top),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(r.right - l, r.top)
          ..lineTo(r.right - k, r.top)
          ..arcToPoint(Offset(r.right, r.top + k), radius: Radius.circular(k))
          ..lineTo(r.right, r.top + l),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(r.right, r.bottom - l)
          ..lineTo(r.right, r.bottom - k)
          ..arcToPoint(
            Offset(r.right - k, r.bottom),
            radius: Radius.circular(k),
          )
          ..lineTo(r.right - l, r.bottom),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(r.left + l, r.bottom)
          ..lineTo(r.left + k, r.bottom)
          ..arcToPoint(Offset(r.left, r.bottom - k), radius: Radius.circular(k))
          ..lineTo(r.left, r.bottom - l),
        paint,
      );
  }

  @override
  bool shouldRepaint(_BracketsPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.length != length ||
      old.radius != radius;
}
