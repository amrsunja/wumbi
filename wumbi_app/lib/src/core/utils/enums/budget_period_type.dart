/// How a budget repeats (`budgets.period`).
///
/// [custom] is a one-time range: `anchor_date` (inclusive) → `end_date`
/// (exclusive). The others repeat forever from `anchor_date`.
enum BudgetPeriodType {
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly'),
  custom('custom');

  const BudgetPeriodType(this.dbValue);

  /// Value stored in `budgets.period`.
  final String dbValue;

  bool get isCustom => this == custom;

  static BudgetPeriodType fromString(String value) {
    final v = value.toLowerCase();
    for (final p in values) {
      if (p.dbValue == v) return p;
    }
    throw ArgumentError('Unknown budget period: $value');
  }
}
