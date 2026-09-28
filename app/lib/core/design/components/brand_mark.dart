import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';
import '../typography.dart';

/// The Kanz mark: a cut gem built from three flat shapes. A clay crown
/// sits over an ink pavilion split into two facets. Read upside down the
/// pavilion is also a map pin, the other half of what Kanz does.
///
/// The geometry lives in [BrandMarkGeometry] and is mirrored exactly by
/// tool/brand/make_brand.py, which renders the launcher icon and splash.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 48,
    this.crownColor,
    this.pavilionColor,
    this.semanticsLabel,
  });

  final double size;

  /// Defaults to the theme accent (clay).
  final Color? crownColor;

  /// Defaults to the theme ink.
  final Color? pavilionColor;

  /// Accessible name, usually "Kanz". Decorative when null.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(
          crown: crownColor ?? c.accent,
          pavilion: pavilionColor ?? c.ink,
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
  static const List<Offset> crown = [
    Offset(0.30, 0.16),
    Offset(0.70, 0.16),
    Offset(0.88, 0.36),
    Offset(0.12, 0.36),
  ];
  static const List<Offset> pavilionStart = [
    Offset(0.12, 0.41),
    Offset(0.475, 0.41),
    Offset(0.475, 0.812),
  ];
  static const List<Offset> pavilionEnd = [
    Offset(0.525, 0.41),
    Offset(0.88, 0.41),
    Offset(0.525, 0.812),
  ];
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter({required this.crown, required this.pavilion});

  final Color crown;
  final Color pavilion;

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
    final fill = Paint()..isAntiAlias = true;
    canvas.drawPath(_poly(BrandMarkGeometry.crown, size), fill..color = crown);
    canvas.drawPath(
      _poly(BrandMarkGeometry.pavilionStart, size),
      fill..color = pavilion,
    );
    canvas.drawPath(
      _poly(BrandMarkGeometry.pavilionEnd, size),
      fill..color = pavilion,
    );
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) =>
      old.crown != crown || old.pavilion != pavilion;
}
