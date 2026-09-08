import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/money/currency_type.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/models/progress_stats.dart';
import '../data/progress_repository.dart';

class ProgressState {
  const ProgressState({
    this.granularity = ProgressGranularity.month,
    this.walletId,
    this.stats = const AsyncValue.loading(),
  });

  final ProgressGranularity granularity;

  /// Null = every wallet, converted into the base currency.
  final String? walletId;
  final AsyncValue<ProgressStats> stats;

  ProgressState copyWith({
    ProgressGranularity? granularity,
    AsyncValue<ProgressStats>? stats,
  }) =>
      ProgressState(
        granularity: granularity ?? this.granularity,
        walletId: walletId,
        stats: stats ?? this.stats,
      );
}

final progressProvider =
    NotifierProvider.autoDispose<ProgressNotifier, ProgressState>(ProgressNotifier.new);

class ProgressNotifier extends Notifier<ProgressState> {
  /// Guards against a slow response for an old granularity / wallet landing
  /// after a newer one.
  int _requestId = 0;

  @override
  ProgressState build() {
    ref.watch(dbRevisionProvider);
    final base = ref.watch(baseCurrencyProvider);
    final wallets = ref.watch(walletsProvider).value;
    final previous = stateOrNull;

    // A filtered wallet that has been deleted falls back to "all wallets".
    var walletId = previous?.walletId;
    if (walletId != null && wallets != null && !wallets.any((w) => w.id == walletId)) {
      walletId = null;
    }

    final next = ProgressState(
      granularity: previous?.granularity ?? ProgressGranularity.month,
      walletId: walletId,
      stats: previous?.stats ?? const AsyncValue.loading(),
    );
    Future.microtask(() => _load(base));
    return next;
  }

  void setGranularity(ProgressGranularity granularity) {
    if (granularity == state.granularity) return;
    state = state.copyWith(granularity: granularity, stats: const AsyncValue.loading());
    _load(ref.read(baseCurrencyProvider));
  }

  /// [walletId] null = every wallet.
  void setWallet(String? walletId) {
    if (walletId == state.walletId) return;
    state = ProgressState(
      granularity: state.granularity,
      walletId: walletId,
      stats: const AsyncValue.loading(),
    );
    _load(ref.read(baseCurrencyProvider));
  }

  /// Filtering to one wallet reports in that wallet's own currency — no FX
  /// conversion, so nothing can end up unconvertible.
  CurrencyType _targetCurrency(CurrencyType base, String? walletId) {
    if (walletId == null) return base;
    final wallets = ref.read(walletsProvider).value ?? const <WalletSummary>[];
    for (final wallet in wallets) {
      if (wallet.id == walletId) return wallet.currency;
    }
    return base;
  }

  Future<void> _load(CurrencyType base) async {
    final requestId = ++_requestId;
    final granularity = state.granularity;
    final walletId = state.walletId;

    final result = await ref.read(progressRepositoryProvider).load(
          granularity: granularity,
          target: _targetCurrency(base, walletId),
          walletId: walletId,
        );
    if (!ref.mounted || requestId != _requestId) return;

    result.when(
      (stats) => state = state.copyWith(stats: AsyncValue.data(stats)),
      (error) => state = state.copyWith(stats: AsyncValue.error(error, StackTrace.current)),
    );
  }
}
