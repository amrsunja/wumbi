/// Lifecycle of a transaction row.
///
/// * [posted] — counted in `wallet_balances`.
/// * [upcoming] — future-dated, user-created; shown dimmed at the top of the
///   wallet list and excluded from balances until `UpcomingPoster` promotes
///   it on / after its `transaction_date`.
///
/// Recurring-engine occurrences are always [posted] (they are generated on
/// their due date).
enum TransactionStatus {
  posted('posted'),
  upcoming('upcoming');

  const TransactionStatus(this.dbValue);

  /// Value stored in the `status` column.
  final String dbValue;

  static TransactionStatus fromString(String? value) {
    if (value == null) return posted;
    final v = value.toLowerCase();
    for (final s in values) {
      if (s.dbValue == v) return s;
    }
    return posted;
  }

  bool get isUpcoming => this == upcoming;

  /// A user-created transaction dated after *today* is upcoming; anything
  /// today or earlier posts immediately.
  static TransactionStatus forDate(DateTime date, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final endOfToday = DateTime(n.year, n.month, n.day + 1);
    return date.isBefore(endOfToday) ? posted : upcoming;
  }
}
