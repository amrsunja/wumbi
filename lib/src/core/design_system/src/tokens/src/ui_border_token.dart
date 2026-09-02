part of '../../../app_ui.dart';

class UIBorderToken {
  const UIBorderToken({required this.tileRadius, required this.sheetRadius, required this.swatchRadius});

  factory UIBorderToken.light() => const UIBorderToken(tileRadius: 12, sheetRadius: 24, swatchRadius: 6);
  factory UIBorderToken.dark() => const UIBorderToken(tileRadius: 12, sheetRadius: 24, swatchRadius: 6);

  final double tileRadius;
  final double sheetRadius;
  final double swatchRadius;
}
