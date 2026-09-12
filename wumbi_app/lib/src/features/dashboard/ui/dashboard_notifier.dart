import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/data/fx_provider.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/dashboard_repo.dart';

/// Dashboard data: wallets (from `walletsProvider`, which follows every DB
/// write) converted to the base currency with cached rates.
final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardData>(DashboardNotifier.new);

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  /// Currencies + base already warmed up — prevents a refresh loop when a
  /// rate stays unavailable (offline).
  String _warmedSignature = '';

  @override
  Future<DashboardData> build() async {
    final base = ref.watch(baseCurrencyProvider);
    final wallets = await ref.watch(walletsProvider.future);
    final data = await ref.read(dashboardRepoProvider).build(wallets, base);

    // Best effort background refresh (once per currency set); re-run once
    // rates land. The UI never waits on it.
    final currencies = wallets.map((w) => w.currency).toSet();
    final signature = '${base.code}:${(currencies.map((c) => c.code).toList()..sort()).join(',')}';
    if (signature != _warmedSignature && (data.unconvertible.isNotEmpty || data.ratesStale)) {
      _warmedSignature = signature;
      Future(() async {
        await ref.read(fxServiceProvider).warmUp(currencies, base);
        if (ref.mounted) ref.invalidateSelf();
      });
    }
    return data;
  }

  /// Caption tap: retry fetching the missing rates.
  Future<void> retryRates() async {
    final data = state.value;
    if (data == null) return;
    final base = ref.read(baseCurrencyProvider);
    await ref.read(fxServiceProvider).warmUp(data.wallets.map((w) => w.currency).toSet(), base);
    ref.invalidateSelf();
  }
}
