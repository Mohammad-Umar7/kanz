import 'package:flutter/material.dart';

import '../../core/data/db/database.dart' show ImpactKind;
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/impact_providers.dart';
import '../../l10n/l10n.dart';

/// The three facts in big numerals: items kept out of the bin (the hero),
/// then projects finished and the day streak side by side, with today's
/// status under the streak.
class ImpactNumbers extends StatelessWidget {
  const ImpactNumbers({super.key, required this.summary});

  final ImpactSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatNumeral(
          value: '${summary.totalItems}',
          label: l10n.impactItemsLabel,
        ),
        const SizedBox(height: KanzSpace.s20),
        Divider(height: 1, color: c.line),
        const SizedBox(height: KanzSpace.s20),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: StatNumeral(
                    value: '${summary.projectsCompleted}',
                    label: l10n.impactProjectsLabel,
                  ),
                ),
              ),
              VerticalDivider(width: KanzSpace.s32, color: c.line),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatNumeral(
                      value: '${summary.streakDays}',
                      label: l10n.impactStreakLabel,
                    ),
                    if (summary.activeToday) ...[
                      const SizedBox(height: KanzSpace.s8),
                      Row(
                        children: [
                          Icon(
                            KanzIcons.checkCircle,
                            size: 14,
                            color: c.positive,
                          ),
                          const SizedBox(width: KanzSpace.s4),
                          Flexible(
                            child: Text(
                              l10n.impactActiveToday,
                              style: context.textStyles.labelSmall?.copyWith(
                                color: c.positive,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Nothing logged today: one line on keeping (or starting) the streak and
/// the way to the scan action.
class ImpactNudge extends StatelessWidget {
  const ImpactNudge({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s16,
        KanzSpace.s16,
        KanzSpace.s16,
        KanzSpace.s8,
      ),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: KanzRadii.inputAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Icon(KanzIcons.calendar, size: 20, color: c.ink),
              ),
              const SizedBox(width: KanzSpace.s12),
              Expanded(
                child: Text(message, style: context.textStyles.bodyMedium),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: KanzSpace.s24),
            child: KanzButton.tertiary(
              label: actionLabel,
              icon: KanzIcons.scan,
              onPressed: onAction,
            ),
          ),
        ],
      ),
    );
  }
}

/// Items per material as bars in material colors, longest first.
class ImpactByMaterial extends StatelessWidget {
  const ImpactByMaterial({
    super.key,
    required this.summary,
    required this.vocab,
  });

  final ImpactSummary summary;
  final Vocab vocab;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return MaterialBars(
      shares: [
        for (final entry in summary.itemsByMaterial.entries)
          if (entry.value > 0)
            MaterialShare(
              categoryId: entry.key.id,
              label: vocab.material(entry.key).label.forLocale(locale),
              value: entry.value.toDouble(),
              valueLabel: '${entry.value}',
            ),
      ],
    );
  }
}

/// How the items left the home: upcycled, recycled, donated, disposed of
/// safely, as a spec-sheet grid of mono labels over numerals.
class ImpactByPath extends StatelessWidget {
  const ImpactByPath({super.key, required this.summary});

  final ImpactSummary summary;

  static const _order = [
    ImpactKind.upcycled,
    ImpactKind.recycled,
    ImpactKind.donated,
    ImpactKind.disposed,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    String label(ImpactKind kind) => switch (kind) {
      ImpactKind.upcycled => l10n.impactKindUpcycled,
      ImpactKind.recycled => l10n.impactKindRecycled,
      ImpactKind.donated => l10n.impactKindDonated,
      ImpactKind.disposed => l10n.impactKindDisposed,
    };
    IconData icon(ImpactKind kind) => switch (kind) {
      ImpactKind.upcycled => KanzIcons.upcycle,
      ImpactKind.recycled => KanzIcons.recycle,
      ImpactKind.donated => KanzIcons.donate,
      ImpactKind.disposed => KanzIcons.safety,
    };
    return DataGrid(
      entries: [
        for (final kind in _order)
          DataGridEntry(
            label(kind),
            child: Semantics(
              label: l10n.impactItemCount(summary.itemsByKind[kind] ?? 0),
              excludeSemantics: true,
              child: Row(
                children: [
                  Icon(icon(kind), size: 18, color: c.inkSecondary),
                  const SizedBox(width: KanzSpace.s8),
                  Text(
                    '${summary.itemsByKind[kind] ?? 0}',
                    style: context.kanzType.numeralSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Mass kept from landfill and CO2e avoided, set apart on a sunken panel
/// and always labelled as an estimate with the disclaimer.
class ImpactEstimate extends StatelessWidget {
  const ImpactEstimate({super.key, required this.summary});

  final ImpactSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    Widget row(String value, String label) => MergeSemantics(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: KanzSpace.s12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: KanzSpace.s12,
          runSpacing: KanzSpace.s2,
          children: [
            Text(value, style: t.titleLarge),
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 2),
              child: Text(label, style: t.bodySmall),
            ),
          ],
        ),
      ),
    );
    return Container(
      padding: const EdgeInsetsDirectional.all(KanzSpace.s16),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: KanzRadii.inputAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(l10n.impactEstimateLabel),
          if (summary.estimatedMassKg > 0)
            row(formatKg(l10n, summary.estimatedMassKg), l10n.impactMassLabel),
          if (summary.co2eKgEstimate > 0)
            row(formatCo2e(l10n, summary.co2eKgEstimate), l10n.impactCo2Label),
          const SizedBox(height: KanzSpace.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Icon(KanzIcons.info, size: 14, color: c.inkSecondary),
              ),
              const SizedBox(width: KanzSpace.s4),
              Expanded(
                child: Text(l10n.commonCo2eDisclaimer, style: t.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Placeholders shaped like the numbers and bars, under a live line.
class ImpactSkeleton extends StatelessWidget {
  const ImpactSkeleton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            children: [
              SizedBox.square(
                dimension: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: c.inkSecondary,
                ),
              ),
              const SizedBox(width: KanzSpace.s8),
              Flexible(child: MonoLabel(label)),
            ],
          ),
        ),
        const SizedBox(height: KanzSpace.s24),
        const Skeleton(width: 72, height: 52),
        const SizedBox(height: KanzSpace.s8),
        const Skeleton(width: 160, height: 12),
        const SizedBox(height: KanzSpace.s20),
        Divider(height: 1, color: c.line),
        const SizedBox(height: KanzSpace.s20),
        const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 48, height: 52),
                  SizedBox(height: KanzSpace.s8),
                  Skeleton(width: 110, height: 12),
                ],
              ),
            ),
            SizedBox(width: KanzSpace.s32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 48, height: 52),
                  SizedBox(height: KanzSpace.s8),
                  Skeleton(width: 90, height: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: KanzSpace.s40),
        for (final w in const [1.0, 0.6, 0.35]) ...[
          const Skeleton(width: 120, height: 12),
          const SizedBox(height: KanzSpace.s8),
          SizedBox(
            width: double.infinity,
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: w,
              child: const Skeleton(height: 6),
            ),
          ),
          const SizedBox(height: KanzSpace.s16),
        ],
      ],
    );
  }
}

/// Under the new-user empty state: what the tab counts, so the first scan
/// has a clear payoff.
class ImpactWhatCounts extends StatelessWidget {
  const ImpactWhatCounts({super.key, required this.title, required this.lines});

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
          Divider(height: 1, color: c.line),
          const SizedBox(height: KanzSpace.s24),
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
