import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/data/vocab/vocab.dart';
import '../../../core/design/design.dart';
import '../../../l10n/l10n.dart';
import 'page_parts.dart';

/// The first page of the tutorial: what the project needs before step 1.
///
/// Hero picture, title, the "your version" line (the backend's adapted note,
/// highlighted right after a rewrite), a spec grid, materials (the ones from
/// the scan marked with their material color), tools with have / missing and
/// the stand-in for a missing one, safety notes with protective gear, and the
/// knowledge documents the tutorial was grounded in.
class TutorialOverviewPage extends StatelessWidget {
  const TutorialOverviewPage({
    super.key,
    required this.tutorial,
    required this.vocab,
    required this.hero,
    this.heroInset,
    required this.categoryOf,
    required this.noteHighlighted,
    required this.onAdapt,
  });

  final Tutorial tutorial;
  final Vocab vocab;

  /// The makeover when it exists, otherwise the user's photo.
  final ImageProvider? hero;

  /// The user's photo, inset in the corner when [hero] is the makeover.
  final ImageProvider? heroInset;

  /// Material category of a scanned item, for the dots on "from your scan"
  /// materials. Null when the item is unknown.
  final MaterialCategory? Function(String itemId) categoryOf;
  final bool noteHighlighted;

  /// Opens the adapt sheet; null hides the action (offline).
  final VoidCallback? onAdapt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.textStyles;
    final locale = Localizations.localeOf(context);
    final have = tutorial.tools.where((tool) => tool.have).length;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.gutter,
        KanzSpace.s8,
        KanzSpace.gutter,
        KanzSpace.s32,
      ),
      children: [
        if (hero != null) ...[
          HeroPicture(
            image: hero!,
            inset: heroInset,
            insetLabel: l10n.tutorialBefore,
          ),
          const SizedBox(height: KanzSpace.s24),
        ],
        MonoLabel(l10n.tutorialEyebrow),
        const SizedBox(height: KanzSpace.s4),
        Semantics(
          header: true,
          child: Text(tutorial.title, style: t.headlineLarge),
        ),
        const SizedBox(height: KanzSpace.s20),
        AdaptedNote(
          label: l10n.tutorialAdaptedLabel,
          note: tutorial.adaptedNote,
          highlighted: noteHighlighted,
          updatedLabel: l10n.tutorialUpdated,
          actionLabel: l10n.tutorialChangeSetup,
          onAction: onAdapt,
        ),
        const SizedBox(height: KanzSpace.s24),
        DataGrid(
          entries: [
            DataGridEntry(
              l10n.tutorialSpecSkill,
              value: skillLabel(l10n, tutorial.skill),
            ),
            DataGridEntry(
              l10n.tutorialSpecTime,
              value: l10n.commonMinutes(tutorial.totalMinutes),
            ),
            DataGridEntry(
              l10n.tutorialSpecSteps,
              value: '${tutorial.steps.length}',
            ),
            DataGridEntry(
              l10n.tutorialSpecTools,
              value: l10n.tutorialToolsReady(have, tutorial.tools.length),
            ),
          ],
        ),
        if (tutorial.materials.isNotEmpty) ...[
          const SizedBox(height: KanzSpace.s32),
          PageSectionTitle(l10n.tutorialMaterialsTitle),
          for (var i = 0; i < tutorial.materials.length; i++)
            _MaterialRow(
              material: tutorial.materials[i],
              category: tutorial.materials[i].itemId == null
                  ? null
                  : categoryOf(tutorial.materials[i].itemId!),
              fromScanLabel: l10n.tutorialFromScan,
              divider: i > 0,
            ),
        ],
        if (tutorial.tools.isNotEmpty) ...[
          const SizedBox(height: KanzSpace.s32),
          PageSectionTitle(l10n.tutorialToolsTitle),
          for (var i = 0; i < tutorial.tools.length; i++)
            _ToolRow(
              tool: tutorial.tools[i],
              label: vocab
                  .tool(tutorial.tools[i].toolId)
                  .label
                  .forLocale(locale),
              haveLabel: l10n.tutorialToolHave,
              missingLabel: l10n.tutorialToolMissing,
              insteadLabel: l10n.tutorialToolInstead,
              divider: i > 0,
            ),
        ],
        const SizedBox(height: KanzSpace.s32),
        PageSectionTitle(l10n.tutorialSafetyTitle),
        const SizedBox(height: KanzSpace.s4),
        if (tutorial.safety.isNotEmpty) ...[
          Callout(
            variant: CalloutVariant.safety,
            title: l10n.tutorialSafetyNotes,
            message: tutorial.safety.join('\n'),
          ),
          const SizedBox(height: KanzSpace.s20),
        ],
        MonoLabel(l10n.tutorialGearLabel),
        const SizedBox(height: KanzSpace.s8),
        Wrap(
          spacing: KanzSpace.s8,
          runSpacing: KanzSpace.s8,
          children: [
            for (final gear in protectiveGearFor(tutorial, vocab))
              _GearTag(
                icon: gearIcon(gear.id),
                label: gear.label.forLocale(locale),
              ),
          ],
        ),
        if (tutorial.sources.isNotEmpty) ...[
          const SizedBox(height: KanzSpace.s32),
          SourceChips(
            title: l10n.tutorialSourcesLabel,
            sources: [for (final s in tutorial.sources) s.title],
          ),
        ],
      ],
    );
  }
}

