import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../../core/utils/typedefs.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/dashboard_repo.dart';
import 'dashboard_notifier.dart';

@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final dashboard = ref.watch(dashboardProvider);
    final data = dashboard.value;
    final hasWallets = data != null && !data.isEmpty;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bgColor)),
        const Positioned.fill(child: UiAmbientBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: UIAppbar(
            title: l10n.dashboard_title,
            transparent: true,
            action: UIIcon(
              UIIconToken.icons.general.settings01,
              size: 22,
              onTap: () => context.router.push(const SettingsRoute()),
            ),
          ),
          floatingActionButton: hasWallets
              ? Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: UiFab(
                    heroTag: kHeroFab,
                    onTap: () {
                      final primary = ref.read(primaryWalletProvider);
                      return context.router.push(TransactionRoute(walletId: primary?.id));
                    },
                  ),
                )
              : null,
          body: Stack(
            children: [
              const Positioned(left: 0, top: 12, child: UIFiinLooksFromLeft()),
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 72, kPageHorzPadding, 0),
                      child: _Header(data: data),
                    ),
                  ),
                  const SliverToBoxAdapter(child: UISpace.vert(64)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.dashboard_wallets,
                            style: UITextStyleToken.interSemiBold.copyWith(fontSize: 20, color: colors.contentColor),
                          ),
                          UiIconTextButton(
                            icon: UIIconToken.icons.general.plusCircle,
                            title: l10n.dashboard_new_wallet,
                            onTap: () => context.router.push(WalletFormRoute()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: UISpace.vert(12)),
                  _WalletList(dashboard: dashboard),
                  const SliverToBoxAdapter(child: UISpace.vert(96)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.data});

  final DashboardData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final d = data;

    if (d == null) {
      return const SizedBox(height: 84);
    }

    final codes = d.unconvertible.map((c) => c.code).join(', ');
    final caption = d.unconvertible.isEmpty
        ? l10n.dashboard_across_wallets(d.walletCount)
        : '${l10n.dashboard_across_wallets(d.walletCount)} · ${l10n.dashboard_not_included(codes)}';

    return Column(
      children: [
        UiTotalAmount(money: d.total, animated: true),
        const UISpace.vert(8),
        UITap(
          onTap: d.unconvertible.isEmpty ? null : () => ref.read(dashboardProvider.notifier).retryRates(),
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: UITextStyleToken.interMedium.copyWith(fontSize: 14, color: colors.secondContentColor),
          ),
        ),
      ],
    );
  }
}

/// Wallet rows. Long-press + drag reorders; the new first wallet becomes
/// primary. The dragged order is shown optimistically until the DB refresh
/// (which yields the same order) lands.
class _WalletList extends HookConsumerWidget {
  const _WalletList({required this.dashboard});

  final AsyncValue<DashboardData> dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final data = dashboard.value;
    final override = useState<List<WalletSummary>?>(null);

    useEffect(() {
      override.value = null;
      return null;
    }, [data?.wallets]);

    if (data == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: kListHorzPadding),
          child: UiSkeletonList(),
        ),
      );
    }

    if (data.isEmpty) {
      return SliverToBoxAdapter(
        child: UiEmptyState(
          image: AppAssets.images.fiinOo.path,
          title: l10n.dashboard_empty_title,
          subtitle: l10n.dashboard_empty_subtitle,
          action: UiIconTextButton(
            icon: UIIconToken.icons.general.plusCircle,
            title: l10n.dashboard_new_wallet,
            onTap: () => context.router.push(WalletFormRoute()),
          ),
        ),
      );
    }

    final wallets = override.value ?? data.wallets;

    Future<void> onReorder(int oldIndex, int newIndex) async {
      if (newIndex > oldIndex) newIndex -= 1;
      if (oldIndex == newIndex) return;
      final next = List<WalletSummary>.from(wallets);
      final moved = next.removeAt(oldIndex);
      next.insert(newIndex, moved);
      override.value = next;
      AppVibrations.medium();
      final result = await ref.read(walletRepositoryProvider).reorder(next.map((w) => w.id).toList());
      result.whenError((e) {
        override.value = null;
        ref.read(appEventProvider).send(ShowErrorEvent(e));
      });
    }

    Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = Curves.easeOut.transform(animation.value);
          return Transform.scale(
            scale: 1 + 0.03 * t,
            child: Material(
              color: Color.lerp(Colors.transparent, colors.fgColor, t),
              borderRadius: BorderRadius.circular(16),
              shadowColor: UIColorToken.bismark.withValues(alpha: 0.18 * t),
              elevation: 12 * t,
              child: child,
            ),
          );
        },
        child: child,
      );
    }

    // 8 px of the gutter lives inside each item so the lifted (dragged) card
    // gets a background inset around its content.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding - 8),
      sliver: SliverReorderableList(
        itemCount: wallets.length,
        onReorder: onReorder,
        onReorderStart: (_) => AppVibrations.light(),
        proxyDecorator: proxyDecorator,
        itemBuilder: (context, index) {
          final w = wallets[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey('wallet-${w.id}'),
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: UiWalletCard(
                title: w.name,
                balance: w.balance,
                color: w.color.color,
                animatedBadge: true,
                badgePhase: (index * 0.23) % 1,
                nameHeroTag: heroWalletName(w.id),
                balanceHeroTag: heroWalletBalance(w.id),
                onTap: () => context.router.push(WalletDetailsRoute(walletId: w.id)),
              ),
            ),
          );
        },
      ),
    );
  }
}
