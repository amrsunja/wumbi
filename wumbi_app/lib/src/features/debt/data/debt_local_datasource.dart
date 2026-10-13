import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/enums/debt_close_reason.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/payment_kind.dart';
import 'models/debt_model.dart';

/// A debt row with its derived remaining amount (query D1).
typedef DebtWithRemaining = ({DebtModel debt, int remaining});

/// Live-payment aggregate used to recompute a debt's cached status.
typedef DebtPaymentTotals = ({int paid, int? lastPaidAt, bool hasForgiveness});

/// Raw queries for `debts` and `debt_payments`. No business rules: remaining
/// amounts are computed in SQL (D1) from live payments, never stored.
class DebtLocalDatasource {
  const DebtLocalDatasource();

  static const _d = SQLiteConfig.debtsTable;
  static const _p = SQLiteConfig.debtPaymentsTable;
  static const _t = SQLiteConfig.transactionsTable;
  static const _w = SQLiteConfig.walletsTable;

  /// `principal − Σ live payments` for the debt row aliased `d`.
  static const _remainingExpr = '''
      d.${SQLiteConfig.debtPrincipalMinor} - COALESCE(
        (SELECT SUM(p.${SQLiteConfig.dpAmountMinor}) FROM $_p p
         WHERE p.${SQLiteConfig.dpDebtId} = d.${SQLiteConfig.id} AND p.${SQLiteConfig.deletedAt} IS NULL), 0)''';

  // ------------------------------------------------------------------ debts

  Future<void> insertDebt(DatabaseExecutor db, DebtModel debt) => db.insert(_d, debt.toRow());

  Future<void> updateDebt(DatabaseExecutor db, DebtModel debt) => db.update(
        _d,
        debt.toRow(),
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [debt.id],
      );