/// Keywords that tie safety text to a piece of protective gear, in both
/// content languages.
const Map<ToolId, List<String>> _gearKeywords = {
  ToolId.gloves: ['glove', 'قفاز'],
  ToolId.safetyGlasses: ['glasses', 'goggles', 'eye protection', 'نظار'],
  ToolId.dustMask: ['mask', 'respirator', 'كمام'],
};

/// The protective gear this tutorial's safety notes and warnings call for;
/// all of it when the text names none, so the section is never empty.
List<ToolEntry> protectiveGearFor(Tutorial tutorial, Vocab vocab) {
  final text = [
    ...tutorial.safety,
    for (final step in tutorial.steps) ?step.warning,
  ].join(' ').toLowerCase();
  final gear = vocab.safetyGear;
  final named = [
    for (final entry in gear)
      if ((_gearKeywords[entry.id] ?? const <String>[]).any(text.contains))
        entry,
  ];
  return named.isEmpty ? gear : named;
}

IconData gearIcon(ToolId id) => switch (id) {
  ToolId.gloves => KanzIcons.gloves,
  ToolId.safetyGlasses => KanzIcons.goggles,
  ToolId.dustMask => KanzIcons.mask,
  _ => KanzIcons.safety,
};

/// "Your version": the backend's adapted note with the way to change it.
/// Right after a rewrite it takes an ink outline and an "Updated" tag.
class AdaptedNote extends StatelessWidget {
  const AdaptedNote({
    super.key,
    required this.label,
    required this.note,
    required this.highlighted,
    required this.updatedLabel,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final String note;
  final bool highlighted;
  final String updatedLabel;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    return AnimatedContainer(
      key: const ValueKey('adapted-note'),
      duration: KanzMotion.of(context, KanzMotion.medium),
      curve: KanzMotion.standard,
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: KanzRadii.inputAll,
        border: Border.all(
          color: highlighted ? c.ink : c.surfaceSunken,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KanzSpace.s16,
              KanzSpace.s12,
              KanzSpace.s16,
              KanzSpace.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: MonoLabel(label)),
                    if (highlighted) InverseTag(label: updatedLabel),
                  ],
                ),
                const SizedBox(height: KanzSpace.s4),
                Semantics(
                  liveRegion: true,
                  child: Text(note, style: t.bodyLarge),
                ),
              ],
            ),
          ),
          if (onAction != null) ...[
            Divider(height: 1, thickness: 1, color: c.line),
            InkWell(
              onTap: onAction,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(KanzRadii.input),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: KanzSpace.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: KanzSpace.s16,
                    vertical: KanzSpace.s12,
                  ),
                  child: Row(
                    children: [
                      Icon(KanzIcons.filters, size: 18, color: c.ink),
                      const SizedBox(width: KanzSpace.s12),
                      Expanded(child: Text(actionLabel, style: t.labelLarge)),
                      Icon(
                        KanzIcons.chevronForward,
                        size: 18,
                        color: c.inkSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({
    required this.material,
    required this.category,
    required this.fromScanLabel,
    required this.divider,
  });

  final TutorialMaterial material;
  final MaterialCategory? category;
  final String fromScanLabel;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final quantity = material.quantity;
    return HairlineRow(
      divider: divider,
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: KanzSpace.s8),
              child: material.fromScan
                  ? MaterialDot(category?.id ?? 'other', size: 10)
                  : ExcludeSemantics(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.lineStrong),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: KanzSpace.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.name, style: t.bodyLarge),
                  if (material.fromScan) ...[
                    const SizedBox(height: KanzSpace.s2),
                    MonoLabel(fromScanLabel, color: c.ink),
                  ],
                ],
              ),
            ),
            if (quantity != null && quantity.isNotEmpty) ...[
              const SizedBox(width: KanzSpace.s12),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: KanzSpace.s2),
                child: MonoLabel(quantity, strong: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.tool,
    required this.label,
    required this.haveLabel,
    required this.missingLabel,
    required this.insteadLabel,
    required this.divider,
  });

  final TutorialTool tool;
  final String label;
  final String haveLabel;
  final String missingLabel;
  final String insteadLabel;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    final t = context.textStyles;
    final alternative = tool.alternative;
    return HairlineRow(
      divider: divider,
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: KanzSpace.s2),
              child: Icon(
                tool.have ? KanzIcons.checkCircle : KanzIcons.circle,
                size: 20,
                color: tool.have ? c.ink : c.lineStrong,
              ),
            ),
            const SizedBox(width: KanzSpace.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.bodyLarge),
                  if (!tool.have &&
                      alternative != null &&
                      alternative.isNotEmpty) ...[
                    const SizedBox(height: KanzSpace.s8),
                    MonoLabel(insteadLabel),
                    const SizedBox(height: KanzSpace.s2),
                    Text(alternative, style: t.bodyMedium),
                  ],
                ],
              ),
            ),
            // The check says "you have it"; only a missing tool gets a word.
            if (tool.have)
              Semantics(label: haveLabel, child: const SizedBox.shrink())
            else ...[
              const SizedBox(width: KanzSpace.s12),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: KanzSpace.s4),
                child: MonoLabel(missingLabel, color: c.ink),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GearTag extends StatelessWidget {
  const _GearTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s8,
        KanzSpace.s4,
        KanzSpace.s12,
        KanzSpace.s4,
      ),
      decoration: BoxDecoration(
        borderRadius: KanzRadii.chipAll,
        border: Border.all(color: c.line),
        color: c.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: c.ink),
          const SizedBox(width: KanzSpace.s8),
          Flexible(child: Text(label, style: context.textStyles.labelMedium)),
        ],
      ),
    );
  }
}
