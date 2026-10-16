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
    this.offset = 0,
    this.baseline = const ProgressBaseline.previous(),
    this.walletId,
    this.report,
    this.loading = true,
    this.error,
  });

  final ProgressGranularity granularity;

  /// Viewed period relative to the running one: 0 = now, −1 = previous …
  final int offset;
  final ProgressBaseline baseline;

  /// Null = every wallet, converted into the base currency.
  final String? walletId;

  /// Last loaded report. Kept on screen while the next one loads so the
  /// numbers glide instead of flashing a skeleton.
  final ProgressReport? report;
  final bool loading;
  final Object? error;

  /// Start of the viewed period.
  DateTime viewed([DateTime? now]) => granularity.shift(granularity.startOf(now ?? DateTime.now()), offset);

  ProgressState copyWith({
    ProgressGranularity? granularity,
    int? offset,
    ProgressBaseline? baseline,
    String? Function()? walletId,
    ProgressReport? Function()? report,
    bool? loading,
    Object? Function()? error,
  }) =>
      ProgressState(
        granularity: granularity ?? this.granularity,
        offset: offset ?? this.offset,
        baseline: baseline ?? this.baseline,
        walletId: walletId == null ? this.walletId : walletId(),
        report: report == null ? this.report : report(),
        loading: loading ?? this.loading,
        error: error == null ? this.error : error(),
      );
}

final progressProvider = NotifierProvider.autoDispose<ProgressNotifier, ProgressState>(ProgressNotifier.new);

class ProgressNotifier extends Notifier<ProgressState> {
  /// Guards against a slow response for an old query landing after a newer one.
  int _requestId = 0;

  @override
  ProgressState build() {
    ref.watch(dbRevisionProvider);
    ref.watch(baseCurrencyProvider);
    final wallets = ref.watch(walletsProvider).value;
    final previous = stateOrNull ?? const ProgressState();

    // A filtered wallet that has been deleted falls back to "all wallets".
    var walletId = previous.walletId;
    if (walletId != null && wallets != null && !wallets.any((w) => w.id == walletId)) {
      walletId = null;
    }

    Future.microtask(_load);
    return previous.copyWith(walletId: () => walletId, loading: true);
  }

  /// Month ↔ year: back to the running period, a month-only baseline falls
  /// back to the previous period, a picked one too (it was a month / year).
  void setGranularity(ProgressGranularity granularity) {
    if (granularity == state.granularity) return;
    final keep = switch (state.baseline.kind) {
      ProgressBaselineKind.previous || ProgressBaselineKind.average => state.baseline,
      _ => const ProgressBaseline.previous(),
    };
    _update(state.copyWith(granularity: granularity, offset: 0, baseline: keep, report: () => null));
  }

  /// Moves the viewed period; never past the running one.
  void browse(int delta) {
    final next = (state.offset + delta).clamp(-1200, 0);
    if (next == state.offset) return;
    _update(state.copyWith(offset: next));
  }

  void backToCurrent() => browse(-state.offset);

  /// Jumps to the period starting at [start] (a history bar).
  void goTo(DateTime start) {
    final g = state.granularity;
    browse(g.between(g.startOf(DateTime.now()), start) - state.offset);
  }

  void setBaseline(ProgressBaseline baseline) {
    if (baseline == state.baseline) return;
    _update(state.copyWith(baseline: baseline));
  }

  /// [walletId] null = every wallet.
  void setWallet(String? walletId) {
    if (walletId == state.walletId) return;
    // Another currency: the old numbers would glide from a wrong scale.
    _update(state.copyWith(walletId: () => walletId, report: () => null));
  }

  void _update(ProgressState next) {
    state = next.copyWith(loading: true);
    _load();
  }

  /// Filtering to one wallet reports in that wallet's own currency — no FX
  /// conversion, so nothing can end up unconvertible.
  CurrencyType _target(String? walletId) {
    final base = ref.read(baseCurrencyProvider);
    if (walletId == null) return base;
    final wallets = ref.read(walletsProvider).value ?? const <WalletSummary>[];
    for (final wallet in wallets) {
      if (wallet.id == walletId) return wallet.currency;
    }
    return base;
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    final s = state;
    final now = DateTime.now();

    final result = await ref.read(progressRepositoryProvider).load(
          granularity: s.granularity,
          viewed: s.viewed(now),
          baseline: s.baseline,
          target: _target(s.walletId),
          walletId: s.walletId,
          now: now,
        );
    if (!ref.mounted || requestId != _requestId) return;

    result.when(
      (report) => state = state.copyWith(report: () => report, loading: false, error: () => null),
      (error) => state = state.copyWith(loading: false, error: () => error),
    );
  }
}
