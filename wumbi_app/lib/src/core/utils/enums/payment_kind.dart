/// How part of a debt was settled (`debt_payments.kind`).
///
/// * [repayment] — money really came back (optionally through a wallet
///   transaction).
/// * [forgiveness] — the user waived the rest; never moves money, so it never
///   has a transaction.
enum PaymentKind {
  repayment('repayment'),
  forgiveness('forgiveness');

  const PaymentKind(this.dbValue);

  /// Value stored in `debt_payments.kind`.
  final String dbValue;

  static PaymentKind fromString(String value) {
    final v = value.toLowerCase();
    for (final k in values) {
      if (k.dbValue == v) return k;
    }
    throw ArgumentError('Unknown payment kind: $value');
  }
}
