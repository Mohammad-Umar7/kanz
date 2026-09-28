import 'package:flutter/material.dart';

import '../context.dart';
import '../icons.dart';
import '../tokens.dart';
import 'buttons.dart';
import 'card.dart';
import 'data.dart';

/// Field names for a [SpecimenCard], passed in so they can be localized.
class SpecimenLabels {
  const SpecimenLabels({
    required this.material,
    required this.type,
    required this.quantity,
    required this.quality,
    required this.state,
    required this.recyclable,
    required this.confidence,
    required this.edit,
  });

  final String material;
  final String type;
  final String quantity;
  final String quality;
  final String state;
  final String recyclable;
  final String confidence;

  /// Label of the edit button, for example "Correct this item".
  final String edit;
}

/// Recyclability as a glyph: yes, conditional or no.
enum SpecimenRecyclable { yes, conditional, no }

/// A recognized item presented like a museum label or a lab spec sheet:
/// a material dot and name, then a mono grid of MATERIAL, TYPE, QTY,
/// QUALITY (five segments), RECYCLABLE, CONFIDENCE and STATE tags.
///
/// All strings arrive formatted and localized. [compact] is the narrow
/// variant for the horizontal carousel under the photo.
class SpecimenCard extends StatelessWidget {
  const SpecimenCard({
    super.key,
    required this.labels,
    required this.categoryId,
    required this.categoryLabel,
    required this.name,
    required this.material,
    required this.quantity,
    required this.qualityScore,
    required this.qualityLabel,
    required this.qualitySemantics,
    required this.stateLabels,
    required this.recyclable,
    required this.recyclableLabel,
    required this.confidence,
    this.index,
    this.hazardLabel,
    this.note,
    this.selected = false,
    this.compact = false,
    this.onTap,
    this.onEdit,
  });

  final SpecimenLabels labels;
  final String categoryId;
  final String categoryLabel;
  final String name;

  /// Specific material, for example "Clear soda-lime glass" or "PET · #1".
  final String material;

  /// Formatted quantity, for example "1 pc" or "about 2 kg".
  final String quantity;
  final int qualityScore;
  final String qualityLabel;
  final String qualitySemantics;
  final List<String> stateLabels;
  final SpecimenRecyclable recyclable;

  /// Formatted recyclability, for example "Yes · glass bank".
  final String recyclableLabel;

  /// Formatted confidence, for example "93%".
  final String confidence;

  /// Item position, for example "01 / 02". Always laid out left to right.
  final String? index;

  /// Shown as a warning row when the item is hazardous.
  final String? hazardLabel;

  /// Short condition note under the grid.
  final String? note;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return compact ? _compact(context) : _full(context);
  }

  Widget _header(BuildContext context, {required bool large}) {
    final t = context.textStyles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and position wrap as two units, so a long category
              // ("Electronics", "Paper & cardboard") beside the edit button
              // moves the index to the next line instead of cutting it.
              Wrap(
                spacing: KanzSpace.s12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaterialDot(categoryId),
                      const SizedBox(width: KanzSpace.s8),
                      Flexible(child: MonoLabel(categoryLabel)),
                    ],
                  ),
                  if (index != null)
                    MonoLabel(index!, textDirection: TextDirection.ltr),
                ],
              ),
              const SizedBox(height: KanzSpace.s4),
              Text(
                name,
                style: large ? t.headlineSmall : t.titleMedium,
                maxLines: large ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onEdit != null && large)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: KanzSpace.s4),
            child: Transform.translate(
              offset: const Offset(0, -KanzSpace.s8),
              child: KanzIconButton(
                icon: KanzIcons.edit,
                semanticsLabel: labels.edit,
                onPressed: onEdit,
              ),
            ),
          ),
      ],
    );
  }

  Widget _recyclable(BuildContext context) {
    final c = context.kanzColors;
    final (icon, color) = switch (recyclable) {
      SpecimenRecyclable.yes => (KanzIcons.checkCircle, c.ink),
      SpecimenRecyclable.conditional => (KanzIcons.info, c.ink),
      SpecimenRecyclable.no => (KanzIcons.prohibited, c.danger),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: KanzSpace.s4),
        Expanded(
          child: Text(recyclableLabel, style: context.textStyles.bodyMedium),
        ),
      ],
    );
  }

  Widget _hazard(BuildContext context) {
    final c = context.kanzColors;
    return Padding(
      padding: const EdgeInsets.only(top: KanzSpace.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(KanzIcons.warning, size: 18, color: c.danger),
          const SizedBox(width: KanzSpace.s8),
          Expanded(
            child: Text(
              hazardLabel!,
              style: context.textStyles.labelMedium?.copyWith(color: c.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _full(BuildContext context) {
    final t = context.textStyles;
    return KanzCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(
        KanzSpace.s16,
        KanzSpace.s16,
        KanzSpace.s16,
        KanzSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context, large: true),
          if (hazardLabel != null) _hazard(context),
          const SizedBox(height: KanzSpace.s12),
          DataGrid(
            entries: [
              DataGridEntry(labels.material, value: categoryLabel),
              DataGridEntry(labels.type, value: material),
              DataGridEntry(labels.quantity, value: quantity),
              DataGridEntry(
                labels.quality,
                child: QualityBar(
                  score: qualityScore,
                  label: qualityLabel,
                  semanticsLabel: qualitySemantics,
                ),
              ),
              DataGridEntry(labels.recyclable, child: _recyclable(context)),
              DataGridEntry(
                labels.confidence,
                child: MonoLabel(confidence, strong: true),
              ),
              if (stateLabels.isNotEmpty)
                DataGridEntry(
                  labels.state,
                  span: true,
                  child: StateTags(labels: stateLabels),
                ),
            ],
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(bottom: KanzSpace.s12),
              child: Text(note!, style: t.bodySmall),
            ),
        ],
      ),
    );
  }

  Widget _compact(BuildContext context) {
    return KanzCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsetsDirectional.all(KanzSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context, large: false),
          if (hazardLabel != null) _hazard(context),
          const SizedBox(height: KanzSpace.s8),
          // Two lines: carousel cards share the tallest card's height, so a
          // long material ("Tin-plated steel with plastic liner") at large
          // text grows the row instead of being cut.
          Text(
            material,
            style: context.textStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: KanzSpace.s8),
          Wrap(
            spacing: KanzSpace.s12,
            runSpacing: KanzSpace.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MonoLabel(quantity, strong: true),
              QualityBar(
                score: qualityScore,
                semanticsLabel: qualitySemantics,
                segmentWidth: 10,
              ),
              MonoLabel(confidence),
            ],
          ),
        ],
      ),
    );
  }
}

/// A horizontal row of compact [SpecimenCard]s under the photo. Cards share
/// the height of the tallest one, so the row grows with text size and
/// language instead of clipping.
class SpecimenCarousel extends StatelessWidget {
  const SpecimenCarousel({
    super.key,
    required this.children,
    this.itemWidth = 232,
  });

  final List<Widget> children;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: KanzSpace.page,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: KanzSpace.s12,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        ),
      ),
    );
  }
}
