/// Material category colors from contracts/vocab.json, tuned per theme.
///
/// These are data colors: chips, dots, bounding boxes and map pins only,
/// never large fills. The vocabulary's base colors are kept wherever they
/// already reach 3:1 against the theme's background and surface; the few
/// that do not (light glass, paper, metal, electronics and other; dark
/// textile, wood and hazardous) get a lightness-shifted variant with the
/// same hue. Measured ratios are in DESIGN.md and enforced by
/// test/design/material_colors_test.dart.
library;

import 'package:flutter/material.dart';

import 'contrast.dart';

/// One material category's colors.
@immutable
class MaterialSwatch {
  const MaterialSwatch({
    required this.id,
    required this.base,
    required this.light,
    required this.dark,
  });

  /// Category id, e.g. `glass`.
  final String id;

  /// The canonical color from the shared vocabulary.
  final Color base;

  /// Variant used on light surfaces (dots, chips, pins, outlines).
  final Color light;

  /// Variant used on dark surfaces.
  final Color dark;

  /// The dot, chip and pin color for a theme brightness.
  Color on(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Bounding-box stroke on photos. Photos have no theme, so boxes use the
  /// canonical color and get a dark halo from the overlay for legibility.
  Color get box => base;

  /// Text or glyph color to place on a fill of [on] (ink or white, whichever
  /// contrasts more). Prefer a surface tag with a dot over text on color.
  Color onColor(Brightness brightness) => KanzContrast.bestOn(
    on(brightness),
    dark: const Color(0xFF161616),
    light: const Color(0xFFFFFFFF),
  );
}

abstract final class KanzMaterialColors {
  static const MaterialSwatch glass = MaterialSwatch(
    id: 'glass',
    base: Color(0xFF5FA8A0),
    light: Color(0xFF4C8D86),
    dark: Color(0xFF5FA8A0),
  );
  static const MaterialSwatch plastic = MaterialSwatch(
    id: 'plastic',
    base: Color(0xFF3D6FD9),
    light: Color(0xFF3D6FD9),
    dark: Color(0xFF3D6FD9),
  );
  static const MaterialSwatch paper = MaterialSwatch(
    id: 'paper',
    base: Color(0xFFB8895A),
    light: Color(0xFFA87848),
    dark: Color(0xFFB8895A),
  );
  static const MaterialSwatch metal = MaterialSwatch(
    id: 'metal',
    base: Color(0xFF7D8894),
    light: Color(0xFF77838F),
    dark: Color(0xFF7D8894),
  );
  static const MaterialSwatch textile = MaterialSwatch(
    id: 'textile',
    base: Color(0xFF4B5A9C),
    light: Color(0xFF4B5A9C),
    dark: Color(0xFF5B6AB0),
  );
  static const MaterialSwatch wood = MaterialSwatch(
    id: 'wood',
    base: Color(0xFF8A5A3B),
    light: Color(0xFF8A5A3B),
    dark: Color(0xFF976240),
  );
  static const MaterialSwatch electronics = MaterialSwatch(
    id: 'electronics',
    base: Color(0xFFD4A017),
    light: Color(0xFFA47C12),
    dark: Color(0xFFD4A017),
  );
  static const MaterialSwatch hazardous = MaterialSwatch(
    id: 'hazardous',
    base: Color(0xFFB3261E),
    light: Color(0xFFB3261E),
    dark: Color(0xFFD42D23),
  );
  static const MaterialSwatch organic = MaterialSwatch(
    id: 'organic',
    base: Color(0xFF6B7F3A),
    light: Color(0xFF6B7F3A),
    dark: Color(0xFF6B7F3A),
  );
  static const MaterialSwatch other = MaterialSwatch(
    id: 'other',
    base: Color(0xFF9A968C),
    light: Color(0xFF858175),
    dark: Color(0xFF9A968C),
  );

  /// Every category in vocabulary order.
  static const List<MaterialSwatch> all = [
    glass,
    plastic,
    paper,
    metal,
    textile,
    wood,
    electronics,
    hazardous,
    organic,
    other,
  ];

  /// The swatch for a category id; unknown ids fall back to [other].
  static MaterialSwatch of(String categoryId) => switch (categoryId) {
    'glass' => glass,
    'plastic' => plastic,
    'paper' => paper,
    'metal' => metal,
    'textile' => textile,
    'wood' => wood,
    'electronics' => electronics,
    'hazardous' => hazardous,
    'organic' => organic,
    _ => other,
  };

  /// Dot and chip color for [categoryId] in the ambient theme.
  static Color dot(BuildContext context, String categoryId) =>
      of(categoryId).on(Theme.of(context).brightness);

  /// Map pin color for [categoryId] in the ambient theme.
  static Color pin(BuildContext context, String categoryId) =>
      dot(context, categoryId);
}
