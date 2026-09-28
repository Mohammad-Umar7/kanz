// The brand mark is drawn twice: by BrandMark in the app and by
// tool/brand/make_brand.py for the launcher icon and splash PNGs. Both must
// use the same geometry and the same token colors, or the icon on the home
// screen and the mark inside the app drift apart.
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

final String _script = File('tool/brand/make_brand.py').readAsStringSync();

/// Reads a Python list of (x, y) tuples, for example `TABLE = [(0.3, 0.1)]`.
List<Offset> _points(String name) {
  final line = RegExp(
    '^$name = \\[(.*)\\]\$',
    multiLine: true,
  ).firstMatch(_script)!.group(1)!;
  return [
    for (final m in RegExp(r'\(([\d.]+), ([\d.]+)\)').allMatches(line))
      Offset(double.parse(m.group(1)!), double.parse(m.group(2)!)),
  ];
}

/// Reads a Python RGBA tuple constant, for example `INK = (22, 22, 22, 255)`.
Color _color(String name) {
  final m = RegExp(
    '^$name = \\((\\d+), (\\d+), (\\d+), 255\\)',
    multiLine: true,
  ).firstMatch(_script)!;
  return Color.fromARGB(
    255,
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

void main() {
  test('make_brand.py draws the same facets as BrandMarkGeometry', () {
    expect(_points('CROWN_START'), BrandMarkGeometry.crownStart);
    expect(_points('TABLE'), BrandMarkGeometry.table);
    expect(_points('CROWN_END'), BrandMarkGeometry.crownEnd);
    expect(_points('PAVILION'), BrandMarkGeometry.pavilion);
  });

  test('make_brand.py paints with the design tokens', () {
    expect(_color('PAPER'), KanzColors.light.background);
    expect(_color('INK'), KanzColors.light.ink);
    expect(_color('CLAY'), KanzColors.light.accent);
    expect(_color('DARK_BG'), KanzColors.dark.background);
    expect(_color('DARK_INK'), KanzColors.dark.ink);
    expect(_color('DARK_CLAY'), KanzColors.dark.accent);
  });

  test('launcher icon and splash backgrounds are the paper tokens', () {
    String hex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
            .toUpperCase();
    final icons = File('flutter_launcher_icons.yaml').readAsStringSync();
    final splash = File('flutter_native_splash.yaml').readAsStringSync();
    final paper = hex(KanzColors.light.background);
    final night = hex(KanzColors.dark.background);
    expect(icons, contains('adaptive_icon_background: "$paper"'));
    expect(icons, contains('background_color_ios: "$paper"'));
    expect(RegExp('  color: "$paper"').allMatches(splash).length, 2);
    expect(RegExp('  color_dark: "$night"').allMatches(splash).length, 2);
  });
}
