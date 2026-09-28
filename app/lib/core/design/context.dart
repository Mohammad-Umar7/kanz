/// Shortcuts from a [BuildContext] to the Kanz theme extensions.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

extension KanzThemeContext on BuildContext {
  /// Semantic colors of the ambient Kanz theme.
  KanzColors get kanzColors =>
      Theme.of(this).extension<KanzColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? KanzColors.dark
          : KanzColors.light);

  /// Kanz text roles (mono data, numerals) of the ambient theme.
  KanzType get kanzType =>
      Theme.of(this).extension<KanzType>() ?? KanzType.build(kanzColors);

  /// Material text roles of the ambient theme.
  TextTheme get textStyles => Theme.of(this).textTheme;

  /// Whether the platform asked for reduced motion.
  bool get reduceMotion => KanzMotion.reduced(this);

  /// Whether the ambient text direction is right-to-left.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
