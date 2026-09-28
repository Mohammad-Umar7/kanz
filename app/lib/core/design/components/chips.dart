import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'data.dart';

/// A filter or choice chip. Unselected chips are outlined; selected chips
/// are ink with paper text. An optional material dot identifies a category.
///
/// The visual chip is 36 dp tall inside a 48 dp touch target.
class KanzChip extends StatelessWidget {
  const KanzChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.materialId,
    this.icon,
    this.count,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  /// Draws a [MaterialDot] before the label.
  final String? materialId;
  final IconData? icon;

  /// Optional count after the label, set in mono ("3").
  final String? count;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final fg = selected ? c.onInverse : c.ink;
    final enabled = onSelected != null;
    void toggle() => onSelected!(!selected);
    // The node replaces the InkWell's semantics (one clean label with the
    // count), so it carries the tap action itself.
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: count == null ? label : '$label, $count',
      onTap: enabled ? toggle : null,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
        child: Center(
          widthFactor: 1,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled ? toggle : null,
              borderRadius: KanzRadii.chipAll,
              child: AnimatedContainer(
                duration: KanzMotion.of(context, KanzMotion.fast),
                curve: KanzMotion.standard,
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: KanzSpace.s12,
                  vertical: KanzSpace.s4,
                ),
                decoration: BoxDecoration(
                  color: selected ? c.inverse : c.surface,
                  borderRadius: KanzRadii.chipAll,
                  border: Border.all(color: selected ? c.inverse : c.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (materialId != null) ...[
                      MaterialDot(materialId!),
                      const SizedBox(width: KanzSpace.s8),
                    ] else if (icon != null) ...[
                      Icon(icon, size: 16, color: fg),
                      const SizedBox(width: KanzSpace.s8),
                    ],
                    // One paragraph so the mono count shares the label's
                    // baseline.
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          text: label,
                          children: [
                            if (count != null)
                              TextSpan(
                                text: '  $count',
                                style: context.kanzType.data.copyWith(
                                  color: selected
                                      ? c.onInverse
                                      : c.inkSecondary,
                                ),
                              ),
                          ],
                        ),
                        style: context.textStyles.labelMedium?.copyWith(
                          color: enabled ? fg : c.inkDisabled,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The knowledge documents an answer was grounded in (RAG sources), shown
/// as a quiet row so the user can see where advice came from.
class SourceChips extends StatelessWidget {
  const SourceChips({
    super.key,
    required this.title,
    required this.sources,
    this.onTap,
  });

  /// Heading, for example "Sources".
  final String title;
  final List<String> sources;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MonoLabel(title),
        const SizedBox(height: KanzSpace.s8),
        Wrap(
          spacing: KanzSpace.s8,
          runSpacing: KanzSpace.s8,
          children: [
            for (var i = 0; i < sources.length; i++)
              Semantics(
                button: onTap != null,
                child: InkWell(
                  onTap: onTap == null ? null : () => onTap!(i),
                  borderRadius: KanzRadii.tagAll,
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      KanzSpace.s8,
                      KanzSpace.s4,
                      KanzSpace.s12,
                      KanzSpace.s4,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceSunken,
                      borderRadius: KanzRadii.tagAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(KanzIcons.source, size: 14, color: c.inkSecondary),
                        const SizedBox(width: KanzSpace.s4),
                        Flexible(
                          child: Text(
                            sources[i],
                            style: context.textStyles.labelSmall?.copyWith(
                              color: c.ink,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// How many of an idea's tools the user already owns: a row of small
/// marks (filled for owned) and a sentence such as "You have 3 of 4 tools".
class ToolMatchBadge extends StatelessWidget {
  const ToolMatchBadge({
    super.key,
    required this.label,
    required this.have,
    required this.total,
  });

  final String label;
  final int have;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final complete = total > 0 && have >= total;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (complete)
            Icon(KanzIcons.checkCircle, size: 16, color: c.ink)
          else
            for (var i = 0; i < total.clamp(0, 8); i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Container(
                width: 6,
                height: 10,
                decoration: BoxDecoration(
                  color: i < have ? c.ink : null,
                  border: Border.all(color: i < have ? c.ink : c.lineStrong),
                  borderRadius: const BorderRadius.all(Radius.circular(1.5)),
                ),
              ),
            ],
          const SizedBox(width: KanzSpace.s8),
          Flexible(
            child: Text(
              label,
              style: context.textStyles.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
