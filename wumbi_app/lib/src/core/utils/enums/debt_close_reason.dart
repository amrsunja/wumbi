/// Cached reason a debt is closed (`debts.close_reason`). Recomputed with
/// `closed_at` after every write touching the debt or its payments.
enum DebtCloseReason {
  repaid('repaid'),
  forgiven('forgiven');

  const DebtCloseReason(this.dbValue);

  /// Value stored in `debts.close_reason`.
  final String dbValue;

  static DebtCloseReason? tryFromString(String? value) {
    if (value == null) return null;
    final v = value.toLowerCase();
    for (final r in values) {
      if (r.dbValue == v) return r;
    }
    return null;
  }
}
