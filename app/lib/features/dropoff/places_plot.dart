import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import 'place_info.dart';

/// A drawn field-guide plot of the results around the search centre: range
/// rings, a north mark, a surveyor's cross for the centre and one mark per
/// place at its real bearing and distance ([PinMark]: a dot in material
/// colors when the listing names what it accepts, a hollow ring when it
/// does not). A key under the plot names the centre, the ring spacing and
/// the two marks. It gives the list a sense of place when there is no map;
/// tapping a mark opens that place.
///
/// Geography never mirrors: east stays on the right in Arabic, like the
/// bounding boxes on photos. Only the key follows the reading direction.
class PlacesPlot extends StatelessWidget {
  const PlacesPlot({
    super.key,
    required this.center,
    required this.places,
    required this.pinMarks,
    required this.northLabel,
    required this.semanticsLabel,
    this.centerLabel,
    this.ringsLabel,
    this.listedLabel,
    this.unlistedLabel,
    this.selectedId,
    this.onPinTap,
    this.height,
  });

  final GeoPoint center;

  /// Nearest first.
  final List<Place> places;

  /// Place id to its mark (a missing id draws a neutral ring).
  final Map<String, PinMark> pinMarks;
  final String northLabel;
  final String semanticsLabel;

  /// Key under the plot: "Abu Dhabi centre", "You". Null hides the key.
  final String? centerLabel;

  /// "Rings every 5 km" for the ring spacing the plot picked.
  final String Function(double km)? ringsLabel;

  /// Key entries for the two marks ("Takes your materials", "Materials
  /// not listed"), shown when some places have no listed materials.
  final String? listedLabel;
  final String? unlistedLabel;

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
          final marks = [
            for (final p in layout.pins)
              pinMarks[p.place.id] ?? const PinMark(listed: false),
          ];
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
                marks: marks,
                colors: [for (final m in marks) pinColors(context, m)],
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
                // A map key: each glyph with its label, wrapping onto new
                // start-aligned lines rather than squeezing.
                child: Wrap(
                  spacing: KanzSpace.s16,
                  runSpacing: KanzSpace.s8,
                  children: [
                    _KeyEntry(glyph: _CrossPainter(c.ink), label: centerLabel!),
                    if (ringsLabel != null)
                      _KeyEntry(
                        glyph: _RingsPainter(c.lineStrong),
                        label: ringsLabel!(layout.ringStepKm),
                      ),
                    ...placeMarkKeyEntries(
                      context,
                      places: places,
                      pinMarks: pinMarks,
                      listedLabel: listedLabel,
                      unlistedLabel: unlistedLabel,
                      mono: true,
                    ),
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

/// The key entries for the place marks: "Takes your materials" next to the
/// nearest listed place's own dot when some places are listed and some are
/// not, and "Materials not listed" next to a ring when any place is
/// unlisted. Empty when every mark is a colored dot (the chips above
/// already name those colors).
List<Widget> placeMarkKeyEntries(
  BuildContext context, {
  required List<Place> places,
  required Map<String, PinMark> pinMarks,
  required String? listedLabel,
  required String? unlistedLabel,
  bool mono = false,
}) {
  final c = context.kanzColors;
  final anyUnlisted = places.any((p) => !(pinMarks[p.id]?.listed ?? false));
  final listed = keyListedMark(places, pinMarks);
  return [
    if (anyUnlisted && listed != null && listedLabel != null)
      _KeyEntry(
        glyph: _MarkPainter(
          listed,
          colors: pinColors(context, listed),
          surface: c.surface,
        ),
        label: listedLabel,
        mono: mono,
      ),
    if (anyUnlisted && unlistedLabel != null)
      _KeyEntry(
        glyph: _MarkPainter(
          const PinMark(listed: false),
          colors: [c.lineStrong],
          surface: c.surface,
        ),
        label: unlistedLabel,
        mono: mono,
      ),
  ];
}

/// One entry of a map key: a small drawn glyph and its label, as a mono
/// data label (under the plot) or a quiet caption (the map's sheet).
class _KeyEntry extends StatelessWidget {
  const _KeyEntry({required this.glyph, required this.label, this.mono = true});

  final CustomPainter glyph;
  final String label;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: const Size.square(12), painter: glyph),
        const SizedBox(width: KanzSpace.s8),
        Flexible(
          child: mono
              ? MonoLabel(label)
              : Text(label, style: context.textStyles.bodySmall),
        ),
      ],
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
  /// step that gives two to four rings. Marks that would touch are pushed
  /// apart along their bearing from the centre, so each stays readable and
  /// tappable while keeping its direction.
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
    final projected = [
      for (final o in offsets)
        origin + Offset(o.east * scale, -o.north * scale),
    ];
    final separated = _separate(projected, origin, size, margin: margin / 2);
    final pins = [
      for (var i = 0; i < places.length; i++)
        _PlotPin(
          places[i],
          separated[i],
          emphasized: places[i].id == selectedId,
        ),
    ];
    // The selected pin last, so it draws on top.
    pins.sort((a, b) => (a.emphasized ? 1 : 0) - (b.emphasized ? 1 : 0));
    return _PlotLayout(size, origin, scale, step, pins);
  }

