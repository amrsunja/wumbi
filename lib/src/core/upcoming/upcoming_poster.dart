import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/transaction/data/transaction_repository.dart';
import '../local/database/sqlite/sqlite_services.dart';
import '../providers/data/db_revision_provider.dart';
import '../providers/local/sqlite_database_provider.dart';
import '../utils/debug_print.dart';

final upcomingPosterProvider = Provider<UpcomingPoster>((ref) {
  final poster = UpcomingPoster(
    sqlite: ref.read(sqliteDataBaseProvider),
    transactions: ref.read(transactionRepositoryProvider),
  );
  // Any write may create / move / delete an upcoming row → re-arm the timer.
  ref.listen(dbRevisionProvider, (_, _) => poster.reschedule());
  ref.onDispose(poster.dispose);
  return poster;
});

/// Promotes `upcoming` transactions to `posted` once their date arrives.
///
/// Runs at startup (after the recurring catch-up), on every foreground
/// re-entry, and from an in-app timer armed for the earliest pending date
/// (so a transaction dated today at 12:00 posts while the app stays open —
/// no background execution is needed, the next launch catches up anyway).
class UpcomingPoster {
  UpcomingPoster({required this.sqlite, required this.transactions});

  final SQLiteServices sqlite;
  final TransactionRepository transactions;

  Timer? _timer;
  bool _running = false;

  /// Foreground re-entry: ignore when the DB is not open yet (splash owns it).
  Future<void> postDueIfPossible() async {
    if (!sqlite.isOpen) return;
    await postDue();
  }

  /// Returns the number of transactions posted.
  Future<int> postDue({DateTime? now}) async {
    if (_running) return 0;
    _running = true;
    try {
      final posted = await transactions.postDueUpcoming(now: now);
      if (posted > 0) debugPrint('Upcoming: posted $posted transaction(s)');
      await _armTimer();
      return posted;
    } finally {
      _running = false;
    }
  }

  /// Call after any write that may have created / moved an upcoming row.
  Future<void> reschedule() => _armTimer();

  Future<void> _armTimer() async {
    _timer?.cancel();
    _timer = null;
    final next = await transactions.nextUpcomingDate();
    if (next == null) return;
    var delay = next.difference(DateTime.now());
    if (delay.isNegative) delay = Duration.zero;
    // Timer.periodic-free: one shot, capped at a day so long waits re-arm.
    if (delay > const Duration(days: 1)) delay = const Duration(days: 1);
    _timer = Timer(delay + const Duration(seconds: 1), () {
      _timer = null;
      postDue();
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
