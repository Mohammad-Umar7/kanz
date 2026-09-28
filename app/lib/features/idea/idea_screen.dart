import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/models/models.dart';
import '../../core/design/design.dart' hide PipelineStage;
import '../../core/state/core_providers.dart';
import '../../core/state/scan_session.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import '../results/results_format.dart';
import '../results/scan_images.dart';
import '../results/widgets/guide_list.dart';
import 'widgets/idea_visual.dart';

/// Idea detail (`/results/:scanId/idea/:ideaId`): the makeover as a
/// before/after slider, then everything needed to decide: difficulty, time,
/// the tools the user has and lacks, other materials, safety and the
/// knowledge it came from. "See the tutorial" stays within reach.
class IdeaScreen extends ConsumerStatefulWidget {
  const IdeaScreen({super.key, required this.scanId, required this.ideaId});

  final String scanId;
  final String ideaId;

  @override
  ConsumerState<IdeaScreen> createState() => _IdeaScreenState();
}

class _IdeaScreenState extends ConsumerState<IdeaScreen> {
  final StableImages _images = StableImages();

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.results(widget.scanId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(scanSessionProvider(widget.scanId));
    final format = ResultsFormat.of(context, ref.watch(vocabProvider));
    final owned = ref.watch(settingsProvider.select((s) => s.tools));
    final ideas = session.ideas;
    final index = ideas.indexWhere((i) => i.id == widget.ideaId);
    final idea = index < 0 ? null : ideas[index];

    final Widget body;
    Widget? bottom;
    if (session.origin == ScanOrigin.loading) {
      body = const _LoadingIdea();
    } else if (idea == null) {
      body = ListView(
        children: [
          EmptyState(
            icon: KanzIcons.upcycle,
            title: l10n.ideaMissingTitle,
            message: l10n.ideaMissingBody,
            actionLabel: l10n.ideaBackToResults,
            onAction: () => context.go(AppRoutes.results(widget.scanId)),
          ),
        ],
      );
    } else {
      body = _IdeaBody(
        scanId: widget.scanId,
        session: session,
        idea: idea,
        index: index,
        total: ideas.length,
        format: format,
        match: format.toolMatch(idea, owned),
        images: _images,
        onRegenerate: () => unawaited(
          ref
              .read(scanSessionProvider(widget.scanId).notifier)
              .regenerateAfterImage(idea.id),
        ),
      );
      bottom = _TutorialBar(
        label: l10n.ideaSeeTutorial,
        onPressed: () =>
            context.push(AppRoutes.tutorial(widget.scanId, idea.id)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: KanzIconButton(
          icon: KanzIcons.back,
          semanticsLabel: l10n.commonBack,
          onPressed: _back,
        ),
      ),
      body: body,
      bottomNavigationBar: bottom,
    );
  }
}

class _IdeaBody extends StatelessWidget {
  const _IdeaBody({
    required this.scanId,
    required this.session,
    required this.idea,
    required this.index,
    required this.total,
    required this.format,
    required this.match,
    required this.images,
    required this.onRegenerate,
  });

  final String scanId;
  final ScanSessionState session;
  final UpcycleIdea idea;
  final int index;
  final int total;
  final ResultsFormat format;
  final ToolMatch match;
  final StableImages images;
  final VoidCallback onRegenerate;

