import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/widgets/wumbi_logo_draw.dart';
import '../../../budget/ui/budgets_provider.dart';
import '../../../debt/ui/debts_provider.dart';
import '../../../settings/ui/state_management/settings_provider.dart';
import '../../../subscription/ui/subscriptions_provider.dart';
import '../../data/dashboard_repo.dart';
import '../dashboard_notifier.dart';

/// Dashboard side menu (X-style, inside [UiSideMenu]): the logo drawing
/// itself in (as on the splash) and "N wallets  N budgets" on top,
/// then the secondary screens; Settings and Help under a hairline at the
/// bottom. Wumbi peeks out from behind the menu's page-side border as the
/// menu opens. Search stays in the app bar, the money tabs on the page.
class DashboardMenu extends ConsumerWidget {
  const DashboardMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final menu = UiSideMenu.of(context);
    final router = context.router;
    // Push at once; the menu snaps shut behind the new page.
    void go(PageRouteInfo route) => menu.navigate(() => router.push(route));

    final data = ref.watch(dashboardProvider).value;
    final showMascot = ref.watch(showMascotProvider);
    final budgets = ref.watch(dashboardBudgetsProvider.select((b) => b?.total ?? 0));
    final debts = ref.watch(openDebtsBadgeProvider);
    final subscriptions = ref.watch(activeSubscriptionCountProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: UiAmbientBackground(intensity: 0.6)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kListHorzPadding, 20, kListHorzPadding, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MenuHeader(
                  data: data,
                  budgets: budgets,
                  onWallets: menu.close,
                  onBudgets: () => go(BudgetsRoute()),
                ),
                // Rows are 56 px with the label centred, so 4 px here already
                // reads as ~25 px — tighter than logo → info row.
                const UISpace.vert(4),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ListView(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _MenuItem(
                            icon: UIIconToken.icons.charts.barChart10,
                            label: l10n.progress_title,
                            onTap: () => go(const ProgressRoute()),
                          ),
                          _MenuItem(
                            icon: UIIconToken.icons.charts.pieChart03,
                            label: l10n.budgets_title,
                            count: budgets,
                            onTap: () => go(BudgetsRoute()),
                          ),
                          _MenuItem(
                            icon: UIIconToken.icons.financeEcommerce.coinsHand,
                            label: l10n.debts_title,
                            count: debts.count,
                            dot: debts.overdueCount > 0,
                            onTap: () => go(const DebtsRoute()),
                          ),
                          _MenuItem(
                            icon: UIIconToken.icons.mediaDevices.repeat01,
                            label: l10n.subscriptions_title,
                            count: subscriptions,
                            onTap: () => go(SubscriptionsRoute()),
                          ),
                          _MenuItem(
                            icon: UIIconToken.icons.general.hash01,
                            label: l10n.tags_title,
                            onTap: () => go(const TagsRoute()),
                          ),
                        ],
                      ),
                      // Out to the menu's border (past the gutter); the
                      // menu's own bounds clip it, so it emerges from behind
                      // the page.
                      if (showMascot)
                        const PositionedDirectional(end: -kListHorzPadding, bottom: 8, child: _BorderWumbi()),
                    ],
                  ),
                ),
                const UIDivider(),
                const UISpace.vert(8),
                _MenuItem.secondary(
                  icon: UIIconToken.icons.general.settings01,
                  label: l10n.settings_title,
                  onTap: () => go(const SettingsRoute()),
                ),
                _MenuItem.secondary(
                  icon: UIIconToken.icons.general.lifeBuoy01,
                  label: l10n.settings_help,
                  onTap: () => go(const HelpRoute()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ☰ for the app bar's leading slot; carries the overdue-debt dot that used
/// to sit on the header's Debts pill.
class DashboardMenuButton extends ConsumerWidget {
  const DashboardMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = ref.watch(openDebtsBadgeProvider.select((b) => b.overdueCount > 0));
    return Semantics(
      button: true,
      label: context.l10n.menu_open,
      excludeSemantics: true,
      child: UITap(
        onTap: () => UiSideMenu.of(context).open(),
        child: SizedBox.square(
          dimension: 44,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              UIIcon(UIIconToken.icons.general.menu02, size: 24),
              if (overdue) const PositionedDirectional(top: 9, end: 8, child: _Dot()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo, then "4 wallets  2 budgets".
class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.data,
    required this.budgets,
    required this.onWallets,
    required this.onBudgets,
  });

  final DashboardData? data;
  final int budgets;
  final VoidCallback onWallets;
  final VoidCallback onBudgets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Same draw-in as the splash, replayed on every open (the menu is
        // built fresh each time); starts once the slide is under way.
        const SizedBox(
          width: 128,
          child: WumbiLogoDraw(delay: UIAnim.fast, strokeWidth: 1.2),
        ),
        if (d != null && !d.isEmpty) ...[
          const UISpace.vert(52),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _Stat(count: d.walletCount, label: l10n.menu_wallets(d.walletCount), onTap: onWallets),
              _Stat(count: budgets, label: l10n.menu_budgets(budgets), onTap: onBudgets),
            ],
          ),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label, required this.onTap});

  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$count', style: typo.listTitle),
              TextSpan(text: ' $label', style: typo.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary row: 22 px icon, 17/600 label, then its count (when > 0, casper)
/// and the red dot right after the label. Secondary row (Settings, Help): 18 px icon, 16/500 label.
class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.count, this.dot = false})
      : primary = true;

  const _MenuItem.secondary({required this.icon, required this.label, required this.onTap})
      : primary = false,
        count = null,
        dot = false;

  final String icon;
  final String label;
  final VoidCallback onTap;
  final int? count;
  final bool dot;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    final colors = context.colors;
    final n = count ?? 0;
    return UITap(
      onTap: onTap,
      child: SizedBox(
        height: primary ? 56 : 48,
        child: Row(
          children: [
            UIIcon(icon, size: primary ? 22 : 18),
            UISpace.horz(primary ? 14 : 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: primary ? typo.title : typo.body,
                    ),
                  ),
                  if (n > 0) ...[const UISpace.horz(8), Text('$n', style: typo.title.copyWith(color: colors.secondContentColor))],
                  if (dot) ...[const UISpace.horz(6), const _Dot()],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wumbi holding on to the menu's border (`peek_right`; `peek_left` in RTL,
/// where the border is on the left). The menu is painted under the page
/// ([UiSideMenu]), so at rest offset by its own width it sits hidden behind
/// the page; it tracks the menu's open fraction — still behind the page
/// until the menu is ~⅓ open, out by the time it settles, back behind it
/// on close — and bobs gently while out.
class _BorderWumbi extends StatelessWidget {
  const _BorderWumbi();

  static const double _height = 112;

  /// Open fraction over which it slides out.
  static const Interval _peek = Interval(0.3, 1, curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final progress = UiSideMenu.of(context).progress;

    final mascot = UIWumbi(rtl ? WumbiMood.peekLeft : WumbiMood.peekRight, height: _height)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -5, duration: 1800.ms, curve: Curves.easeInOut);

    return AnimatedBuilder(
      animation: progress,
      child: IgnorePointer(child: mascot),
      // No overshoot: the art is cut flat on the border side.
      builder: (context, child) => FractionalTranslation(
        translation: Offset((1 - _peek.transform(progress.value)) * (rtl ? -1 : 1), 0),
        child: child,
      ),
    );
  }
}

/// 6 px overdue dot (same as `UiSegmentedToggle`'s).
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 6,
      child: DecoratedBox(decoration: BoxDecoration(color: UIColorToken.neg500, shape: BoxShape.circle)),
    );
  }
}
