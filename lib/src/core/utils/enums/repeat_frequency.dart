enum RepeatFrequency {
  never('never'),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const RepeatFrequency(this.dbValue);

  /// Value stored in `recurring_rules.frequency` (`never` is never stored).
  final String dbValue;

  bool get isNever => this == never;

  static RepeatFrequency fromString(String? value) {
    if (value == null) return never;
    final v = value.toLowerCase();
    for (final f in values) {
      if (f.dbValue == v) return f;
    }
    return never;
  }
}
