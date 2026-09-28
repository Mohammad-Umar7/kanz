import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/router.dart';
import '../../core/data/db/database.dart' show ProjectStatus;
import '../../core/design/design.dart';
import '../../core/state/history_providers.dart';
import '../../core/state/impact_providers.dart';
import '../../l10n/l10n.dart';
import 'home_sections.dart';

/// Home tab (`/`): the scan action first, then whatever the user is in the
/// middle of (a project to resume, recent scans, a glance at their impact).
/// On first run the recent scans give way to a short guide to what to
/// photograph.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.today});

  /// The date in the eyebrow; defaults to now (tests pin it).
  final DateTime? today;

  /// Recent scans shown on the strip; the rest are in History.
  static const recentLimit = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scans = ref.watch(scanHistoryProvider);
    final projects = ref.watch(projectsProvider);
    final impact = ref.watch(impactProvider);

    final scanList = scans.value;
    final activeProject = projects.value
        ?.where((p) => p.status == ProjectStatus.inProgress)
        .firstOrNull;
    final summary = impact.value;
    final hasImpact =
        summary != null &&
        (summary.totalItems > 0 ||
            summary.streakDays > 0 ||
            summary.projectsCompleted > 0);

    final Widget recent = switch (scans) {
      AsyncValue(:final value?) when value.isEmpty => const FirstRunGuide(),
      AsyncValue(:final value?) => RecentScans(
        scans: value.take(recentLimit).toList(),
        onSeeAll: () => context.push(AppRoutes.history),
        onOpen: (scan) => context.push(AppRoutes.results(scan.id)),
      ),
      AsyncError() => ErrorState(
        title: l10n.homeErrorTitle,
        message: l10n.homeErrorMessage,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(scanHistoryProvider),
      ),
      _ => RecentScansSkeleton(label: l10n.homeLoadingRecent),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _TopBar(
                onHistory: () => context.push(AppRoutes.history),
                onSettings: () => context.push(AppRoutes.settings),
              ),
            ),
            SliverToBoxAdapter(child: _Intro(today: today ?? DateTime.now())),
            const SliverToBoxAdapter(child: SizedBox(height: KanzSpace.s24)),
            SliverToBoxAdapter(
              child: _Actions(
                onScan: () => context.push(AppRoutes.scan(ScanMode.camera)),
                onGallery: () => context.push(AppRoutes.scan(ScanMode.gallery)),
                onDescribe: () => context.push(AppRoutes.scan(ScanMode.text)),
              ),
            ),
            if (activeProject != null)
              SliverToBoxAdapter(
                child: ResumeCard(
                  project: activeProject,
                  scan: scanList
                      ?.where((s) => s.id == activeProject.scanId)
                      .firstOrNull,
                  onTap: () => context.push(
                    AppRoutes.tutorial(
                      activeProject.scanId,
                      activeProject.ideaId,
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: KanzSpace.s40),
                child: recent,
              ),
            ),
            if (hasImpact)
              SliverToBoxAdapter(
                child: ImpactGlance(
                  summary: summary,
                  onTap: () => context.go(AppRoutes.impact),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: KanzSpace.s40 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onHistory, required this.onSettings});

  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.gutter,
          0,
          KanzSpace.s8,
          0,
        ),
        child: Row(
          children: [
            const BrandLockup(markSize: 28),
            const Spacer(),
            KanzIconButton(
              icon: KanzIcons.history,
              semanticsLabel: l10n.homeHistory,
              onPressed: onHistory,
            ),
            KanzIconButton(
              icon: KanzIcons.settings,
              semanticsLabel: l10n.homeSettings,
              onPressed: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    final weekday = DateFormat.EEEE(l10n.localeName).format(today);
    final month = DateFormat.MMMM(l10n.localeName).format(today);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s16,
        KanzSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel('$weekday ${today.day} $month'),
          const SizedBox(height: KanzSpace.s12),
          Semantics(
            header: true,
            child: Text(l10n.homeHeadline, style: t.displaySmall),
          ),
          const SizedBox(height: KanzSpace.s12),
          Text(
            l10n.homeLead,
            style: t.bodyLarge?.copyWith(color: c.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onScan,
    required this.onGallery,
    required this.onDescribe,
  });

  final VoidCallback onScan;
  final VoidCallback onGallery;
  final VoidCallback onDescribe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gallery = KanzButton.secondary(
      label: l10n.homeGallery,
      icon: KanzIcons.gallery,
      onPressed: onGallery,
    );
    final describe = KanzButton.secondary(
      label: l10n.homeDescribe,
      icon: KanzIcons.describe,
      onPressed: onDescribe,
    );
    // Large text: the two labels no longer fit side by side, so they stack
    // at full width instead of squeezing into two-line buttons.
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    return Padding(
      padding: KanzSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScanActionButton(
            label: l10n.homeScan,
            semanticsLabel: l10n.homeScan,
            icon: KanzIcons.camera,
            size: 64,
            onPressed: onScan,
          ),
          const SizedBox(height: KanzSpace.s8),
          // The two other ways in: outlined, half width each, under the
          // scan action, on the same edges as everything else on the page.
          if (largeText)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: KanzSpace.s8,
              children: [gallery, describe],
            )
          else
            Row(
              spacing: KanzSpace.s8,
              children: [
                Expanded(child: gallery),
                Expanded(child: describe),
              ],
            ),
        ],
      ),
    );
  }
}
