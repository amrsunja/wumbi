part of '../../../app_ui.dart';

abstract class UITextStyleToken {
  static final TextStyle interExtra = GoogleFonts.inter(fontWeight: FontWeight.w900);
  static final TextStyle interBold = GoogleFonts.inter(fontWeight: FontWeight.bold);
  static final TextStyle interSemiBold = GoogleFonts.inter(fontWeight: FontWeight.w600);
  static final TextStyle interMedium = GoogleFonts.inter(fontWeight: FontWeight.w500);
  static final TextStyle interRegular = GoogleFonts.inter(fontWeight: FontWeight.w400);
  static final TextStyle interLight = GoogleFonts.inter(fontWeight: FontWeight.w300);

  /// Big amounts: Montserrat 300 (totals) / 700 (transaction input).
  static final TextStyle montserratLight = GoogleFonts.montserrat(fontWeight: FontWeight.w300);
  static final TextStyle montserratBold = GoogleFonts.montserrat(fontWeight: FontWeight.w700);

  /// Uppercase section label: 11 px, casper, tracking 1.2.
  static TextStyle sectionLabel(UIColorToken colors) => interSemiBold.copyWith(
        fontSize: 11,
        letterSpacing: 1.2,
        color: colors.secondContentColor,
      );

  /// Captions: 12 px medium casper.
  static TextStyle caption(UIColorToken colors) => interMedium.copyWith(
        fontSize: 12,
        color: colors.secondContentColor,
      );

  /// Row title: 16 px medium.
  static TextStyle rowTitle(UIColorToken colors) => interMedium.copyWith(
        fontSize: 16,
        color: colors.contentColor,
      );
}
