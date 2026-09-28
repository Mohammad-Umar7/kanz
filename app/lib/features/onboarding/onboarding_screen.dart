import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import 'choice_card.dart';
import 'tool_picker.dart';

/// Onboarding (`/onboarding`): welcome, language, skill and tools, four short
/// steps. Every choice is saved as it is made, so "Skip" keeps whatever was
/// chosen so far (and the defaults for the rest). The router keeps the user
/// here until `completeOnboarding()`; then it redirects to Home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.initialStep = 0});

  /// First step shown (tests and screenshots).
  final int initialStep;

  static const stepCount = 4;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialStep,
  );
  late int _step = widget.initialStep;
  bool _finishing = false;

  /// The step's content runs on under the pinned button: draw a hairline
  /// over the button so the edge reads as intended.
  bool _contentBelow = false;

  bool _onScrollMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical) return false;
    final below = metrics.extentAfter > 0.5;
    if (below != _contentBelow) setState(() => _contentBelow = below);
    return false;
  }

  bool get _isLast => _step == OnboardingScreen.stepCount - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    final target = step.clamp(0, OnboardingScreen.stepCount - 1);
    final duration = KanzMotion.of(context, KanzMotion.slow);
    if (duration == Duration.zero) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(
        target,
        duration: duration,
        curve: KanzMotion.emphasized,
      );
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await ref.read(settingsProvider.notifier).completeOnboarding();
    // The router redirects on its own; going home explicitly also covers a
    // router that is not listening yet.
    if (mounted) GoRouter.maybeOf(context)?.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Watched: onboarding writes language, skill and tools as they change.
    final settings = ref.watch(settingsProvider);
    final vocab = ref.watch(vocabProvider);
    final controller = ref.read(settingsProvider.notifier);

    final primaryLabel = switch (_step) {
      0 => l10n.onboardingGetStarted,
      OnboardingScreen.stepCount - 1 => l10n.onboardingFinish,
      _ => l10n.commonContinue,
    };

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(_step - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                step: _step,
                onBack: _step == 0 ? null : () => _goTo(_step - 1),
                onSkip: _isLast || _finishing ? null : _finish,
              ),
              Expanded(
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (n) => _onScrollMetrics(n.metrics),
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (n) => _onScrollMetrics(n.metrics),
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (i) => setState(() => _step = i),
                      children: [
                        const _WelcomeStep(),
                        _LanguageStep(
                          selected: Localizations.localeOf(
                            context,
                          ).languageCode,
                          onSelect: (pref) => controller.setLocale(pref),
                        ),
                        _SkillStep(
                          selected: settings.skill,
                          onSelect: controller.setSkill,
                        ),
                        _ToolsStep(
                          tools: vocab.realTools,
                          selected: settings.tools.toSet(),
                          onToggle: controller.toggleTool,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: KanzMotion.of(context, KanzMotion.fast),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _contentBelow
                          ? context.kanzColors.line
                          : Colors.transparent,
                    ),
                  ),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  KanzSpace.gutter,
                  KanzSpace.s12,
                  KanzSpace.gutter,
                  KanzSpace.s16,
                ),
                child: KanzButton(
                  label: primaryLabel,
                  expand: true,
                  loading: _finishing,
                  loadingLabel: primaryLabel,
                  trailingIcon: _isLast ? null : KanzIcons.forward,
                  onPressed: _isLast ? _finish : () => _goTo(_step + 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step, this.onBack, this.onSkip});

  final int step;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: KanzSpace.s8,
        ),
        child: Row(
          children: [
            // On the first step there is nothing to go back to, so the bar
            // starts on the page gutter like everything under it; from the
            // second step the back button slides in before it.
            AnimatedSize(
              duration: KanzMotion.of(context, KanzMotion.medium),
              curve: KanzMotion.emphasized,
              alignment: AlignmentDirectional.centerStart,
              child: onBack == null
                  ? const SizedBox(width: KanzSpace.gutter - KanzSpace.s8)
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: KanzSpace.s8,
                      ),
                      child: KanzIconButton(
                        icon: KanzIcons.back,
                        semanticsLabel: l10n.commonBack,
                        onPressed: onBack,
                      ),
                    ),
            ),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: StepProgressBar(
                  total: OnboardingScreen.stepCount,
                  current: step,
                  semanticsLabel: l10n.commonStepOf(
                    step + 1,
                    OnboardingScreen.stepCount,
                  ),
                ),
              ),
            ),
            const SizedBox(width: KanzSpace.s8),
            // Same width on every step, so the bar keeps its length.
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72),
              child: onSkip == null
                  ? const SizedBox.shrink()
                  : KanzButton.tertiary(
                      label: l10n.commonSkip,
                      onPressed: onSkip,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable step body with the page gutter and room to breathe.
class _StepBody extends StatelessWidget {
  const _StepBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s24,
        KanzSpace.gutter,
        KanzSpace.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final c = context.kanzColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: t.headlineLarge)),
        const SizedBox(height: KanzSpace.s12),
        Text(body, style: t.bodyLarge?.copyWith(color: c.inkSecondary)),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    final steps = [
      (l10n.onboardingWelcomeStep1Title, l10n.onboardingWelcomeStep1Body),
      (l10n.onboardingWelcomeStep2Title, l10n.onboardingWelcomeStep2Body),
      (l10n.onboardingWelcomeStep3Title, l10n.onboardingWelcomeStep3Body),
    ];
    return _StepBody(
      children: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: BrandLockup(markSize: 36),
        ),
        const SizedBox(height: KanzSpace.s40),
        Semantics(
          header: true,
          child: Text(l10n.onboardingWelcomeTitle, style: t.displayMedium),
        ),
        const SizedBox(height: KanzSpace.s16),
        Text(
          l10n.onboardingWelcomeBody,
          style: t.bodyLarge?.copyWith(color: c.inkSecondary),
        ),
        const SizedBox(height: KanzSpace.s32),
        for (final (i, (title, body)) in steps.indexed)
          FadeUp.staggered(
            index: i,
            child: _HowItWorksRow(number: i + 1, title: title, body: body),
          ),
      ],
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow({
    required this.number,
    required this.title,
    required this.body,
  });

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final c = context.kanzColors;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: KanzSpace.s16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: context.kanzType.dataStrong,
                textDirection: TextDirection.ltr,
                textAlign: context.isRtl ? TextAlign.right : TextAlign.left,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium),
                  const SizedBox(height: KanzSpace.s2),
                  Text(
                    body,
                    style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({required this.selected, required this.onSelect});

  /// The language the app is showing now ('en' or 'ar').
  final String selected;
  final ValueChanged<LocalePref> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    // Each option is written in its own language; its lines keep the
    // screen's alignment so the two cards read as one list.
    final align = context.isRtl ? TextAlign.right : TextAlign.left;
    Widget option({
      required String name,
      required String sample,
      required TextDirection direction,
      required bool isSelected,
      required LocalePref pref,
    }) => ChoiceCard(
      selected: isSelected,
      semanticsLabel: '$name. $sample',
      onTap: () => onSelect(pref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            style: t.headlineSmall,
            textDirection: direction,
            textAlign: align,
          ),
          const SizedBox(height: KanzSpace.s4),
          Text(
            sample,
            style: t.bodyMedium?.copyWith(color: c.inkSecondary),
            textDirection: direction,
            textAlign: align,
          ),
        ],
      ),
    );

    return _StepBody(
      children: [
        _StepHeading(
          title: l10n.onboardingLanguageTitle,
          body: l10n.onboardingLanguageBody,
        ),
        const SizedBox(height: KanzSpace.s32),
        option(
          name: l10n.commonLanguageEnglish,
          sample: l10n.onboardingLanguageEnglishSample,
          direction: TextDirection.ltr,
          isSelected: selected == 'en',
          pref: LocalePref.en,
        ),
        const SizedBox(height: KanzSpace.s12),
        option(
          name: l10n.commonLanguageArabic,
          sample: l10n.onboardingLanguageArabicSample,
          direction: TextDirection.rtl,
          isSelected: selected == 'ar',
          pref: LocalePref.ar,
        ),
        const SizedBox(height: KanzSpace.s16),
        Text(l10n.onboardingChangeLater, style: t.bodySmall),
      ],
    );
  }
}

