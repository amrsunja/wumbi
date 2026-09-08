import 'dart:ui';

import '../../design_system/app_ui.dart';

/// Wallet colours are stored as keys so the theme can restyle them.
/// 20 swatches; the first five are the v1 set (DB rows already use them).
enum WalletColor {
  blue('blue', UIColorToken.blue),
  amber('amber', UIColorToken.buttercup),
  red('red', UIColorToken.red),
  green('green', UIColorToken.mountainMeadow),
  violet('violet', UIColorToken.violet),
  sky('sky', Color(0xff0EA5E9)),
  cyan('cyan', Color(0xff06B6D4)),
  teal('teal', Color(0xff14B8A6)),
  emerald('emerald', Color(0xff10B981)),
  lime('lime', Color(0xff84CC16)),
  yellow('yellow', Color(0xffEAB308)),
  orange('orange', Color(0xffF97316)),
  coral('coral', Color(0xffFB7185)),
  pink('pink', Color(0xffEC4899)),
  fuchsia('fuchsia', Color(0xffD946EF)),
  purple('purple', Color(0xffA855F7)),
  indigo('indigo', Color(0xff6366F1)),
  navy('navy', Color(0xff1E3A8A)),
  brown('brown', Color(0xffA16207)),
  slate('slate', Color(0xff64748B));

  const WalletColor(this.dbValue, this.color);

  final String dbValue;
  final Color color;

  static WalletColor fromString(String? value) {
    if (value == null) return blue;
    final v = value.toLowerCase();
    for (final c in values) {
      if (c.dbValue == v) return c;
    }
    return blue;
  }
}
