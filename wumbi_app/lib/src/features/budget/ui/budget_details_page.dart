import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/typedefs.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/budget_metrics.dart';
import '../data/models/budget_model.dart';
import 'budget_details_notifier.dart';
import 'budget_labels.dart';

/// `/budgets/:id` (spec B&D §6.7). A budget may span several wallets, so it
/// gets its own page: browse periods, see the numbers, and the rows counted.
///
/// Layout: period switcher → ring gauge (remaining in the middle) → pace →
/// stat tiles → scope chips → counted rows. Everything cascades in on first
/// display; browsing periods keeps the previous numbers on screen and lets
/// the ring / counters glide to the new ones. The FAB adds a transaction
/// preset to this budget's wallet and tags.
@RoutePage()
class BudgetDetailsPage extends HookConsumerWidget {
  const BudgetDetailsPage({super.key, @PathParam('id') required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final offset = useState(0);
    final args = BudgetDetailsArgs(budgetId: budgetId, periodOffset: offset.value);
    final state = ref.watch(budgetDetailsProvider(args));
    final notifier = ref.read(budgetDetailsProvider(args).notifier);
    final scrollController = useScrollController();
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final pos = scrollController.position;
        if (pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent * 0.8) notifier.loadMore();
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, notifier]);

    // Deleted underneath us: leave quietly (the form already showed Undo).
    useEffect(() {
      if (!state.notFound) return null;
      Future.microtask(() {
        if (context.mounted) context.router.maybePop();
      });
      return null;
    }, [state.notFound]);

    // Each period is its own provider instance (it starts empty): keep the
    // last numbers on screen meanwhile so the ring and counters animate from
    // them instead of flashing a skeleton.
    final lastProgress = useRef<BudgetProgress?>(null);
    final lastTagNames = useRef<List<String>>(const []);
    final loaded = state.progress.value != null;
    if (loaded) {
      lastProgress.value = state.progress.value;
      lastTagNames.value = state.tagNames;
    }
    final progress = state.progress.value ?? lastProgress.value;
    final tagNames = loaded ? state.tagNames : lastTagNames.value;

    void browse(int delta) {
      AppVibrations.selection();
      offset.value = offset.value + delta;
    }

