import 'package:flutter/material.dart';

import '../context.dart';
import '../tokens.dart';

/// The one card surface in Kanz: white (or dark surface), a hairline
/// border, radius 16, no shadow. Cards are never nested in cards.
///
/// When [selected] the border becomes a 1.5 px ink line, which reads as a
/// selection in both themes without adding a color.
class KanzCard extends StatelessWidget {
  const KanzCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsetsDirectional.all(KanzSpace.s16),
    this.color,
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;

  /// Overrides the surface color (for example the sunken fill of a callout).
  final Color? color;

  /// Describes the card when it is tappable.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final shape = RoundedRectangleBorder(
      borderRadius: KanzRadii.cardAll,
      side: selected
          ? BorderSide(color: c.ink, width: 1.5)
          : BorderSide(color: c.line),
    );
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, customBorder: shape, child: content);
    }
    return Semantics(
      container: true,
      button: onTap != null,
      selected: onTap != null ? selected : null,
      label: semanticsLabel,
      child: AnimatedContainer(
        duration: KanzMotion.of(context, KanzMotion.fast),
        curve: KanzMotion.standard,
        decoration: ShapeDecoration(color: color ?? c.surface, shape: shape),
        child: Material(
          type: MaterialType.transparency,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: content,
        ),
      ),
    );
  }
}
