import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'card.dart';
import 'data.dart';

/// An eco-friendly swap: what to stop using in one quiet line ("Instead of
/// single-use plastic bags"), what to use instead under a mono "Try" with an
/// arrow that follows the reading direction, why it helps, one practical
/// tip, the effort and cost in mono, and an optional [footer] (an impact
/// note, the sources it was grounded in) inside the card.
class SwapCard extends StatelessWidget {
  const SwapCard({
    super.key,
    required this.fromLabel,
    required this.from,
    required this.toLabel,
    required this.to,
    required this.why,
    required this.meta,
    this.categoryId,
    this.tipLabel,
    this.tip,
    this.badge,
    this.footer,
    this.onTap,
  });

  /// Lead-in of the from line, for example "Instead of"; the line reads
  /// "Instead of single-use plastic bags".
  final String fromLabel;
  final String from;

  /// Mono cue over the swap, for example "Try".
  final String toLabel;
  final String to;
  final String why;

  /// Meta items, for example ["Low effort", "Low cost"], joined with " · ".
  final List<String> meta;

  /// Material category the swap reduces, shown as a dot.
  final String? categoryId;
  final String? tipLabel;
  final String? tip;

  /// Small tag such as "From your scans".
  final String? badge;

  /// Shown last, under the meta line, for example the impact note and the
  /// [SourceChips] the swap was grounded in.
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return KanzCard(
      onTap: onTap,
      padding: const EdgeInsetsDirectional.all(KanzSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null || categoryId != null) ...[
            Row(
              children: [
                if (categoryId != null) ...[
                  MaterialDot(categoryId!),
                  const SizedBox(width: KanzSpace.s8),
                ],
                if (badge != null) Flexible(child: MonoLabel(badge!)),
              ],
            ),
            const SizedBox(height: KanzSpace.s12),
          ],
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$fromLabel $from',
                  style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: KanzSpace.s12,
                    bottom: KanzSpace.s4,
                  ),
                  child: Row(
                    children: [
                      Icon(KanzIcons.forward, size: 16, color: c.ink),
                      const SizedBox(width: KanzSpace.s8),
                      MonoLabel(toLabel, color: c.ink),
                    ],
                  ),
                ),
                Text(to, style: t.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: KanzSpace.s12),
          Text(why, style: t.bodyMedium),
          if (tip != null) ...[
            const SizedBox(height: KanzSpace.s12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(KanzIcons.tip, size: 16, color: c.inkSecondary),
                ),
                const SizedBox(width: KanzSpace.s8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (tipLabel != null)
                          TextSpan(
                            text: '$tipLabel  ',
                            style: t.bodySmall?.copyWith(
                              color: c.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        TextSpan(text: tip),
                      ],
                    ),
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          if (meta.isNotEmpty || footer != null) ...[
            const SizedBox(height: KanzSpace.s12),
            Divider(color: c.line),
            const SizedBox(height: KanzSpace.s12),
          ],
          if (meta.isNotEmpty) MonoLabel(meta.join(' · ')),
          if (footer != null) ...[
            if (meta.isNotEmpty) const SizedBox(height: KanzSpace.s12),
            footer!,
          ],
        ],
      ),
    );
  }
}