    return Scaffold(
      appBar: UIAppbar(
        title: progress?.budget.name ?? '',
        backTap: () => context.router.maybePop(),
        action: progress == null
            ? null
            : UIIcon(
                UIIconToken.icons.general.edit05,
                size: 22,
                onTap: () => context.router.push(BudgetFormRoute(budgetId: budgetId)),
              ),
      ),
      floatingActionButton: progress == null || state.notFound
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: UiFab(
                heroTag: kHeroFab,
                onTap: () => context.router.push(
                  TransactionRoute(
                    walletId: _walletFor(progress.budget, wallets),
                    tags: tagNames.isEmpty ? null : tagNames,
                  ),
                ),
              ),
            ),
      body: state.notFound
          ? const SizedBox.shrink()
          : CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, 0),
                    child: progress == null
                        ? const UiSkeletonList(rows: 3)
                        : _Header(
                            progress: progress,
                            tagNames: tagNames,
                            wallets: wallets,
                            canGoForward: offset.value < 0,
                            onPrevious: () => browse(-1),
                            onNext: () => browse(1),
                          ),
                  ),
                ),
                if (progress != null && progress.subscriptionCount > 0 && progress.subscriptionPlanned != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 12, kListHorzPadding, 0),
                      child: _SubscriptionsLink(progress: progress),
                    ),
                  ),
                if (progress != null)
                  SliverToBoxAdapter(
                    child: UiSectionLabel(
                      text: l10n.wallet_tab_transactions,
                      padding: const EdgeInsets.fromLTRB(kListHorzPadding, 28, kListHorzPadding, 0),
                    ).uiFadeSlideIn(delay: const Duration(milliseconds: 520), offset: 0.4),
                  ),
                _Rows(key: ValueKey('rows-${offset.value}'), rows: state.rows),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                  ),
                // Room for the FAB under the last row.
                const SliverToBoxAdapter(child: UISpace.vert(104)),
              ],
            ),
    );
  }

  /// Wallet the FAB preselects: none for an all-wallets budget (the
  /// Transaction page falls back to the primary one), else the primary if it
  /// is in scope, else the first scoped wallet in the user's order.
  static String? _walletFor(BudgetModel b, List<WalletSummary> wallets) {
    if (b.walletIds.isEmpty) return null;
    final scoped = wallets.where((w) => b.walletIds.contains(w.id));
    for (final w in scoped) {
      if (w.isPrimary) return w.id;
    }
    return scoped.firstOrNull?.id ?? b.walletIds.first;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.progress,
    required this.tagNames,
    required this.wallets,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  final BudgetProgress progress;
  final List<String> tagNames;
  final List<WalletSummary> wallets;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final pace = _pace(context, p);
    final statusColor = BudgetLabels.statusColor(p.status, context.colors);

    return Column(
      children: [
        _PeriodSwitcher(
          progress: p,
          canGoForward: canGoForward,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
        const UISpace.vert(20),
        _Ring(progress: p).uiFadeSlideIn(offset: 0.06, duration: UIAnim.slow),
        const UISpace.vert(16),
        AnimatedSwitcher(
          duration: UIAnim.fast,
          child: pace == null
              ? const SizedBox(key: ValueKey('no-pace'), height: 0, width: double.infinity)
              : _Pill(key: ValueKey(pace), text: pace, color: statusColor, dot: true),
        ).uiFadeSlideIn(delay: const Duration(milliseconds: 200), offset: 0.3),
        const UISpace.vert(20),
        _Stats(progress: p),
        const UISpace.vert(16),
        _Scope(budget: p.budget, wallets: wallets, tagNames: tagNames, incomplete: p.incomplete)
            .uiFadeSlideIn(delay: const Duration(milliseconds: 440), offset: 0.3),
      ],
    );
  }

  /// "On track" / "€25 ahead of pace" / "€40 faster than planned" (running
  /// period only; within 1 % of the limit counts as on track).
  static String? _pace(BuildContext context, BudgetProgress p) {
    if (!p.isCurrent || !p.limit.isPositive || !p.spent.isPositive) return null;
    final l10n = context.l10n;
    final delta = p.paceDelta;
    if (delta.minor.abs() * 100 < p.limit.minor) return l10n.budget_on_track;
    return delta.isPositive ? l10n.budget_ahead_of_pace(delta.format()) : l10n.budget_faster_than_planned(delta.abs().format());
  }
}

