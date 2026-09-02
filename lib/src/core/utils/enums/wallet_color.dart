import 'dart:ui';

import '../../design_system/app_ui.dart';

/// Wallet colours are stored as keys so the theme can restyle them.
enum WalletColor {
  blue('blue'),
  amber('amber'),
  red('red'),
  green('green'),
  violet('violet');

  const WalletColor(this.dbValue);

  final String dbValue;

  Color get color => switch (this) {
        blue => UIColorToken.blue,
        amber => UIColorToken.buttercup,
        red => UIColorToken.red,
        green => UIColorToken.mountainMeadow,
        violet => UIColorToken.violet,
      };

  static WalletColor fromString(String? value) {
    if (value == null) return blue;
    final v = value.toLowerCase();
    for (final c in values) {
      if (c.dbValue == v) return c;
    }
    return blue;
  }
}