class _SkillStep extends StatelessWidget {
  const _SkillStep({required this.selected, required this.onSelect});

  final SkillLevel selected;
  final ValueChanged<SkillLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    return _StepBody(
      children: [
        _StepHeading(
          title: l10n.onboardingSkillTitle,
          body: l10n.onboardingSkillBody,
        ),
        const SizedBox(height: KanzSpace.s32),
        for (final skill in SkillLevel.values) ...[
          if (skill != SkillLevel.values.first)
            const SizedBox(height: KanzSpace.s12),
          ChoiceCard(
            selected: skill == selected,
            semanticsLabel:
                '${skillLabel(l10n, skill)}. ${skillLine(l10n, skill)}',
            onTap: () => onSelect(skill),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LevelMeter(level: skillRank(skill)),
                const SizedBox(height: KanzSpace.s12),
                Text(skillLabel(l10n, skill), style: t.headlineSmall),
                const SizedBox(height: KanzSpace.s4),
                Text(
                  skillLine(l10n, skill),
                  style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ToolsStep extends StatelessWidget {
  const _ToolsStep({
    required this.tools,
    required this.selected,
    required this.onToggle,
  });

  final List<ToolEntry> tools;
  final Set<ToolId> selected;
  final ValueChanged<ToolId> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final c = context.kanzColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: KanzSpace.s24, bottom: KanzSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: KanzSpace.page,
            child: _StepHeading(
              title: l10n.onboardingToolsTitle,
              body: l10n.onboardingToolsBody,
            ),
          ),
          const SizedBox(height: KanzSpace.s24),
          Padding(
            padding: KanzSpace.page,
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingToolsCount(selected.length),
                    style: t.titleSmall,
                  ),
                  if (selected.isEmpty) ...[
                    const SizedBox(height: KanzSpace.s4),
                    Text(
                      l10n.onboardingToolsNone,
                      style: t.bodySmall?.copyWith(color: c.inkSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: KanzSpace.s16),
          ToolPicker(tools: tools, selected: selected, onToggle: onToggle),
        ],
      ),
    );
  }
}
