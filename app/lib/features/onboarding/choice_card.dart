import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/design/design.dart';
import '../../l10n/l10n.dart';

/// One answer of a single-choice question: a card with its content and a
/// radio mark at the end. Selected draws the card's 1.5 px ink border and
/// fills the mark; it is announced as a selected option in a group.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.semanticsLabel,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final String semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: semanticsLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: KanzCard(
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.s20,
          KanzSpace.s16,
          KanzSpace.s16,
          KanzSpace.s16,
        ),
        child: Row(
          children: [
            Expanded(child: child),
            const SizedBox(width: KanzSpace.s16),
            RadioMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// A radio circle drawn from tokens: hairline when off, ink ring and dot
/// when on.
class RadioMark extends StatelessWidget {
  const RadioMark({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final duration = KanzMotion.of(context, KanzMotion.fast);
    return AnimatedContainer(
      duration: duration,
      curve: KanzMotion.standard,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.ink : c.lineStrong,
          width: selected ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: duration,
        curve: KanzMotion.standard,
        width: selected ? 10 : 0,
        height: selected ? 10 : 0,
        decoration: BoxDecoration(color: c.ink, shape: BoxShape.circle),
      ),
    );
  }
}

/// Three short bars, [level] of them filled: the skill level at a glance.
class LevelMeter extends StatelessWidget {
  const LevelMeter({super.key, required this.level, this.of = 3});

  final int level;
  final int of;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < of; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Container(
              width: 16,
              height: 6,
              decoration: BoxDecoration(
                color: i < level ? c.ink : c.track,
                borderRadius: const BorderRadius.all(Radius.circular(1.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One concrete line that says what each skill level can do.
String skillLine(AppLocalizations l10n, SkillLevel skill) => switch (skill) {
  SkillLevel.beginner => l10n.onboardingSkillBeginnerLine,
  SkillLevel.intermediate => l10n.onboardingSkillIntermediateLine,
  SkillLevel.advanced => l10n.onboardingSkillAdvancedLine,
};

/// 1, 2 or 3.
int skillRank(SkillLevel skill) => SkillLevel.values.indexOf(skill) + 1;
