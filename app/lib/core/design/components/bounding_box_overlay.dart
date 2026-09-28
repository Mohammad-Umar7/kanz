import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../context.dart';
import '../material_colors.dart';
import '../tokens.dart';
import '../typography.dart';

/// One detected item on a photo.
@immutable
class DetectionBox {
  const DetectionBox({
    required this.id,
    required this.rect,
    required this.categoryId,
    required this.label,
    this.semanticsLabel,
  });

  /// Item id, returned by [BoundingBoxOverlay.onSelect].
  final String id;

  /// Box in normalized image coordinates (0..1, top-left origin), as the
  /// API returns it: `Rect.fromLTWH(bbox.x, bbox.y, bbox.w, bbox.h)`.
  final Rect rect;
  final String categoryId;

  /// Short tag text, for example "Glass · 93%".
  final String label;

  /// Screen reader description; defaults to [label].
  final String? semanticsLabel;
}

/// The user's photo with material-colored outlines around each detected
/// item. On first show a thin scan line passes once over the photo, then
/// the outlines draw in one after another. The selected item is drawn
/// heavier and the others recede.
///
/// Boxes are mapped with the same [BoxFit] math the image uses, so they
/// stay on their items with [BoxFit.cover] (cropped) and [BoxFit.contain]
/// (letterboxed) alike. Boxes live in image space and never mirror in RTL.
class BoundingBoxOverlay extends StatefulWidget {
  const BoundingBoxOverlay({
    super.key,
    required this.image,
    required this.imageSize,
    required this.boxes,
    required this.semanticsLabel,
    this.selectedId,
    this.onSelect,
    this.fit = BoxFit.cover,
    this.animate = true,
    this.heroTag,
    this.borderRadius = KanzRadii.cardAll,
  });

  final ImageProvider image;

  /// Pixel size (or any size with the same aspect ratio) of [image].
  final Size imageSize;
  final List<DetectionBox> boxes;

  /// Describes the photo itself, for example "Your photo, 2 items found".
  final String semanticsLabel;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final BoxFit fit;

  /// Play the scan line and draw-in. Ignored when motion is reduced.
  final bool animate;

  /// Hero tag shared with the captured photo on the previous screen.
  final Object? heroTag;
  final BorderRadius borderRadius;

  /// Maps a normalized image-space [box] into a [viewport] showing an image
  /// of [imageSize] with [fit] and [alignment], exactly as [paintImage]
  /// lays the image out.
  static Rect mapBox(
    Rect box, {
    required Size imageSize,
    required Size viewport,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
  }) {
    final fitted = applyBoxFit(fit, imageSize, viewport);
    final src = alignment.inscribe(fitted.source, Offset.zero & imageSize);
    final dst = alignment.inscribe(fitted.destination, Offset.zero & viewport);
    final sx = dst.width / src.width;
    final sy = dst.height / src.height;
    return Rect.fromLTRB(
      dst.left + (box.left * imageSize.width - src.left) * sx,
      dst.top + (box.top * imageSize.height - src.top) * sy,
      dst.left + (box.right * imageSize.width - src.left) * sx,
      dst.top + (box.bottom * imageSize.height - src.top) * sy,
    );
  }

  /// The visible image area inside [viewport] (letterbox excluded).
  static Rect imageArea({
    required Size imageSize,
    required Size viewport,
    BoxFit fit = BoxFit.cover,
  }) {
    final fitted = applyBoxFit(fit, imageSize, viewport);
    return Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & viewport,
    );
  }

  @override
  State<BoundingBoxOverlay> createState() => _BoundingBoxOverlayState();
}