/// ‹ October › — the label slides in the browsing direction.
class _PeriodSwitcher extends HookWidget {
  const _PeriodSwitcher({
    required this.progress,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  final BudgetProgress progress;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final p = progress;
    final b = p.budget;

    final label = b.period.isCustom
        ? BudgetLabels.range(p.period)
        : BudgetLabels.period(l10n, b, p.period, isCurrent: p.isCurrent);

    // +1 = moving forward in time (slide from the right), −1 = back.
    final direction = useRef(1);
    final lastIndex = useRef(p.period.index);
    if (p.period.index != lastIndex.value) {
      direction.value = p.period.index > lastIndex.value ? 1 : -1;
      lastIndex.value = p.period.index;
    }

    final text = AnimatedSwitcher(
      duration: UIAnim.fast,
      switchInCurve: UIAnim.easeOut,
      switchOutCurve: UIAnim.easeOut,
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(label);
        final dx = (incoming ? 0.25 : -0.25) * direction.value;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(label, key: ValueKey(label), textAlign: TextAlign.center, style: typo.label),
    );

    if (b.period.isCustom) return text;
    return Row(
      children: [
        UIIcon(UIIconToken.icons.arrows.chevronLeft, size: 22, onTap: onPrevious),
        Expanded(child: text),
        AnimatedOpacity(
          duration: UIAnim.fast,
          opacity: canGoForward ? 1 : 0.3,
          child: UIIcon(UIIconToken.icons.arrows.chevronRight, size: 22, onTap: canGoForward ? onNext : null),
        ),
      ],
    );
  }
}

/// Ring gauge with the remaining amount, its word and "42 % used".
class _Ring extends StatelessWidget {
  const _Ring({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final p = progress;
    final statusColor = BudgetLabels.statusColor(p.status, context.colors);

    // Big number + its word: running → left / over; past → under / over.
    final over = p.remaining.isNegative;
    final String word;
    if (p.status == BudgetStatus.notStarted) {
      word = l10n.budget_starts(p.period.start.formatShortDate());
    } else if (over) {
      word = l10n.budget_over_caption;
    } else {
      word = p.isCurrent ? l10n.budget_left_caption : l10n.budget_under_caption;
    }
    final percent = p.spentRatio.isFinite ? (p.spentRatio * 100).round() : 0;

    return UiBudgetRing(
      spentRatio: p.spentRatio,
      plannedRatio: p.plannedRatio,
      color: statusColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiTotalAmount(
            money: p.remaining.abs(),
            animated: true,
            fontSize: 30,
            color: over ? UIColorToken.neg500 : null,
          ),
          AnimatedSwitcher(
            duration: UIAnim.fast,
            child: Text(
              word,
              key: ValueKey(word),
              textAlign: TextAlign.center,
              style: typo.subtitle.copyWith(color: over ? UIColorToken.neg500 : null),
            ),
          ),
          const UISpace.vert(10),
          _Pill(text: l10n.budget_used_percent(percent), color: statusColor),
        ],
      ),
    );
  }
}

/// Spent · Limit · Planned · Per day · Forecast tiles, two per row (a lone
/// last tile spans the row). Values cross-fade when they change.
class _Stats extends StatelessWidget {
  const _Stats({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    final carry = p.carry;
    final perDay = p.perDay;
    final forecast = p.forecast;

    final tiles = <_StatData>[
      _StatData(
        label: l10n.budget_stat_spent,
        value: '${p.incomplete ? '≈ ' : ''}${p.spent.format()}',
        color: p.isOver ? UIColorToken.neg500 : null,
      ),
      _StatData(
        label: l10n.budget_stat_limit,
        value: p.limit.format(),
        sub: carry.isZero ? null : l10n.budget_carried(carry.format(signed: true, positiveSign: true)),
      ),
      if (p.planned.isPositive) _StatData(label: l10n.budget_stat_planned, value: p.planned.format()),
      if (perDay != null)
        _StatData(label: l10n.budget_stat_per_day, value: perDay.format(), sub: l10n.budget_days_left(p.daysLeft)),
      if (forecast != null)
        _StatData(
          label: l10n.budget_stat_forecast,
          value: forecast.format(),
          color: forecast.minor > p.limit.minor ? UIColorToken.buttercup : null,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final half = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < tiles.length; i++)
              SizedBox(
                key: ValueKey(tiles[i].label),
                width: i == tiles.length - 1 && tiles.length.isOdd ? constraints.maxWidth : half,
                child: _StatTile(data: tiles[i]).uiFadeSlideIn(
                  delay: Duration(milliseconds: 260 + 60 * i),
                  offset: 0.25,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatData {
  const _StatData({required this.label, required this.value, this.sub, this.color});

  final String label;
  final String value;
  final String? sub;
  final Color? color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final sub = data.sub;

    Widget fade(Widget child) => AnimatedSwitcher(
          duration: UIAnim.fast,
          layoutBuilder: (current, previous) => Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [...previous, ?current],
          ),
          child: child,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.secondContentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.sectionLabel),
          const UISpace.vert(6),
          fade(
            Text(
              data.value,
              key: ValueKey(data.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.rowTitle.copyWith(color: data.color),
            ),
          ),
          if (sub != null) ...[
            const UISpace.vert(2),
            fade(Text(sub, key: ValueKey(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption)),
          ],
        ],
      ),
    );
  }
}

/// What the budget counts: wallet chips (colour dot) and #tag chips.
class _Scope extends StatelessWidget {
  const _Scope({required this.budget, required this.wallets, required this.tagNames, required this.incomplete});

  final BudgetModel budget;
  final List<WalletSummary> wallets;
  final List<String> tagNames;

  /// Some amounts could not be converted (no cached rate).
  final bool incomplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final scoped = wallets.where((w) => budget.walletIds.contains(w.id)).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        if (budget.walletIds.isEmpty)
          _Pill(
            text: l10n.budget_all_wallets,
            color: colors.secondContentColor,
            leading: UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 12, color: colors.secondContentColor),
          )
        else
          for (final w in scoped)
            _Pill(
              text: w.name,
              color: colors.secondContentColor,
              leading: UiCircleColorBadge(color: w.color.color, size: 8),
            ),
        for (final t in tagNames) _Pill(text: '#$t', color: UIColorToken.blue),
        if (incomplete) _Pill(text: '≈', color: colors.secondContentColor),
      ],
    );
  }
}

