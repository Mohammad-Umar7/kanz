import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import 'place_info.dart';

/// A drawn field-guide plot of the results around the search centre: range
/// rings, a north mark, a surveyor's cross for the centre and one dot per
/// place at its real bearing and distance, colored by the one material it
/// takes (ink when it takes several). A key under the plot names the centre
/// and the ring spacing. It gives the list a sense of place when there is
/// no map; tapping a dot opens that place.
///
/// Geography never mirrors: east stays on the right in Arabic, like the
/// bounding boxes on photos. Only the key follows the reading direction.
class PlacesPlot extends StatelessWidget {
  const PlacesPlot({
    super.key,
    required this.center,
    required this.places,
    required this.pinMaterials,
    required this.northLabel,
    required this.semanticsLabel,
    this.centerLabel,
    this.ringsLabel,
    this.selectedId,
    this.onPinTap,
    this.height,
  });

  final GeoPoint center;

  /// Nearest first.
  final List<Place> places;

  /// Place id to material id (null draws a neutral ink dot).
  final Map<String, String?> pinMaterials;
  final String northLabel;
  final String semanticsLabel;

  /// Key under the plot: "Abu Dhabi centre", "You". Null hides the key.
  final String? centerLabel;

  /// "Rings every 5 km" for the ring spacing the plot picked.
  final String Function(double km)? ringsLabel;

  /// Drawn larger with an ink ring.
  final String? selectedId;
  final ValueChanged<Place>? onPinTap;

  /// Height of the drawing; by default it follows the width.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      label: semanticsLabel,
      container: true,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final h =
              height ??
              (constraints.hasBoundedHeight && centerLabel == null
                  ? constraints.maxHeight
                  : (width * 0.5).clamp(152.0, 208.0));
          final layout = _PlotLayout.compute(
            Size(width, h),
            center,
            places,
            selectedId: selectedId,
          );
          final plot = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onPinTap == null
                ? null
                : (details) {
                    final hit = layout.hitTest(details.localPosition);
                    if (hit != null) onPinTap!(hit);
                  },
            child: CustomPaint(
              size: Size(width, h),
              painter: _PlotPainter(
                layout: layout,
                colors: [
                  for (final p in layout.pins)
                    pinColor(context, pinMaterials[p.place.id]),
                ],
                line: c.line,
                axis: c.lineStrong,
                ink: c.ink,
                surface: c.surface,
                northStyle: context.kanzType.data.copyWith(color: c.ink),
                northLabel: northLabel,
              ),
            ),
          );
          if (centerLabel == null) return plot;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              plot,
              Divider(height: 1, color: c.line),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  KanzSpace.s16,
                  KanzSpace.s12,
                  KanzSpace.s16,
                  KanzSpace.s12,
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: KanzSpace.s16,
                  runSpacing: KanzSpace.s4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size.square(10),
                          painter: _CrossPainter(c.ink),
                        ),
                        const SizedBox(width: KanzSpace.s8),
                        Flexible(child: MonoLabel(centerLabel!)),
                      ],
                    ),
                    if (ringsLabel != null)
                      MonoLabel(ringsLabel!(layout.ringStepKm)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One place projected onto the plot.
class _PlotPin {
  const _PlotPin(this.place, this.offset, {required this.emphasized});

  final Place place;
  final Offset offset;
  final bool emphasized;
}

class _PlotLayout {
  _PlotLayout(this.size, this.origin, this.scale, this.ringStepKm, this.pins);

  /// Projects the places so every one fits with a margin, then picks a ring
  /// step that gives two to four rings.
  factory _PlotLayout.compute(
    Size size,
    GeoPoint center,
    List<Place> places, {
    required String? selectedId,
  }) {
    const margin = 18.0;
    final offsets = [for (final p in places) offsetKm(center, p.lat, p.lng)];
    var maxEast = 0.5;
    var maxNorth = 0.5;
    for (final o in offsets) {
      maxEast = math.max(maxEast, o.east.abs());
      maxNorth = math.max(maxNorth, o.north.abs());
    }
    final scale = math.min(
      (size.width / 2 - margin) / maxEast,
      (size.height / 2 - margin) / maxNorth,
    );
    final origin = size.center(Offset.zero);
    final reach = math.max(maxEast, maxNorth);
    const steps = [0.5, 1.0, 2.0, 5.0, 10.0];
    final step = steps.firstWhere(
      (s) => reach / s <= 3.2,
      orElse: () => steps.last,
    );
    final pins = [
      for (var i = 0; i < places.length; i++)
        _PlotPin(
          places[i],
          origin + Offset(offsets[i].east * scale, -offsets[i].north * scale),
          emphasized: places[i].id == selectedId,
        ),
    ];
    // The selected pin last, so it draws on top.
    pins.sort((a, b) => (a.emphasized ? 1 : 0) - (b.emphasized ? 1 : 0));
    return _PlotLayout(size, origin, scale, step, pins);
  }

  final Size size;
  final Offset origin;

  /// Pixels per kilometre.
  final double scale;
  final double ringStepKm;
  final List<_PlotPin> pins;

  /// The place under [position] (within a finger's reach), nearest first.
  Place? hitTest(Offset position) {
    _PlotPin? best;
    var bestDistance = KanzSpace.touchTarget / 2;
    for (final pin in pins) {
      final d = (pin.offset - position).distance;
      if (d <= bestDistance) {
        best = pin;
        bestDistance = d;
      }
    }
    return best?.place;
  }
}

/// The surveyor's cross that marks the search centre.
void _paintCross(Canvas canvas, Offset at, Color ink, {double arm = 5}) {
  final paint = Paint()
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..color = ink;
  canvas
    ..drawLine(at - Offset(arm, 0), at + Offset(arm, 0), paint)
    ..drawLine(at - Offset(0, arm), at + Offset(0, arm), paint);
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) =>
      _paintCross(canvas, size.center(Offset.zero), ink, arm: size.width / 2);

  @override
  bool shouldRepaint(_CrossPainter old) => old.ink != ink;
}

