import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// How a [GuideList] marks its lines.
enum GuideListStyle {
  /// "01", "02"... for steps done in order.
  numbered,

  /// A check: things to do.
  dos,

  /// A prohibition glyph: things never to do.
  donts,

  /// A short dash: plain facts (where to donate).
  plain,
}

/// A mono heading over short lines of advice: prep steps, do's and don'ts,
/// disposal steps. Numbers stay left to right in Arabic too.
class GuideList extends StatelessWidget {
  const GuideList({
    super.key,
    required this.title,
    required this.lines,
    this.style = GuideListStyle.plain,
    this.danger = false,
  });

  final String title;
  final List<String> lines;
  final GuideListStyle style;

  /// Width of the marker column; text starts [markerWidth] + 12 dp in.
  static const double markerWidth = 24;

  /// Where the text of every line starts, for content aligned with it.
  static const double textInset = markerWidth + KanzSpace.s12;

  /// Draws the glyphs and heading in the danger color (disposal "Never").
  final bool danger;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();
    final c = context.kanzColors;
    final t = context.textStyles;
    final accent = danger ? c.danger : c.ink;
    // Every marker sits in the same 24 dp column, so the text of numbered
    // steps, do's, don'ts and plain lines starts on one vertical line.
    Widget marker(int i) => SizedBox(
      width: GuideList.markerWidth,
      child: switch (style) {
        GuideListStyle.numbered => Text(
          (i + 1).toString().padLeft(2, '0'),
          style: context.kanzType.dataStrong.copyWith(color: c.inkSecondary),
          textDirection: TextDirection.ltr,
        ),
        GuideListStyle.dos => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Icon(KanzIcons.check, size: 18, color: accent),
        ),
        GuideListStyle.donts => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Icon(
            KanzIcons.prohibited,
            size: 18,
            color: danger ? c.danger : c.inkSecondary,
          ),
        ),
        // A small dot centred on the first line of text.
        GuideListStyle.plain => Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4,
            top:
                ((t.bodyMedium?.fontSize ?? 14) *
                            (t.bodyMedium?.height ?? 1.5) -
                        6) /
                    2 -
                2,
          ),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: c.inkSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonoLabel(title, color: danger ? c.danger : null),
        const SizedBox(height: KanzSpace.s8),
        for (var i = 0; i < lines.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == lines.length - 1 ? 0 : KanzSpace.s8,
            ),
            child: MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ExcludeSemantics(
                      excluding: style != GuideListStyle.numbered,
                      child: marker(i),
                    ),
                  ),
                  const SizedBox(width: KanzSpace.s12),
                  Expanded(child: Text(lines[i], style: t.bodyMedium)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Records that the user recycled, donated or disposed of an item. Once
/// done it turns into a quiet confirmation (the impact event is kept; there
/// is nothing to undo).
class MarkButton extends StatefulWidget {
  const MarkButton({
    super.key,
    required this.label,
    required this.doneLabel,
    required this.done,
    required this.onMark,
  });

  final String label;
  final String doneLabel;
  final bool done;
  final Future<void> Function() onMark;

  @override
  State<MarkButton> createState() => _MarkButtonState();
}

class _MarkButtonState extends State<MarkButton> {
  bool _busy = false;

  Future<void> _mark() async {
    setState(() => _busy = true);
    try {
      await widget.onMark();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return AnimatedSwitcher(
      duration: KanzMotion.of(context, KanzMotion.fast),
      child: widget.done
          ? Semantics(
              key: const ValueKey('done'),
              liveRegion: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: KanzSpace.touchTarget,
                ),
                child: Row(
                  children: [
                    Icon(KanzIcons.checkCircle, size: 20, color: c.ink),
                    const SizedBox(width: KanzSpace.s8),
                    Expanded(
                      child: Text(
                        widget.doneLabel,
                        style: context.textStyles.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Align(
              key: const ValueKey('mark'),
              alignment: AlignmentDirectional.centerStart,
              child: KanzButton.secondary(
                label: widget.label,
                icon: KanzIcons.check,
                loading: _busy,
                onPressed: _mark,
              ),
            ),
    );
  }
}
