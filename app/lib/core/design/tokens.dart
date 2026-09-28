/// Design tokens for Kanz: color, spacing, radii, elevation and motion.
///
/// Screens never use raw colors, sizes or durations; they read these tokens
/// (usually through `context.kanzColors` and friends from `design.dart`).
/// Every value here is documented, with measured contrast ratios, in
/// DESIGN.md at the repository root.
library;

import 'package:flutter/material.dart';

/// Semantic color tokens, available from the theme as a [ThemeExtension].
///
/// The palette is warm paper and ink with a single accent (clay). Clay is
/// reserved for the scan action, active states and the before/after handle;
/// primary buttons are ink.
@immutable
class KanzColors extends ThemeExtension<KanzColors> {
  const KanzColors({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.raised,
    required this.track,
    required this.ink,
    required this.inkSecondary,
    required this.inkDisabled,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.onAccent,
    required this.inverse,
    required this.onInverse,
    required this.danger,
    required this.onDanger,
    required this.caution,
    required this.positive,
    required this.scrim,
    required this.photoBackdrop,
    required this.shadow,
  });

  /// Paper: the page background behind cards and lists.
  final Color background;

  /// Cards, sheets, dialogs and the navigation bar.
  final Color surface;

  /// Recessed fills: segmented tracks, skeletons, callouts, tags.
  final Color surfaceSunken;

  /// A control raised above a sunken track (the segmented-tab thumb).
  final Color raised;

  /// Empty segments of quality, step and material bars: quiet, but visible
  /// on both background and surface.
  final Color track;

  /// Primary text and icons, and the fill of primary buttons.
  final Color ink;

  /// Secondary text (captions, data labels). AA on background and surface.
  final Color inkSecondary;

  /// Disabled text and icons. Exempt from contrast rules by WCAG.
  final Color inkDisabled;

  /// Hairline dividers and card borders. Decorative only.
  final Color line;

  /// Borders that identify a control (inputs, outlined buttons, unchecked
  /// boxes). At least 3:1 against background and surface.
  final Color lineStrong;

  /// Clay, the one accent.
  final Color accent;

  /// Text and glyphs on [accent]. At least 4.5:1.
  final Color onAccent;

  /// Inverse surface (snackbars, selected chips).
  final Color inverse;

  /// Text on [inverse].
  final Color onInverse;

  /// Errors and hazard warnings (text and glyphs).
  final Color danger;

  /// Text on a [danger] fill (destructive buttons).
  final Color onDanger;

  /// Caution glyphs in warning callouts.
  final Color caution;

  /// Small positive signals such as "Open now".
  final Color positive;

  /// Modal barrier color.
  final Color scrim;

  /// Behind camera previews and photos, identical in both themes.
  final Color photoBackdrop;

  /// Base color for the soft shadows of floating elements.
  final Color shadow;

  static const KanzColors light = KanzColors(
    background: Color(0xFFF4F1EA),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFECE8DF),
    raised: Color(0xFFFFFFFF),
    track: Color(0xFFD8D2C6),
    ink: Color(0xFF161616),
    inkSecondary: Color(0xFF5C5A55),
    inkDisabled: Color(0xFFA9A59C),
    line: Color(0xFFE2DDD3),
    lineStrong: Color(0xFF8A857B),
    accent: Color(0xFFC65026),
    onAccent: Color(0xFFFFFFFF),
    inverse: Color(0xFF161616),
    onInverse: Color(0xFFF4F1EA),
    danger: Color(0xFFB3261E),
    onDanger: Color(0xFFFFFFFF),
    caution: Color(0xFF8A5D00),
    positive: Color(0xFF2F6B3A),
    scrim: Color(0x80161616),
    photoBackdrop: Color(0xFF0B0B0A),
    shadow: Color(0xFF2B2418),
  );

  static const KanzColors dark = KanzColors(
    background: Color(0xFF111210),
    surface: Color(0xFF1A1B19),
    surfaceSunken: Color(0xFF242522),
    raised: Color(0xFF33342F),
    track: Color(0xFF3A3B36),
    ink: Color(0xFFF2EFE8),
    inkSecondary: Color(0xFFA8A59C),
    inkDisabled: Color(0xFF5E5C56),
    line: Color(0xFF2C2D29),
    lineStrong: Color(0xFF77746C),
    accent: Color(0xFFF07A4F),
    onAccent: Color(0xFF161616),
    inverse: Color(0xFFF2EFE8),
    onInverse: Color(0xFF161616),
    danger: Color(0xFFF28B82),
    onDanger: Color(0xFF161616),
    caution: Color(0xFFE3B341),
    positive: Color(0xFF8FC79A),
    scrim: Color(0xB3000000),
    photoBackdrop: Color(0xFF0B0B0A),
    shadow: Color(0xFF000000),
  );

  @override
  KanzColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSunken,
    Color? raised,
    Color? track,
    Color? ink,
    Color? inkSecondary,
    Color? inkDisabled,
    Color? line,
    Color? lineStrong,
    Color? accent,
    Color? onAccent,
    Color? inverse,
    Color? onInverse,
    Color? danger,
    Color? onDanger,
    Color? caution,
    Color? positive,
    Color? scrim,
    Color? photoBackdrop,
    Color? shadow,
  }) {
    return KanzColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      raised: raised ?? this.raised,
      track: track ?? this.track,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkDisabled: inkDisabled ?? this.inkDisabled,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      inverse: inverse ?? this.inverse,
      onInverse: onInverse ?? this.onInverse,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      caution: caution ?? this.caution,
      positive: positive ?? this.positive,
      scrim: scrim ?? this.scrim,
      photoBackdrop: photoBackdrop ?? this.photoBackdrop,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  KanzColors lerp(ThemeExtension<KanzColors>? other, double t) {
    if (other is! KanzColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return KanzColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      raised: l(raised, other.raised),
      track: l(track, other.track),
      ink: l(ink, other.ink),
      inkSecondary: l(inkSecondary, other.inkSecondary),
      inkDisabled: l(inkDisabled, other.inkDisabled),
      line: l(line, other.line),
      lineStrong: l(lineStrong, other.lineStrong),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      inverse: l(inverse, other.inverse),
      onInverse: l(onInverse, other.onInverse),
      danger: l(danger, other.danger),
      onDanger: l(onDanger, other.onDanger),
      caution: l(caution, other.caution),
      positive: l(positive, other.positive),
      scrim: l(scrim, other.scrim),
      photoBackdrop: l(photoBackdrop, other.photoBackdrop),
      shadow: l(shadow, other.shadow),
    );
  }
}

