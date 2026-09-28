import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/history_providers.dart';
import '../../core/state/impact_providers.dart';
import '../../core/state/scan_session.dart';
import '../../core/state/tutorial_controller.dart';
import '../../l10n/l10n.dart';
import '../tutorial/widgets/content_direction.dart';
import '../tutorial/widgets/image_sources.dart';
import '../tutorial/widgets/page_parts.dart';
import 'share_card.dart';

/// Completion (`/projects/:projectId/done`): the finished project.
///
/// A Fraunces headline naming it, the user's photo against the makeover (or
/// the last step picture) on the before/after slider, what the project
/// changed in the user's impact, a share card, and the next things to do.
/// It is reached with `go`, so back and close lead Home.
class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  bool _sharing = false;

  void _goHome() => context.go(AppRoutes.home);

  /// Home first, then [location] on top of it, so back from there lands on
  /// Home instead of closing the app.
  void _goHomeThen(String location) {
    final router = GoRouter.of(context);
    router.go(AppRoutes.home);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(router.push(location)),
    );
  }

  Future<void> _share(_Visuals visuals, ProjectRecord project) async {
    if (_sharing) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final share = ref.read(shareServiceProvider);
    final renderer = ref.read(shareCardRendererProvider);
    setState(() => _sharing = true);
    String? imagePath;
    try {
      imagePath = await renderer.render(
        context,
        ShareCardData(
          id: project.id,
          title: project.title,
          madeFrom: visuals.madeFrom == null
              ? null
              : l10n.completionCardMadeFrom(visuals.madeFrom!),
          before: visuals.before,
          after: visuals.after,
          beforeLabel: l10n.completionBefore,
          afterLabel: l10n.completionAfter,
        ),
      );
    } on Object catch (e) {
      debugPrint('Share card not rendered: $e');
      imagePath = null;
    }
    try {
      await share.share(
        text: l10n.completionShareText(project.title),
        imagePath: imagePath,
      );
      if (imagePath == null && visuals.hasPicture) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.completionShareFallback)),
        );
      }
    } on Object catch (e) {
      debugPrint('Share failed: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final project = ref.watch(projectProvider(widget.projectId));
    final canPop = Navigator.of(context).canPop();

    final Widget body = switch (project) {
      AsyncData(value: final record?) => _content(record),
      AsyncData() => Align(
        alignment: AlignmentDirectional.topStart,
        child: EmptyState(
          icon: KanzIcons.question,
          title: l10n.completionMissingTitle,
          message: l10n.completionMissingBody,
          actionLabel: l10n.completionSeeProjects,
          onAction: () => _goHomeThen(AppRoutes.history),
        ),
      ),
      AsyncError() => Align(
        alignment: AlignmentDirectional.topStart,
        child: ErrorState(
          title: l10n.completionErrorTitle,
          message: l10n.completionErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(projectProvider(widget.projectId)),
        ),
      ),
      _ => const _CompletionSkeleton(),
    };

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: KanzIconButton(
            key: const ValueKey('completion-close'),
            icon: canPop ? KanzIcons.back : KanzIcons.close,
            semanticsLabel: canPop ? l10n.commonBack : l10n.commonClose,
            onPressed: () =>
                canPop ? Navigator.of(context).maybePop() : _goHome(),
          ),
        ),
        body: body,
      ),
    );
  }

  Widget _content(ProjectRecord project) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final scan = ref.watch(scanSessionProvider(project.scanId));
    final key = (scanId: project.scanId, ideaId: project.ideaId);
    // The tutorial's pictures are only used when the tutorial is still in
    // memory (just finished); reopening an old project never starts the
    // step image chain again.
    final lastStep = ref.exists(tutorialControllerProvider(key))
        ? ref.watch(
            tutorialControllerProvider(
              key,
            ).select((s) => s.stepImage(s.stepCount)),
          )
        : null;
    final impact = ref.watch(impactProvider);
    final events = ref.watch(impactEventsProvider).value ?? const [];
    final tutorial = project.tutorial;
    final idea = project.idea;
    // The project's own words (its title, the scanned items) keep the
    // direction of the language they were written in.
    final contentLang = tutorial?.lang ?? scan.lang;
    final direction = contentDirection(contentLang);

    final madeFrom = [
      for (final id in idea?.usesItemIds ?? const <String>[])
        ?scan.itemById(id)?.name,
    ];
    final visuals = _Visuals(
      before:
          localPhotoProvider(scan.localImagePath) ??
          generatedImageProvider(scan.referenceImage),
      after:
          generatedImageProvider(scan.afterImage(project.ideaId)) ??
          (lastStep == null ? null : generatedImageProvider(lastStep)),
      madeFrom: madeFrom.isEmpty
          ? null
          : isolateContent(
              context,
              formatList(l10n, madeFrom, sentence: true),
              contentLang,
            ),
    );
    final projectItems = events.where((e) => e.projectId == project.id).length;
    final completedAt = project.completedAt;
    final eyebrow = project.isCompleted
        ? [
            l10n.completionEyebrow,
            if (completedAt != null) formatRelative(l10n, completedAt),
          ].join(' · ')
        : l10n.completionEyebrowInProgress;
    final totalSteps = tutorial?.steps.length ?? project.totalSteps;

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      children: [
        FadeUp(child: MonoLabel(eyebrow)),
        const SizedBox(height: KanzSpace.s8),
        FadeUp(
          child: Semantics(
            header: true,
            child: Text(
              project.title,
              style: t.displayMedium,
              textDirection: direction,
            ),
          ),
        ),
        const SizedBox(height: KanzSpace.s24),
        FadeUp(
          delay: KanzMotion.stagger,
          child: _Comparison(visuals: visuals, description: scan.inputText),
        ),
        const SizedBox(height: KanzSpace.s16),
        KanzButton.secondary(
          key: const ValueKey('share-project'),
          label: visuals.before != null && visuals.after != null
              ? l10n.completionShare
              : l10n.completionShareProject,
          icon: KanzIcons.share,
          expand: true,
          loading: _sharing,
          loadingLabel: l10n.completionSharing,
          onPressed: () => unawaited(_share(visuals, project)),
        ),
        const SizedBox(height: KanzSpace.s32),
        DataGrid(
          columns: 3,
          entries: [
            if (visuals.madeFrom != null)
              DataGridEntry(
                l10n.completionMadeFrom,
                value: visuals.madeFrom,
                span: true,
              ),
            DataGridEntry(
              l10n.completionSteps,
              value: l10n.completionStepsValue(
                project.completedSteps.length.clamp(0, totalSteps),
                totalSteps,
              ),
            ),
            if (tutorial != null)
              DataGridEntry(
                l10n.completionTime,
                value: l10n.commonMinutes(tutorial.totalMinutes),
              ),
            if (tutorial != null)
              DataGridEntry(
                l10n.completionSkill,
                value: skillLabel(l10n, tutorial.skill),
              ),
          ],
        ),
        const SizedBox(height: KanzSpace.s40),
        SectionHeader(
          title: l10n.completionImpactTitle,
          large: true,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: KanzSpace.s16),
        // This project first: the one number it changed.
        if (projectItems > 0)
          StatNumeral(
            value: '$projectItems',
            label: l10n.completionProjectItems(projectItems),
          )
        else
          Text(
            project.isCompleted
                ? l10n.completionThisProject(0)
                : l10n.completionNotFinished,
            style: t.bodyMedium?.copyWith(color: c.inkSecondary),
          ),
        const SizedBox(height: KanzSpace.s32),
        // Then where the user stands overall.
        MonoLabel(l10n.completionAllTime),
        const SizedBox(height: KanzSpace.s8),
        _ImpactRow(
          impact: impact.value,
          itemsLabel: l10n.completionItems,
          projectsLabel: l10n.completionProjects,
          streakLabel: l10n.completionStreak,
        ),
        const SizedBox(height: KanzSpace.s40),
        KanzButton(
          key: const ValueKey('scan-again'),
          label: l10n.completionScanAgain,
          icon: KanzIcons.scan,
          expand: true,
          onPressed: () => _goHomeThen(AppRoutes.scan(ScanMode.camera)),
        ),
        const SizedBox(height: KanzSpace.s8),
        KanzButton.tertiary(
          key: const ValueKey('see-projects'),
          label: l10n.completionSeeProjects,
          expand: true,
          onPressed: () => _goHomeThen(AppRoutes.history),
        ),
      ],
    );
  }
}

