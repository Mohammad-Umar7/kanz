// Material category colors: they must match the shared vocabulary and the
// per-theme variants must stay visible (3:1) on background and surface.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

Color _parse(String hex) =>
    Color(int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000);

void main() {
  final vocab =
      jsonDecode(File('assets/config/vocab.json').readAsStringSync())
          as Map<String, dynamic>;
  final materials = (vocab['materials'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('every vocabulary material has a swatch with the canonical color', () {
    expect(KanzMaterialColors.all.map((s) => s.id).toList(), [
      for (final m in materials) m['id'] as String,
    ]);
    for (final m in materials) {
      final swatch = KanzMaterialColors.of(m['id'] as String);
      expect(
        swatch.base,
        _parse(m['color'] as String),
        reason: m['id'] as String,
      );
    }
  });

  test('unknown categories fall back to other', () {
    expect(KanzMaterialColors.of('unobtainium'), KanzMaterialColors.other);
  });

  for (final (name, brightness, colors) in [
    ('light', Brightness.light, KanzColors.light),
    ('dark', Brightness.dark, KanzColors.dark),
  ]) {
    test('$name dots reach 3:1 on background and surface', () {
      for (final swatch in KanzMaterialColors.all) {
        final dot = swatch.on(brightness);
        for (final ground in [colors.background, colors.surface]) {
          expect(
            KanzContrast.ratio(dot, ground),
            greaterThanOrEqualTo(KanzContrast.large),
            reason: '${swatch.id} on $ground',
          );
        }
      }
    });

    test('$name tuned variants keep the canonical hue', () {
      for (final swatch in KanzMaterialColors.all) {
        final base = HSLColor.fromColor(swatch.base);
        final tuned = HSLColor.fromColor(swatch.on(brightness));
        if (base.saturation < 0.05) continue;
        expect((base.hue - tuned.hue).abs(), lessThan(4), reason: swatch.id);
      }
    });
  }

  test('text on a material fill picks the more legible of ink and white', () {
    for (final swatch in KanzMaterialColors.all) {
      final fill = swatch.on(Brightness.light);
      final on = swatch.onColor(Brightness.light);
      final other = on == const Color(0xFF161616)
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF161616);
      expect(
        KanzContrast.ratio(on, fill),
        greaterThanOrEqualTo(KanzContrast.ratio(other, fill)),
      );
    }
  });
}
