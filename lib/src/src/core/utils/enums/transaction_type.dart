import 'dart:ui';

import 'package:fiin/src/src/core/design_system/app_ui.dart';

enum TransactionType {
  income,
  expense,
  transfer,
  undefined;

  static TransactionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'income': return income;
      case 'expense': return expense;
      case 'transfer': return transfer;
      default: return undefined;
    }
  }

  String get symbol {
    switch (this) {
      case income: return '+';
      case expense: return '-';
      case transfer: return '⇆';
      default: return '';
    }
  }

  Color get color {
    switch (this) {
      case income: return UIColorToken.blue;
      case expense: return UIColorToken.black;
      case transfer: return UIColorToken.casper;
      default: return UIColorToken.grey;
    }
  }
}