/// The pictures of a project: the user's photo (or a text scan's reference
/// picture) and the makeover (or the last step picture).
class _Visuals {
  const _Visuals({this.before, this.after, this.madeFrom});

  final ImageProvider? before;
  final ImageProvider? after;
  final String? madeFrom;

  bool get hasPicture => before != null || after != null;
}

/// Before and after on the slider when both exist; otherwise the one
/// picture there is, with a line saying why; for a text scan with no
/// picture at all, the description the user typed.
class _Comparison extends StatelessWidget {
  const _Comparison({required this.visuals, required this.description});

  final _Visuals visuals;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final before = visuals.before;
    final after = visuals.after;
    if (before != null && after != null) {
      return BeforeAfterSlider(
        before: before,
        after: after,
        beforeLabel: l10n.completionBefore,
        afterLabel: l10n.completionAfter,
        semanticsLabel: l10n.completionCompare,
        initialValue: 0.5,
      );
    }
    if (before != null || after != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              HeroPicture(image: (after ?? before)!, aspectRatio: 4 / 3),
              // Only a makeover needs a tag; the lone photo is explained
              // by the note under it.
              if (after != null)
                PositionedDirectional(
                  top: KanzSpace.s12,
                  start: KanzSpace.s12,
                  child: _PhotoTag(label: l10n.completionAfter),
                ),
            ],
          ),
          if (after == null) ...[
            const SizedBox(height: KanzSpace.s12),
            _Note(icon: KanzIcons.info, text: l10n.completionPhotoOnly),
          ],
        ],
      );
    }
    final text = description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (text != null && text.isNotEmpty)
          Container(
            padding: const EdgeInsetsDirectional.all(KanzSpace.s20),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: KanzRadii.cardAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoLabel(l10n.completionDescribedLabel),
                const SizedBox(height: KanzSpace.s8),
                Text(text, style: t.headlineSmall),
              ],
            ),
          ),
        const SizedBox(height: KanzSpace.s12),
        _Note(icon: KanzIcons.describe, text: l10n.completionNoPhoto),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: KanzSpace.s2),
          child: Icon(icon, size: 16, color: c.inkSecondary),
        ),
        const SizedBox(width: KanzSpace.s8),
        Expanded(child: Text(text, style: context.textStyles.bodySmall)),
      ],
    );
  }
}

