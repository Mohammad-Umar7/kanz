import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';

/// What the photo is made of: every item's specimen label (MATERIAL, TYPE,
/// QTY, QUALITY, RECYCLABLE, CONFIDENCE, STATE). Several items sit in a row
/// the user swipes through; choosing one highlights its box on the photo
/// and offers to point the ideas at it.
class SpecimenSection extends StatelessWidget {
  const SpecimenSection({
    super.key,
    required this.items,
    required this.selectedId,
    required this.focusId,
    required this.format,
    required this.onSelect,
    required this.onEdit,
    required this.onFocus,
    this.cardKeys,
  });

  final List<Item> items;
  final String? selectedId;

  /// The item the ideas are about.
  final String? focusId;
  final ResultsFormat format;
  final ValueChanged<String> onSelect;
  final ValueChanged<Item> onEdit;
  final ValueChanged<Item> onFocus;

  /// Keys of the cards by item id, so the screen can scroll a card into
  /// view when its box is tapped on the photo.
  final Map<String, GlobalKey>? cardKeys;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final multi = items.length > 1;
    final index = items.indexWhere((i) => i.id == selectedId);
    final selected = index < 0 ? 0 : index;
    final item = items[selected];
    String position(int i) =>
        '${format.index(i + 1)} / ${format.index(items.length)}';

    // Several items: their full labels side by side, the next one peeking
    // in, so QUALITY, QTY and STATE stay spelled out for every item.
    final cardWidth = math.min(
      MediaQuery.sizeOf(context).width - 2 * KanzSpace.gutter - KanzSpace.s24,
      420.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.resultsMaterialsTitle,
          subtitle: multi ? l10n.resultsMaterialsSubtitle : null,
        ),
        const SizedBox(height: KanzSpace.s16),
        if (multi)
          SpecimenCarousel(
            itemWidth: cardWidth,
            children: [
              for (var i = 0; i < items.length; i++)
                KeyedSubtree(
                  key: cardKeys?[items[i].id],
                  child: format.specimenCard(
                    items[i],
                    index: position(i),
                    selected: i == selected,
                    onTap: () => onSelect(items[i].id),
                    onEdit: () => onEdit(items[i]),
                  ),
                ),
            ],
          )
        else
          Padding(
            padding: KanzSpace.page,
            child: format.specimenCard(item, onEdit: () => onEdit(item)),
          ),
        if (multi) ...[
          const SizedBox(height: KanzSpace.s8),
          Padding(
            padding: KanzSpace.page,
            child: AnimatedSwitcher(
              duration: KanzMotion.of(context, KanzMotion.fast),
              child: item.id == focusId
                  ? _FocusedNote(
                      key: ValueKey('focused-${item.id}'),
                      label: l10n.resultsFocusedItem,
                    )
                  : Align(
                      key: ValueKey('focus-${item.id}'),
                      alignment: AlignmentDirectional.centerStart,
                      child: KanzButton.secondary(
                        label: l10n.resultsFocusItem,
                        icon: KanzIcons.upcycle,
                        onPressed: () => onFocus(item),
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FocusedNote extends StatelessWidget {
  const _FocusedNote({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: KanzSpace.touchTarget),
      child: Row(
        children: [
          Icon(KanzIcons.checkCircle, size: 18, color: c.inkSecondary),
          const SizedBox(width: KanzSpace.s8),
          Expanded(child: MonoLabel(label)),
        ],
      ),
    );
  }
}

/// Stands in for the specimen label while the materials are identified:
/// the same shape, with the stage named in it.
class SpecimenSkeleton extends StatelessWidget {
  const SpecimenSkeleton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.kanzColors;
    Widget cell() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(width: 56, height: 10),
        SizedBox(height: KanzSpace.s8),
        Skeleton(width: 96, height: 14),
      ],
    );
    Widget row() => Container(
      padding: const EdgeInsets.symmetric(vertical: KanzSpace.s12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          Expanded(child: cell()),
          const SizedBox(width: KanzSpace.s16),
          Expanded(child: cell()),
        ],
      ),
    );
    return Semantics(
      liveRegion: true,
      label: label,
      child: KanzCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 12,
                  child: context.reduceMotion
                      ? Icon(KanzIcons.clock, size: 12, color: c.inkSecondary)
                      : CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: c.inkSecondary,
                        ),
                ),
                const SizedBox(width: KanzSpace.s8),
                Flexible(child: ExcludeSemantics(child: MonoLabel(label))),
              ],
            ),
            const SizedBox(height: KanzSpace.s12),
            const FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.6,
              child: Skeleton(height: 22),
            ),
            const SizedBox(height: KanzSpace.s16),
            row(),
            row(),
            row(),
          ],
        ),
      ),
    );
  }
}
