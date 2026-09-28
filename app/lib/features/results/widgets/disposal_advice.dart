import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';
import 'guide_list.dart';

/// Replaces the ideas for hazardous items (batteries, e-waste, medicine...):
/// a calm, serious explanation of why there is no DIY, the hazards, and how
/// to get rid of each item safely.
class DisposalAdvice extends StatelessWidget {
  const DisposalAdvice({
    super.key,
    required this.recommendation,
    required this.items,
    required this.format,
    required this.disposed,
    required this.onMarkDisposed,
  });

  final RecommendResponse recommendation;
  final List<Item> items;
  final ResultsFormat format;

  /// Item ids already marked as disposed.
  final Set<String> disposed;
  final Future<void> Function(String itemId) onMarkDisposed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final hazards = <HazardFlag>{
      for (final g in recommendation.disposal) g.hazard,
      for (final item in items)
        if (recommendation.routing.hazardousItemIds.contains(item.id))
          ...item.hazards.where((h) => h.isDisposalOnly),
    };
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.s16,
              KanzSpace.s16,
              KanzSpace.s16,
              KanzSpace.s20,
            ),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: KanzRadii.cardAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(KanzIcons.prohibited, size: 20, color: c.danger),
                    const SizedBox(width: KanzSpace.s8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: MonoLabel(
                          l10n.resultsNoDiyTitle,
                          color: c.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                if (recommendation.routing.reason case final reason?) ...[
                  const SizedBox(height: KanzSpace.s12),
                  Text(format.ai(reason), style: t.bodyLarge),
                ],
                if (hazards.isNotEmpty) ...[
                  const SizedBox(height: KanzSpace.s16),
                  Wrap(
                    spacing: KanzSpace.s8,
                    runSpacing: KanzSpace.s8,
                    children: [
                      for (final h in hazards)
                        HazardTag(
                          icon: KanzIcons.hazard(h.id),
                          label: format.hazard(h),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          for (final guidance in recommendation.disposal) ...[
            const SizedBox(height: KanzSpace.s12),
            DisposalGuideCard(
              guidance: guidance,
              item: items.where((i) => i.id == guidance.itemId).firstOrNull,
              format: format,
              disposed: disposed.contains(guidance.itemId),
              onMark: () => onMarkDisposed(guidance.itemId),
            ),
          ],
        ],
      ),
    );
  }
}

/// One hazardous item's disposal: the headline in Fraunces, the steps, the
/// never-list in danger ink, and "Mark as disposed".
class DisposalGuideCard extends StatelessWidget {
  const DisposalGuideCard({
    super.key,
    required this.guidance,
    required this.item,
    required this.format,
    required this.disposed,
    required this.onMark,
  });

  final DisposalGuidance guidance;
  final Item? item;
  final ResultsFormat format;
  final bool disposed;
  final Future<void> Function() onMark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = this.item;
    return KanzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item != null) ...[
            Row(
              children: [
                MaterialDot(item.category.id),
                const SizedBox(width: KanzSpace.s8),
                Expanded(child: MonoLabel(format.ai(item.name), maxLines: 2)),
              ],
            ),
            const SizedBox(height: KanzSpace.s8),
          ],
          Text(
            format.ai(guidance.headline),
            style: context.textStyles.headlineSmall,
          ),
          const SizedBox(height: KanzSpace.s20),
          GuideList(
            title: l10n.resultsDisposalSteps,
            lines: format.aiLines(guidance.steps),
            style: GuideListStyle.numbered,
          ),
          if (guidance.never.isNotEmpty) ...[
            const SizedBox(height: KanzSpace.s20),
            GuideList(
              title: l10n.resultsDisposalNever,
              lines: format.aiLines(guidance.never),
              style: GuideListStyle.donts,
              danger: true,
            ),
          ],
          const SizedBox(height: KanzSpace.s16),
          MarkButton(
            label: l10n.resultsMarkDisposed,
            doneLabel: l10n.resultsMarkedDisposed,
            done: disposed,
            onMark: onMark,
          ),
        ],
      ),
    );
  }
}

/// A hazard named with its glyph, in a hairline tag.
class HazardTag extends StatelessWidget {
  const HazardTag({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s8,
        KanzSpace.s4,
        KanzSpace.s12,
        KanzSpace.s4,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: KanzRadii.tagAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c.danger),
          const SizedBox(width: KanzSpace.s8),
          Flexible(child: Text(label, style: context.textStyles.labelMedium)),
        ],
      ),
    );
  }
}
