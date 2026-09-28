import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/data/vocab/vocab.dart';
import '../../../core/design/design.dart';
import '../../../l10n/l10n.dart';

/// What the user asked the tutorial to be rewritten for.
typedef AdaptRequest = ({SkillLevel skill, List<ToolId> tools});

/// Opens the adapt sheet and returns the new skill and tools, or null when
/// the user closed it without a change.
Future<AdaptRequest?> showAdaptSheet({
  required BuildContext context,
  required SkillLevel skill,
  required List<ToolId> tools,
  required List<ToolEntry> choices,
  required bool offline,
}) {
  return showKanzSheet<AdaptRequest>(
    context: context,
    builder: (context) => AdaptSheet(
      skill: skill,
      tools: tools,
      choices: choices,
      offline: offline,
    ),
  );
}

/// Skill as three segments and the tools the user has as chips. The
/// primary action stays disabled until something changed, and offline it
/// explains why it cannot run.
class AdaptSheet extends StatefulWidget {
  const AdaptSheet({
    super.key,
    required this.skill,
    required this.tools,
    required this.choices,
    required this.offline,
  });

  final SkillLevel skill;
  final List<ToolId> tools;

  /// Tools to offer, the ones this tutorial uses first.
  final List<ToolEntry> choices;
  final bool offline;

  @override
  State<AdaptSheet> createState() => _AdaptSheetState();
}

class _AdaptSheetState extends State<AdaptSheet> {
  late SkillLevel _skill = widget.skill;
  late final Set<ToolId> _tools = {...widget.tools};

  bool get _changed =>
      _skill != widget.skill ||
      _tools.length != widget.tools.length ||
      !_tools.containsAll(widget.tools);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.kanzColors;
    final t = context.textStyles;
    final locale = Localizations.localeOf(context);
    final canSubmit = _changed && !widget.offline;
    return KanzSheet(
      title: l10n.tutorialAdaptTitle,
      subtitle: l10n.tutorialAdaptBody,
      actions: [
        if (widget.offline || _changed)
          Row(
            children: [
              Icon(
                widget.offline ? KanzIcons.offline : KanzIcons.info,
                size: 16,
                color: c.inkSecondary,
              ),
              const SizedBox(width: KanzSpace.s8),
              Expanded(
                child: Text(
                  widget.offline
                      ? l10n.tutorialAdaptOffline
                      : l10n.tutorialAdaptProgressNote,
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
        KanzButton(
          label: l10n.tutorialAdaptSubmit,
          expand: true,
          onPressed: canSubmit
              ? () => Navigator.of(context).pop<AdaptRequest>((
                  skill: _skill,
                  tools: [
                    for (final entry in widget.choices)
                      if (_tools.contains(entry.id)) entry.id,
                  ],
                ))
              : null,
        ),
      ],
      child: SingleChildScrollView(
        padding: KanzSpace.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonoLabel(l10n.tutorialAdaptSkill),
            const SizedBox(height: KanzSpace.s8),
            SegmentedTabs(
              selectedIndex: SkillLevel.values.indexOf(_skill),
              onChanged: (i) => setState(() => _skill = SkillLevel.values[i]),
              tabs: [
                for (final level in SkillLevel.values)
                  SegmentedTab(label: skillLabel(l10n, level)),
              ],
            ),
            const SizedBox(height: KanzSpace.s24),
            MonoLabel(l10n.tutorialAdaptTools),
            const SizedBox(height: KanzSpace.s4),
            Text(l10n.tutorialAdaptToolsHint, style: t.bodySmall),
            const SizedBox(height: KanzSpace.s8),
            Wrap(
              spacing: KanzSpace.s8,
              children: [
                for (final entry in widget.choices)
                  KanzChip(
                    key: ValueKey('adapt-tool-${entry.id.id}'),
                    label: entry.label.forLocale(locale),
                    selected: _tools.contains(entry.id),
                    icon: _tools.contains(entry.id) ? KanzIcons.check : null,
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _tools.add(entry.id);
                      } else {
                        _tools.remove(entry.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: KanzSpace.s8),
          ],
        ),
      ),
    );
  }
}
