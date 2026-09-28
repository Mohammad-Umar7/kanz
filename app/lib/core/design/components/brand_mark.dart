import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';
import '../typography.dart';

/// The Kanz mark (كنز, "treasure"): a cut gem seen from the front, built
/// from four flat shapes. Two ink crown facets flank a clay table facet,
/// the glint, above a solid ink pavilion. The pavilion alone reads as a map
/// pin, the other half of what Kanz does.
///
/// The geometry lives in [BrandMarkGeometry] and is mirrored exactly by
/// tool/brand/make_brand.py, which renders the launcher icon and splash.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 48,
    this.accentColor,
    this.inkColor,
    this.semanticsLabel,
  });

  final double size;

  /// The table facet. Defaults to the theme accent (clay).
  final Color? accentColor;

  /// The other facets. Defaults to the theme ink.
  final Color? inkColor;

  /// Accessible name, usually "Kanz". Decorative when null.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(
          accent: accentColor ?? c.accent,
          ink: inkColor ?? c.ink,
        ),
      ),
    );
    if (semanticsLabel == null) return ExcludeSemantics(child: mark);
    return Semantics(label: semanticsLabel, image: true, child: mark);
  }
}

/// The mark with the name set beside it: "Kanz" in Fraunces and "كنز" in
/// IBM Plex Sans Arabic.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markSize = 40});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      label: 'Kanz',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: [
          BrandMark(size: markSize),
          const SizedBox(width: KanzSpace.s12),
          Text(
            'Kanz',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: KanzFonts.display,
              fontSize: markSize * 0.8,
              height: 1,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
              color: c.ink,
            ),
          ),
          const SizedBox(width: KanzSpace.s8),
          Text(
            'كنز',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: KanzFonts.arabic,
              fontSize: markSize * 0.56,
              height: 1,
              fontWeight: FontWeight.w500,
              color: c.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Unit-square coordinates of the mark's three shapes.
abstract final class BrandMarkGeometry {
  /// Left crown facet (ink).
  static const List<Offset> crownStart = [
    Offset(0.285, 0.16),
    Offset(0.10, 0.36),
    Offset(0.325, 0.36),
  ];

  /// Table facet (accent).
  static const List<Offset> table = [
    Offset(0.335, 0.16),
    Offset(0.665, 0.16),
    Offset(0.625, 0.36),
    Offset(0.375, 0.36),
  ];

  /// Right crown facet (ink).
  static const List<Offset> crownEnd = [
    Offset(0.715, 0.16),
    Offset(0.90, 0.36),
    Offset(0.675, 0.36),
  ];

  /// Pavilion (ink).
  static const List<Offset> pavilion = [
    Offset(0.10, 0.41),
    Offset(0.90, 0.41),
    Offset(0.50, 0.84),
  ];
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter({required this.accent, required this.ink});

  final Color accent;
  final Color ink;

  Path _poly(List<Offset> points, Size size) {
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final inkPaint = Paint()..color = ink;
    canvas
      ..drawPath(_poly(BrandMarkGeometry.crownStart, size), inkPaint)
      ..drawPath(_poly(BrandMarkGeometry.crownEnd, size), inkPaint)
      ..drawPath(_poly(BrandMarkGeometry.pavilion, size), inkPaint)
      ..drawPath(_poly(BrandMarkGeometry.table, size), Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) =>
      old.accent != accent || old.ink != ink;
}
