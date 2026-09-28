import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/history_providers.dart';
import '../../core/state/impact_providers.dart';
import '../../l10n/l10n.dart';
import 'impact_sections.dart';

/// Impact tab (`/impact`): what the user has kept out of the bin, all
/// counted from their own scans, marked items and finished projects on this
/// phone. The CO2e figure is an estimate and is always shown as one.
class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  void _scan(BuildContext context) =>
      context.push(AppRoutes.scan(ScanMode.camera));

  void _retry(WidgetRef ref) {
    ref
      ..invalidate(impactEventsProvider)
      ..invalidate(projectsProvider)
      ..invalidate(scanHistoryProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    final impact = ref.watch(impactProvider);
    final vocab = ref.watch(vocabProvider);

    final header = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s12,
        KanzSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.impactTitle, style: t.headlineLarge),
          ),
          const SizedBox(height: KanzSpace.s8),
          Text(
            l10n.impactIntro,
            style: t.bodyMedium?.copyWith(color: c.inkSecondary),
          ),
        ],
      ),
    );

    final List<Widget> body = switch (impact) {
      AsyncData(:final value) => _content(context, value, vocab),
      AsyncError() => [
        ErrorState(
          title: l10n.impactErrorTitle,
          message: l10n.commonErrorGeneric,
          retryLabel: l10n.commonRetry,
          onRetry: () => _retry(ref),
        ),
      ],
      _ => [
        Padding(
          padding: KanzSpace.page,
          child: ImpactSkeleton(label: l10n.impactLoading),
        ),
      ],
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s48),
          children: [
            header,
            const SizedBox(height: KanzSpace.s32),
            ...body,
          ],
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    ImpactSummary summary,
    Vocab vocab,
  ) {
    final l10n = context.l10n;
    final isNew =
        summary.totalItems == 0 &&
        summary.projectsCompleted == 0 &&
        summary.streakDays == 0;
    if (isNew) {
      return [
        EmptyState(
          icon: KanzIcons.leaf,
          title: l10n.impactEmptyTitle,
          message: l10n.impactEmptyMessage,
          actionLabel: l10n.impactScanAction,
          onAction: () => _scan(context),
        ),
        ImpactWhatCounts(
          title: l10n.impactHowTitle,
          lines: [
            (KanzIcons.recycle, l10n.impactHowItems),
            (KanzIcons.upcycle, l10n.impactHowProjects),
            (KanzIcons.calendar, l10n.impactHowStreak),
          ],
        ),
      ];
    }

    Widget section(String title) => Padding(
      padding: const EdgeInsetsDirectional.only(
        top: KanzSpace.s40,
        bottom: KanzSpace.s16,
      ),
      child: SectionHeader(title: title, padding: EdgeInsetsDirectional.zero),
    );

    final hasItems = summary.totalItems > 0;
    final hasEstimate =
        summary.estimatedMassKg > 0 || summary.co2eKgEstimate > 0;
    return [
      Padding(
        padding: KanzSpace.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeUp(child: ImpactNumbers(summary: summary)),
            if (!summary.activeToday) ...[
              const SizedBox(height: KanzSpace.s24),
              ImpactNudge(
                message: summary.streakDays > 0
                    ? l10n.impactKeepStreak
                    : l10n.impactStartStreak,
                actionLabel: l10n.impactScanAction,
                onAction: () => _scan(context),
              ),
            ],
            section(l10n.impactByMaterial),
            if (hasItems)
              FadeUp.staggered(
                index: 1,
                child: ImpactByMaterial(summary: summary, vocab: vocab),
              )
            else
              Text(
                l10n.impactNoItemsYet,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.kanzColors.inkSecondary,
                ),
              ),
            if (hasItems) ...[
              section(l10n.impactByPath),
              FadeUp.staggered(index: 2, child: ImpactByPath(summary: summary)),
            ],
            if (hasEstimate) ...[
              const SizedBox(height: KanzSpace.s32),
              FadeUp.staggered(
                index: 3,
                child: ImpactEstimate(summary: summary),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}