class _PlotPainter extends CustomPainter {
  _PlotPainter({
    required this.layout,
    required this.colors,
    required this.line,
    required this.axis,
    required this.ink,
    required this.surface,
    required this.northStyle,
    required this.northLabel,
  });

  final _PlotLayout layout;

  /// Aligned with `layout.pins`.
  final List<Color> colors;
  final Color line;
  final Color axis;
  final Color ink;
  final Color surface;
  final TextStyle northStyle;
  final String northLabel;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final o = layout.origin;
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = line;

    // Axes through the centre, then the range rings.
    canvas
      ..drawLine(Offset(0, o.dy), Offset(size.width, o.dy), hairline)
      ..drawLine(Offset(o.dx, 0), Offset(o.dx, size.height), hairline);
    final halfDiagonal = size.center(Offset.zero).distance;
    for (var k = 1; k < 16; k++) {
      final r = layout.ringStepKm * k * layout.scale;
      if (r > halfDiagonal) break;
      canvas.drawCircle(o, r, hairline);
    }

    // North mark in the top corner (geographic, so it never mirrors).
    final north = TextPainter(
      text: TextSpan(text: northLabel, style: northStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final nx = size.width - KanzSpace.s16;
    final arrow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..color = axis;
    final tip = Offset(nx, KanzSpace.s12 + north.height + 3);
    canvas
      ..drawLine(tip, tip + const Offset(0, 14), arrow)
      ..drawLine(tip, tip + const Offset(-3, 4), arrow)
      ..drawLine(tip, tip + const Offset(3, 4), arrow);
    north.paint(canvas, Offset(nx - north.width / 2, KanzSpace.s12));

    _paintCross(canvas, o, ink);

    // Places: dots in a paper ring; the selected one larger, ringed in ink.
    for (var i = 0; i < layout.pins.length; i++) {
      final pin = layout.pins[i];
      final p = pin.offset;
      if (pin.emphasized) {
        canvas
          ..drawCircle(
            p,
            10.5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = ink,
          )
          ..drawCircle(p, 8, Paint()..color = surface)
          ..drawCircle(p, 6, Paint()..color = colors[i]);
      } else {
        canvas
          ..drawCircle(p, 6.5, Paint()..color = surface)
          ..drawCircle(p, 4.5, Paint()..color = colors[i]);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlotPainter old) =>
      old.layout.size != layout.size ||
      old.layout.scale != layout.scale ||
      old.line != line ||
      old.ink != ink ||
      old.surface != surface ||
      old.northLabel != northLabel ||
      !_samePins(old, this);

  static bool _samePins(_PlotPainter a, _PlotPainter b) {
    final pa = a.layout.pins;
    final pb = b.layout.pins;
    if (pa.length != pb.length) return false;
    for (var i = 0; i < pa.length; i++) {
      if (pa[i].place.id != pb[i].place.id ||
          pa[i].offset != pb[i].offset ||
          pa[i].emphasized != pb[i].emphasized ||
          a.colors[i] != b.colors[i]) {
        return false;
      }
    }
    return true;
  }
}
