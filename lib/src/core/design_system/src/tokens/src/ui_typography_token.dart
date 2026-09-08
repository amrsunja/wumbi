part of '../../../app_ui.dart';

/// Themed typography. Colors are baked in per theme (same logic as nour's
/// `UITypographyToken`): read via `context.typo.inter.rowTitle` and override
/// with `copyWith` only for semantic accents (blue / expense / destructive).
class UITypographyToken {
  const UITypographyToken({required this.inter, required this.montserrat});

  factory UITypographyToken.light() => UITypographyToken(
        inter: InterStyle.light(),
        montserrat: MontserratStyle.light(),
      );

  factory UITypographyToken.dark() => UITypographyToken(
        inter: InterStyle.dark(),
        montserrat: MontserratStyle.dark(),
      );

  /// UI text.
  final InterStyle inter;

  /// Big amounts (44 light for totals, 44 bold for the transaction input).
  final MontserratStyle montserrat;
}

/// Inter (google_fonts). `primary` = content colour, `secondary` = casper.
class InterStyle {
  InterStyle._({required Color primary, required Color secondary})
      // ---- weight bases (no size) — for one-offs / scaled illustrations ----
      : light = _style(FontWeight.w300, primary),
        regular = _style(FontWeight.w400, primary),
        medium = _style(FontWeight.w500, primary),
        semiBold = _style(FontWeight.w600, primary),
        bold = _style(FontWeight.w700, primary),
        extra = _style(FontWeight.w900, primary),

        // ---- primary content ----
        // 32 / 300 — wallet form title, big form inputs.
        display = _style(FontWeight.w300, primary, size: 32),

        // 20 / 600 — section headline ("Wallets").
        headline = _style(FontWeight.w700, primary, size: 19),

        // 17 / 600 — dialog title.
        title = _style(FontWeight.w600, primary, size: 17),

        // 18 / 600 — bottom-bar text buttons (Delete / Cancel / Save).
        button = _style(FontWeight.w600, primary, size: 18),

        // 16 / 600 — list row titles, wallet / transaction names, sheet titles.
        rowTitle = _style(FontWeight.w600, primary, size: 16),

        // 15 / 600 — compact picker rows.
        listTitle = _style(FontWeight.w600, primary, size: 15),

        // 16 / 500 — inputs, radio rows, settings tiles.
        body = _style(FontWeight.w500, primary, size: 16),

        // 15 / 500 — description field.
        bodyMedium = _style(FontWeight.w500, primary, size: 15),

        // 14 / 600 — emphasised labels (rule descriptions, currency names).
        label = _style(FontWeight.w600, primary, size: 14),

        // 14 / 500 — plain labels, tag input.
        labelMedium = _style(FontWeight.w500, primary, size: 14),

        // 24 / 500 — numpad digits.
        numpadKey = _style(FontWeight.w500, primary, size: 24),

        // 10 / 700 tracking 1.0 — uppercase micro labels (type actions, pills).
        micro = _style(FontWeight.w700, primary, size: 10, letterSpacing: 1.0),

        // 12 / 500 tracking 0.2 — date / repeat chips (was 10 in v1).
        chip = _style(FontWeight.w500, primary, size: 12, letterSpacing: 0.2),

        // ---- secondary content (casper) ----
        // 14 / 500 — subtitles ("Across 4 wallets", settings values).
        subtitle = _style(FontWeight.w500, secondary, size: 14),

        // 14 / 400 lh 1.5 — paragraphs (about, dialog messages).
        paragraph = _style(FontWeight.w400, secondary, size: 14, height: 1.5),

        // 13 / 500 — hints under lists / empty states.
        hint = _style(FontWeight.w500, secondary, size: 13),

        // 12 / 500 — captions (dates, conversion hints).
        caption = _style(FontWeight.w500, secondary, size: 12),

        // 12 / 600 — emphasised captions (calendar weekdays).
        captionBold = _style(FontWeight.w600, secondary, size: 12),

        // 12 / 700 tracking 1.6 — uppercase app-bar title.
        overline = _style(FontWeight.w700, secondary, size: 12, letterSpacing: 1.6),

        // 12 / 700 tracking 1.2 — currency code under a wallet name.
        currencyCode = _style(FontWeight.w700, secondary, size: 12, letterSpacing: 1.2),

        // 12 / 700 tracking 0.3 — select buttons ("USD ⌄").
        select = _style(FontWeight.w700, secondary, size: 12, letterSpacing: 0.3),

        // 11 / 600 tracking 1.2 — uppercase section labels.
        sectionLabel = _style(FontWeight.w600, secondary, size: 11, letterSpacing: 1.2);

  factory InterStyle.light() => InterStyle._(
        primary: UIColorToken.bismark,
        secondary: UIColorToken.casper,
      );

  factory InterStyle.dark() => InterStyle._(
        primary: UIColorToken.bismarkLight,
        secondary: UIColorToken.casper,
      );

  static TextStyle _style(
    FontWeight weight,
    Color color, {
    double? size,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontWeight: weight,
        fontSize: size,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );

  final TextStyle light;
  final TextStyle regular;
  final TextStyle medium;
  final TextStyle semiBold;
  final TextStyle bold;
  final TextStyle extra;

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle button;
  final TextStyle rowTitle;
  final TextStyle listTitle;
  final TextStyle body;
  final TextStyle bodyMedium;
  final TextStyle label;
  final TextStyle labelMedium;
  final TextStyle numpadKey;
  final TextStyle micro;
  final TextStyle chip;

  final TextStyle subtitle;
  final TextStyle paragraph;
  final TextStyle hint;
  final TextStyle caption;
  final TextStyle captionBold;
  final TextStyle overline;
  final TextStyle currencyCode;
  final TextStyle select;
  final TextStyle sectionLabel;
}

/// Montserrat — amounts only.
class MontserratStyle {
  MontserratStyle._({required Color primary})
      : light = GoogleFonts.montserrat(fontWeight: FontWeight.w300, color: primary),
        bold = GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: primary),

        // 44 / 300 — dashboard & wallet totals.
        total = GoogleFonts.montserrat(fontWeight: FontWeight.w300, fontSize: 44, color: primary),

        // 44 / 700 — amount being typed.
        input = GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 44, color: primary),

        // 40 / 300 — form balance / numpad sheet.
        formAmount = GoogleFonts.montserrat(fontWeight: FontWeight.w300, fontSize: 40, color: primary),

        // 32 / 700 — sheet amounts (transfer received).
        sheetAmount = GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 32, color: primary);

  factory MontserratStyle.light() => MontserratStyle._(primary: UIColorToken.bismark);
  factory MontserratStyle.dark() => MontserratStyle._(primary: UIColorToken.bismarkLight);

  final TextStyle light;
  final TextStyle bold;
  final TextStyle total;
  final TextStyle input;
  final TextStyle formAmount;
  final TextStyle sheetAmount;
}
