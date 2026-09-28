/// Kanz typography: Fraunces for editorial moments, IBM Plex Sans (or IBM
/// Plex Sans Arabic) for interface text, IBM Plex Mono for data labels.
///
/// The family is chosen by locale. Arabic uses IBM Plex Sans Arabic for
/// every role, with taller line heights and no letter-spacing, because
/// tracking breaks the joins of Arabic script and Fraunces has no Arabic
/// glyphs. Each style also carries the other script's family as a fallback
/// so mixed strings (an Arabic place name in the English UI) render cleanly.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Font family names as declared in pubspec.yaml.
abstract final class KanzFonts {
  static const String display = 'Fraunces';
  static const String sans = 'IBMPlexSans';
  static const String arabic = 'IBMPlexSansArabic';
  static const String mono = 'IBMPlexMono';

  /// Whether [locale] should use the Arabic type system.
  static bool isArabic(Locale? locale) => locale?.languageCode == 'ar';
}

/// Builds the Material [TextTheme] for a language.
abstract final class KanzTypography {
  static TextTheme textTheme(KanzColors c, {bool arabic = false}) {
    return arabic ? _arabic(c) : _latin(c);
  }

  static const List<String> _latinFallback = [KanzFonts.arabic];
  static const List<String> _arabicFallback = [KanzFonts.sans];

  static TextStyle _style(
    String family,
    double size,
    double lineHeight,
    FontWeight weight,
    Color color, {
    double letterSpacing = 0,
    List<String> fallback = _latinFallback,
  }) {
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: fallback,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static TextTheme _latin(KanzColors c) {
    const d = KanzFonts.display;
    const s = KanzFonts.sans;
    const light = FontWeight.w300;
    const regular = FontWeight.w400;
    const medium = FontWeight.w500;
    const semi = FontWeight.w600;
    return TextTheme(
      displayLarge: _style(d, 48, 52, light, c.ink, letterSpacing: -0.8),
      displayMedium: _style(d, 40, 44, light, c.ink, letterSpacing: -0.6),
      displaySmall: _style(d, 32, 38, regular, c.ink, letterSpacing: -0.4),
      headlineLarge: _style(d, 28, 34, regular, c.ink, letterSpacing: -0.3),
      headlineMedium: _style(d, 24, 30, regular, c.ink, letterSpacing: -0.2),
      headlineSmall: _style(d, 20, 26, regular, c.ink, letterSpacing: -0.1),
      titleLarge: _style(s, 18, 24, semi, c.ink),
      titleMedium: _style(s, 16, 22, semi, c.ink),
      titleSmall: _style(s, 14, 20, semi, c.ink),
      bodyLarge: _style(s, 16, 24, regular, c.ink),
      bodyMedium: _style(s, 14, 21, regular, c.ink),
      bodySmall: _style(s, 13, 19, regular, c.inkSecondary),
      labelLarge: _style(s, 15, 20, medium, c.ink, letterSpacing: 0.1),
      labelMedium: _style(s, 13, 18, medium, c.ink, letterSpacing: 0.1),
      labelSmall: _style(s, 12, 16, medium, c.inkSecondary, letterSpacing: 0.2),
    );
  }

  static TextTheme _arabic(KanzColors c) {
    const a = KanzFonts.arabic;
    const regular = FontWeight.w400;
    const medium = FontWeight.w500;
    const semi = FontWeight.w600;
    TextStyle st(double size, double lh, FontWeight w, Color color) =>
        _style(a, size, lh, w, color, fallback: _arabicFallback);
    return TextTheme(
      displayLarge: st(40, 56, medium, c.ink),
      displayMedium: st(34, 48, medium, c.ink),
      displaySmall: st(28, 40, semi, c.ink),
      headlineLarge: st(25, 38, semi, c.ink),
      headlineMedium: st(22, 33, semi, c.ink),
      headlineSmall: st(19, 29, semi, c.ink),
      titleLarge: st(18, 28, semi, c.ink),
      titleMedium: st(16, 25, semi, c.ink),
      titleSmall: st(14, 22, semi, c.ink),
      bodyLarge: st(16, 27, regular, c.ink),
      bodyMedium: st(14, 23, regular, c.ink),
      bodySmall: st(13, 21, regular, c.inkSecondary),
      labelLarge: st(15, 22, medium, c.ink),
      labelMedium: st(13, 20, medium, c.ink),
      labelSmall: st(12, 18, medium, c.inkSecondary),
    );
  }
}

/// Kanz-specific text roles that Material's [TextTheme] has no slot for.
@immutable
class KanzType extends ThemeExtension<KanzType> {
  const KanzType({
    required this.data,
    required this.dataStrong,
    required this.numeralLarge,
    required this.numeral,
    required this.numeralSmall,
    required this.uppercaseData,
  });

