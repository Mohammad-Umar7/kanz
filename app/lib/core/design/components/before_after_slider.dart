import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../context.dart';
import '../haptics.dart';
import '../icons.dart';
import '../tokens.dart';
import 'data.dart';

/// Compares the user's photo with the generated makeover. The before image
/// covers the start side up to a clay handle that the user drags.
///
/// Accessible by design: the control is a semantic slider with increase
/// and decrease actions (10 % steps), arrow keys move it when focused, and
/// it follows the reading direction (in Arabic "before" sits on the right).
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    required this.beforeLabel,
    required this.afterLabel,
    required this.semanticsLabel,
    this.initialValue = 0.5,
    this.onChanged,
    this.aspectRatio = 4 / 3,
    this.borderRadius = KanzRadii.cardAll,
    this.afterHeroTag,
  });

  final ImageProvider before;
  final ImageProvider after;

  /// Mono tags on each side, for example "Before" and "After".
  final String beforeLabel;
  final String afterLabel;

  /// Names the control, for example "Compare before and after".
  final String semanticsLabel;

  /// Share of the width showing the before image, 0..1.
  final double initialValue;
  final ValueChanged<double>? onChanged;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final Object? afterHeroTag;

  /// Change per semantic action or arrow key press.
  static const double step = 0.1;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _value = widget.initialValue.clamp(0.0, 1.0);
  bool _dragging = false;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'BeforeAfterSlider');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _set(double v) {
    final next = v.clamp(0.0, 1.0);
    if (next == _value) return;
    final hitEnd = (next == 0 || next == 1) && _value != next;
    setState(() => _value = next);
    if (hitEnd) KanzHaptics.selection();
    widget.onChanged?.call(next);
  }

  /// Converts a horizontal position into a value, honoring direction.
  double _valueAt(double dx, double width, bool rtl) {
    final f = (dx / width).clamp(0.0, 1.0);
    return rtl ? 1 - f : f;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final rtl = context.isRtl;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      _set(_value + (rtl ? -BeforeAfterSlider.step : BeforeAfterSlider.step));
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _set(_value + (rtl ? BeforeAfterSlider.step : -BeforeAfterSlider.step));
    } else if (key == LogicalKeyboardKey.home) {
      _set(0);
    } else if (key == LogicalKeyboardKey.end) {
      _set(1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  String _percent(double v) => '${(v * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final rtl = context.isRtl;
    return Semantics(
      slider: true,
      label: widget.semanticsLabel,
      value: _percent(_value),
      increasedValue: _percent((_value + BeforeAfterSlider.step).clamp(0, 1)),
      decreasedValue: _percent((_value - BeforeAfterSlider.step).clamp(0, 1)),
      onIncrease: () => _set(_value + BeforeAfterSlider.step),
      onDecrease: () => _set(_value - BeforeAfterSlider.step),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        onFocusChange: (f) => setState(() => _focused = f),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final splitX = rtl ? w * (1 - _value) : w * _value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                // The slider semantics above describe this control; raw
                // tap and drag actions would only confuse screen readers.
                excludeFromSemantics: true,
                onHorizontalDragStart: (d) {
                  _focusNode.requestFocus();
                  setState(() => _dragging = true);
                  _set(_valueAt(d.localPosition.dx, w, rtl));
                },
                onHorizontalDragUpdate: (d) =>
                    _set(_valueAt(d.localPosition.dx, w, rtl)),
                onHorizontalDragEnd: (_) => setState(() => _dragging = false),
                onHorizontalDragCancel: () => setState(() => _dragging = false),
                onTapUp: (d) {
                  _focusNode.requestFocus();
                  _set(_valueAt(d.localPosition.dx, w, rtl));
                },
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: c.photoBackdrop),
                      _image(widget.after, heroTag: widget.afterHeroTag),
                      ClipRect(
                        clipper: _SideClipper(splitX: splitX, rtl: rtl),
                        child: _image(widget.before),
                      ),
                      PositionedDirectional(
                        top: KanzSpace.s12,
                        start: KanzSpace.s12,
                        child: _Tag(widget.beforeLabel),
                      ),
                      PositionedDirectional(
                        top: KanzSpace.s12,
                        end: KanzSpace.s12,
                        child: _Tag(widget.afterLabel),
                      ),
                      Positioned(
                        left: splitX - 1,
                        top: 0,
                        bottom: 0,
                        width: 2,
                        child: const ColoredBox(color: Color(0xFFF2EFE8)),
                      ),
                      Positioned(
                        left: splitX - 24,
                        top: 0,
                        bottom: 0,
                        width: 48,
                        child: Center(
                          child: _Handle(
                            active: _dragging || _focused,
                            color: c.accent,
                            onColor: c.onAccent,
                            shadow: KanzElevation.floating(c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _image(ImageProvider image, {Object? heroTag}) {
    final img = Image(
      image: image,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      gaplessPlayback: true,
    );
    return heroTag == null ? img : Hero(tag: heroTag, child: img);
  }
}

class _SideClipper extends CustomClipper<Rect> {
  _SideClipper({required this.splitX, required this.rtl});

  final double splitX;
  final bool rtl;

  @override
  Rect getClip(Size size) => rtl
      ? Rect.fromLTRB(splitX, 0, size.width, size.height)
      : Rect.fromLTRB(0, 0, splitX, size.height);

  @override
  bool shouldReclip(_SideClipper old) => old.splitX != splitX || old.rtl != rtl;
}

class _Handle extends StatelessWidget {
  const _Handle({
    required this.active,
    required this.color,
    required this.onColor,
    required this.shadow,
  });

  final bool active;
  final Color color;
  final Color onColor;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.08 : 1,
      duration: KanzMotion.of(context, KanzMotion.fast),
      curve: KanzMotion.standard,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF2EFE8), width: 2),
          boxShadow: shadow,
        ),
        child: Icon(KanzIcons.compare, size: 22, color: onColor),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: const BoxDecoration(
          color: Color(0xE6161616),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: MonoLabel(label, color: const Color(0xFFF2EFE8)),
      ),
    );
  }
}
