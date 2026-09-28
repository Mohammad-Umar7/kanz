import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'data.dart';

/// A start-aligned section heading: optional mono eyebrow, a title and an
/// optional trailing action ("See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.action,
    this.large = false,
    this.padding = KanzSpace.page,
  });

  final String title;

  /// Mono label above the title, for example "Step 2".
  final String? eyebrow;
  final String? subtitle;

  /// Usually a [KanzButton.tertiary].
  final Widget? action;

  /// Fraunces headline instead of the sans title.
  final bool large;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  MonoLabel(eyebrow!),
                  const SizedBox(height: KanzSpace.s4),
                ],
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: large ? t.headlineMedium : t.titleLarge,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: KanzSpace.s4),
                  Text(subtitle!, style: t.bodySmall),
                ],
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: KanzSpace.s8), action!],
        ],
      ),
    );
  }
}

/// Shows [KanzSheet] content as a modal bottom sheet.
Future<T?> showKanzSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    useSafeArea: true,
    showDragHandle: false,
    builder: builder,
  );
}

/// The layout inside a bottom sheet: handle, title, optional subtitle,
/// content and an optional action row pinned under it. Radius 20 on top.
class KanzSheet extends StatelessWidget {
  const KanzSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Buttons, primary last (it sits nearest the thumb).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: KanzRadii.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: KanzSpace.s12,
                    bottom: KanzSpace.s16,
                  ),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.lineStrong,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              Padding(
                padding: KanzSpace.page,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: t.headlineSmall),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: KanzSpace.s4),
                      Text(
                        subtitle!,
                        style: t.bodyMedium?.copyWith(color: c.inkSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: KanzSpace.s16),
              Flexible(child: child),
              if (actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    KanzSpace.gutter,
                    KanzSpace.s16,
                    KanzSpace.gutter,
                    KanzSpace.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: KanzSpace.s8,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A list row: optional leading glyph, title, subtitle and a trailing
/// value or chevron. 56 dp minimum, gutter-aligned.
class KanzListTile extends StatelessWidget {
  const KanzListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.value,
    this.onTap,
    this.showChevron = false,
    this.divider = false,
  });

  final String title;
  final String? subtitle;

  /// Usually an [Icon] from [KanzIcons].
  final Widget? leading;
  final Widget? trailing;

  /// Mono value at the end ("English", "12 KM").
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  /// Hairline under the row.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final tile = Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: KanzSpace.gutter,
            vertical: KanzSpace.s12,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: c.ink, size: 22),
                  child: leading!,
                ),
                const SizedBox(width: KanzSpace.s16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: t.bodySmall),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: KanzSpace.s12),
                MonoLabel(value!),
              ],
              if (trailing != null) ...[
                const SizedBox(width: KanzSpace.s12),
                trailing!,
              ],
              if (showChevron) ...[
                const SizedBox(width: KanzSpace.s8),
                Icon(KanzIcons.chevronForward, size: 18, color: c.inkSecondary),
              ],
            ],
          ),
        ),
      ),
    );
    if (!divider) return tile;
    // The hairline starts at the gutter so rows read as one list.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Padding(
          padding: const EdgeInsetsDirectional.only(start: KanzSpace.gutter),
          child: Divider(height: 1, color: c.line),
        ),
      ],
    );
  }
}