  /// The photo's shape, kept between 4:5 and 4:3 like on the results.
  double get _aspect {
    final w = session.analysis?.imageWidth;
    final h = session.analysis?.imageHeight;
    if (w == null || h == null || w <= 0 || h <= 0) return 4 / 3;
    return math.min(4 / 3, math.max(4 / 5, w / h));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final image = session.afterImage(idea.id);
    final paused = image.error?.isQuotaExhausted ?? false;
    final state = switch (image.status) {
      ImageStatus.ready => MakeoverState.ready,
      ImageStatus.failed => MakeoverState.failed,
      ImageStatus.idle || ImageStatus.loading => MakeoverState.rendering,
    };
    // A new image is offered once one exists (another take) or after a
    // failure a retry can fix; never for the free-tier quota.
    final canRegenerate = !paused && (image.isReady || canRetryImage(image));
    final sources = format.sourceTitles(idea.sources);

    return ListView(
      padding: const EdgeInsets.only(bottom: KanzSpace.s32),
      children: [
        IdeaVisual(
          state: state,
          before: images.before(session),
          after: images.resolve(idea.id, image),
          aspectRatio: _aspect,
          beforeLabel: l10n.ideaBefore,
          afterLabel: l10n.ideaAfter,
          compareLabel: l10n.ideaCompare,
          pendingLabel: l10n.ideaRendering,
          note: paused ? l10n.ideaImagePaused : l10n.ideaImageFailed,
          description: session.inputText,
          descriptionLabel: l10n.ideaFromDescription,
          afterHeroTag: afterHeroTag(scanId, idea.id),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s8,
            KanzSpace.gutter,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A caption under the figure: how to use it, and another take.
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: KanzSpace.touchTarget,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: state == MakeoverState.ready
                          ? ExcludeSemantics(
                              child: MonoLabel(l10n.ideaDragHint),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (canRegenerate)
                      KanzButton.tertiary(
                        label: l10n.commonRegenerate,
                        icon: KanzIcons.retry,
                        onPressed: onRegenerate,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: KanzSpace.s16),
              MonoLabel(l10n.ideaEyebrow(index + 1, total)),
              const SizedBox(height: KanzSpace.s8),
              Semantics(
                header: true,
                child: Text(idea.title, style: t.headlineLarge),
              ),
              const SizedBox(height: KanzSpace.s8),
              Text(
                idea.pitch,
                style: t.bodyLarge?.copyWith(color: c.inkSecondary),
              ),
              const SizedBox(height: KanzSpace.s24),
              DataGrid(
                entries: [
                  DataGridEntry(
                    l10n.ideaDifficulty,
                    value: difficultyLabel(l10n, idea.difficulty),
                  ),
                  DataGridEntry(
                    l10n.ideaTime,
                    value: l10n.commonMinutes(idea.timeMinutes),
                  ),
                  DataGridEntry(
                    l10n.ideaTools,
                    span: true,
                    child: match.badge(),
                  ),
                ],
              ),
              Divider(height: 1, color: c.line),
              const SizedBox(height: KanzSpace.s32),
              _ToolList(match: match, format: format),
              if (idea.extraMaterials.isNotEmpty) ...[
                const SizedBox(height: KanzSpace.s32),
                GuideList(
                  title: l10n.ideaMaterialsTitle,
                  lines: idea.extraMaterials,
                ),
              ],
              if (idea.safetyNote case final note?
                  when note.trim().isNotEmpty) ...[
                const SizedBox(height: KanzSpace.s32),
                Callout(
                  variant: CalloutVariant.safety,
                  title: l10n.ideaSafety,
                  message: note,
                ),
              ],
              if (sources.isNotEmpty) ...[
                const SizedBox(height: KanzSpace.s32),
                SourceChips(title: l10n.ideaBasedOn, sources: sources),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The idea's tools, the ones the user owns first, each marked have or need.
class _ToolList extends StatelessWidget {
  const _ToolList({required this.match, required this.format});

  final ToolMatch match;
  final ResultsFormat format;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    Widget row(ToolId tool, {required bool have}) => MergeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
        padding: const EdgeInsets.symmetric(vertical: KanzSpace.s8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: [
            Icon(
              have ? KanzIcons.checkCircle : KanzIcons.circle,
              size: 20,
              color: have ? c.ink : c.lineStrong,
            ),
            const SizedBox(width: KanzSpace.s12),
            Expanded(child: Text(format.tool(tool), style: t.bodyLarge)),
            const SizedBox(width: KanzSpace.s8),
            MonoLabel(
              have ? l10n.ideaToolHave : l10n.ideaToolMissing,
              color: have ? c.ink : null,
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.ideaToolsTitle, style: t.titleLarge),
        ),
        const SizedBox(height: KanzSpace.s8),
        if (match.total == 0)
          Text(
            l10n.ideaNoTools,
            style: t.bodyMedium?.copyWith(color: c.inkSecondary),
          )
        else ...[
          Divider(height: 1, color: c.line),
          for (final tool in match.have) row(tool, have: true),
          for (final tool in match.missing) row(tool, have: false),
        ],
      ],
    );
  }
}

/// "See the tutorial", pinned over the bottom edge.
class _TutorialBar extends StatelessWidget {
  const _TutorialBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s12,
            KanzSpace.gutter,
            KanzSpace.s12,
          ),
          child: KanzButton(
            label: label,
            trailingIcon: KanzIcons.forward,
            onPressed: onPressed,
            expand: true,
          ),
        ),
      ),
    );
  }
}

class _LoadingIdea extends StatelessWidget {
  const _LoadingIdea();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Skeleton(
            height: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            KanzSpace.s32,
            KanzSpace.gutter,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 80, height: 10),
              SizedBox(height: KanzSpace.s12),
              Skeleton(width: 220, height: 28),
              SizedBox(height: KanzSpace.s16),
              Skeleton(height: 14),
              SizedBox(height: KanzSpace.s8),
              Skeleton(width: 180, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
