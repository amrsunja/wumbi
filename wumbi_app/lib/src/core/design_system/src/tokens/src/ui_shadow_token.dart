part of '../../../app_ui.dart';

abstract class UIShadowToken {
  static final dropShadow = [
    BoxShadow(
      color: UIColorToken.black.withValues(alpha: 0.1),
      blurRadius: 4,
      spreadRadius: -2,
      offset: const Offset(0, 2),
    ),
  ];

  static final buttonBlueShadow = [
    BoxShadow(
      color: UIColorToken.blue.withValues(alpha: 0.35),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static final sheetShadow = [
    BoxShadow(
      color: UIColorToken.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];
}
