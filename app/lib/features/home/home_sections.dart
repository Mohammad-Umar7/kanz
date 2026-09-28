/// The sections of the Home tab below the scan actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/history_providers.dart';
import '../../core/state/impact_providers.dart';
import '../../l10n/l10n.dart';
import '../history/scan_thumbnail.dart';

/// The project the user was last working on, with its progress.
class ResumeCard extends StatelessWidget {
  const ResumeCard({
    super.key,
    required this.project,
    required this.scan,
    required this.onTap,
  });

  final ProjectRecord project;
  final ScanSummary? scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final p = project;
    final started = p.totalSteps > 0;
    final step = p.currentStep.clamp(1, p.totalSteps < 1 ? 1 : p.totalSteps);
    final progress = started
        ? l10n.homeResumeProgress(step, p.totalSteps)
        : l10n.homeResumeNotStarted;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s40,
        KanzSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonoLabel(l10n.homeResumeEyebrow),
          const SizedBox(height: KanzSpace.s12),
          FadeUp(
            child: Semantics(
              button: true,
              label: '${l10n.homeResumeEyebrow}: ${p.title}, $progress',
              excludeSemantics: true,
              onTap: onTap,
              child: KanzCard(
                onTap: onTap,
                padding: const EdgeInsets.all(KanzSpace.s12),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 88,
                      child: scan == null
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: c.surfaceSunken,
                                borderRadius: KanzRadii.inputAll,
                              ),
                              child: Icon(
                                KanzIcons.upcycle,
                                color: c.inkSecondary,
                              ),
                            )
                          : ScanThumbnail(scan: scan!),
                    ),
                    const SizedBox(width: KanzSpace.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OwnDirectionText(p.title, style: t.headlineSmall),
                          const SizedBox(height: KanzSpace.s8),
                          if (started) ...[
                            StepProgressBar(
                              total: p.totalSteps,
                              current: step - 1,
                              completed: {
                                for (final s in p.completedSteps) s - 1,
                              },
                              semanticsLabel: progress,
                            ),
                            const SizedBox(height: KanzSpace.s8),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: Text(progress, style: t.bodySmall),
                              ),
                              const SizedBox(width: KanzSpace.s8),
                              Text(l10n.homeResume, style: t.labelLarge),
                              const SizedBox(width: KanzSpace.s4),
                              Icon(KanzIcons.forward, size: 18, color: c.ink),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal strip of recent scans: photo (or description) tiles with the
/// item, its material and when it was scanned.
class RecentScans extends ConsumerWidget {
  const RecentScans({
    super.key,
    required this.scans,
    required this.onSeeAll,
    required this.onOpen,
  });

  final List<ScanSummary> scans;
  final VoidCallback onSeeAll;
  final ValueChanged<ScanSummary> onOpen;

  static const tileWidth = 148.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final vocab = ref.watch(vocabProvider);
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: KanzSpace.gutter,
            end: KanzSpace.s8,
          ),
          child: Row(
            children: [
              // A mono eyebrow like every other Home section.
              Expanded(
                child: Semantics(
                  header: true,
                  child: MonoLabel(l10n.homeRecentTitle),
                ),
              ),
              KanzButton.tertiary(label: l10n.homeSeeAll, onPressed: onSeeAll),
            ],
          ),
        ),
        const SizedBox(height: KanzSpace.s8),
        // A row sized by its tallest tile, so long names and large text
        // grow the strip instead of being cut.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: KanzSpace.page,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, scan) in scans.indexed) ...[
                  if (i > 0) const SizedBox(width: KanzSpace.s12),
                  FadeUp.staggered(
                    index: i,
                    child: _RecentTile(
                      scan: scan,
                      material: scanMaterial(vocab, locale, scan),
                      onTap: () => onOpen(scan),
                    ),
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

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.scan,
    required this.material,
    required this.onTap,
  });

  final ScanSummary scan;
  final String? material;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final title = scanTitle(l10n, scan);
    final when = formatRelative(l10n, scan.createdAt);
    return Semantics(
      button: true,
      label: formatList(l10n, [title, ?material, when]),
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox(
        width: RecentScans.tileWidth,
        child: InkWell(
          onTap: onTap,
          borderRadius: KanzRadii.inputAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: ScanThumbnail(scan: scan, large: true),
              ),
              const SizedBox(height: KanzSpace.s12),
              OwnDirectionText(title, style: t.titleSmall),
              const SizedBox(height: KanzSpace.s4),
              if (scan.primaryCategory case final category?) ...[
                MaterialTag(categoryId: category.id, label: material!),
                const SizedBox(height: KanzSpace.s2),
              ],
              Text(when, style: t.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stand-in for the strip while the saved scans load.
class RecentScansSkeleton extends StatelessWidget {
  const RecentScansSkeleton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: KanzSpace.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoLabel(context.l10n.homeRecentTitle),
                const SizedBox(height: KanzSpace.s8),
                Text(label, style: context.textStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: KanzSpace.s20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: KanzSpace.page,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: KanzSpace.s12),
                  SizedBox(
                    width: RecentScans.tileWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(
                          height: RecentScans.tileWidth * 5 / 4,
                          borderRadius: KanzRadii.inputAll,
                        ),
                        const SizedBox(height: KanzSpace.s12),
                        Skeleton.text(lines: 2, lineHeight: 12),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// First run: what to photograph, as a specimen list with material dots,
/// and three tips for a photo Kanz can read.
class FirstRunGuide extends ConsumerWidget {
  const FirstRunGuide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    final vocab = ref.watch(vocabProvider);
    final locale = Localizations.localeOf(context);
    final examples = [
      (MaterialCategory.glass, l10n.homeGuideGlass),
      (MaterialCategory.textile, l10n.homeGuideTextile),
      (MaterialCategory.paper, l10n.homeGuidePaper),
      (MaterialCategory.metal, l10n.homeGuideMetal),
      (MaterialCategory.hazardous, l10n.homeGuideHazardous),
    ];
    final tips = [l10n.homeTip1, l10n.homeTip2, l10n.homeTip3];
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonoLabel(l10n.homeGuideEyebrow),
          const SizedBox(height: KanzSpace.s8),
          Semantics(
            header: true,
            child: Text(l10n.homeGuideTitle, style: t.headlineSmall),
          ),
          const SizedBox(height: KanzSpace.s16),
          for (final (i, (category, examplesText)) in examples.indexed)
            FadeUp.staggered(
              index: i,
              child: MergeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: KanzSpace.s12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.line)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: KanzSpace.s4),
                        child: MaterialDot(category.id, size: 10),
                      ),
                      const SizedBox(width: KanzSpace.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MonoLabel(
                              vocab.material(category).label.forLocale(locale),
                            ),
                            const SizedBox(height: KanzSpace.s2),
                            Text(examplesText, style: t.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Divider(height: 1, color: c.line),
          const SizedBox(height: KanzSpace.s32),
          MonoLabel(l10n.homeTipsTitle),
          const SizedBox(height: KanzSpace.s12),
          for (final (i, tip) in tips.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: KanzSpace.s12),
              child: MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '0${i + 1}',
                        style: context.kanzType.dataStrong,
                        textDirection: TextDirection.ltr,
                        textAlign: context.isRtl
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ),
                    Expanded(child: Text(tip, style: t.bodyMedium)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Items kept out of the bin and the streak, as big numerals; opens Impact.
class ImpactGlance extends StatelessWidget {
  const ImpactGlance({super.key, required this.summary, required this.onTap});

  final ImpactSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final type = context.kanzType;
    final second = summary.streakDays > 0
        ? (summary.streakDays, l10n.homeImpactStreak(summary.streakDays))
        : (
            summary.projectsCompleted,
            l10n.homeImpactProjects(summary.projectsCompleted),
          );
    final stats = [
      (summary.totalItems, l10n.homeImpactItems(summary.totalItems)),
      second,
    ];
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s40,
        KanzSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonoLabel(l10n.homeImpactTitle),
          const SizedBox(height: KanzSpace.s12),
          Semantics(
            button: true,
            label: formatList(l10n, [
              l10n.homeImpactOpen,
              for (final (n, label) in stats) '$n $label',
            ]),
            excludeSemantics: true,
            onTap: onTap,
            child: KanzCard(
              onTap: onTap,
              padding: const EdgeInsetsDirectional.fromSTEB(
                KanzSpace.s20,
                KanzSpace.s16,
                KanzSpace.s12,
                KanzSpace.s20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, (n, label)) in stats.indexed) ...[
                    if (i > 0) const SizedBox(width: KanzSpace.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$n',
                            style: type.numeral,
                            textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(height: KanzSpace.s4),
                          Text(label, style: t.bodySmall),
                        ],
                      ),
                    ),
                  ],
                  Icon(
                    KanzIcons.chevronForward,
                    size: 18,
                    color: c.inkSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
