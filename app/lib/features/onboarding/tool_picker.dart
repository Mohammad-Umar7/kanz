/// The tools grid used in onboarding and in Settings > My tools: the
/// vocabulary's real tools (never protective gear) grouped the way a
/// workshop wall is, each group with a glyph and a count.
library;

import 'package:flutter/material.dart';

import '../../core/data/models/models.dart';
import '../../core/data/vocab/vocab.dart';
import '../../core/design/design.dart';
import '../../l10n/l10n.dart';

/// Workshop groups, in the order they are shown.
enum ToolGroup {
  cutting,
  measuring,
  joining,
  building,
  finishing,
  sewing,
  other,
}

ToolGroup toolGroupOf(ToolId tool) => switch (tool) {
  ToolId.scissors ||
  ToolId.craftKnife ||
  ToolId.handsaw ||
  ToolId.wireCutter => ToolGroup.cutting,
  ToolId.measuringTape || ToolId.rulerPencil => ToolGroup.measuring,
  ToolId.hotGlueGun ||
  ToolId.strongGlue ||
  ToolId.woodGlue ||
  ToolId.maskingTape ||
  ToolId.twine ||
  ToolId.craftWire ||
  ToolId.clamps ||
  ToolId.stapleGun => ToolGroup.joining,
  ToolId.drill ||
  ToolId.screwdriver ||
  ToolId.hammer ||
  ToolId.pliers => ToolGroup.building,
  ToolId.sandpaper ||
  ToolId.paintbrush ||
  ToolId.acrylicPaint ||
  ToolId.sprayPaint ||
  ToolId.varnish => ToolGroup.finishing,
  ToolId.sewingKit || ToolId.sewingMachine || ToolId.iron => ToolGroup.sewing,
  _ => ToolGroup.other,
};

IconData toolGroupGlyph(ToolGroup group) => switch (group) {
  ToolGroup.cutting => KanzIcons.scissors,
  ToolGroup.measuring => KanzIcons.ruler,
  ToolGroup.joining => KanzIcons.water,
  ToolGroup.building => KanzIcons.hammer,
  ToolGroup.finishing => KanzIcons.paintBrush,
  ToolGroup.sewing => KanzIcons.textile,
  ToolGroup.other => KanzIcons.tools,
};

String toolGroupLabel(AppLocalizations l10n, ToolGroup group) =>
    switch (group) {
      ToolGroup.cutting => l10n.onboardingToolGroupCutting,
      ToolGroup.measuring => l10n.onboardingToolGroupMeasuring,
      ToolGroup.joining => l10n.onboardingToolGroupJoining,
      ToolGroup.building => l10n.onboardingToolGroupBuilding,
      ToolGroup.finishing => l10n.onboardingToolGroupFinishing,
      ToolGroup.sewing => l10n.onboardingToolGroupSewing,
      ToolGroup.other => l10n.onboardingToolGroupOther,
    };

/// Groups [tools] (keeping the vocabulary order inside each group) and drops
/// empty groups.
List<(ToolGroup, List<ToolEntry>)> groupTools(List<ToolEntry> tools) {
  final byGroup = <ToolGroup, List<ToolEntry>>{};
  for (final tool in tools) {
    if (tool.id.isSafetyGear) continue;
    byGroup.putIfAbsent(toolGroupOf(tool.id), () => []).add(tool);
  }
  return [
    for (final group in ToolGroup.values)
      if (byGroup[group] case final entries?) (group, entries),
  ];
}

/// The grouped chip grid. Selected chips are ink with a check; the others
/// carry a plus, so a chip keeps its width when toggled.
class ToolPicker extends StatelessWidget {
  const ToolPicker({
    super.key,
    required this.tools,
    required this.selected,
    required this.onToggle,
    this.padding = KanzSpace.page,
  });

  /// Usually `vocab.realTools`.
  final List<ToolEntry> tools;
  final Set<ToolId> selected;
  final ValueChanged<ToolId> onToggle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final c = context.kanzColors;
    final t = context.textStyles;
    final groups = groupTools(tools);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (group, entries) in groups)
            Container(
              padding: const EdgeInsets.only(
                top: KanzSpace.s16,
                bottom: KanzSpace.s12,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GroupHeader(
                    glyph: toolGroupGlyph(group),
                    label: toolGroupLabel(l10n, group),
                    selected: entries
                        .where((e) => selected.contains(e.id))
                        .length,
                    total: entries.length,
                    style: t.titleSmall,
                  ),
                  const SizedBox(height: KanzSpace.s4),
                  Wrap(
                    spacing: KanzSpace.s8,
                    children: [
                      for (final tool in entries)
                        KanzChip(
                          label: tool.label.forLocale(locale),
                          icon: selected.contains(tool.id)
                              ? KanzIcons.check
                              : KanzIcons.add,
                          selected: selected.contains(tool.id),
                          onSelected: (_) => onToggle(tool.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.total,
    required this.style,
  });

  final IconData glyph;
  final String label;
  final int selected;
  final int total;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final l10n = context.l10n;
    return MergeSemantics(
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Icon(glyph, size: 20, color: c.ink),
            const SizedBox(width: KanzSpace.s12),
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: KanzSpace.s12),
            Semantics(
              label: l10n.onboardingToolGroupCount(selected, total),
              excludeSemantics: true,
              child: MonoLabel(
                '$selected / $total',
                color: selected > 0 ? c.ink : null,
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
