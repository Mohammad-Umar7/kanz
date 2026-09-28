import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../l10n/l10n.dart';

/// While the Swap Advisor works: a live line naming what it is looking at,
/// and two placeholder cards shaped like [SwapCard].
class SwapsLoading extends StatelessWidget {
  const SwapsLoading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2),
                  child: SizedBox.square(
                    dimension: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: c.inkSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: KanzSpace.s8),
                Expanded(child: MonoLabel(label)),
              ],
            ),
          ),
          const SizedBox(height: KanzSpace.s16),
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: KanzSpace.s12),
            KanzCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Skeleton(width: 8, height: 8),
                      SizedBox(width: KanzSpace.s8),
                      Skeleton(width: 88, height: 10),
                    ],
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  const Skeleton(width: 64, height: 10),
                  const SizedBox(height: KanzSpace.s8),
                  FractionallySizedBox(
                    widthFactor: i.isEven ? 0.55 : 0.45,
                    child: const Skeleton(height: 16),
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  const Skeleton(width: 48, height: 10),
                  const SizedBox(height: KanzSpace.s8),
                  FractionallySizedBox(
                    widthFactor: i.isEven ? 0.8 : 0.7,
                    child: const Skeleton(height: 22),
                  ),
                  const SizedBox(height: KanzSpace.s16),
                  Skeleton.text(lines: 2),
                  const SizedBox(height: KanzSpace.s16),
                  Divider(height: 1, color: c.line),
                  const SizedBox(height: KanzSpace.s12),
                  const Skeleton(width: 150, height: 10),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The calm lead-in above the cards when the advisor read the history:
/// "You scanned 6 plastic bottles this month."
class SwapsInsight extends StatelessWidget {
  const SwapsInsight({super.key, required this.label, required this.insight});

  final String label;
  final String insight;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: KanzSpace.page,
      child: Container(
        padding: const EdgeInsetsDirectional.only(start: KanzSpace.s16),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: c.lineStrong, width: 2),
          ),
        ),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoLabel(label),
              const SizedBox(height: KanzSpace.s4),
              Text(insight, style: context.textStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

/// One suggested swap: the [SwapCard] and, under it, the knowledge
/// documents it was grounded in.
class SwapEntry extends StatelessWidget {
  const SwapEntry({super.key, required this.swap, required this.vocab});

  final Swap swap;
  final Vocab vocab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final matched = swap.matchedInput?.trim();
    final badge = swap.fromHistory
        ? l10n.swapsFromScans
        : (matched != null && matched.isNotEmpty
              ? matched
              : vocab.material(swap.category).label.forLocale(locale));
    final impact = swap.impactNote?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwapCard(
          fromLabel: l10n.swapsInsteadOf,
          from: swap.fromItem,
          toLabel: l10n.swapsTry,
          to: swap.toItem,
          why: impact == null || impact.isEmpty
              ? swap.why
              : '${swap.why} $impact',
          tipLabel: l10n.swapsTip,
          tip: swap.tip.trim().isEmpty ? null : swap.tip,
          meta: [
            l10n.swapsEffort(levelLabel(l10n, swap.effort)),
            l10n.swapsCost(levelLabel(l10n, swap.cost)),
          ],
          categoryId: swap.category.id,
          badge: badge,
        ),
        if (swap.sources.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.s16,
              KanzSpace.s12,
              KanzSpace.s16,
              0,
            ),
            child: SourceChips(
              title: l10n.swapsSources,
              sources: [for (final s in swap.sources) s.title],
            ),
          ),
      ],
    );
  }
}

/// Before the first request: what the tab will give back, so the empty
/// space under the form teaches the next step instead of sitting blank.
class SwapsHowItWorks extends StatelessWidget {
  const SwapsHowItWorks({super.key, required this.title, required this.lines});

  final String title;
  final List<(IconData, String)> lines;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(title),
          const SizedBox(height: KanzSpace.s12),
          for (final (icon, text) in lines)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 2),
                    child: Icon(icon, size: 18, color: c.inkSecondary),
                  ),
                  const SizedBox(width: KanzSpace.s12),
                  Expanded(
                    child: Text(
                      text,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
