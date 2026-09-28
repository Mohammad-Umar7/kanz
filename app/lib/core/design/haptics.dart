/// Haptic feedback vocabulary. Kanz uses haptics for two moments only:
/// taking a photo and completing a tutorial step, plus selection ticks on
/// discrete controls such as the before/after slider's end stops.
library;

import 'package:flutter/services.dart';

abstract final class KanzHaptics {
  /// The shutter fires.
  static Future<void> capture() => HapticFeedback.mediumImpact();

  /// A tutorial step is marked done.
  static Future<void> stepComplete() => HapticFeedback.lightImpact();

  /// A discrete selection changes.
  static Future<void> selection() => HapticFeedback.selectionClick();
}
