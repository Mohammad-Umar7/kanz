import 'package:flutter/material.dart';

import '../../../core/data/models/models.dart';
import '../../../core/design/design.dart';
import '../../../core/state/scan_session.dart';
import '../../../l10n/l10n.dart';
import '../results_format.dart';

/// Opens the correction sheet for [item]. Resolves to the user's changes
/// (only the fields they touched), or null when they closed it.
Future<ItemCorrection?> showItemEditSheet(
  BuildContext context, {
  required Item item,
  required ResultsFormat format,
}) {
  return showKanzSheet<ItemCorrection>(
    context: context,
    builder: (context) => ItemEditSheet(item: item, format: format),
  );
}

/// Corrects what the model read: name, material category and specific
/// material, quantity and unit, quality, state tags and hazards. Saving
/// re-runs the ideas with the corrected item.
class ItemEditSheet extends StatefulWidget {
  const ItemEditSheet({super.key, required this.item, required this.format});

  final Item item;
  final ResultsFormat format;

  /// Units the Material Analyst uses (see `quantity_display` in the backend).
  static const units = ['pcs', 'kg', 'g', 'm', 'm2', 'L', 'handful', 'bag'];

  @override
  State<ItemEditSheet> createState() => _ItemEditSheetState();
}

class _ItemEditSheetState extends State<ItemEditSheet> {
  late final Item _item = widget.item;
  late final _name = TextEditingController(text: _item.name);
  late final _material = TextEditingController(text: _item.material);
  late final _quantity = TextEditingController(
    text: _number(_item.quantity.value),
  );
  late MaterialCategory _category = _item.category;
  late String _unit = _item.quantity.unit;
  late int _quality = _item.quality.score.clamp(1, 5);
  late final Set<StateTag> _state = {..._item.state};
  late final Set<HazardFlag> _hazards = {..._item.hazards};

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _material, _quantity]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _material.dispose();
    _quantity.dispose();
    super.dispose();
  }

  static String _number(double v) => v == v.roundToDouble()
      ? v.round().toString()
      : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');

  /// Reads "2", "0.5", "0,5" and Arabic-Indic digits ("٢٫٥").
  double? get _quantityValue {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final ch in _quantity.text.trim().split('')) {
      final i = arabic.indexOf(ch);
      buffer.write(i >= 0 ? '$i' : (ch == '٫' || ch == ',' ? '.' : ch));
    }
    final value = double.tryParse(buffer.toString());
    return value == null || value <= 0 ? null : value;
  }

  bool _sameSet<T>(Set<T> a, List<T> b) =>
      a.length == b.toSet().length && a.containsAll(b);

  ItemCorrection get _changes {
    final name = _name.text.trim();
    final material = _material.text.trim();
    final quantity = _quantityValue;
    return ItemCorrection(
      name: name.isNotEmpty && name != _item.name ? name : null,
      category: _category != _item.category ? _category : null,
      material: material.isNotEmpty && material != _item.material
          ? material
          : null,
      quantityValue: quantity != null && quantity != _item.quantity.value
          ? quantity
          : null,
      quantityUnit: _unit != _item.quantity.unit ? _unit : null,
      qualityScore: _quality != _item.quality.score ? _quality : null,
      state: _sameSet(_state, _item.state)
          ? null
          : _ordered(_state, StateTag.values),
      hazards: _sameSet(_hazards, _item.hazards)
          ? null
          : _ordered(_hazards, HazardFlag.values),
    );
  }

  static List<T> _ordered<T>(Set<T> set, List<T> order) => [
    for (final v in order)
      if (set.contains(v)) v,
  ];

  bool get _valid => _name.text.trim().isNotEmpty && _quantityValue != null;

  bool get _changed => _changes != const ItemCorrection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = widget.format;
    final vocab = format.vocab;
    final quantityError =
        _quantity.text.trim().isNotEmpty && _quantityValue == null
        ? l10n.resultsEditQuantityInvalid
        : null;

    Widget group(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: context.textStyles.labelMedium),
        ),
        const SizedBox(height: KanzSpace.s4),
        child,
      ],
    );

    Widget chips(List<Widget> children) =>
        Wrap(spacing: KanzSpace.s8, children: children);

    return KanzSheet(
      title: l10n.resultsEditItem,
      subtitle: l10n.resultsEditSubtitle,
      actions: [
        KanzButton(
          label: l10n.resultsEditSave,
          onPressed: _valid && _changed
              ? () => Navigator.of(context).pop(_changes)
              : null,
          expand: true,
        ),
      ],
      child: SingleChildScrollView(
        padding: KanzSpace.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: KanzSpace.s24,
          children: [
            KanzTextField(
              label: l10n.resultsEditName,
              controller: _name,
              textInputAction: TextInputAction.next,
            ),
            group(
              l10n.resultsEditCategory,
              chips([
                for (final m in vocab.materials)
                  KanzChip(
                    label: format.category(m.id),
                    materialId: m.id.id,
                    selected: _category == m.id,
                    onSelected: (_) => setState(() => _category = m.id),
                  ),
              ]),
            ),
            KanzTextField(
              label: l10n.resultsEditMaterial,
              controller: _material,
              hint: l10n.resultsEditMaterialHint,
              textInputAction: TextInputAction.next,
            ),
            KanzTextField(
              label: l10n.resultsEditQuantity,
              controller: _quantity,
              error: quantityError,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            group(
              l10n.resultsEditUnit,
              chips([
                for (final unit in ItemEditSheet.units)
                  KanzChip(
                    label: format.unit(unit),
                    selected: _unit == unit,
                    onSelected: (_) => setState(() => _unit = unit),
                  ),
              ]),
            ),
            group(
              l10n.resultsEditQuality,
              chips([
                for (var score = 1; score <= 5; score++)
                  KanzChip(
                    label: format.qualityLabel(score),
                    count: '$score',
                    selected: _quality == score,
                    onSelected: (_) => setState(() => _quality = score),
                  ),
              ]),
            ),
            group(
              l10n.resultsEditState,
              chips([
                for (final tag in vocab.stateTags)
                  KanzChip(
                    label: format.stateTag(tag.id),
                    selected: _state.contains(tag.id),
                    onSelected: (on) => setState(
                      () => on ? _state.add(tag.id) : _state.remove(tag.id),
                    ),
                  ),
              ]),
            ),
            group(
              l10n.resultsEditHazards,
              chips([
                for (final hazard in vocab.hazards)
                  KanzChip(
                    label: format.hazard(hazard.id),
                    icon: KanzIcons.hazard(hazard.id.id),
                    selected: _hazards.contains(hazard.id),
                    onSelected: (on) => setState(
                      () => on
                          ? _hazards.add(hazard.id)
                          : _hazards.remove(hazard.id),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