class _BoundingBoxOverlayState extends State<BoundingBoxOverlay>
    with SingleTickerProviderStateMixin {
  static const _scanMs = 900;
  static const _drawMs = 350;
  static const _staggerMs = 120;

  late final AnimationController _controller;

  int get _totalMs =>
      _scanMs + _drawMs + _staggerMs * math.max(0, widget.boxes.length - 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.animate || KanzMotion.reduced(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BoundingBoxOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boxes.length != widget.boxes.length) {
      _controller.duration = Duration(milliseconds: _totalMs);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scanProgress(double t) {
    final ms = t * _totalMs;
    return (ms / _scanMs).clamp(0.0, 1.0);
  }

  double _boxProgress(double t, int index) {
    final ms = t * _totalMs - _scanMs - index * _staggerMs;
    return KanzMotion.enter.transform((ms / _drawMs).clamp(0.0, 1.0));
  }

  void _handleTap(TapUpDetails details, Size viewport) {
    final onSelect = widget.onSelect;
    if (onSelect == null) return;
    DetectionBox? hit;
    var hitArea = double.infinity;
    for (final box in widget.boxes) {
      final r = _mapped(box, viewport).inflate(8);
      if (r.contains(details.localPosition)) {
        final area = r.width * r.height;
        if (area < hitArea) {
          hit = box;
          hitArea = area;
        }
      }
    }
    if (hit != null) onSelect(hit.id);
  }

  Rect _mapped(DetectionBox box, Size viewport) => BoundingBoxOverlay.mapBox(
    box.rect,
    imageSize: widget.imageSize,
    viewport: viewport,
    fit: widget.fit,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return AspectRatio(
            aspectRatio: widget.imageSize.aspectRatio,
            child: _buildSized(context),
          );
        }
        return _buildSized(context);
      },
    );
  }

  Widget _buildSized(BuildContext context) {
    final c = context.kanzColors;
    Widget image = Image(
      image: widget.image,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stack) =>
          ColoredBox(color: c.photoBackdrop),
    );
    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: ColoredBox(
        color: c.photoBackdrop,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = constraints.biggest;
            final mapped = [for (final b in widget.boxes) _mapped(b, viewport)];
            final tags = _placeTags(context, mapped, viewport);
            return Semantics(
              label: widget.semanticsLabel,
              image: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _handleTap(d, viewport),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    image,
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final t = _controller.value;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: _BoxesPainter(
                                boxes: widget.boxes,
                                rects: mapped,
                                progress: [
                                  for (var i = 0; i < mapped.length; i++)
                                    _boxProgress(t, i),
                                ],
                                selectedId: widget.selectedId,
                                scan: t >= 1 ? null : _scanProgress(t),
                                scanArea: BoundingBoxOverlay.imageArea(
                                  imageSize: widget.imageSize,
                                  viewport: viewport,
                                  fit: widget.fit,
                                ),
                                brightness: Theme.of(context).brightness,
                              ),
                            ),
                            for (var i = 0; i < mapped.length; i++)
                              _tag(
                                widget.boxes[i],
                                tags[i],
                                _boxProgress(t, i),
                              ),
                          ],
                        );
                      },
                    ),
                    for (var i = 0; i < mapped.length; i++)
                      _semanticsNode(widget.boxes[i], mapped[i], viewport),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _semanticsNode(DetectionBox box, Rect rect, Size viewport) {
    final clipped = rect.intersect(Offset.zero & viewport);
    if (clipped.isEmpty) return const SizedBox.shrink();
    return Positioned.fromRect(
      rect: clipped,
      child: Semantics(
        button: widget.onSelect != null,
        selected: widget.selectedId == box.id,
        label: box.semanticsLabel ?? box.label,
        onTap: widget.onSelect == null ? null : () => widget.onSelect!(box.id),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// Finds a spot for every tag that stays inside the photo and does not
  /// cover another tag. The selected box is placed first so it gets the
  /// natural spot above its top edge; the others fall back to inside the
  /// top edge, below the box, or inside the bottom edge.
  List<Rect> _placeTags(BuildContext context, List<Rect> rects, Size viewport) {
    const h = _BoxTag.height;
    const m = 4.0;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final arabic = !context.kanzType.uppercaseData;
    final order = [
      for (var i = 0; i < rects.length; i++)
        if (widget.boxes[i].id == widget.selectedId) i,
      for (var i = 0; i < rects.length; i++)
        if (widget.boxes[i].id != widget.selectedId) i,
    ];
    final placed = List<Rect>.filled(rects.length, Rect.zero);
    final taken = <Rect>[];
    for (final i in order) {
      final r = rects[i];
      final w = math.min(
        _BoxTag.widthFor(widget.boxes[i].label, arabic: arabic),
        viewport.width - 2 * m,
      );
      double startX(double inset) => rtl ? r.right - w - inset : r.left + inset;
      final candidates = [
        Offset(startX(0), r.top - h - m),
        Offset(startX(m), r.top + m),
        Offset(startX(0), r.bottom + m),
        Offset(startX(m), r.bottom - h - m),
      ];
      Rect? choice;
      for (final c in candidates) {
        final rect = Rect.fromLTWH(
          c.dx.clamp(m, math.max(m, viewport.width - w - m)),
          c.dy.clamp(m, math.max(m, viewport.height - h - m)),
          w,
          h,
        );
        if (taken.every((t) => !t.inflate(2).overlaps(rect))) {
          choice = rect;
          break;
        }
      }
      choice ??= Rect.fromLTWH(
        candidates.first.dx.clamp(m, math.max(m, viewport.width - w - m)),
        candidates.first.dy.clamp(m, math.max(m, viewport.height - h - m)),
        w,
        h,
      );
      placed[i] = choice;
      taken.add(choice);
    }
    return placed;
  }

  Widget _tag(DetectionBox box, Rect placement, double progress) {
    final dimmed = widget.selectedId != null && widget.selectedId != box.id;
    final opacity = (progress * 1.4 - 0.4).clamp(0.0, 1.0) * (dimmed ? 0.6 : 1);
    return Positioned.fromRect(
      rect: placement,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: opacity,
            child: _BoxTag(
              label: box.label,
              color: KanzMaterialColors.of(box.categoryId).box,
              selected: widget.selectedId == box.id,
            ),
          ),
        ),
      ),
    );
  }
}

