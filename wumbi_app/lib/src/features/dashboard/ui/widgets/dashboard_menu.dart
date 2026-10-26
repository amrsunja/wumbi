import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/widgets/wumbi_logo_draw.dart';
import '../../../budget/ui/budgets_provider.dart';
import '../../../debt/ui/debts_provider.dart';
import '../../../subscription/ui/subscriptions_provider.dart';

/// Dashboard side menu (X-style, inside [UiSideMenu]): the logo drawing
/// itself in (as on the splash) on top, then the secondary screens; Settings and Help under a hairline at the
/// bottom. No mascot here: the menu covers the dashboard, whose companion is
/// the screen's one hamster. Search stays in the app bar, the money tabs on
/// the page.
class DashboardMenu extends ConsumerWidget {
  const DashboardMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final menu = UiSideMenu.of(context);
    final router = context.router;
    // Push at once; the menu snaps shut behind the new page.
    void go(PageRouteInfo route) => menu.navigate(() => router.push(route));

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
                // Same draw-in as the splash, replayed on every open (the menu
                // is built fresh each time); starts once the slide is under way.
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    width: 128,
                    child: WumbiLogoDraw(delay: UIAnim.fast, strokeWidth: 1.2),
                  ),
                ),
                // Rows are 56 px with the label centred: reads as ~50 px.
                const UISpace.vert(32),
                Expanded(
                  child: ListView(
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