class _PhotoTag extends StatelessWidget {
  const _PhotoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // Tags are anchored to the picture: they keep their size.
    return MediaQuery.withNoTextScaling(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: KanzPhotoColors.tag,
          borderRadius: KanzRadii.tagAll,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: KanzSpace.s8,
            vertical: KanzSpace.s2,
          ),
          child: MonoLabel(label, color: KanzPhotoColors.ink),
        ),
      ),
    );
  }
}

/// All time: items kept out of the bin, projects finished and the streak,
/// as three Fraunces numerals under a hairline, a step smaller than this
/// project's own number above them. Dashes while the numbers load.
class _ImpactRow extends StatelessWidget {
  const _ImpactRow({
    required this.impact,
    required this.itemsLabel,
    required this.projectsLabel,
    required this.streakLabel,
  });

  final ImpactSummary? impact;
  final String itemsLabel;
  final String projectsLabel;
  final String streakLabel;

  @override
  Widget build(BuildContext context) {
    final impact = this.impact;
    String n(int Function(ImpactSummary) pick) =>
        impact == null ? '–' : '${pick(impact)}';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.kanzColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: KanzSpace.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Stat(value: n((i) => i.totalItems), label: itemsLabel),
            ),
            const SizedBox(width: KanzSpace.s16),
            Expanded(
              child: _Stat(
                value: n((i) => i.projectsCompleted),
                label: projectsLabel,
              ),
            ),
            const SizedBox(width: KanzSpace.s16),
            Expanded(
              child: _Stat(value: n((i) => i.streakDays), label: streakLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: context.kanzType.numeral,
              textDirection: TextDirection.ltr,
            ),
          ),
          Text(label, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}

/// Mirrors the finished page: eyebrow, title, the 4:3 picture, the share
/// button, the spec grid, then this project's number over the all-time row.
class _CompletionSkeleton extends StatelessWidget {
  const _CompletionSkeleton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      children: [
        Semantics(liveRegion: true, child: MonoLabel(l10n.completionLoading)),
        const SizedBox(height: KanzSpace.s12),
        const _Start(Skeleton(width: 240, height: 40)),
        const SizedBox(height: KanzSpace.s24),
        const AspectRatio(
          aspectRatio: 4 / 3,
          child: Skeleton(
            height: double.infinity,
            borderRadius: KanzRadii.cardAll,
          ),
        ),
        const SizedBox(height: KanzSpace.s16),
        const Skeleton(height: 48, borderRadius: KanzRadii.buttonAll),
        const SizedBox(height: KanzSpace.s32),
        Divider(height: 1, thickness: 1, color: c.line),
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: KanzSpace.s16),
          child: Row(
            children: [
              Expanded(child: _Cell()),
              SizedBox(width: KanzSpace.s16),
              Expanded(child: _Cell()),
              SizedBox(width: KanzSpace.s16),
              Expanded(child: _Cell()),
            ],
          ),
        ),
        const SizedBox(height: KanzSpace.s24),
        const _Start(Skeleton(width: 220, height: 24)),
        const SizedBox(height: KanzSpace.s16),
        const _Start(Skeleton(width: 48, height: 56)),
        const SizedBox(height: KanzSpace.s8),
        const _Start(Skeleton(width: 160, height: 14)),
      ],
    );
  }
}

/// A fixed-width skeleton kept at its size on the start edge (a list
/// would stretch it to the full width).
class _Start extends StatelessWidget {
  const _Start(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Align(alignment: AlignmentDirectional.centerStart, child: child);
}

class _Cell extends StatelessWidget {
  const _Cell();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(width: 48, height: 10),
        SizedBox(height: KanzSpace.s8),
        FractionallySizedBox(widthFactor: 0.7, child: Skeleton(height: 14)),
      ],
    );
  }
}
