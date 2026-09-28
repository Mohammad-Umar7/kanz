import 'package:flutter/services.dart';

/// Named haptic moments so the feel is consistent across screens.
abstract final class Haptics {
  /// Chips, toggles, tab changes.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Shutter press and primary actions.
  static Future<void> tap() => HapticFeedback.lightImpact();

  /// Analysis finished, step done, project completed.
  static Future<void> success() => HapticFeedback.mediumImpact();

  /// A stage failed or an action was refused.
  static Future<void> warning() => HapticFeedback.heavyImpact();
}
