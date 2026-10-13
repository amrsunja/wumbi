/// Why a transaction is linked to a debt (`transactions.debt_role`).
///
/// * [principal] — the money that moved when the debt was opened (lent out
///   or borrowed in).
/// * [repayment] — the money that moved when (part of) a debt was paid back.
///
/// Debt-linked rows are real money, so they move wallet balances, but they
/// are neither spending nor income: budgets, Progress and tag analytics
/// filter them out (`debt_role IS NULL`).
enum DebtRole {
  principal('principal'),
  repayment('repayment');

  const DebtRole(this.dbValue);

  /// Value stored in the `debt_role` column.
  final String dbValue;

  /// `null` for ordinary (not debt-linked) rows.
  static DebtRole? tryFromString(String? value) {
    if (value == null) return null;
    final v = value.toLowerCase();
    for (final r in values) {
      if (r.dbValue == v) return r;
    }
    return null;
  }
}
