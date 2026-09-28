import 'package:flutter/material.dart';

import '../context.dart';
import '../material_colors.dart';
import '../tokens.dart';

/// A data label in IBM Plex Mono, uppercase and tracked ("PET · #1 ·
/// 3 PCS"). Arabic text keeps its natural case and no tracking.
class MonoLabel extends StatelessWidget {
  const MonoLabel(
    this.text, {
    super.key,
    this.color,
    this.strong = false,
    this.maxLines,
    this.textAlign,
  });

  final String text;
  final Color? color;

  /// Larger size in full ink, for values such as counts and codes.
  final bool strong;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final type = context.kanzType;
    final style = strong ? type.dataStrong : type.data;
    return Text(
      type.uppercaseData ? text.toUpperCase() : text,
      style: color == null ? style : style.copyWith(color: color),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

/// A small circle in a material category's color. Decorative: the category
/// name is always shown next to it, so it is excluded from semantics.
class MaterialDot extends StatelessWidget {
  const MaterialDot(this.categoryId, {super.key, this.size = 8});

  final String categoryId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: KanzMaterialColors.dot(context, categoryId),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// One cell of a [DataGrid]: a mono label above a value.
class DataGridEntry {
  const DataGridEntry(this.label, {this.value, this.child, this.span = false})
    : assert(value != null || child != null, 'Give a value or a child');

  final String label;

  /// Plain text value, set in body type.
  final String? value;

  /// Custom value widget (a quality bar, tags) used instead of [value].
  final Widget? child;

  /// Whether the cell takes the full row.
  final bool span;
}

/// A spec-sheet grid of mono labels and values, two columns, separated by
/// hairlines. Cells wrap onto new rows rather than shrinking text, so it
/// holds up at 130 % text scale and in Arabic.
class DataGrid extends StatelessWidget {
  const DataGrid({super.key, required this.entries, this.columns = 2});

  final List<DataGridEntry> entries;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = <List<DataGridEntry>>[];
    var current = <DataGridEntry>[];
    for (final e in entries) {
      if (e.span) {
        if (current.isNotEmpty) rows.add(current);
        rows.add([e]);
        current = [];
        continue;
      }
      current.add(e);
      if (current.length == columns) {
        rows.add(current);
        current = [];
      }
    }
    if (current.isNotEmpty) rows.add(current);

    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.line)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: KanzSpace.s12),
              child: row.length == 1 && row.first.span
                  ? _Cell(entry: row.first)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < columns; i++) ...[
                          if (i > 0) const SizedBox(width: KanzSpace.s16),
                          Expanded(
                            child: i < row.length
                                ? _Cell(entry: row[i])
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.entry});

  final DataGridEntry entry;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MonoLabel(entry.label),
          const SizedBox(height: KanzSpace.s4),
          entry.child ??
              Text(entry.value!, style: context.textStyles.bodyMedium),
        ],
      ),
    );
  }
}

/// Condition on a 1-5 scale as five segments, with an optional label.
class QualityBar extends StatelessWidget {
  const QualityBar({
    super.key,
    required this.score,
    this.label,
    required this.semanticsLabel,
    this.segmentWidth = 14,
  }) : assert(score >= 0 && score <= 5);

  /// Filled segments, 0-5.
  final int score;

  /// Visible label after the bar, for example "Good".
  final String? label;

  /// Full description for screen readers, for example "Quality 4 of 5, good".
  final String semanticsLabel;
  final double segmentWidth;

  static const int segments = 5;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < segments; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Container(
              key: ValueKey('quality-segment-$i'),
              width: segmentWidth,
              height: 6,
              decoration: BoxDecoration(
                color: i < score ? c.ink : c.surfaceSunken,
                borderRadius: const BorderRadius.all(Radius.circular(1.5)),
              ),
            ),
          ],
          if (label != null) ...[
            const SizedBox(width: KanzSpace.s8),
            Flexible(
              child: Text(
                label!,
                style: context.textStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Condition tags ("Empty", "Label on") as quiet outlined labels. Not
/// interactive; use [KanzChip] for choices.
class StateTags extends StatelessWidget {
  const StateTags({
    super.key,
    required this.labels,
    this.emphasized = const {},
  });

  final List<String> labels;

  /// Labels that signal a problem (cracked, rusted), drawn in full ink.
  final Set<String> emphasized;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final style = context.textStyles.labelSmall!;
    return Wrap(
      spacing: KanzSpace.s4,
      runSpacing: KanzSpace.s4,
      children: [
        for (final label in labels)
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: KanzSpace.s8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: emphasized.contains(label) ? c.surfaceSunken : null,
              border: Border.all(color: c.line),
              borderRadius: KanzRadii.tagAll,
            ),
            child: Text(
              label,
              style: style.copyWith(
                color: emphasized.contains(label) ? c.ink : c.inkSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// A large Fraunces numeral with a label, for the impact dashboard.
class StatNumeral extends StatelessWidget {
  const StatNumeral({
    super.key,
    required this.value,
    required this.label,
    this.unit,
  });

  /// The formatted number ("12", "3.4").
  final String value;
  final String label;

  /// Optional mono unit after the number ("KG").
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final type = context.kanzType;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: type.numeralLarge),
              if (unit != null) ...[
                const SizedBox(width: KanzSpace.s4),
                MonoLabel(unit!),
              ],
            ],
          ),
          Text(label, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}

/// One row of [MaterialBars].
class MaterialShare {
  const MaterialShare({
    required this.categoryId,
    required this.label,
    required this.value,
    required this.valueLabel,
  });

  final String categoryId;
  final String label;
  final double value;

  /// Formatted value shown at the row end ("7 items").
  final String valueLabel;
}

/// Simple horizontal bars in material colors, longest first.
class MaterialBars extends StatelessWidget {
  const MaterialBars({super.key, required this.shares});

  final List<MaterialShare> shares;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final sorted = [...shares]..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1.0 : sorted.first.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: KanzSpace.s12),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      MaterialDot(s.categoryId),
                      const SizedBox(width: KanzSpace.s8),
                      Expanded(
                        child: Text(
                          s.label,
                          style: context.textStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      MonoLabel(s.valueLabel),
                    ],
                  ),
                  const SizedBox(height: KanzSpace.s4),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: c.surfaceSunken),
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: max <= 0
                                ? 0
                                : (s.value / max).clamp(0.0, 1.0),
                            child: ColoredBox(
                              color: KanzMaterialColors.dot(
                                context,
                                s.categoryId,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
