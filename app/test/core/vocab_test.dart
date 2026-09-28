import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/data/models/vocab_enums.dart';
import 'package:kanz/core/data/vocab/vocab.dart';

void main() {
  late Vocab vocab;

  setUpAll(() {
    final raw = File('assets/config/vocab.json').readAsStringSync();
    vocab = Vocab.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('the app copy of the vocabulary matches contracts/vocab.json', () {
    expect(
      File('assets/config/vocab.json').readAsStringSync(),
      File('../contracts/vocab.json').readAsStringSync(),
    );
  });

  test('every contract enum value has a vocabulary entry', () {
    expect(vocab.materials.map((e) => e.id), MaterialCategory.values);
    expect(vocab.tools.map((e) => e.id), ToolId.values);
    expect(vocab.stateTags.map((e) => e.id), StateTag.values);
    expect(vocab.hazards.map((e) => e.id), HazardFlag.values);
    expect(vocab.facilityTypes.map((e) => e.id), FacilityType.values);
    expect(vocab.cities.map((e) => e.id), CityId.values);
    expect(vocab.qualityLabels.map((e) => e.score), [1, 2, 3, 4, 5]);
  });

  test('labels resolve by language and locale', () {
    final glass = vocab.material(MaterialCategory.glass).label;
    expect(glass.of(Lang.en), 'Glass');
    expect(glass.forLocale(const Locale('ar')), 'زجاج');
    expect(vocab.qualityLabel(9).en, 'Like new');
  });

  test('material colors are opaque ARGB values', () {
    expect(vocab.material(MaterialCategory.glass).colorValue, 0xFF5FA8A0);
  });

  test('safety gear is separated from real tools', () {
    expect(vocab.safetyGear.map((t) => t.id), [
      ToolId.gloves,
      ToolId.safetyGlasses,
      ToolId.dustMask,
    ]);
    expect(vocab.realTools.every((t) => !t.id.isSafetyGear), isTrue);
  });

  test('disposal-only hazards agree with the enum helper', () {
    for (final h in vocab.hazards) {
      expect(h.disposalOnly, h.id.isDisposalOnly, reason: h.id.id);
    }
  });

  test('nearest city picks the closest emirate centre', () {
    expect(vocab.nearestCity(25.19, 55.27).id, CityId.dubai);
    expect(vocab.nearestCity(24.22, 55.76).id, CityId.alAin);
  });
}
