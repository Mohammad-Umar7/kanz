/// WCAG 2.x contrast math, used to pick legible text on data colors and to
/// test every token pair (see test/design/contrast_test.dart).
library;

import 'package:flutter/painting.dart';

abstract final class KanzContrast {
  /// WCAG contrast ratio between two opaque colors, from 1 to 21.
  static double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Minimum ratio for body text (WCAG AA).
  static const double text = 4.5;

  /// Minimum ratio for large text (24 px, or 18.66 px bold) and for the
  /// glyphs and boundaries of interface components (WCAG AA).
  static const double large = 3.0;

  /// Whichever of [dark] and [light] reads better on [background].
  static Color bestOn(
    Color background, {
    required Color dark,
    required Color light,
  }) {
    return ratio(dark, background) >= ratio(light, background) ? dark : light;
  }
}
