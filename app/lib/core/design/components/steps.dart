import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';

/// "03 / 07" in Fraunces: the current step large, the total small.
class StepNumeral extends StatelessWidget {
  const StepNumeral({
    super.key,
    required this.current,
    required this.total,
    required this.semanticsLabel,
  });

  final int current;
  final int total;

  /// For example "Step 3 of 7".
  final String semanticsLabel;

  static String pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final type = context.kanzType;
    final c = context.kanzColors;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: pad(current), style: type.numeral),
            TextSpan(
              text: '  /  ${pad(total)}',
              style: type.numeralSmall.copyWith(color: c.inkSecondary),
            ),
          ],
        ),
        // Numerals read left to right in both languages.
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

/// Tutorial progress as one segment per step: done steps in ink, the
/// current step in clay, upcoming steps sunken.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.total,
    required this.current,
    required this.semanticsLabel,
    this.completed = const {},
  });

  final int total;

  /// Zero-based index of the step on screen.
  final int current;

  /// Zero-based indexes of steps marked done. When empty, every step
  /// before [current] counts as done.
  final Set<int> completed;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    bool isDone(int i) =>
        completed.isEmpty ? i < current : completed.contains(i);
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: KanzSpace.s4),
            Expanded(
              child: AnimatedContainer(
                key: ValueKey('step-segment-$i'),
                duration: KanzMotion.of(context, KanzMotion.medium),
                curve: KanzMotion.standard,
                height: 4,
                decoration: BoxDecoration(
                  color: i == current
                      ? c.accent
                      : (isDone(i) ? c.ink : c.surfaceSunken),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
