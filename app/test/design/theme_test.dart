// The theme must never fall back to Material's seeded purple (or its blue
// default swatch): every ColorScheme slot and legacy ThemeData color is
// checked for hue in both themes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanz/core/design/design.dart';

/// Purple and violet: hue 250-330 degrees with visible saturation.
bool isPurple(Color color) {
  final hsv = HSVColor.fromColor(color);
  return hsv.saturation > 0.15 &&
      hsv.value > 0.1 &&
      hsv.hue >= 250 &&
      hsv.hue <= 330;
}

Map<String, Color> schemeSlots(ColorScheme s) => {
  'primary': s.primary,
  'onPrimary': s.onPrimary,
  'primaryContainer': s.primaryContainer,
  'onPrimaryContainer': s.onPrimaryContainer,
  'primaryFixed': s.primaryFixed,
  'primaryFixedDim': s.primaryFixedDim,
  'onPrimaryFixed': s.onPrimaryFixed,
  'onPrimaryFixedVariant': s.onPrimaryFixedVariant,
  'secondary': s.secondary,
  'onSecondary': s.onSecondary,
  'secondaryContainer': s.secondaryContainer,
  'onSecondaryContainer': s.onSecondaryContainer,
  'secondaryFixed': s.secondaryFixed,
  'secondaryFixedDim': s.secondaryFixedDim,
  'onSecondaryFixed': s.onSecondaryFixed,
  'onSecondaryFixedVariant': s.onSecondaryFixedVariant,
  'tertiary': s.tertiary,
  'onTertiary': s.onTertiary,
  'tertiaryContainer': s.tertiaryContainer,
  'onTertiaryContainer': s.onTertiaryContainer,
  'tertiaryFixed': s.tertiaryFixed,
  'tertiaryFixedDim': s.tertiaryFixedDim,
  'onTertiaryFixed': s.onTertiaryFixed,
  'onTertiaryFixedVariant': s.onTertiaryFixedVariant,
  'error': s.error,
  'onError': s.onError,
  'errorContainer': s.errorContainer,
  'onErrorContainer': s.onErrorContainer,
  'surface': s.surface,
  'onSurface': s.onSurface,
  'surfaceDim': s.surfaceDim,
  'surfaceBright': s.surfaceBright,
  'surfaceContainerLowest': s.surfaceContainerLowest,
  'surfaceContainerLow': s.surfaceContainerLow,
  'surfaceContainer': s.surfaceContainer,
  'surfaceContainerHigh': s.surfaceContainerHigh,
  'surfaceContainerHighest': s.surfaceContainerHighest,
  'onSurfaceVariant': s.onSurfaceVariant,
  'outline': s.outline,
  'outlineVariant': s.outlineVariant,
  'shadow': s.shadow,
  'scrim': s.scrim,
  'inverseSurface': s.inverseSurface,
  'onInverseSurface': s.onInverseSurface,
  'inversePrimary': s.inversePrimary,
};

void main() {
  final themes = {
    'light': KanzTheme.light(),
    'dark': KanzTheme.dark(),
    'light ar': KanzTheme.light(locale: const Locale('ar')),
  };

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    group('$name theme', () {
      test('uses Material 3 and the Kanz extensions', () {
        expect(theme.useMaterial3, isTrue);
        expect(theme.extension<KanzColors>(), isNotNull);
        expect(theme.extension<KanzType>(), isNotNull);
      });

      test('no ColorScheme slot is purple', () {
        final purple = [
          for (final e in schemeSlots(theme.colorScheme).entries)
            if (isPurple(e.value)) e.key,
        ];
        expect(purple, isEmpty);
      });

      test('no legacy ThemeData color is purple or Material blue', () {
        final legacy = {
          'primaryColor': theme.primaryColor,
          'primaryColorLight': theme.primaryColorLight,
          'primaryColorDark': theme.primaryColorDark,
          'secondaryHeaderColor': theme.secondaryHeaderColor,
          'scaffoldBackgroundColor': theme.scaffoldBackgroundColor,
          'canvasColor': theme.canvasColor,
          'cardColor': theme.cardColor,
          'dividerColor': theme.dividerColor,
          'unselectedWidgetColor': theme.unselectedWidgetColor,
          'hintColor': theme.hintColor,
          'disabledColor': theme.disabledColor,
        };
        for (final e in legacy.entries) {
          expect(isPurple(e.value), isFalse, reason: e.key);
          final hsv = HSVColor.fromColor(e.value);
          final materialBlue =
              hsv.saturation > 0.3 && hsv.hue > 195 && hsv.hue < 235;
          expect(materialBlue, isFalse, reason: e.key);
        }
      });

      test('surfaces carry no tonal tint', () {
        expect(theme.colorScheme.surfaceTint, Colors.transparent);
      });

      test('the one accent is the tertiary slot', () {
        final c = theme.extension<KanzColors>()!;
        expect(theme.colorScheme.tertiary, c.accent);
        expect(theme.colorScheme.primary, c.ink);
      });
    });
  }

  test('Arabic locale switches every text role to IBM Plex Sans Arabic', () {
    final text = KanzTheme.light(locale: const Locale('ar')).textTheme;
    for (final style in [
      text.displayLarge,
      text.headlineMedium,
      text.titleMedium,
      text.bodyMedium,
      text.labelSmall,
    ]) {
      expect(style!.fontFamily, KanzFonts.arabic);
      expect(style.letterSpacing ?? 0, 0);
    }
  });

  test('English uses Fraunces for display and Plex Sans for interface', () {
    final text = KanzTheme.light().textTheme;
    expect(text.displayLarge!.fontFamily, KanzFonts.display);
    expect(text.headlineSmall!.fontFamily, KanzFonts.display);
    expect(text.titleMedium!.fontFamily, KanzFonts.sans);
    expect(text.bodyMedium!.fontFamily, KanzFonts.sans);
    final type = KanzTheme.light().extension<KanzType>()!;
    expect(type.data.fontFamily, KanzFonts.mono);
    expect(type.uppercaseData, isTrue);
  });
}
