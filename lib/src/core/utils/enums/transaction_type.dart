enum TransactionType {
  income('income'),
  expense('expense'),
  transfer('transfer');

  const TransactionType(this.dbValue);

  /// Value stored in the `type` column.
  final String dbValue;

  static TransactionType? tryFromString(String? value) {
    if (value == null) return null;
    final v = value.toLowerCase();
    for (final t in values) {
      if (t.dbValue == v) return t;
    }
    return null;
  }

  static TransactionType fromString(String value) =>
      tryFromString(value) ?? (throw ArgumentError('Unknown transaction type: $value'));

  bool get isTransfer => this == transfer;
}
