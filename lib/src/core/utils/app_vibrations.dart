import 'package:flutter/services.dart';

/// Haptics: light on numpad keys, medium on commit, heavy on delete.
abstract class AppVibrations {
  static Future<void> buttonClick() => HapticFeedback.mediumImpact();
  static Future<void> selection() => HapticFeedback.selectionClick();
  static Future<void> light() => HapticFeedback.lightImpact();
  static Future<void> medium() => HapticFeedback.mediumImpact();
  static Future<void> heavy() => HapticFeedback.heavyImpact();
  static Future<void> error() => HapticFeedback.vibrate();

  /// Kept for existing call sites.
  static Future<void> hight() => heavy();
}