  /// Mono data label: MATERIAL, QTY, "PET · #1 · 3 PCS". Secondary ink.
  final TextStyle data;

  /// Mono data at a larger size in full ink, for values that are codes or
  /// counts ("#1", "3 PCS").
  final TextStyle dataStrong;

  /// Big statistic numerals (impact dashboard).
  final TextStyle numeralLarge;

  /// Step numerals ("03").
  final TextStyle numeral;

  /// Small numerals next to labels ("/ 07").
  final TextStyle numeralSmall;

  /// Whether [data] text is set in uppercase. False for Arabic, which has
  /// no case and must not be tracked.
  final bool uppercaseData;

  static KanzType build(KanzColors c, {bool arabic = false}) {
    const tabular = [FontFeature.tabularFigures()];
    // Fraunces defaults to old-style figures; numerals must line up.
    const lining = [FontFeature.liningFigures(), FontFeature.tabularFigures()];
    final fallback = arabic ? [KanzFonts.sans] : [KanzFonts.arabic];
    TextStyle numeralStyle(double size, double lh, FontWeight w, double ls) =>
        TextStyle(
          fontFamily: KanzFonts.display,
          fontFamilyFallback: const [KanzFonts.arabic],
          fontSize: size,
          height: lh / size,
          fontWeight: w,
          letterSpacing: ls,
          color: c.ink,
          fontFeatures: lining,
          leadingDistribution: TextLeadingDistribution.even,
        );
    return KanzType(
      data: arabic
          ? TextStyle(
              fontFamily: KanzFonts.arabic,
              fontFamilyFallback: fallback,
              fontSize: 12,
              height: 18 / 12,
              fontWeight: FontWeight.w500,
              color: c.inkSecondary,
              leadingDistribution: TextLeadingDistribution.even,
            )
          : TextStyle(
              fontFamily: KanzFonts.mono,
              fontFamilyFallback: fallback,
              fontSize: 11,
              height: 16 / 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.1,
              color: c.inkSecondary,
              fontFeatures: tabular,
              leadingDistribution: TextLeadingDistribution.even,
            ),
      dataStrong: arabic
          ? TextStyle(
              fontFamily: KanzFonts.arabic,
              fontFamilyFallback: fallback,
              fontSize: 14,
              height: 22 / 14,
              fontWeight: FontWeight.w500,
              color: c.ink,
              leadingDistribution: TextLeadingDistribution.even,
            )
          : TextStyle(
              fontFamily: KanzFonts.mono,
              fontFamilyFallback: fallback,
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              color: c.ink,
              fontFeatures: tabular,
              leadingDistribution: TextLeadingDistribution.even,
            ),
      numeralLarge: numeralStyle(56, 60, FontWeight.w300, -1.2),
      numeral: numeralStyle(40, 44, FontWeight.w300, -0.8),
      numeralSmall: numeralStyle(20, 24, FontWeight.w400, 0),
      uppercaseData: !arabic,
    );
  }

  @override
  KanzType copyWith({
    TextStyle? data,
    TextStyle? dataStrong,
    TextStyle? numeralLarge,
    TextStyle? numeral,
    TextStyle? numeralSmall,
    bool? uppercaseData,
  }) {
    return KanzType(
      data: data ?? this.data,
      dataStrong: dataStrong ?? this.dataStrong,
      numeralLarge: numeralLarge ?? this.numeralLarge,
      numeral: numeral ?? this.numeral,
      numeralSmall: numeralSmall ?? this.numeralSmall,
      uppercaseData: uppercaseData ?? this.uppercaseData,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is KanzType &&
      other.data == data &&
      other.dataStrong == dataStrong &&
      other.numeralLarge == numeralLarge &&
      other.numeral == numeral &&
      other.numeralSmall == numeralSmall &&
      other.uppercaseData == uppercaseData;

  @override
  int get hashCode => Object.hash(
    data,
    dataStrong,
    numeralLarge,
    numeral,
    numeralSmall,
    uppercaseData,
  );

  @override
  KanzType lerp(ThemeExtension<KanzType>? other, double t) {
    if (other is! KanzType) return this;
    return KanzType(
      data: TextStyle.lerp(data, other.data, t)!,
      dataStrong: TextStyle.lerp(dataStrong, other.dataStrong, t)!,
      numeralLarge: TextStyle.lerp(numeralLarge, other.numeralLarge, t)!,
      numeral: TextStyle.lerp(numeral, other.numeral, t)!,
      numeralSmall: TextStyle.lerp(numeralSmall, other.numeralSmall, t)!,
      uppercaseData: t < 0.5 ? uppercaseData : other.uppercaseData,
    );
  }
}
