import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import '../../core/network/api_exception.dart';
import '../../core/state/connectivity_providers.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/hands_free_controller.dart';
import '../../core/state/scan_session.dart';
import '../../core/state/settings_providers.dart';
import '../../core/state/tutorial_controller.dart';
import '../../l10n/l10n.dart';
import 'widgets/adapt_sheet.dart';
import 'widgets/finish_page.dart';
import 'widgets/image_sources.dart';
import 'widgets/overview_page.dart';
import 'widgets/status_strips.dart';
import 'widgets/step_image.dart';
import 'widgets/step_page.dart';
import 'widgets/tutorial_states.dart';

/// Tutorial pager (`/results/:scanId/idea/:ideaId/tutorial`).
///
/// Pages: an overview (materials, tools, safety), one page per step, then
/// finishing and care. Swiping follows the reading direction; the step on
/// screen is saved as the project's current step, so voice commands, the
/// buttons and swipes all move the same pager. The adapt sheet rewrites the
/// tutorial for another skill or tool set while the current one stays
/// readable, and hands-free mode reads each step aloud.
class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({
    super.key,
    required this.scanId,
    required this.ideaId,
    @visibleForTesting this.initialPage,
  });

  final String scanId;
  final String ideaId;

  /// Opens on this page (0 overview, 1..n steps, n + 1 finishing) instead
  /// of the saved step. For screenshot tests.
  final int? initialPage;

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  TutorialKey get _key => (scanId: widget.scanId, ideaId: widget.ideaId);

  TutorialController get _controller =>
      ref.read(tutorialControllerProvider(_key).notifier);

  PageController? _pages;

  /// Page on screen: 0 overview, 1..n steps, n + 1 finishing.
  int _page = 0;

  /// Set when a rewritten tutorial arrives, until the user leaves the
  /// overview.
  bool _noteHighlighted = false;

  /// The last adapt request, for the retry after a failure.
  AdaptRequest? _lastAdapt;
  ApiException? _dismissedAdaptError;
  bool _finishing = false;
  bool _defaultsApplied = false;

  /// A rewritten tutorial just arrived and the pager is going back to the
  /// overview; its restarted step must not pull the pager elsewhere.
  bool _showOverviewAfterRewrite = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      tutorialControllerProvider(_key),
      _onTutorial,
      fireImmediately: true,
    );
    ref.listenManual(
      tutorialControllerProvider(_key).select((s) => s.currentStep),
      _onCurrentStep,
    );
  }

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- listeners

  void _onTutorial(TutorialState? previous, TutorialState next) {
    if (next.phase == TutorialPhase.ready && !_defaultsApplied) {
      _defaultsApplied = true;
      if (ref.read(settingsProvider).handsFree) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_handsFree.enable());
        });
      }
    }
    final rewritten =
        previous != null &&
        previous.adapting &&
        !next.adapting &&
        next.adaptError == null;
    if (rewritten) {
      // The new version starts from its overview, with the note marked.
      _showOverviewAfterRewrite = true;
      setState(() => _noteHighlighted = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOverviewAfterRewrite = false;
        final pages = _pages;
        if (mounted && pages != null && pages.hasClients) pages.jumpToPage(0);
      });
    }
  }

  /// Voice commands (and restored progress) move the current step; bring
  /// the pager along. Swipes already put the pager there.
  void _onCurrentStep(int? previous, int next) {
    if (previous == null || _page == next || _showOverviewAfterRewrite) return;
    _goToPage(next);
  }

  HandsFreeController get _handsFree =>
      ref.read(handsFreeProvider(_key).notifier);

  // --------------------------------------------------------------- actions

  void _goToPage(int index) {
    final pages = _pages;
    if (pages == null || !pages.hasClients) return;
    final duration = KanzMotion.of(context, KanzMotion.slow);
    if (duration == Duration.zero) {
      pages.jumpToPage(index);
    } else {
      unawaited(
        pages.animateToPage(
          index,
          duration: duration,
          curve: KanzMotion.emphasized,
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _page = index;
      if (index != 0) _noteHighlighted = false;
    });
    final state = ref.read(tutorialControllerProvider(_key));
    if (index >= 1 && index <= state.stepCount && state.currentStep != index) {
      unawaited(_controller.goToStep(index));
    }
  }

  void _markDone(int step) {
    unawaited(KanzHaptics.stepComplete());
    unawaited(_controller.markStepDone(step));
    _goToPage(step + 1);
  }

  Future<void> _toggleHandsFree(int stepCount) async {
    final enabling = !ref.read(handsFreeProvider(_key)).enabled;
    if (enabling && (_page == 0 || _page > stepCount)) {
      _goToPage(ref.read(tutorialControllerProvider(_key)).currentStep);
    }
    await _handsFree.toggle();
  }

  Future<void> _openAdapt({required bool offline}) async {
    final state = ref.read(tutorialControllerProvider(_key));
    final tutorial = state.tutorial;
    if (tutorial == null) return;
    final vocab = ref.read(vocabProvider);
    final used = [
      for (final tool in tutorial.tools)
        if (!tool.toolId.isSafetyGear) tool.toolId,
    ];
    final request = await showAdaptSheet(
      context: context,
      skill: state.skill,
      tools: state.tools,
      offline: offline,
      choices: [
        for (final id in used) vocab.tool(id),
        for (final entry in vocab.realTools)
          if (!used.contains(entry.id)) entry,
      ],
    );
    if (request == null || !mounted) return;
    _adapt(request);
  }

  void _adapt(AdaptRequest request) {
    setState(() {
      _lastAdapt = request;
      _noteHighlighted = false;
    });
    unawaited(_controller.adapt(skill: request.skill, tools: request.tools));
  }

  Future<void> _finish() async {
    if (_finishing) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _finishing = true);
    String? projectId;
    try {
      projectId = await _controller.complete();
    } on Object {
      projectId = null;
    }
    if (!mounted) return;
    setState(() => _finishing = false);
    if (projectId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.tutorialFinishFailed)),
      );
      return;
    }
    context.go(AppRoutes.completion(projectId));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.idea(widget.scanId, widget.ideaId));
    }
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorialControllerProvider(_key));
    final handsFree = ref.watch(handsFreeProvider(_key));
    final scan = ref.watch(scanSessionProvider(widget.scanId));
    final offline = ref.watch(backendStatusProvider) == BackendStatus.offline;
    final l10n = context.l10n;

    final photo =
        localPhotoProvider(scan.localImagePath) ??
        generatedImageProvider(scan.referenceImage);
    final after = generatedImageProvider(scan.afterImage(widget.ideaId));
    final tutorial = state.tutorial;
    final ready = state.phase == TutorialPhase.ready && tutorial != null;

    final Widget body;
    if (ready) {
      body = _content(
        state: state,
        tutorial: tutorial,
        handsFree: handsFree,
        scan: scan,
        photo: photo,
        after: after,
        offline: offline,
      );
    } else if (state.phase == TutorialPhase.failed) {
      body = TutorialFailedView(
        hero: after ?? photo,
        error: state.error,
        onRetry: () => unawaited(_controller.retry()),
        onBackToIdeas: () => context.go(AppRoutes.results(widget.scanId)),
      );
    } else {
      final idea = state.idea ?? scan.recommendation?.ideaById(widget.ideaId);
      body = TutorialLoadingView(hero: after ?? photo, title: idea?.title);
    }

    return Scaffold(
      appBar: AppBar(
        leading: KanzIconButton(
          icon: KanzIcons.back,
          semanticsLabel: l10n.commonBack,
          onPressed: _back,
        ),
        actions: [
          if (ready) ...[
            KanzIconButton(
              key: const ValueKey('hands-free-toggle'),
              icon: KanzIcons.microphone,
              semanticsLabel: l10n.tutorialHandsFree,
              selected: handsFree.enabled,
              onPressed: () => unawaited(_toggleHandsFree(state.stepCount)),
            ),
            KanzIconButton(
              key: const ValueKey('adapt-action'),
              icon: KanzIcons.filters,
              semanticsLabel: l10n.tutorialAdaptTooltip,
              onPressed: state.adapting
                  ? null
                  : () => unawaited(_openAdapt(offline: offline)),
            ),
            const SizedBox(width: KanzSpace.s8),
          ],
        ],
      ),
      body: body,
    );
  }

  Widget _content({
    required TutorialState state,
    required Tutorial tutorial,
    required HandsFreeState handsFree,
    required ScanSessionState scan,
    required ImageProvider? photo,
    required ImageProvider? after,
    required bool offline,
  }) {
    final l10n = context.l10n;
    final vocab = ref.watch(vocabProvider);
    final stepCount = state.stepCount;
    final pages = _pages ??= _createPages(state);
    final adaptError = state.adaptError;
    final lastStepImage = generatedImageProvider(state.stepImage(stepCount));
    final showAdaptError =
        adaptError != null && adaptError != _dismissedAdaptError;
    final strips =
        offline || state.adapting || showAdaptError || handsFree.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (offline) OfflineBanner(message: l10n.tutorialOfflineBanner),
        if (state.adapting)
          AdaptingStrip(
            message: l10n.tutorialAdapting(
              skillLabel(l10n, _lastAdapt?.skill ?? state.skill),
            ),
          )
        else if (showAdaptError)
          AdaptErrorStrip(
            message: l10n.tutorialAdaptFailed(
              apiErrorMessage(l10n, adaptError),
            ),
            retryLabel: l10n.commonRetry,
            dismissLabel: l10n.tutorialDismiss,
            // Always a way forward while online: the same request again
            // when it can help, otherwise the sheet to choose again.
            onRetry: offline
                ? null
                : (adaptError.retryable && _lastAdapt != null
                      ? () => _adapt(_lastAdapt!)
                      : () => unawaited(_openAdapt(offline: offline))),
            onDismiss: () => setState(() => _dismissedAdaptError = adaptError),
          ),
        if (handsFree.enabled)
          HandsFreeStrip(state: handsFree, currentStep: state.currentStep),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            KanzSpace.gutter,
            strips ? KanzSpace.s16 : KanzSpace.s8,
            KanzSpace.gutter,
            KanzSpace.s12,
          ),
          child: StepProgressBar(
            total: stepCount,
            current: _page >= 1 && _page <= stepCount ? _page - 1 : -1,
            // A sentinel keeps the bar in "marked steps only" mode, so steps
            // the user skipped past are not drawn as done.
            completed: {-1, for (final n in state.completedSteps) n - 1},
            semanticsLabel: l10n.tutorialStepsDone(
              state.completedSteps.length,
              stepCount,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: pages,
            onPageChanged: _onPageChanged,
            itemCount: stepCount + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return TutorialOverviewPage(
                  tutorial: tutorial,
                  vocab: vocab,
                  hero: after ?? photo,
                  heroInset: after == null ? null : photo,
                  categoryOf: (id) => scan.itemById(id)?.category,
                  noteHighlighted: _noteHighlighted,
                  adapting: state.adapting,
                  offline: offline,
                  onAdapt: offline || state.adapting
                      ? null
                      : () => unawaited(_openAdapt(offline: offline)),
                );
              }
              if (index > stepCount) {
                return TutorialFinishPage(
                  tutorial: tutorial,
                  doneCount: state.completedSteps.length,
                  hero: lastStepImage ?? after ?? photo,
                );
              }
              final step = state.step(index) ?? tutorial.steps[index - 1];
              final image = state.stepImage(step.number);
              return TutorialStepPage(
                key: ValueKey('step-${tutorial.tutorialId}-${step.number}'),
                step: step,
                total: stepCount,
                done: state.completedSteps.contains(step.number),
                image: image,
                blockedBy: _blockFor(state, step.number),
                fallbackPhoto: photo,
                lang: tutorial.lang,
                offline: offline,
                onRegenerate: offline || isQuotaPaused(image)
                    ? null
                    : () => unawaited(_controller.regenerateStep(step.number)),
              );
            },
          ),
        ),
        _BottomBar(
          child: AnimatedSwitcher(
            duration: KanzMotion.of(context, KanzMotion.fast),
            child: KeyedSubtree(
              key: ValueKey(
                _page == 0
                    ? 'overview'
                    : (_page > stepCount ? 'finish' : 'step'),
              ),
              child: _actions(state),
            ),
          ),
        ),
      ],
    );
  }

  PageController _createPages(TutorialState state) {
    final resumed = state.completedSteps.isNotEmpty || state.currentStep > 1;
    _page =
        (widget.initialPage ??
                (resumed ? state.currentStep.clamp(1, state.stepCount) : 0))
            .clamp(0, state.stepCount + 1);
    return PageController(initialPage: _page);
  }

  /// The earlier step whose failed picture holds this one back, if any.
  StepImageBlock? _blockFor(TutorialState state, int number) {
    for (var n = 1; n < number; n++) {
      final image = state.stepImage(n);
      if (image.status == ImageStatus.failed) {
        return (step: n, quotaPaused: isQuotaPaused(image));
      }
    }
    return null;
  }

  Widget _actions(TutorialState state) {
    final l10n = context.l10n;
    final stepCount = state.stepCount;
    // With large text the label needs the room between the arrows more than
    // the button needs its glyph.
    final glyphs = MediaQuery.textScalerOf(context).scale(1) <= 1.15;
    if (_page == 0) {
      final resumed = state.completedSteps.isNotEmpty || state.currentStep > 1;
      return KanzButton(
        key: const ValueKey('start-steps'),
        label: resumed
            ? l10n.tutorialContinue(state.currentStep)
            : l10n.tutorialStart,
        trailingIcon: KanzIcons.forward,
        expand: true,
        onPressed: () => _goToPage(resumed ? state.currentStep : 1),
      );
    }
    if (_page > stepCount) {
      return Row(
        children: [
          KanzIconButton(
            icon: KanzIcons.chevronBack,
            style: KanzIconButtonStyle.outlined,
            semanticsLabel: l10n.tutorialPrevious,
            onPressed: () => _goToPage(stepCount),
          ),
          const SizedBox(width: KanzSpace.s12),
          Expanded(
            child: KanzButton(
              key: const ValueKey('finish-project'),
              label: l10n.tutorialFinish,
              // One arrow beside it leaves room for the glyph at any size.
              icon: KanzIcons.checkCircle,
              expand: true,
              loading: _finishing,
              loadingLabel: l10n.tutorialFinishSaving,
              onPressed: () => unawaited(_finish()),
            ),
          ),
        ],
      );
    }
    final step = _page;
    final done = state.completedSteps.contains(step);
    return Row(
      children: [
        KanzIconButton(
          key: const ValueKey('previous-step'),
          icon: KanzIcons.chevronBack,
          style: KanzIconButtonStyle.outlined,
          semanticsLabel: step == 1
              ? l10n.tutorialOverview
              : l10n.tutorialPrevious,
          onPressed: () => _goToPage(step - 1),
        ),
        const SizedBox(width: KanzSpace.s12),
        Expanded(
          child: done
              ? Semantics(
                  hint: l10n.tutorialStepDoneHint,
                  child: KanzButton.secondary(
                    key: const ValueKey('step-done'),
                    label: l10n.tutorialStepDone,
                    icon: glyphs ? KanzIcons.checkCircle : null,
                    expand: true,
                    onPressed: () =>
                        unawaited(_controller.markStepDone(step, done: false)),
                  ),
                )
              : KanzButton(
                  key: const ValueKey('mark-done'),
                  label: l10n.tutorialMarkDone,
                  icon: glyphs ? KanzIcons.check : null,
                  expand: true,
                  onPressed: () => _markDone(step),
                ),
        ),
        const SizedBox(width: KanzSpace.s12),
        KanzIconButton(
          key: const ValueKey('next-step'),
          icon: KanzIcons.chevronForward,
          style: KanzIconButtonStyle.outlined,
          semanticsLabel: step == stepCount
              ? l10n.tutorialToFinish
              : l10n.tutorialNext,
          onPressed: () => _goToPage(step + 1),
        ),
      ],
    );
  }
}

/// The action row pinned under the pages: paper with a hairline above,
/// clear of the gesture bar.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

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
          child: child,
        ),
      ),
    );
  }
}