/// Colors for chrome laid over photos and the camera preview: bounding box
/// tags, before/after labels, the shutter ring, controls on the viewfinder.
/// Photos have no theme, so these are the same in light and dark mode.
abstract final class KanzPhotoColors {
  /// Text, hairlines and rings on photos: warm white.
  static const Color ink = Color(0xFFF2EFE8);

  /// Solid label chips on photos. Near-opaque so text reads on any image.
  static const Color tag = Color(0xF0161616);

  /// Discs behind icon buttons on photos (80 % ink): a plain tint, never a
  /// blur or glass effect.
  static const Color control = Color(0xCC161616);

  /// A toggled control on a photo (flash on): the dark-theme clay, which
  /// keeps its contrast on the dark disc in both themes.
  static Color get accent => KanzColors.dark.accent;
}

/// Spacing on an 8 pt grid (4 pt half steps for tight clusters).
abstract final class KanzSpace {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;

  /// Horizontal screen gutter.
  static const double gutter = 20;

  /// Minimum interactive target (Material and WCAG 2.2 guidance).
  static const double touchTarget = 48;

  /// Standard horizontal page padding, direction-aware.
  static const EdgeInsetsDirectional page = EdgeInsetsDirectional.symmetric(
    horizontal: gutter,
  );
}

/// Corner radii. Larger containers get larger radii.
abstract final class KanzRadii {
  static const double sheet = 20;
  static const double card = 16;
  static const double button = 14;
  static const double input = 12;
  static const double chip = 10;
  static const double tag = 6;

  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonAll = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius chipAll = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius tagAll = BorderRadius.all(Radius.circular(tag));
}

/// Borders and shadows. Kanz is mostly flat: hairline borders everywhere,
/// soft shadows only on elements that float above content (the navigation
/// bar, the shutter, sheets, the before/after handle).
abstract final class KanzElevation {
  static const double hairline = 1;

  /// Soft two-layer shadow for floating elements: a short, low ambient
  /// shadow and a tight contact shadow. Kept close to the element so it
  /// separates without looking like a second shape.
  static List<BoxShadow> floating(KanzColors colors) {
    final dark = colors.surface.computeLuminance() < 0.2;
    return [
      BoxShadow(
        color: colors.shadow.withValues(alpha: dark ? 0.40 : 0.10),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: colors.shadow.withValues(alpha: dark ? 0.25 : 0.06),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }
}

/// Motion tokens: three durations and Material 3 emphasized easing.
///
/// Motion is short and calm: nothing bounces and nothing runs longer than
/// [slow] except the one-pass scan line. When the platform asks for reduced
/// motion ([MediaQuery.disableAnimations]) animations resolve instantly.
abstract final class KanzMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  /// Delay between items in a staggered list entrance.
  static const Duration stagger = Duration(milliseconds: 40);

  /// Items after this index enter without extra delay.
  static const int maxStaggered = 6;

  /// Elements entering the screen.
  static const Curve enter = Easing.emphasizedDecelerate;

  /// Elements leaving the screen.
  static const Curve exit = Easing.emphasizedAccelerate;

  /// Elements that move while staying on screen.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Small state changes (color, opacity).
  static const Curve standard = Easing.standard;

  /// Whether the user asked the platform to reduce motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when motion is reduced.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
