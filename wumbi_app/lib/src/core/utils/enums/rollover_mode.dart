/// What happens to a budget's leftover at the end of a period
/// (`budgets.rollover`). Not available for one-time (custom) budgets.
///
/// * [none] — every period starts at the limit.
/// * [surplus] — unspent money carries into the next period; overspend is
///   forgotten.
/// * [both] — surplus and overspend carry over (the effective limit may
///   drop to zero or below).
enum RolloverMode {
  none('none'),
  surplus('surplus'),
  both('both');

  const RolloverMode(this.dbValue);

  /// Value stored in `budgets.rollover`.
  final String dbValue;

  bool get isNone => this == none;

  static RolloverMode fromString(String? value) {
    if (value == null) return none;
    final v = value.toLowerCase();
    for (final m in values) {
      if (m.dbValue == v) return m;
    }
    return none;
  }
}
