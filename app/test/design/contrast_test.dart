// WCAG AA contrast for every text/background pairing the design system
// uses, in both themes. Body text needs 4.5:1; interface glyphs, control
// boundaries and data dots need 3:1.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

void main() {
  final themes = {'light': KanzColors.light, 'dark': KanzColors.dark};

  for (final MapEntry(key: name, value: c) in themes.entries) {
    group('$name theme', () {
      final grounds = {
        'background': c.background,
        'surface': c.surface,
        'surfaceSunken': c.surfaceSunken,
      };

      // Text colors that may sit on any of the three grounds.
      final texts = {
        'ink': c.ink,
        'inkSecondary': c.inkSecondary,
        'danger': c.danger,
        'caution': c.caution,
        'positive': c.positive,
      };
      for (final t in texts.entries) {
        for (final g in grounds.entries) {
          test('${t.key} text on ${g.key} >= 4.5', () {
            expect(
              KanzContrast.ratio(t.value, g.value),
              greaterThanOrEqualTo(KanzContrast.text),
            );
          });
        }
      }

      final fills = <String, (Color, Color)>{
        'onAccent on accent': (c.onAccent, c.accent),
        'onInverse on inverse': (c.onInverse, c.inverse),
        'onDanger on danger': (c.onDanger, c.danger),
        'ink on raised': (c.ink, c.raised),
        'inkSecondary on raised': (c.inkSecondary, c.raised),
      };
      for (final f in fills.entries) {
        test('${f.key} >= 4.5', () {
          expect(
            KanzContrast.ratio(f.value.$1, f.value.$2),
            greaterThanOrEqualTo(KanzContrast.text),
          );
        });
      }

      // Non-text: the accent (scan action, active states), control borders.
      for (final g in ['background', 'surface']) {
        test('accent against $g >= 3', () {
          expect(
            KanzContrast.ratio(c.accent, grounds[g]!),
            greaterThanOrEqualTo(KanzContrast.large),
          );
        });
        test('lineStrong against $g >= 3', () {
          expect(
            KanzContrast.ratio(c.lineStrong, grounds[g]!),
            greaterThanOrEqualTo(KanzContrast.large),
          );
        });
      }
    });
  }

  // Chrome on photos must hold up on any image, so the translucent tag and
  // control fills are composited over the worst case: a white photo.
  test('photo tags and controls: warm white text on the tag fill', () {
    const white = Color(0xFFFFFFFF);
    for (final fill in [KanzPhotoColors.tag, KanzPhotoColors.control]) {
      expect(
        KanzContrast.ratio(KanzPhotoColors.ink, Color.alphaBlend(fill, white)),
        greaterThanOrEqualTo(KanzContrast.text),
      );
    }
    expect(
      KanzContrast.ratio(
        KanzPhotoColors.accent,
        Color.alphaBlend(KanzPhotoColors.control, white),
      ),
      greaterThanOrEqualTo(KanzContrast.large),
    );
  });

  test('contrast math matches WCAG reference values', () {
    expect(
      KanzContrast.ratio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      KanzContrast.ratio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
      closeTo(4.48, 0.01),
    );
  });
}
