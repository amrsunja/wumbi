import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../transaction/data/models/recurring_rule_model.dart';
import '../../transaction/data/transaction_repository.dart';

/// Every non-deleted recurring rule (active first, soonest due next).
/// Re-queried after every write anywhere in the app (via `dbRevisionProvider`).
final subscriptionsProvider =
    AsyncNotifierProvider.autoDispose<SubscriptionsNotifier, List<RecurringRuleModel>>(SubscriptionsNotifier.new);

class SubscriptionsNotifier extends AsyncNotifier<List<RecurringRuleModel>> {
  TransactionRepository get _transactions => ref.read(transactionRepositoryProvider);

  @override
  Future<List<RecurringRuleModel>> build() async {
    ref.watch(dbRevisionProvider);
    final result = await _transactions.allRules();
    return result.when((rules) => rules, (error) => throw error);
  }

  /// Pause / resume. The row flips immediately; the DB refresh confirms it.
  Future<void> setActive(String ruleId, bool active) async {
    final current = state.value;
    if (current != null) {
      state = AsyncData([
        for (final r in current)
          if (r.id == ruleId) r.copyWith(isActive: active) else r,
      ]);
    }
    final result = await _transactions.setRuleActive(ruleId, active);
    if (!ref.mounted) return;
    result.whenError((e) {
      if (current != null) state = AsyncData(current);
      ref.read(appEventProvider).send(ShowErrorEvent(e));
    });
  }

  /// Stop (soft delete) a rule; existing occurrences stay.
  Future<void> delete(String ruleId, {required String message}) async {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((r) => r.id != ruleId).toList());
    }
    final result = await _transactions.deleteRule(ruleId);
    if (!ref.mounted) return;
    result.when(
      (_) => ref.read(appEventProvider).send(ShowInfoMessageEvent(message)),
      (error) {
        if (current != null) state = AsyncData(current);
        ref.read(appEventProvider).send(ShowErrorEvent(error));
      },
    );
  }
}

/// Active, non-deleted rules — the dashboard "N subscriptions" pill.
final activeSubscriptionCountProvider = Provider.autoDispose<int>((ref) {
  final rules = ref.watch(subscriptionsProvider).value ?? const <RecurringRuleModel>[];
  return rules.where((r) => r.isActive && r.deletedAt == null).length;
});

/// Active rules touching a wallet (as wallet, source or destination).
final subscriptionCountForWalletProvider = Provider.autoDispose.family<int, String>((ref, walletId) {
  final rules = ref.watch(subscriptionsProvider).value ?? const <RecurringRuleModel>[];
  return rules.where((r) => r.isActive && r.deletedAt == null && ruleTouchesWallet(r, walletId)).length;
});

/// True when the rule debits or credits [walletId].
bool ruleTouchesWallet(RecurringRuleModel r, String walletId) =>
    r.walletId == walletId || r.fromWalletId == walletId || r.toWalletId == walletId;

/// Occurrences per month for a frequency (daily×30, weekly×4.33, yearly÷12).
double monthlyFactor(RepeatFrequency f, int interval) {
  final perMonth = switch (f) {
    RepeatFrequency.never => 0.0,
    RepeatFrequency.daily => 30.0,
    RepeatFrequency.weekly => 4.33,
    RepeatFrequency.monthly => 1.0,
    RepeatFrequency.yearly => 1 / 12,
  };
  return perMonth / (interval <= 0 ? 1 : interval);
}

/// Sum of ACTIVE expense rules (income and transfers excluded), normalised to
/// one month and converted to the base currency with cached rates only.
/// Currencies without a cached rate are skipped. Scoped to a wallet when the
/// family argument is non-null. Zero when nothing could be summed.
final monthlySubscriptionTotalProvider = FutureProvider.autoDispose.family<Money, String?>((ref, walletId) async {
  final rules = ref.watch(subscriptionsProvider.select((s) => s.value)) ?? const <RecurringRuleModel>[];
  final base = ref.watch(baseCurrencyProvider);
  final fx = ref.read(fxServiceProvider);

  final rates = <CurrencyType, double?>{};
  var total = 0;
  for (final r in rules) {
    if (!r.isActive || r.deletedAt != null) continue;
    if (r.type != TransactionType.expense) continue;
    if (walletId != null && r.walletId != walletId) continue;
    final factor = monthlyFactor(r.frequency, r.interval);
    if (factor == 0) continue;
    final monthlyMinor = ((r.amountMinor ?? 0) * factor).round();
    if (monthlyMinor == 0) continue;

    if (r.currency == base) {
      total += monthlyMinor;
      continue;
    }
    double? rate;
    if (rates.containsKey(r.currency)) {
      rate = rates[r.currency];
    } else {
      rate = rates[r.currency] = (await fx.cachedRate(r.currency, base))?.rate;
    }
    if (rate == null) continue;
    total += convertMinor(monthlyMinor, r.currency, base, rate);
  }
  return Money(total, base);
});