  /// Closest two marks may sit, centre to centre: a dot (9) and a gap.
  static const double minGap = 12;

  /// Walks the points nearest first and moves each one that would touch the
  /// centre cross or a mark already placed outward along its bearing, in
  /// small steps, until it is clear (or the plot's edge stops it).
  static List<Offset> _separate(
    List<Offset> points,
    Offset origin,
    Size size, {
    required double margin,
  }) {
    final placed = <Offset>[];
    final taken = [origin];
    for (var i = 0; i < points.length; i++) {
      var p = points[i];
      var bearing = p - origin;
      if (bearing.distance < 0.5) {
        // At the centre: fan out, starting towards north-east.
        final angle = -math.pi / 4 + i * 2.399;
        bearing = Offset(math.cos(angle), math.sin(angle));
      }
      final unit = bearing / bearing.distance;
      for (var tries = 0; tries < 16; tries++) {
        if (!taken.any((q) => (q - p).distance < minGap)) break;
        p = Offset(
          (p.dx + unit.dx * 3).clamp(margin, size.width - margin),
          (p.dy + unit.dy * 3).clamp(margin, size.height - margin),
        );
      }
      placed.add(p);
      taken.add(p);
    }
    return placed;
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

/// A place's mark without its paper halo: a filled dot (two half-discs for
/// two [colors]), or a hollow ring ([radius] is the outer edge in both
/// cases, so the two read the same size).
void _paintMark(
  Canvas canvas,
  Offset at,
  PinMark mark,
  List<Color> colors,
  Color surface, {
  required double radius,
  double stroke = 1.5,
}) {
  if (mark.listed) {
    paintSplitDot(canvas, at, radius, colors);
    return;
  }
  canvas
    ..drawCircle(at, radius, Paint()..color = surface)
    ..drawCircle(
      at,
      radius - stroke / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors.first,
    );
}

/// A disc in one color, or two half-discs in two: the first on the left,
/// the second on the right (geography never mirrors, so neither does the
/// mark). Shared with the map's pins so both views draw the same marks.
void paintSplitDot(
  Canvas canvas,
  Offset at,
  double radius,
  List<Color> colors,
) {
  if (colors.length < 2) {
    canvas.drawCircle(at, radius, Paint()..color = colors.first);
    return;
  }
  // The whole disc in the first color, then the right half over it: one
  // anti-aliased edge down the middle, so no background seam shows there.
  canvas
    ..drawCircle(at, radius, Paint()..color = colors[0])
    ..drawArc(
      Rect.fromCircle(center: at, radius: radius),
      -math.pi / 2,
      math.pi,
      true,
      Paint()..color = colors[1],
    );
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

/// Two concentric hairline rings, the key glyph for the ring spacing.
class _RingsPainter extends CustomPainter {
  _RingsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final o = size.center(Offset.zero);
    canvas
      ..drawCircle(o, size.width / 2 - 0.5, paint)
      ..drawCircle(o, size.width / 4, paint);
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.color != color;
}

/// A place mark as a key glyph.
class _MarkPainter extends CustomPainter {
  _MarkPainter(this.mark, {required this.colors, required this.surface});

  final PinMark mark;
  final List<Color> colors;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) => _paintMark(
    canvas,
    size.center(Offset.zero),
    mark,
    colors,
    surface,
    radius: 4.5,
  );

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.mark != mark ||
      !listEquals(old.colors, colors) ||
      old.surface != surface;
}

class _PlotPainter extends CustomPainter {
  _PlotPainter({
    required this.layout,
    required this.marks,
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
  final List<PinMark> marks;
  final List<List<Color>> colors;
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

    // Places in two passes: every paper halo first, then every mark, so a
    // neighbour's halo never bites into a dot. The selected one is last in
    // the list: larger, ringed in ink.
    final halo = Paint()..color = surface;
    for (final pin in layout.pins) {
      canvas.drawCircle(pin.offset, pin.emphasized ? 12 : 6.5, halo);
    }
    for (var i = 0; i < layout.pins.length; i++) {
      final pin = layout.pins[i];
      if (pin.emphasized) {
        canvas.drawCircle(
          pin.offset,
          10.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = ink,
        );
      }
      _paintMark(
        canvas,
        pin.offset,
        marks[i],
        colors[i],
        surface,
        radius: pin.emphasized ? 6 : 4.5,
        stroke: pin.emphasized ? 2 : 1.5,
      );
    }

    // The centre last, so no mark ever hides it.
    _paintCross(canvas, o, ink);
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
          a.marks[i] != b.marks[i] ||
          !listEquals(a.colors[i], b.colors[i])) {
        return false;
      }
    }
    return true;
  }
}