  /// Any debt, deleted or not.
  Future<DebtWithRemaining?> byId(DatabaseExecutor db, String id) async {
    final rows = await db.rawQuery('''
      SELECT d.*, $_remainingExpr AS ${SQLiteConfig.debtRemainingMinor}
      FROM $_d d WHERE d.${SQLiteConfig.id} = ? LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    return _withRemaining(rows.first);
  }

  /// The debt opened by [transactionId] (deleted or not).
  Future<DebtModel?> byPrincipalTransaction(DatabaseExecutor db, String transactionId) async {
    final rows = await db.query(
      _d,
      where: '${SQLiteConfig.debtPrincipalTransactionId} = ?',
      whereArgs: [transactionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DebtModel.fromRow(rows.first);
  }

  /// D1 — live debts with remaining, FIFO order (`opened_at, created_at`).
  /// [openOnly] keeps `remaining > 0`.
  Future<List<DebtWithRemaining>> live(
    DatabaseExecutor db, {
    String? personId,
    DebtDirection? direction,
    bool openOnly = false,
  }) async {
    final where = StringBuffer('d.${SQLiteConfig.deletedAt} IS NULL');
    final args = <Object?>[];
    if (personId != null) {
      where.write(' AND d.${SQLiteConfig.debtPersonId} = ?');
      args.add(personId);
    }
    if (direction != null) {
      where.write(' AND d.${SQLiteConfig.debtDirection} = ?');
      args.add(direction.dbValue);
    }
    final rows = await db.rawQuery('''
      SELECT * FROM (
        SELECT d.*, $_remainingExpr AS ${SQLiteConfig.debtRemainingMinor}
        FROM $_d d WHERE $where
      )
      ${openOnly ? 'WHERE ${SQLiteConfig.debtRemainingMinor} > 0' : ''}
      ORDER BY ${SQLiteConfig.debtOpenedAt}, ${SQLiteConfig.createdAt}
    ''', args);
    return rows.map(_withRemaining).toList();
  }

  Future<int> countLiveOfPerson(DatabaseExecutor db, String personId) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) FROM $_d WHERE ${SQLiteConfig.debtPersonId} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
      [personId],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// Person merge: every debt (live or not) follows the surviving person.
  Future<void> moveToPerson(DatabaseExecutor db, String fromPersonId, String toPersonId, int now) => db.update(
        _d,
        {SQLiteConfig.debtPersonId: toPersonId, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.debtPersonId} = ?',
        whereArgs: [fromPersonId],
      );

  Future<void> setStatus(
    DatabaseExecutor db,
    String id, {
    required int? closedAt,
    required DebtCloseReason? reason,
    required int now,
  }) =>
      db.update(
        _d,
        {
          SQLiteConfig.debtClosedAt: closedAt,
          SQLiteConfig.debtCloseReason: reason?.dbValue,
          SQLiteConfig.updatedAt: now,
        },
        where: '${SQLiteConfig.id} = ?',
        whereArgs: [id],
      );

  Future<void> softDeleteDebt(DatabaseExecutor db, String id, int now) => db.update(
        _d,
        {SQLiteConfig.deletedAt: now, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ? AND ${SQLiteConfig.deletedAt} IS NULL',
        whereArgs: [id],
      );

  /// Undo: only when the debt was deleted by the cascade stamped [deletedAt].
  Future<int> restoreDebt(DatabaseExecutor db, String id, int deletedAt, int now) => db.update(
        _d,
        {SQLiteConfig.deletedAt: null, SQLiteConfig.updatedAt: now},
        where: '${SQLiteConfig.id} = ? AND ${SQLiteConfig.deletedAt} = ?',
        whereArgs: [id, deletedAt],
      );

  // ---------------------------------------------------------------- payments

  Future<void> insertPayment(DatabaseExecutor db, DebtPaymentModel payment) => db.insert(_p, payment.toRow());

  Future<DebtPaymentModel?> paymentById(DatabaseExecutor db, String id) async {
    final rows = await db.query(_p, where: '${SQLiteConfig.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return DebtPaymentModel.fromRow(rows.first);
  }

  /// Payments of a debt: live ones, or exactly those stamped [deletedAt].
  Future<List<DebtPaymentModel>> paymentsOfDebt(DatabaseExecutor db, String debtId, {int? deletedAt}) async {
    final rows = await db.query(
      _p,
      where: '${SQLiteConfig.dpDebtId} = ? AND ${deletedAt == null ? '${SQLiteConfig.deletedAt} IS NULL' : '${SQLiteConfig.deletedAt} = ?'}',
      whereArgs: [debtId, if (deletedAt != null) deletedAt],
      orderBy: '${SQLiteConfig.dpPaidAt}, ${SQLiteConfig.createdAt}',
    );
    return rows.map(DebtPaymentModel.fromRow).toList();
  }

  /// Payments made by wallet transactions: live ones, or exactly those
  /// stamped [deletedAt].
  Future<List<DebtPaymentModel>> paymentsOfTransactions(
    DatabaseExecutor db,
    List<String> transactionIds, {
    int? deletedAt,
  }) async {
    if (transactionIds.isEmpty) return const [];
    final ph = List.filled(transactionIds.length, '?').join(',');
    final rows = await db.query(
      _p,
      where: '${SQLiteConfig.dpTransactionId} IN ($ph) AND '
          '${deletedAt == null ? '${SQLiteConfig.deletedAt} IS NULL' : '${SQLiteConfig.deletedAt} = ?'}',
      whereArgs: [...transactionIds, if (deletedAt != null) deletedAt],
    );
    return rows.map(DebtPaymentModel.fromRow).toList();
  }

  Future<void> softDeletePayments(DatabaseExecutor db, Iterable<String> ids, int now) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    final ph = List.filled(list.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE $_p SET ${SQLiteConfig.deletedAt} = ?, ${SQLiteConfig.updatedAt} = ? '
      'WHERE ${SQLiteConfig.id} IN ($ph) AND ${SQLiteConfig.deletedAt} IS NULL',
      [now, now, ...list],
    );
  }

  Future<void> restorePayments(DatabaseExecutor db, Iterable<String> ids, int deletedAt, int now) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    final ph = List.filled(list.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE $_p SET ${SQLiteConfig.deletedAt} = NULL, ${SQLiteConfig.updatedAt} = ? '
      'WHERE ${SQLiteConfig.id} IN ($ph) AND ${SQLiteConfig.deletedAt} = ?',
      [now, ...list, deletedAt],
    );
  }

  /// Σ live payments, last payment date, and whether any is a forgiveness.
  Future<DebtPaymentTotals> paymentTotals(DatabaseExecutor db, String debtId) async {
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(${SQLiteConfig.dpAmountMinor}), 0) AS paid,
             MAX(${SQLiteConfig.dpPaidAt}) AS last_paid,
             COALESCE(MAX(${SQLiteConfig.dpKind} = '${PaymentKind.forgiveness.dbValue}'), 0) AS forgiven
      FROM $_p
      WHERE ${SQLiteConfig.dpDebtId} = ? AND ${SQLiteConfig.deletedAt} IS NULL
    ''', [debtId]);
    final r = rows.first;
    return (
      paid: (r['paid'] as int?) ?? 0,
      lastPaidAt: r['last_paid'] as int?,
      hasForgiveness: ((r['forgiven'] as int?) ?? 0) == 1,
    );
  }

