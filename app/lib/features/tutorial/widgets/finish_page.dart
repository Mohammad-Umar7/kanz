import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../l10n/l10n.dart';
import 'content_direction.dart';
import 'page_parts.dart';

/// The last page: the finished object (last step picture, makeover or the
/// user's photo), finishing touches, care notes and how many steps are done.
/// "Finish project" lives in the bottom bar.
class TutorialFinishPage extends StatelessWidget {
  const TutorialFinishPage({
    super.key,
    required this.tutorial,
    required this.doneCount,
    required this.hero,
  });

  final Tutorial tutorial;
  final int doneCount;
  final ImageProvider? hero;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final total = tutorial.steps.length;
    final open = (total - doneCount).clamp(0, total);
    final direction = contentDirection(tutorial.lang);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      children: [
        if (hero != null) ...[
          HeroPicture(image: hero!),
          const SizedBox(height: KanzSpace.s24),
        ],
        MonoLabel(l10n.tutorialFinishEyebrow),
        const SizedBox(height: KanzSpace.s4),
        Semantics(
          header: true,
          child: Text(l10n.tutorialFinishTitle, style: t.headlineLarge),
        ),
        if (tutorial.finishing.isNotEmpty) ...[
          const SizedBox(height: KanzSpace.s24),
          PageSectionTitle(l10n.tutorialFinishingLabel),
          NumberedList(items: tutorial.finishing, textDirection: direction),
        ],
        if (tutorial.care.isNotEmpty) ...[
          const SizedBox(height: KanzSpace.s24),
          PageSectionTitle(l10n.tutorialCareLabel),
          NumberedList(items: tutorial.care, textDirection: direction),
        ],
        const SizedBox(height: KanzSpace.s32),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.line)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: KanzSpace.s16),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        open == 0 ? KanzIcons.checkCircle : KanzIcons.circle,
                        size: 20,
                        color: open == 0 ? c.ink : c.lineStrong,
                      ),
                      const SizedBox(width: KanzSpace.s12),
                      Expanded(
                        child: Text(
                          l10n.tutorialStepsDone(doneCount, total),
                          style: t.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  if (open > 0) ...[
                    const SizedBox(height: KanzSpace.s4),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: KanzSpace.s32,
                      ),
                      child: Text(
                        l10n.tutorialStepsOpen(open),
                        style: t.bodySmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
