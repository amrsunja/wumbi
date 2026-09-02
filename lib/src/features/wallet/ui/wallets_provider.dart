import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/data/db_revision_provider.dart';
import '../data/models/wallet_model.dart';
import '../data/wallet_repository.dart';

/// All non-deleted wallets with balances, creation order. Re-queried after
/// every write anywhere in the app (via `dbRevisionProvider`).
final walletsProvider = AsyncNotifierProvider<WalletsNotifier, List<WalletSummary>>(WalletsNotifier.new);

class WalletsNotifier extends AsyncNotifier<List<WalletSummary>> {
  @override
  Future<List<WalletSummary>> build() async {
    ref.watch(dbRevisionProvider);
    final result = await ref.read(walletRepositoryProvider).listActive();
    return result.when((wallets) => wallets, (error) => throw error);
  }
}

/// A single wallet summary by id (null when deleted / missing).
final walletByIdProvider = Provider.family<WalletSummary?, String>((ref, id) {
  final wallets = ref.watch(walletsProvider).value;
  if (wallets == null) return null;
  for (final w in wallets) {
    if (w.id == id) return w;
  }
  return null;
});

/// The primary wallet, if any.
final primaryWalletProvider = Provider<WalletSummary?>((ref) {
  final wallets = ref.watch(walletsProvider).value;
  if (wallets == null || wallets.isEmpty) return null;
  for (final w in wallets) {
    if (w.isPrimary) return w;
  }
  return wallets.first;
});