  /// Debt sheet history: live payments with the wallet side of their
  /// transaction (wallet names resolve even after the wallet was deleted).
  Future<List<DebtPaymentRow>> history(DatabaseExecutor db, String debtId) async {
    final rows = await db.rawQuery('''
      SELECT p.*,
             t.${SQLiteConfig.txWalletId} AS w_id,
             t.${SQLiteConfig.txAmountMinor} AS w_amount,
             t.${SQLiteConfig.txCurrency} AS w_currency,
             w.${SQLiteConfig.walletName} AS w_name,
             w.${SQLiteConfig.deletedAt} AS w_deleted
      FROM $_p p
      LEFT JOIN $_t t ON t.${SQLiteConfig.id} = p.${SQLiteConfig.dpTransactionId}
      LEFT JOIN $_w w ON w.${SQLiteConfig.id} = t.${SQLiteConfig.txWalletId}
      WHERE p.${SQLiteConfig.dpDebtId} = ? AND p.${SQLiteConfig.deletedAt} IS NULL
      ORDER BY p.${SQLiteConfig.dpPaidAt} DESC, p.${SQLiteConfig.createdAt} DESC
    ''', [debtId]);
    return rows.map((r) {
      final amount = r['w_amount'] as int?;
      final currency = CurrencyType.tryFromCode(r['w_currency'] as String?);
      return DebtPaymentRow(
        payment: DebtPaymentModel.fromRow(r),
        walletId: r['w_id'] as String?,
        walletName: r['w_name'] as String?,
        walletDeleted: r['w_deleted'] != null,
        walletAmount: amount == null || currency == null ? null : Money(amount, currency),
      );
    }).toList();
  }

  /// D2 — debt and person of debt-linked transactions (one query per list
  /// page): `transactionId → (debtId, personName)`. A repayment spread over
  /// several debts (FIFO) reports one of them — they share the person.
  Future<Map<String, ({String debtId, String personName})>> debtInfoOfTransactions(
    DatabaseExecutor db,
    List<String> transactionIds,
  ) async {
    if (transactionIds.isEmpty) return const {};
    final ph = List.filled(transactionIds.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT t.${SQLiteConfig.id} AS tx_id,
             COALESCE(d1.${SQLiteConfig.id}, d2.${SQLiteConfig.id}) AS debt_id,
             pe.${SQLiteConfig.personName} AS person_name
      FROM $_t t
      LEFT JOIN $_d d1 ON d1.${SQLiteConfig.debtPrincipalTransactionId} = t.${SQLiteConfig.id}
      LEFT JOIN $_p p ON p.${SQLiteConfig.dpTransactionId} = t.${SQLiteConfig.id} AND p.${SQLiteConfig.deletedAt} IS NULL
      LEFT JOIN $_d d2 ON d2.${SQLiteConfig.id} = p.${SQLiteConfig.dpDebtId}
      LEFT JOIN ${SQLiteConfig.peopleTable} pe
             ON pe.${SQLiteConfig.id} = COALESCE(d1.${SQLiteConfig.debtPersonId}, d2.${SQLiteConfig.debtPersonId})
      WHERE t.${SQLiteConfig.id} IN ($ph) AND t.${SQLiteConfig.txDebtRole} IS NOT NULL
      GROUP BY t.${SQLiteConfig.id}
    ''', transactionIds);
    return {
      for (final r in rows)
        if (r['debt_id'] != null)
          r['tx_id'] as String: (debtId: r['debt_id'] as String, personName: (r['person_name'] as String?) ?? ''),
    };
  }

  /// Wallet of a transaction (deleted wallets resolve too), or null.
  Future<({String id, String name, bool deleted})?> walletOfTransaction(DatabaseExecutor db, String transactionId) async {
    final rows = await db.rawQuery('''
      SELECT w.${SQLiteConfig.id} AS id, w.${SQLiteConfig.walletName} AS name, w.${SQLiteConfig.deletedAt} AS deleted
      FROM $_t t JOIN $_w w ON w.${SQLiteConfig.id} = t.${SQLiteConfig.txWalletId}
      WHERE t.${SQLiteConfig.id} = ? LIMIT 1
    ''', [transactionId]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return (id: r['id'] as String, name: r['name'] as String, deleted: r['deleted'] != null);
  }

  static DebtWithRemaining _withRemaining(Map<String, Object?> r) =>
      (debt: DebtModel.fromRow(r), remaining: (r[SQLiteConfig.debtRemainingMinor] as int?) ?? 0);
}
