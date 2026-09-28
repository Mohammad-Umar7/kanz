import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../context.dart';
import '../material_colors.dart';
import '../tokens.dart';
import 'buttons.dart';

/// Which geometric drawing heads a [PermissionRationale].
enum PermissionArt { camera, location }

/// One reason in a [PermissionRationale].
@immutable
class RationaleReason {
  const RationaleReason({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// Asks for a permission the respectful way: a drawn illustration (plain
/// geometry, no clip art), a title, two or three concrete reasons and two
/// choices. The secondary action always leads somewhere useful (the city
/// picker, the gallery), never a dead end.
class PermissionRationale extends StatelessWidget {
  const PermissionRationale({
    super.key,
    required this.art,
    required this.title,
    required this.reasons,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.footnote,
  });

  final PermissionArt art;
  final String title;
  final List<RationaleReason> reasons;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  /// Small print, for example "You can change this in Settings".
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: c.surfaceSunken,
                  borderRadius: KanzRadii.cardAll,
                ),
                child: CustomPaint(
                  painter: art == PermissionArt.camera
                      ? _CameraArtPainter(
                          ink: c.ink,
                          line: c.lineStrong,
                          surface: c.surface,
                          box: KanzMaterialColors.glass.box,
                        )
                      : _LocationArtPainter(
                          ink: c.ink,
                          line: c.line,
                          road: c.surface,
                          pins: [
                            KanzMaterialColors.dot(context, 'glass'),
                            KanzMaterialColors.dot(context, 'paper'),
                            KanzMaterialColors.dot(context, 'electronics'),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: KanzSpace.s32),
          Semantics(header: true, child: Text(title, style: t.headlineMedium)),
          const SizedBox(height: KanzSpace.s20),
          for (final r in reasons)
            Padding(
              padding: const EdgeInsets.only(bottom: KanzSpace.s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r.icon, size: 22, color: c.ink),
                  const SizedBox(width: KanzSpace.s16),
                  Expanded(child: Text(r.text, style: t.bodyLarge)),
                ],
              ),
            ),
          const SizedBox(height: KanzSpace.s16),
          KanzButton(label: primaryLabel, onPressed: onPrimary, expand: true),
          const SizedBox(height: KanzSpace.s8),
          KanzButton.tertiary(
            label: secondaryLabel,
            onPressed: onSecondary,
            expand: true,
          ),
          if (footnote != null) ...[
            const SizedBox(height: KanzSpace.s8),
            Text(footnote!, style: t.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Viewfinder brackets around a jar outline with a thin detection box.
class _CameraArtPainter extends CustomPainter {
  _CameraArtPainter({
    required this.ink,
    required this.line,
    required this.surface,
    required this.box,
  });

  final Color ink;
  final Color line;
  final Color surface;
  final Color box;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final center = size.center(Offset.zero);
    final frame = Rect.fromCenter(
      center: center,
      width: s * 0.78,
      height: s * 0.78,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..color = ink;

    // Corner brackets.
    final len = s * 0.12;
    for (final (Offset corner, double dx, double dy) in [
      (frame.topLeft, 1.0, 1.0),
      (frame.topRight, -1.0, 1.0),
      (frame.bottomLeft, 1.0, -1.0),
      (frame.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx, corner.dy + dy * len)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx + dx * len, corner.dy),
        stroke,
      );
    }

    // Jar: lid, neck and body as simple rounded shapes.
    final w = s * 0.30;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, s * 0.06),
        width: w,
        height: s * 0.34,
      ),
      Radius.circular(w * 0.22),
    );
    final lid = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -s * 0.15),
        width: w * 0.78,
        height: s * 0.07,
      ),
      Radius.circular(s * 0.015),
    );
    canvas.drawRRect(body, Paint()..color = surface);
    canvas.drawRRect(body, stroke..strokeWidth = 2);
    canvas.drawRRect(lid, Paint()..color = ink);
    // A label band on the jar.
    canvas.drawLine(
      Offset(body.left + w * 0.18, body.center.dy),
      Offset(body.right - w * 0.18, body.center.dy),
      Paint()
        ..strokeWidth = 1.5
        ..color = line,
    );

    // The detection box, slightly larger than the jar.
    final detection = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        body.left - s * 0.05,
        lid.top - s * 0.04,
        body.right + s * 0.05,
        body.bottom + s * 0.04,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      detection,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = box,
    );
    canvas.drawCircle(
      Offset(detection.left + 8, detection.top - 10),
      3.5,
      Paint()..color = box,
    );
  }

  @override
  bool shouldRepaint(_CameraArtPainter old) =>
      old.ink != ink || old.line != line || old.box != box;
}

/// A quiet street grid, the user's position and three drop-off pins.
class _LocationArtPainter extends CustomPainter {
  _LocationArtPainter({
    required this.ink,
    required this.line,
    required this.road,
    required this.pins,
  });

  final Color ink;
  final Color line;
  final Color road;
  final List<Color> pins;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = h * 0.06;
    // Streets: two horizontals, two verticals and a diagonal avenue.
    canvas.drawLine(Offset(0, h * 0.32), Offset(w, h * 0.28), roadPaint);
    canvas.drawLine(Offset(0, h * 0.74), Offset(w, h * 0.70), roadPaint);
    canvas.drawLine(Offset(w * 0.30, 0), Offset(w * 0.26, h), roadPaint);
    canvas.drawLine(Offset(w * 0.72, 0), Offset(w * 0.76, h), roadPaint);
    canvas.drawLine(
      Offset(w * 0.05, h),
      Offset(w * 0.95, 0),
      roadPaint..strokeWidth = h * 0.035,
    );

    // Walking radius around the user.
    final me = Offset(w * 0.50, h * 0.52);
    canvas.drawCircle(
      me,
      h * 0.30,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ink.withValues(alpha: 0.35),
    );
    canvas.drawCircle(me, 9, Paint()..color = road);
    canvas.drawCircle(me, 6, Paint()..color = ink);

    // Drop-off pins: a circle with a point, in material colors.
    final spots = [
      Offset(w * 0.28, h * 0.30),
      Offset(w * 0.74, h * 0.34),
      Offset(w * 0.64, h * 0.78),
    ];
    for (var i = 0; i < spots.length && i < pins.length; i++) {
      _pin(canvas, spots[i], pins[i], h * 0.075);
    }
  }

  void _pin(Canvas canvas, Offset tip, Color color, double r) {
    final center = tip.translate(0, -r * 2.1);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(center.dx - r * 0.82, center.dy + r * 0.55)
      ..arcToPoint(
        Offset(center.dx + r * 0.82, center.dy + r * 0.55),
        radius: Radius.circular(r),
        largeArc: true,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(center, r * 0.38, Paint()..color = road);
  }

  @override
  bool shouldRepaint(_LocationArtPainter old) =>
      old.ink != ink || old.road != road || old.pins != pins;
}
