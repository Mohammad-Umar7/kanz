import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'data.dart';

enum CalloutVariant {
  /// A helpful hint. Neutral ink.
  tip,

  /// Something that can go wrong. Caution glyph.
  warning,

  /// Protective gear or a hazard rule. Danger glyph and label.
  safety,
}

/// A short note set apart from the body: tip, warning or safety. Sunken
/// fill, a glyph, a mono title and the message. Never a colored slab.
class Callout extends StatelessWidget {
  const Callout({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    this.icon,
  });

  final CalloutVariant variant;

  /// Mono heading, for example "Tip", "Careful" or "Safety".
  final String title;
  final String message;

  /// Overrides the variant's glyph.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final (IconData glyph, Color tint) = switch (variant) {
      CalloutVariant.tip => (KanzIcons.tip, c.ink),
      CalloutVariant.warning => (KanzIcons.warning, c.caution),
      CalloutVariant.safety => (KanzIcons.safety, c.danger),
    };
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(
          KanzSpace.s12,
          KanzSpace.s12,
          KanzSpace.s16,
          KanzSpace.s12,
        ),
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          borderRadius: KanzRadii.inputAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? glyph, size: 20, color: tint),
            const SizedBox(width: KanzSpace.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonoLabel(
                    title,
                    color: variant == CalloutVariant.tip ? null : tint,
                  ),
                  const SizedBox(height: 2),
                  Text(message, style: context.textStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
