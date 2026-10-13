/// Who owes whom, from the user's point of view.
///
/// * [lent] — the person owes the user ("Ahmed owes me €50").
/// * [borrowed] — the user owes the person ("I owe Sara €200").
enum DebtDirection {
  lent('lent'),
  borrowed('borrowed');

  const DebtDirection(this.dbValue);

  /// Value stored in `debts.direction`.
  final String dbValue;

  static DebtDirection fromString(String value) {
    final v = value.toLowerCase();
    for (final d in values) {
      if (d.dbValue == v) return d;
    }
    throw ArgumentError('Unknown debt direction: $value');
  }

  DebtDirection get opposite => this == lent ? borrowed : lent;
}
