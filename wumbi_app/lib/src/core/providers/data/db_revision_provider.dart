import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Monotonic counter bumped by repositories after every successful write.
/// Read-only providers (wallet list, balances, dashboard) `ref.watch` it and
/// re-query — this replaces manual "reload after save" wiring.
final dbRevisionProvider = NotifierProvider<DbRevisionNotifier, int>(
  DbRevisionNotifier.new,
);

class DbRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

/// Convenience for repositories: `ref.read(dbRevisionBumperProvider)()`.
final dbRevisionBumperProvider = Provider<void Function()>(
  (ref) => () => ref.read(dbRevisionProvider.notifier).bump(),
);
