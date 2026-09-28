import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/router.dart';
import '../../core/data/db/database.dart' show ProjectStatus;
import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/history_providers.dart';
import '../../l10n/l10n.dart';
import '../shell/page_chrome.dart';
import 'scan_thumbnail.dart';

/// History and My Projects (`/history`): every scan grouped by day (photos
/// open offline, swipe or the row menu to delete), and every project with
/// its progress.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.initialTab = 0});

  /// 0 scans, 1 projects.
  final int initialTab;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late int _tab = widget.initialTab;

  /// Rows dismissed by a swipe, hidden until the database confirms.
  final Set<String> _removed = {};

  Future<void> _delete(ScanSummary scan) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _removed.add(scan.id));
    try {
      await ref.read(historyActionsProvider).deleteScan(scan.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.historyDeleted)));
    } on Object {
      if (mounted) setState(() => _removed.remove(scan.id));
      messenger.showSnackBar(SnackBar(content: Text(l10n.historyDeleteFailed)));
    }
  }

  Future<void> _confirmAndDelete(ScanSummary scan) async {
    if (await confirmDeleteScan(context) && mounted) await _delete(scan);
  }

  Future<void> _showMenu(ScanSummary scan) async {
    final l10n = context.l10n;
    final choice = await showKanzSheet<_RowAction>(
      context: context,
      builder: (sheetContext) => KanzSheet(
        title: scanTitle(l10n, scan),
        subtitle: formatRelative(l10n, scan.createdAt),
        child: Padding(
          padding: const EdgeInsets.only(bottom: KanzSpace.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetAction(
                icon: KanzIcons.forward,
                label: l10n.historyOpenScan,
                onTap: () => Navigator.pop(sheetContext, _RowAction.open),
              ),
              _SheetAction(
                icon: KanzIcons.delete,
                label: l10n.historyDelete,
                danger: true,
                onTap: () => Navigator.pop(sheetContext, _RowAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case _RowAction.open:
        unawaited(context.push(AppRoutes.results(scan.id)));
      case _RowAction.delete:
        await _confirmAndDelete(scan);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scans = ref.watch(scanHistoryProvider);
    final projects = ref.watch(projectsProvider);
    final visibleScans = scans.whenData(
      (list) => [
        for (final s in list)
          if (!_removed.contains(s.id)) s,
      ],
    );
    final scanList = visibleScans.value;
    final projectList = projects.value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageTopBar(),
            PageTitle(title: l10n.historyTitle),
            const SizedBox(height: KanzSpace.s20),
            Padding(
              padding: KanzSpace.page,
              child: SegmentedTabs(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
                tabs: [
                  SegmentedTab(
                    label: l10n.historyTabScans,
                    count: scanList == null || scanList.isEmpty
                        ? null
                        : '${scanList.length}',
                  ),
                  SegmentedTab(
                    label: l10n.historyTabProjects,
                    count: projectList == null || projectList.isEmpty
                        ? null
                        : '${projectList.length}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: KanzSpace.s8),
            Expanded(
              child: AnimatedSwitcher(
                duration: KanzMotion.of(context, KanzMotion.medium),
                switchInCurve: KanzMotion.enter,
                switchOutCurve: KanzMotion.exit,
                child: _tab == 0
                    ? _ScansTab(
                        key: const ValueKey('scans'),
                        scans: visibleScans,
                        onOpen: (s) => context.push(AppRoutes.results(s.id)),
                        onMenu: _showMenu,
                        onDismissed: _delete,
                        onRetry: () => ref.invalidate(scanHistoryProvider),
                      )
                    : _ProjectsTab(
                        key: const ValueKey('projects'),
                        projects: projects,
                        scans: scanList ?? const [],
                        onRetry: () => ref.invalidate(projectsProvider),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RowAction { open, delete }

/// One quiet action row in the scan menu; destructive rows use the danger
/// color for their glyph and label.
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final color = danger ? c.danger : c.ink;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: KanzSpace.page,
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: KanzSpace.s16),
              Expanded(
                child: Text(
                  label,
                  style: context.textStyles.bodyLarge?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks before a scan is deleted. True when the user confirmed.
Future<bool> confirmDeleteScan(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.historyDeleteTitle),
      content: Text(l10n.historyDeleteBody),
      actionsPadding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s16,
        0,
        KanzSpace.s16,
        KanzSpace.s16,
      ),
      actions: [
        KanzButton.tertiary(
          label: l10n.commonCancel,
          onPressed: () => Navigator.pop(dialogContext, false),
        ),
        KanzButton.destructive(
          label: l10n.historyDeleteConfirm,
          icon: KanzIcons.delete,
          onPressed: () => Navigator.pop(dialogContext, true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// "Today", "Yesterday", then "Monday 22 September" (with the year when it
/// is not this year). Day numbers stay in Western digits.
String historyDayLabel(AppLocalizations l10n, DateTime day, DateTime now) {
  final today = DateTime.utc(now.year, now.month, now.day);
  final that = DateTime.utc(day.year, day.month, day.day);
  final days = today.difference(that).inDays;
  if (days == 0) return l10n.historyToday;
  if (days == 1) return l10n.commonYesterday;
  final weekday = DateFormat.EEEE(l10n.localeName).format(day);
  final month = DateFormat.MMMM(l10n.localeName).format(day);
  final year = day.year == now.year ? '' : ' ${day.year}';
  return '$weekday ${day.day} $month$year';
}

/// "12 Sep 2026", localized month, Western digits.
String shortDate(AppLocalizations l10n, DateTime time) {
  final month = DateFormat.MMM(l10n.localeName).format(time);
  return '${time.day} $month ${time.year}';
}

class _ScansTab extends StatelessWidget {
  const _ScansTab({
    super.key,
    required this.scans,
    required this.onOpen,
    required this.onMenu,
    required this.onDismissed,
    required this.onRetry,
  });

  final AsyncValue<List<ScanSummary>> scans;
  final ValueChanged<ScanSummary> onOpen;
  final ValueChanged<ScanSummary> onMenu;
  final ValueChanged<ScanSummary> onDismissed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (scans) {
      AsyncValue(:final value?) when value.isEmpty => _Scrolling(
        child: EmptyState(
          icon: KanzIcons.camera,
          title: l10n.historyScansEmptyTitle,
          message: l10n.historyScansEmptyBody,
          actionLabel: l10n.homeScan,
          onAction: () => context.push(AppRoutes.scan(ScanMode.camera)),
        ),
      ),
      AsyncValue(:final value?) => _ScanList(
        scans: value,
        onOpen: onOpen,
        onMenu: onMenu,
        onDismissed: onDismissed,
      ),
      AsyncError() => _Scrolling(
        child: ErrorState(
          title: l10n.historyErrorTitle,
          message: l10n.historyErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: onRetry,
        ),
      ),
      _ => _LoadingRows(label: l10n.historyLoading),
    };
  }
}

class _Scrolling extends StatelessWidget {
  const _Scrolling({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: KanzSpace.s32),
    child: child,
  );
}

class _ScanList extends ConsumerWidget {
  const _ScanList({
    required this.scans,
    required this.onOpen,
    required this.onMenu,
    required this.onDismissed,
  });

  final List<ScanSummary> scans;
  final ValueChanged<ScanSummary> onOpen;
  final ValueChanged<ScanSummary> onMenu;
  final ValueChanged<ScanSummary> onDismissed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final vocab = ref.watch(vocabProvider);
    final locale = Localizations.localeOf(context);

    final children = <Widget>[];
    String? currentDay;
    for (final scan in scans) {
      final day = historyDayLabel(l10n, scan.createdAt, now);
      if (day != currentDay) {
        children.add(
          SectionLabel(
            day,
            top: currentDay == null ? KanzSpace.s16 : KanzSpace.s24,
          ),
        );
        currentDay = day;
      }
      children.add(
        _ScanRow(
          key: ValueKey(scan.id),
          scan: scan,
          material: scanMaterial(vocab, locale, scan),
          onOpen: () => onOpen(scan),
          onMenu: () => onMenu(scan),
          onDismissed: () => onDismissed(scan),
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + KanzSpace.s32,
      ),
      children: children,
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({
    super.key,
    required this.scan,
    required this.material,
    required this.onOpen,
    required this.onMenu,
    required this.onDismissed,
  });

  final ScanSummary scan;
  final String? material;
  final VoidCallback onOpen;
  final VoidCallback onMenu;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final title = scanTitle(l10n, scan);
    final time = formatClock(scan.createdAt);
    final count = scan.itemCount > 1
        ? l10n.homeItemCount(scan.itemCount)
        : null;
    final label = [title, ?material, ?count, time].join(', ');

    final row = Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onOpen,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.historyDelete): () async {
          if (await confirmDeleteScan(context)) onDismissed();
        },
      },
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s8,
            KanzSpace.s8,
            KanzSpace.s8,
          ),
          child: Row(
            children: [
              SizedBox.square(dimension: 64, child: ScanThumbnail(scan: scan)),
              const SizedBox(width: KanzSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: KanzSpace.s4),
                    Wrap(
                      spacing: KanzSpace.s12,
                      runSpacing: KanzSpace.s2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (scan.primaryCategory case final category?)
                          MaterialTag(
                            categoryId: category.id,
                            label: material!,
                          ),
                        if (count != null) Text(count, style: t.labelSmall),
                        MonoLabel(time, textDirection: TextDirection.ltr),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KanzSpace.s4),
              KanzIconButton(
                icon: KanzIcons.more,
                semanticsLabel: l10n.historyMore(title),
                onPressed: onMenu,
              ),
            ],
          ),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss-${scan.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDeleteScan(context),
      onDismissed: (_) => onDismissed(),
      background: Container(
        color: c.surfaceSunken,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: KanzSpace.gutter),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(KanzIcons.delete, size: 20, color: c.danger),
            const SizedBox(width: KanzSpace.s8),
            Text(
              l10n.historyDeleteConfirm,
              style: t.labelLarge?.copyWith(color: c.danger),
            ),
          ],
        ),
      ),
      child: row,
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({
    super.key,
    required this.projects,
    required this.scans,
    required this.onRetry,
  });

  final AsyncValue<List<ProjectRecord>> projects;
  final List<ScanSummary> scans;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (projects) {
      AsyncValue(:final value?) when value.isEmpty => _Scrolling(
        child: EmptyState(
          icon: KanzIcons.upcycle,
          title: l10n.historyProjectsEmptyTitle,
          message: l10n.historyProjectsEmptyBody,
        ),
      ),
      AsyncValue(:final value?) => _ProjectList(projects: value, scans: scans),
      AsyncError() => _Scrolling(
        child: ErrorState(
          title: l10n.historyErrorTitle,
          message: l10n.historyErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: onRetry,
        ),
      ),
      _ => _LoadingRows(label: l10n.historyLoading),
    };
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.projects, required this.scans});

  final List<ProjectRecord> projects;
  final List<ScanSummary> scans;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final byId = {for (final s in scans) s.id: s};
    final active = [
      for (final p in projects)
        if (p.status == ProjectStatus.inProgress) p,
    ];
    final finished = [
      for (final p in projects)
        if (p.status == ProjectStatus.completed) p,
    ];
    Widget row(ProjectRecord p) => ProjectRow(
      key: ValueKey(p.id),
      project: p,
      scan: byId[p.scanId],
      onTap: () => context.push(
        p.isCompleted
            ? AppRoutes.completion(p.id)
            : AppRoutes.tutorial(p.scanId, p.ideaId),
      ),
    );
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + KanzSpace.s32,
      ),
      children: [
        if (active.isNotEmpty) ...[
          SectionLabel(l10n.historyInProgress, top: KanzSpace.s16),
          for (final p in active) row(p),
        ],
        if (finished.isNotEmpty) ...[
          SectionLabel(
            l10n.historyFinished,
            top: active.isEmpty ? KanzSpace.s16 : KanzSpace.s24,
          ),
          for (final p in finished) row(p),
        ],
      ],
    );
  }
}

/// One project: its photo, title and progress (or when it was finished).
class ProjectRow extends StatelessWidget {
  const ProjectRow({
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
    final done = p.completedSteps.length.clamp(0, p.totalSteps);
    final String status;
    if (p.isCompleted) {
      status = p.completedAt == null
          ? l10n.historyFinished
          : l10n.historyFinishedOn(shortDate(l10n, p.completedAt!));
    } else if (p.totalSteps == 0) {
      status = l10n.historyNotStarted;
    } else {
      status = l10n.historyStepsDone(done, p.totalSteps);
    }
    final action = p.isCompleted ? l10n.historySeeProject : l10n.historyResume;

    return Semantics(
      button: true,
      label: '${p.title}, $status. $action',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s12,
            KanzSpace.gutter,
            KanzSpace.s12,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 64,
                child: scan == null
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surfaceSunken,
                          borderRadius: KanzRadii.inputAll,
                        ),
                        child: Icon(
                          KanzIcons.upcycle,
                          size: 24,
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
                    Text(p.title, style: t.titleMedium),
                    const SizedBox(height: KanzSpace.s8),
                    if (!p.isCompleted && p.totalSteps > 0) ...[
                      StepProgressBar(
                        total: p.totalSteps,
                        // No step is "current" in a list: done steps in
                        // ink, the rest on the track.
                        current: -1,
                        completed: {for (final s in p.completedSteps) s - 1},
                        semanticsLabel: status,
                      ),
                      const SizedBox(height: KanzSpace.s8),
                    ],
                    Row(
                      children: [
                        if (p.isCompleted) ...[
                          Icon(KanzIcons.checkCircle, size: 16, color: c.ink),
                          const SizedBox(width: KanzSpace.s4),
                        ],
                        Flexible(child: Text(status, style: t.bodySmall)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KanzSpace.s12),
              Icon(KanzIcons.chevronForward, size: 18, color: c.inkSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingRows extends StatelessWidget {
  const _LoadingRows({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: KanzSpace.s16),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.gutter,
              KanzSpace.s16,
              KanzSpace.gutter,
              KanzSpace.s8,
            ),
            child: MonoLabel(label),
          ),
          for (var i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: KanzSpace.gutter,
                vertical: KanzSpace.s8,
              ),
              child: Row(
                children: [
                  const Skeleton(
                    width: 64,
                    height: 64,
                    borderRadius: KanzRadii.inputAll,
                  ),
                  const SizedBox(width: KanzSpace.s16),
                  Expanded(child: Skeleton.text(lines: 2, lineHeight: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
