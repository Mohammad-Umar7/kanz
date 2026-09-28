import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/models.dart';
import 'package:kanz/core/data/vocab/quantity_display.dart';
import 'package:kanz/core/data/vocab/vocab.dart';
import 'package:kanz/core/state/scan_session_state.dart';

import 'support/fixtures.dart';

/// Expected strings are the outputs of `quantity_display` in
/// backend/app/ai/convert.py, so corrected items match analyzed ones.
void main() {
  test('English uses singular and plural units', () {
    expect(formatQuantity(1, 'pcs', Lang.en), '1 pc');
    expect(formatQuantity(3, 'pcs', Lang.en), '3 pcs');
    expect(formatQuantity(30, 'pcs', Lang.en, isEstimate: true), '~30 pcs');
    expect(formatQuantity(0.5, 'kg', Lang.en), '0.5 kg');
    expect(formatQuantity(1, 'bag', Lang.en), '1 bag');
    expect(formatQuantity(2, 'handful', Lang.en), '2 handfuls');
    expect(formatQuantity(2.4, 'm2', Lang.en), '2.4 m²');
  });

  test('Arabic uses counted forms and keeps Western digits', () {
    expect(formatQuantity(1, 'pcs', Lang.ar), 'قطعة واحدة');
    expect(formatQuantity(2, 'pcs', Lang.ar), 'قطعتان');
    expect(formatQuantity(4, 'pcs', Lang.ar), '4 قطع');
    expect(formatQuantity(12, 'bag', Lang.ar), '12 كيسًا');
    expect(
      formatQuantity(30, 'pcs', Lang.ar, isEstimate: true),
      'حوالي 30 قطعة',
    );
    expect(formatQuantity(0.5, 'kg', Lang.ar), '0.5 كغ');
  });

  test('unknown units and negative values stay readable', () {
    expect(formatQuantity(3, 'crate', Lang.en), '3 crate');
    expect(formatQuantity(-1, 'pcs', Lang.en), '0 pcs');
  });

  test('a correction rebuilds quantity and quality in the scan language', () {
    final vocab = Vocab.fromJson(
      jsonDecode(File('assets/config/vocab.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final item = AnalyzeResponse.fromJson(
      fixture('analyze_glass_jar_ar.json'),
    ).analysis.items.first;

    final corrected = const ItemCorrection(
      quantityValue: 3,
      qualityScore: 2,
    ).applyTo(item, vocab: vocab, lang: Lang.ar);

    expect(corrected.userCorrected, isTrue);
    expect(corrected.quantity.display, '3 قطع');
    expect(corrected.quantity.isEstimate, isFalse);
    expect(corrected.quality.label, vocab.qualityLabel(2).ar);
    expect(corrected.name, item.name, reason: 'untouched fields are kept');
  });
}
