import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../../../core/providers/local/sqlite_database_provider.dart';
import '../../../core/utils/enums/transaction_status.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';

final mascotRepositoryProvider = Provider<MascotRepository>(
  (ref) => MascotRepository(ref.read(sqliteDataBaseProvider)),
);

/// How the user has been recording, for the hamster's "activity" signals.
class MascotActivity {
  const MascotActivity({
    this.lastRecordAt,
    this.recordCount = 0,
    this.firstUseAt,
    this.recordsSince = 0,
  });

  /// Newest row the user entered (rows posted by a recurring rule excluded).
  final DateTime? lastRecordAt;
  final int recordCount;

  /// First wallet ever created (deleted ones too).
  final DateTime? firstUseAt;

  /// Rows created since the previous visit (any origin).
  final int recordsSince;
}

/// One wallet's month so far, in the wallet's currency.
class MascotWalletActivity {
  const MascotWalletActivity({required this.monthNetMinor, this.lastActivityAt});

  /// Income + transfers in − expenses − transfers out since the 1st.
  final int monthNetMinor;
  final DateTime? lastActivityAt;
}

/// Read-only queries behind the companion. Never fails loudly: a missing
/// answer just means the hamster stays calm.
class MascotRepository {
  const MascotRepository(this.sqlite);

  final SQLiteServices sqlite;

  static const _t = SQLiteConfig.transactionsTable;

  Future<MascotActivity> activity({DateTime? since}) async {
    try {
      final db = sqlite.db;
      final own = await db.rawQuery('''
        SELECT MAX(${SQLiteConfig.createdAt}) AS last_at, COUNT(*) AS n
        FROM $_t
        WHERE ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.txRecurringRuleId} IS NULL
      ''');
      final first = await db.rawQuery(
        'SELECT MIN(${SQLiteConfig.createdAt}) AS first_at FROM ${SQLiteConfig.walletsTable}',
      );
      var recordsSince = 0;
      if (since != null) {
        recordsSince = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT COUNT(*) FROM $_t WHERE ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.createdAt} > ?',
              [since.epochMs],
            )) ??
            0;
      }
      final lastAt = own.first['last_at'] as int?;
      final firstAt = first.first['first_at'] as int?;
      return MascotActivity(
        lastRecordAt: lastAt == null ? null : DateTimeExtension.fromEpochMs(lastAt),
        recordCount: (own.first['n'] as int?) ?? 0,
        firstUseAt: firstAt == null ? null : DateTimeExtension.fromEpochMs(firstAt),
        recordsSince: recordsSince,
      );
    } catch (_) {
      return const MascotActivity();
    }
  }

  /// When the user's own rows (not posted by a rule) were created since
  /// [since] — today's count and the day streak.
  Future<List<DateTime>> recordTimes({required DateTime since}) async {
    try {
      final rows = await sqlite.db.rawQuery(
        'SELECT ${SQLiteConfig.createdAt} AS at FROM $_t '
        'WHERE ${SQLiteConfig.deletedAt} IS NULL AND ${SQLiteConfig.txRecurringRuleId} IS NULL '
        'AND ${SQLiteConfig.createdAt} >= ?',
        [since.epochMs],
      );
      return [for (final r in rows) DateTimeExtension.fromEpochMs(r['at'] as int)];
    } catch (_) {
      return const [];
    }
  }

  Future<MascotWalletActivity?> walletActivity(String walletId, {DateTime? now}) async {
    try {
      final clock = now ?? DateTime.now();
      final monthStart = DateTime(clock.year, clock.month);
      final posted = TransactionStatus.posted.dbValue;
      final touches = '(${SQLiteConfig.txWalletId} = ?1 OR ${SQLiteConfig.txFromWalletId} = ?1 OR ${SQLiteConfig.txToWalletId} = ?1)';
      final rows = await sqlite.db.rawQuery('''
        SELECT
          COALESCE(SUM(CASE
            WHEN ${SQLiteConfig.txDate} < ?2 THEN 0
            WHEN ${SQLiteConfig.txType} = 'income'  AND ${SQLiteConfig.txWalletId} = ?1 THEN ${SQLiteConfig.txAmountMinor}
            WHEN ${SQLiteConfig.txType} = 'expense' AND ${SQLiteConfig.txWalletId} = ?1 THEN -${SQLiteConfig.txAmountMinor}
            WHEN ${SQLiteConfig.txType} = 'transfer' AND ${SQLiteConfig.txToWalletId} = ?1 THEN ${SQLiteConfig.txToAmountMinor}
            WHEN ${SQLiteConfig.txType} = 'transfer' AND ${SQLiteConfig.txFromWalletId} = ?1 THEN -${SQLiteConfig.txFromAmountMinor}
            ELSE 0 END), 0) AS net,
          MAX(${SQLiteConfig.txDate}) AS last_at
        FROM $_t
        WHERE ${SQLiteConfig.deletedAt} IS NULL
          AND ${SQLiteConfig.txStatus} = '$posted'
          AND $touches
      ''', [walletId, monthStart.epochMs]);
      final lastAt = rows.first['last_at'] as int?;
      return MascotWalletActivity(
        monthNetMinor: (rows.first['net'] as int?) ?? 0,
        lastActivityAt: lastAt == null ? null : DateTimeExtension.fromEpochMs(lastAt),
      );
    } catch (_) {
      return null;
    }
  }
}
