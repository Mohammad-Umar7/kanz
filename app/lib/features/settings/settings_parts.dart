import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../core/state/core_providers.dart';
import '../../core/state/settings_providers.dart';
import '../../l10n/l10n.dart';
import '../onboarding/choice_card.dart';
import '../onboarding/tool_picker.dart';

/// A single-choice settings row: title, optional detail and a radio mark at
/// the end. The whole row is the target.
class RadioRow extends StatelessWidget {
  const RadioRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.titleDirection,
    this.divider = true,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// Shown before the radio mark (a chevron to change the city).
  final Widget? trailing;

  /// For a title written in the other script (العربية in English).
  final TextDirection? titleDirection;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final align = context.isRtl ? TextAlign.right : TextAlign.left;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          margin: const EdgeInsetsDirectional.only(start: KanzSpace.gutter),
          padding: const EdgeInsetsDirectional.fromSTEB(
            0,
            KanzSpace.s12,
            KanzSpace.gutter,
            KanzSpace.s12,
          ),
          // The hairline starts at the gutter so the rows read as one list.
          decoration: BoxDecoration(
            border: divider ? Border(bottom: BorderSide(color: c.line)) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: t.bodyLarge,
                      textDirection: titleDirection,
                      textAlign: titleDirection == null ? null : align,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: KanzSpace.s2),
                      Text(subtitle!, style: t.bodySmall),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: KanzSpace.s12),
                trailing!,
              ],
              const SizedBox(width: KanzSpace.s16),
              RadioMark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Scissors, Pliers, Twine and 4 more", or the no-tools line.
String toolsSummary(
  AppLocalizations l10n,
  Vocab vocab,
  Locale locale,
  List<ToolId> tools,
) {
  if (tools.isEmpty) return l10n.settingsToolsNone;
  final names = [for (final t in tools) vocab.tool(t).label.forLocale(locale)];
  const shown = 3;
  final sep = l10n.settingsToolsListSeparator;
  if (names.length <= shown) return names.join(sep);
  return l10n.settingsToolsMore(
    names.take(shown).join(sep),
    names.length - shown,
  );
}

/// Settings > My tools: the same grouped grid as onboarding, in a sheet.
/// Changes are saved as they are made.
Future<void> showToolsSheet(BuildContext context) => showKanzSheet<void>(
  context: context,
  builder: (sheetContext) => const _ToolsSheet(),
);

class _ToolsSheet extends ConsumerWidget {
  const _ToolsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tools = ref.watch(settingsProvider.select((s) => s.tools));
    final vocab = ref.watch(vocabProvider);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: KanzSheet(
        title: l10n.settingsTools,
        subtitle: l10n.onboardingToolsBody,
        actions: [
          KanzButton(
            label: l10n.commonDone,
            onPressed: () => Navigator.pop(context),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: KanzSpace.page,
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.onboardingToolsCount(tools.length),
                    style: context.textStyles.titleSmall,
                  ),
                ),
              ),
              const SizedBox(height: KanzSpace.s12),
              ToolPicker(
                tools: vocab.realTools,
                selected: tools.toSet(),
                onToggle: ref.read(settingsProvider.notifier).toggleTool,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
