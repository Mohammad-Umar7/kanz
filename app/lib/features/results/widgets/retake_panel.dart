import 'package:flutter/material.dart';

import '../../../core/design/design.dart';

/// The model could not use the photo (too dark, blurry, nothing in it) or
/// could not tell what a description meant: what went wrong in one line,
/// the backend's tip for next time, and the ways to try again.
class RetakePanel extends StatelessWidget {
  const RetakePanel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.tip,
    required this.actions,
  });

  /// Mono label over the title, for example "What to try".
  final String eyebrow;
  final String title;
  final String? tip;

  /// Primary first.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(KanzIcons.warning, size: 18, color: c.caution),
              const SizedBox(width: KanzSpace.s8),
              Expanded(child: MonoLabel(eyebrow, color: c.caution)),
            ],
          ),
          const SizedBox(height: KanzSpace.s8),
          Semantics(header: true, child: Text(title, style: t.headlineMedium)),
          if (tip case final tip? when tip.trim().isNotEmpty) ...[
            const SizedBox(height: KanzSpace.s8),
            Text(tip, style: t.bodyLarge?.copyWith(color: c.inkSecondary)),
          ],
          const SizedBox(height: KanzSpace.s24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: KanzSpace.s8,
            children: actions,
          ),
        ],
      ),
    );
  }
}
