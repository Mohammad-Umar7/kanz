import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../core/state/generated_image.dart';
import '../../../l10n/l10n.dart';
import 'content_direction.dart';
import 'image_sources.dart';
import 'step_image.dart';

/// One tutorial step: the Fraunces numeral ("03 / 07", always left to
/// right) with the step's time, the step picture (with a quiet "Redraw
/// picture" under it once it is ready), the title, the instruction at a
/// comfortable reading size, then the warning and the tip.
class TutorialStepPage extends StatelessWidget {
  const TutorialStepPage({
    super.key,
    required this.step,
    required this.total,
    required this.done,
    required this.image,
    required this.onRegenerate,
    required this.lang,
    this.blockedBy,
    this.fallbackPhoto,
    this.offline = false,
  });

  final TutorialStep step;
  final int total;
  final bool done;
  final GeneratedImageState image;
  final VoidCallback? onRegenerate;

  /// Language the tutorial was written in, for the direction of its text.
  final Lang lang;
  final StepImageBlock? blockedBy;
  final ImageProvider? fallbackPhoto;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final warning = step.warning;
    final tip = step.tip;
    final direction = contentDirection(lang);
    final canRedraw =
        onRegenerate != null && generatedImageProvider(image) != null;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StepNumeral(
              current: step.number,
              total: total,
              semanticsLabel: l10n.commonStepOf(step.number, total),
            ),
            const SizedBox(width: KanzSpace.s16),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(bottom: KanzSpace.s8),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: KanzSpace.s12,
                  runSpacing: KanzSpace.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (done)
                      _Meta(
                        icon: KanzIcons.checkCircle,
                        label: l10n.tutorialStepDoneTag,
                        color: c.ink,
                      ),
                    _Meta(
                      icon: KanzIcons.timer,
                      label: l10n.commonMinutes(step.durationMinutes),
                      color: c.inkSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KanzSpace.s16),
        StepImage(
          number: step.number,
          title: step.title,
          image: image,
          onRegenerate: onRegenerate,
          blockedBy: blockedBy,
          fallbackPhoto: fallbackPhoto,
          offline: offline,
        ),
        if (canRedraw)
          _RedrawLink(label: l10n.tutorialRedraw, onPressed: onRegenerate!)
        else
          const SizedBox(height: KanzSpace.s24),
        Semantics(
          header: true,
          child: Text(
            step.title,
            style: t.headlineMedium,
            textDirection: direction,
          ),
        ),
        const SizedBox(height: KanzSpace.s12),
        Text(step.instruction, style: t.bodyLarge, textDirection: direction),
        if (warning != null && warning.isNotEmpty) ...[
          const SizedBox(height: KanzSpace.s24),
          Callout(
            variant: CalloutVariant.warning,
            title: l10n.tutorialCareful,
            message: isolateContent(context, warning, lang),
          ),
        ],
        if (tip != null && tip.isNotEmpty) ...[
          SizedBox(
            height: warning != null && warning.isNotEmpty
                ? KanzSpace.s12
                : KanzSpace.s24,
          ),
          Callout(
            variant: CalloutVariant.tip,
            title: l10n.tutorialTip,
            message: isolateContent(context, tip, lang),
          ),
        ],
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: KanzSpace.s4),
          MonoLabel(label, color: color),
        ],
      ),
    );
  }
}

/// "Redraw picture": a quiet text action under a finished step picture,
/// starting on the gutter like the title below it. 48 dp tall.
class _RedrawLink extends StatelessWidget {
  const _RedrawLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: KanzSpace.s4,
        bottom: KanzSpace.s12,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          button: true,
          label: label,
          onTap: onPressed,
          excludeSemantics: true,
          child: InkWell(
            key: const ValueKey('redraw-step'),
            onTap: onPressed,
            borderRadius: KanzRadii.tagAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: KanzSpace.touchTarget,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: KanzSpace.s8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(KanzIcons.retry, size: 18, color: c.ink),
                    const SizedBox(width: KanzSpace.s8),
                    Flexible(
                      child: Text(label, style: context.textStyles.labelLarge),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