/// A dark label chip laid over the photo: a color square and mono text.
/// Solid, not translucent, so it reads on any photo.
class _BoxTag extends StatelessWidget {
  const _BoxTag({
    required this.label,
    required this.color,
    required this.selected,
  });

  final String label;
  final Color color;
  final bool selected;

  static const double height = 22;

  // Tags are anchored to image geometry, so they do not grow with the
  // text scale; each box carries a full semantics label instead.
  static TextStyle _style({required bool arabic}) => TextStyle(
    fontFamily: arabic ? KanzFonts.arabic : KanzFonts.mono,
    fontFamilyFallback: const [KanzFonts.arabic],
    fontSize: arabic ? 11 : 10,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: arabic ? 0 : 0.8,
    color: const Color(0xFFF2EFE8),
  );

  static String _text(String label, {required bool arabic}) =>
      arabic ? label : label.toUpperCase();

  /// Laid-out width of a tag: padding, dot, gap, text and border.
  static double widthFor(String label, {required bool arabic}) {
    final painter = TextPainter(
      text: TextSpan(
        text: _text(label, arabic: arabic),
        style: _style(arabic: arabic),
      ),
      maxLines: 1,
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return (6 + 6 + 6 + width + 6 + 3).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = !context.kanzType.uppercaseData;
    return Container(
      height: height,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xF0161616),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: selected ? color : const Color(0x00000000),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _text(label, arabic: arabic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
              style: _style(arabic: arabic),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxesPainter extends CustomPainter {
  _BoxesPainter({
    required this.boxes,
    required this.rects,
    required this.progress,
    required this.selectedId,
    required this.scan,
    required this.scanArea,
    required this.brightness,
  });

  final List<DetectionBox> boxes;
  final List<Rect> rects;
  final List<double> progress;
  final String? selectedId;

  /// Scan line position 0..1, or null once it has passed.
  final double? scan;
  final Rect scanArea;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final scan = this.scan;
    if (scan != null && scan > 0 && scan < 1) {
      final y =
          scanArea.top +
          scanArea.height * KanzMotion.emphasized.transform(scan);
      final fade = scan < 0.1
          ? scan / 0.1
          : (scan > 0.9 ? (1 - scan) / 0.1 : 1.0);
      canvas.drawLine(
        Offset(scanArea.left, y + 1),
        Offset(scanArea.right, y + 1),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25 * fade)
          ..strokeWidth = 1,
      );
      canvas.drawLine(
        Offset(scanArea.left, y),
        Offset(scanArea.right, y),
        Paint()
          ..color = const Color(0xFFF2EFE8).withValues(alpha: 0.85 * fade)
          ..strokeWidth = 1,
      );
    }

    // Draw unselected boxes first so the selected one sits on top.
    final order = [
      for (var i = 0; i < boxes.length; i++)
        if (boxes[i].id != selectedId) i,
      for (var i = 0; i < boxes.length; i++)
        if (boxes[i].id == selectedId) i,
    ];
    for (final i in order) {
      final p = progress[i];
      if (p <= 0) continue;
      final selected = boxes[i].id == selectedId;
      final dimmed = selectedId != null && !selected;
      final color = KanzMaterialColors.of(boxes[i].categoryId).box;
      final rrect = RRect.fromRectAndRadius(rects[i], const Radius.circular(6));
      final path = Path()..addRRect(rrect);
      final drawn = p >= 1 ? path : _partial(path, p);
      final width = selected ? 3.0 : (dimmed ? 1.5 : 2.0);
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width + 2.5
          ..color = Colors.black.withValues(alpha: dimmed ? 0.15 : 0.32),
      );
      canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: dimmed ? 0.55 : 1),
      );
    }
  }

  Path _partial(Path path, double t) {
    final out = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      out.addPath(metric.extractPath(0, metric.length * t), Offset.zero);
    }
    return out;
  }

  @override
  bool shouldRepaint(_BoxesPainter old) =>
      old.progress != progress ||
      old.scan != scan ||
      old.selectedId != selectedId ||
      old.rects != rects ||
      old.brightness != brightness;
}
