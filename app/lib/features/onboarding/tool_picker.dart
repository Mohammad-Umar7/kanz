/// The one tool picker in Kanz. Onboarding owns it; Settings > My tools and
/// the tutorial's adapt sheet use it too, so the user edits the same list in
/// the same design everywhere: the vocabulary's real tools (never protective
/// gear) grouped the way a workshop wall is, each group with a glyph and a
/// count. Its strings are `commonToolGroup*`.
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
      ToolGroup.cutting => l10n.commonToolGroupCutting,
      ToolGroup.measuring => l10n.commonToolGroupMeasuring,
      ToolGroup.joining => l10n.commonToolGroupJoining,
      ToolGroup.building => l10n.commonToolGroupBuilding,
      ToolGroup.finishing => l10n.commonToolGroupFinishing,
      ToolGroup.sewing => l10n.commonToolGroupSewing,
      ToolGroup.other => l10n.commonToolGroupOther,
    };

/// Groups [tools] (keeping their order inside each group) and drops empty
/// groups and protective gear.
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
/// carry a plus, so a chip keeps its width when toggled. Each chip has the
/// key `ValueKey('tool-<id>')`.
///
/// Inside a scrolling sheet, [revealSelected] scrolls it on open just far
/// enough to show the first group that holds a selected tool, so the user
/// sees what they have before what they could add.
class ToolPicker extends StatefulWidget {
  const ToolPicker({
    super.key,
    required this.tools,
    required this.selected,
    required this.onToggle,
    this.padding = KanzSpace.page,
    this.revealSelected = false,
  });

  /// Usually `vocab.realTools`.
  final List<ToolEntry> tools;
  final Set<ToolId> selected;
  final ValueChanged<ToolId> onToggle;
  final EdgeInsetsGeometry padding;
  final bool revealSelected;

  @override
  State<ToolPicker> createState() => _ToolPickerState();
}

class _ToolPickerState extends State<ToolPicker> {
  final _groupKeys = <ToolGroup, GlobalKey>{};

  GlobalKey _keyFor(ToolGroup group) =>
      _groupKeys.putIfAbsent(group, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    if (widget.revealSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  void _reveal() {
    if (!mounted) return;
    for (final (group, entries) in groupTools(widget.tools)) {
      if (!entries.any((e) => widget.selected.contains(e.id))) continue;
      final target = _groupKeys[group]?.currentContext;
      if (target != null && Scrollable.maybeOf(target) != null) {
        // Scrolls only when the group is (partly) below the fold.
        Scrollable.ensureVisible(
          target,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final c = context.kanzColors;
    final t = context.textStyles;
    final selected = widget.selected;
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (group, entries) in groupTools(widget.tools))
            Container(
              key: _keyFor(group),
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
                          key: ValueKey('tool-${tool.id.id}'),
                          label: tool.label.forLocale(locale),
                          icon: selected.contains(tool.id)
                              ? KanzIcons.check
                              : KanzIcons.add,
                          selected: selected.contains(tool.id),
                          onSelected: (_) => widget.onToggle(tool.id),
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
              label: l10n.commonToolGroupCount(selected, total),
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