/// Rounded tinted label: status pill, pace, scope chips.
class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.text, required this.color, this.leading, this.dot = false});

  final String text;
  final Color color;
  final Widget? leading;

  /// Leading status dot in [color].
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (dot)
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ?leading,
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.semiBold.copyWith(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// "2 subscriptions · €45" → Subscriptions page.
class _SubscriptionsLink extends StatelessWidget {
  const _SubscriptionsLink({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = progress;
    return UITap(
      onTap: () => context.router.push(SubscriptionsRoute()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 6,
          children: [
            UIIcon(UIIconToken.icons.mediaDevices.repeat01, size: 14),
            Expanded(
              child: Text(
                l10n.budget_subscriptions_planned(p.subscriptionCount, p.subscriptionPlanned!.format()),
                style: context.typo.inter.caption,
              ),
            ),
            UIIcon(UIIconToken.icons.arrows.chevronRight, size: 14),
          ],
        ),
      ),
    ).uiFadeSlideIn(delay: const Duration(milliseconds: 480), offset: 0.3);
  }
}

class _Rows extends StatelessWidget {
  const _Rows({super.key, required this.rows});

  final AsyncValue<List<TransactionRow>> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = rows.value;
    if (list == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(kListHorzPadding, 8, kListHorzPadding, 0),
          child: UiSkeletonList(rows: 4),
        ),
      );
    }
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: UiEmptyState(image: AppAssets.images.wumbiOo.path, title: l10n.budget_no_spending)
            .uiFadeSlideIn(delay: const Duration(milliseconds: 200), offset: 0.08),
      );
    }
    // The scope is created when the rows arrive, so the cascade plays then.
    return UIStaggerScope(
      child: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: kListHorzPadding),
        sliver: SliverList.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final row = list[index];
            final t = row.transaction;
            return UIStaggerItem(
              key: ValueKey('budget-row-${row.id}'),
              index: index,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UiTransactionCard(
                    title: t.description.isEmpty ? l10n.common_expense : t.description,
                    subtitle: t.transactionDate.formatListDate(),
                    amount: t.amountFor(t.walletId ?? '', t.currency).abs(),
                    direction: UiTransactionDirection.expense,
                    secondaryText: row.walletName,
                    tags: row.tags,
                    upcoming: t.isUpcoming,
                    badge: t.isUpcoming ? l10n.transaction_upcoming_badge : null,
                    onTap: () => context.router.push(TransactionRoute(transactionId: row.id, walletId: t.walletId)),
                  ),
                  if (index + 1 < list.length) const UIDivider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
