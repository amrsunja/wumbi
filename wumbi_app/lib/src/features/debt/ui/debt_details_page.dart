import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/debt_close_reason.dart';
import '../../../core/utils/enums/debt_direction.dart';
import '../../../core/utils/enums/payment_kind.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../data/models/debt_model.dart';
import 'debt_labels.dart';
import 'debt_sheet_notifier.dart';
import 'debts_provider.dart';

/// Room under the list so the last row clears the home indicator.
const double _kBottomInset = 48;

/// `/debts/:id` (spec B&D §8.4) — one debt, read top to bottom:
///
/// 1. who and which side ("Owed to me · overdue"), a ring of what was paid
///    back with what is left in the middle, and one plain sentence
///    ("Ahmed still owes you €130 of the €200 you lent on Oct 3.");
/// 2. while open: close it in one tap ("Returned in full" → wallet), or
///    part / forgive / remind;
/// 3. details as one grouped card (amount, paid back, date, due, note),
///    edited in the debt form (edit icon, due, note);
/// 4. history, newest first, ending with the loan itself.
///
/// Opened from a debt row with its [seed] so the name / ring heroes have a
/// target on the first frame; the full details replace it once loaded.
@RoutePage()
class DebtDetailsPage extends HookConsumerWidget {
  const DebtDetailsPage({super.key, @PathParam('id') required this.debtId, this.seed});

  final String debtId;
  final DebtSummary? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(debtDetailsProvider(debtId));
    final details = async.value;
    final summary = details?.summary ?? seed;
    // Watched here so the (autoDispose) actions notifier lives as long as
    // the page — settled debts show no action row that would watch it.
    ref.watch(debtSheetProvider(debtId));
    // One clock for the ring's sweep-in, shared by the hero shuttle and the
    // ring that replaces it on landing.
    final ringSweepStart = useMemoized(DateTime.now);

    // Deleted (Delete here, or a cascade / undo elsewhere): the details
    // query fails → leave. Only while on top, so a pop already under way
    // never takes the page below with it.
    final gone = async.hasError && !async.isLoading;
    useEffect(() {
      if (!gone) return null;
      Future.microtask(() {
        if (context.mounted && ModalRoute.isCurrentOf(context) != false) context.router.maybePop();
      });
      return null;
    }, [gone]);

    void edit() => context.router.push(NewDebtRoute(debtId: debtId));

    return Scaffold(
      appBar: UIAppbar(
        title: summary?.person.name ?? '',
        titleHeroTag: heroDebtName(debtId),
        backTap: () => context.router.maybePop(),
        action: details == null
            ? null
            : UIIcon(UIIconToken.icons.general.edit05, size: 22, onTap: edit),
      ),
      body: summary == null
          ? const Padding(
              padding: EdgeInsets.fromLTRB(kListHorzPadding, 24, kListHorzPadding, 0),
              child: UiSkeletonList(rows: 4),
            )
          : UIScrollEdgeFade(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(kListHorzPadding, 4, kListHorzPadding, _kBottomInset),
                    sliver: SliverToBoxAdapter(
                      child: _Content(
                        summary: summary,
                        details: details,
                        ringSweepStart: ringSweepStart,
                        onEdit: edit,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Everything under the app bar. [details] is null while only the row's
/// summary is known: the header shows, the rest fades in once loaded.
class _Content extends ConsumerWidget {
  const _Content({
    required this.summary,
    required this.details,
    required this.ringSweepStart,
    required this.onEdit,
  });

  final DebtSummary summary;
  final DebtDetails? details;
  final DateTime ringSweepStart;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final colors = context.colors;
    final s = summary;
    final debt = s.debt;
    final lent = debt.direction == DebtDirection.lent;
    final d = details;
    final tone = _tone(s, colors);

    final date = debt.openedAt.formatShortDate();
    final String story;
    if (s.isOpen) {
      story = lent
          ? l10n.debt_story_lent_open(s.person.name, s.remaining.format(), s.principal.format(), date)
          : l10n.debt_story_borrowed_open(s.person.name, s.remaining.format(), s.principal.format(), date);
    } else if (debt.closeReason == DebtCloseReason.forgiven) {
      story = l10n.debt_story_forgiven(s.principal.format(), (debt.closedAt ?? debt.openedAt).formatShortDate());
    } else {
      story = lent
          ? l10n.debt_story_lent_settled(s.person.name, s.principal.format(), date)
          : l10n.debt_story_borrowed_settled(s.person.name, s.principal.format(), date);
    }

    Widget section(String label, Widget child, int delayMs) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiSectionLabel(text: label, padding: const EdgeInsets.fromLTRB(4, 24, 4, 8)),
            child,
          ],
        ).uiFadeSlideIn(delay: Duration(milliseconds: delayMs), offset: 0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _Pill(text: _status(context, s), color: tone, dot: true).uiFadeSlideIn(offset: 0.3)),
        const UISpace.vert(16),
        // Flies in from the row's bar (no entrance fade: the hero is it).
        Center(
          child: UiHero(
            tag: heroDebtProgress(debt.id),
            pushedShuttle: true,
            child: _Ring(summary: s, color: tone, sweepStartedAt: ringSweepStart),
          ),
        ),
        const UISpace.vert(18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            story,
            textAlign: TextAlign.center,
            style: typo.subtitle.copyWith(color: colors.secondContentColor),
          ),
        ).uiFadeSlideIn(delay: const Duration(milliseconds: 120), offset: 0.3),
        if (d != null) ...[
          if (s.isOpen) ...[
            const UISpace.vert(22),
            _Actions(details: d).uiFadeSlideIn(delay: const Duration(milliseconds: 200), offset: 0.25),
          ],
          section(l10n.debt_section_details, _DetailsBlock(details: d, onEdit: onEdit), 300),
          if (_overall(context, d) case final overall?) ...[
            const UISpace.vert(10),
            Text(overall, textAlign: TextAlign.center, style: typo.caption)
                .uiFadeSlideIn(delay: const Duration(milliseconds: 360), offset: 0.3),
          ],
          section(l10n.debt_history, _History(details: d), 420),
        ],
      ],
    );
  }

  /// Blue: owed to me (money comes in); expense colour: I owe; red when
  /// overdue; muted once closed.
  static Color _tone(DebtSummary s, UIColorToken colors) {
    if (!s.isOpen) return colors.secondContentColor;
    if (s.overdue) return UIColorToken.neg500;
    return s.debt.direction == DebtDirection.lent ? UIColorToken.blue : colors.expenseColor;
  }

  /// "Owed to me" / "I owe · overdue" / "Settled" / "Forgiven".
  static String _status(BuildContext context, DebtSummary s) {
    final l10n = context.l10n;
    if (!s.isOpen) return DebtLabels.remaining(l10n, s);
    final side = s.debt.direction == DebtDirection.lent ? l10n.debts_owed_to_me : l10n.debts_i_owe;
    return s.overdue ? '$side · ${l10n.debt_overdue}' : side;
  }

  /// "Overall: Ahmed owes you €130" — only when this debt is not the whole
  /// story with that person.
  static String? _overall(BuildContext context, DebtDetails d) {
    final l10n = context.l10n;
    final s = d.summary;
    final debt = s.debt;
    final lent = debt.direction == DebtDirection.lent;
    final b = d.personBalance;
    final mine = lent ? b.owedToMe : b.iOwe;
    final other = lent ? b.iOwe : b.owedToMe;
    final sole = other.isEmpty && mine.length == 1 && mine[debt.currency] == s.remaining.minor;
    if (!s.isOpen || sole || !b.hasOpenDebts) return null;
    final owed = DebtLabels.side(b.owedToMe, b.owedToMeBase, incomplete: b.incomplete);
    final owe = DebtLabels.side(b.iOwe, b.iOweBase, incomplete: b.incomplete);
    if (b.owedToMe.isNotEmpty && b.iOwe.isNotEmpty) return l10n.debt_overall_both(s.person.name, owed, owe);
    return l10n.debt_overall(
      b.owedToMe.isNotEmpty
          ? DebtLabels.owes(l10n, DebtDirection.lent, s.person.name, owed)
          : DebtLabels.owes(l10n, DebtDirection.borrowed, s.person.name, owe),
    );
  }
}

// ------------------------------------------------------------------- header

/// Paid-back ring; the middle says what is left ("€130 / left / of €200"),
/// or the whole amount with "Settled" / "Forgiven" once closed.
class _Ring extends StatelessWidget {
  const _Ring({required this.summary, required this.color, required this.sweepStartedAt});

  final DebtSummary summary;
  final Color color;
  final DateTime sweepStartedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final s = summary;
    final word = s.isOpen ? l10n.budget_left_caption : DebtLabels.remaining(l10n, s);
    return UiBudgetRing(
      spentRatio: s.paidRatio,
      color: color,
      sweepStartedAt: sweepStartedAt,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!s.isOpen) ...[
            UIIcon(UIIconToken.icons.general.checkCircle, size: 22, color: color),
            const UISpace.vert(6),
          ],
          UiTotalAmount(money: s.isOpen ? s.remaining : s.principal, animated: true, fontSize: 30),
          AnimatedSwitcher(
            duration: UIAnim.fast,
            child: Text(word, key: ValueKey(word), textAlign: TextAlign.center, style: typo.subtitle),
          ),
          if (s.isOpen) ...[
            const UISpace.vert(10),
            _Pill(text: l10n.debt_of(s.principal.format()), color: color),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ actions

/// "Returned in full" (primary), then the smaller ways out: part · forgive
/// · remind (lent only). Money that moves asks *where* in a sheet that
/// explains the effect (wallet balance before → after, or debt only).
class _Actions extends ConsumerWidget {
  const _Actions({required this.details});

  final DebtDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = details.summary;
    final debt = s.debt;
    final lent = debt.direction == DebtDirection.lent;
    final state = ref.watch(debtSheetProvider(debt.id));
    final notifier = ref.read(debtSheetProvider(debt.id).notifier);

    // Money that moves opens the payment page (wallet, note, tags, date).
    void payAll() => context.router.push(DebtTransactionRoute(debtId: debt.id, full: true));
    void payPart() => context.router.push(DebtTransactionRoute(debtId: debt.id, full: false));

    Future<void> forgive() async {
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.debt_forgive_title(s.person.name),
        message: l10n.debt_forgive_message(s.remaining.format()),
        confirmLabel: l10n.debt_forgive,
        cancelLabel: l10n.common_cancel,
      );
      if (ok) await notifier.forgive(details);
    }

    Future<void> remind() async {
      final date = debt.openedAt.formatShortDate();
      final text = debt.description.isEmpty
          ? l10n.debt_remind_message_no_note(s.person.name, s.remaining.format(), date)
          : l10n.debt_remind_message(s.person.name, s.remaining.format(), debt.description, date);
      await SharePlus.instance.share(ShareParams(text: text));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiPrimaryButton(
          label: lent ? l10n.debt_returned_in_full : l10n.debt_paid_in_full,
          loading: state.isSaving,
          onTap: payAll,
        ),

        const UISpace.vert(12),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _ActionTile(
                icon: UIIconToken.icons.financeEcommerce.coinsHand,
                label: lent ? l10n.debt_got_part_back : l10n.debt_paid_part,
                onTap: payPart,
              ),
            ),
            Expanded(
              child: _ActionTile(
                icon: UIIconToken.icons.general.heartHand,
                label: l10n.debt_forgive,
                onTap: forgive,
              ),
            ),
            /*if (!lent)
              Expanded(
                child: _ActionTile(
                  icon: UIIconToken.icons.communication.send01,
                  label: l10n.debt_remind,
                  onTap: remind,
                ),
              ),
            */
          ],
        ),
      ],
    );
  }
}

/// Tinted square-ish button: icon over a short label.
class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: colors.secondContentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          spacing: 8,
          children: [
            UIIcon(icon, size: 20),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.typo.inter.label,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ details

/// Amount · Paid back · Date · Due · Note as one grouped card (budget details
/// rows). Due and note open the debt form in edit mode while the debt is open.
class _DetailsBlock extends StatelessWidget {
  const _DetailsBlock({required this.details, required this.onEdit});

  final DebtDetails details;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final s = details.summary;
    final debt = s.debt;
    final lent = debt.direction == DebtDirection.lent;
    final due = debt.dueDate;
    final hasNote = debt.description.isNotEmpty;
    final open = s.isOpen;

    return UiGroupCard(
      children: [
        UiValueRow(
          label: lent ? l10n.debt_stat_lent : l10n.debt_stat_borrowed,
          value: s.principal.format(),
        ),
        UiValueRow(label: l10n.debt_stat_paid_back, value: s.paid.format()),
        UiValueRow(label: l10n.debt_stat_date, value: debt.openedAt.formatMediumDate()),
        UiValueRow(
          label: l10n.debt_stat_due,
          value: due == null ? l10n.debt_none : due.formatMediumDate(),
          valueColor: s.overdue ? UIColorToken.neg500 : (due == null ? colors.secondContentColor : null),
          onTap: open ? onEdit : null,
        ),
        if (hasNote || open)
          UiValueRow(
            label: l10n.debt_note,
            value: hasNote ? debt.description : l10n.debt_add_note,
            valueColor: hasNote ? null : UIColorToken.blue,
            onTap: open ? onEdit : null,
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------ history

/// Payments newest first (swipe to delete), ending with the loan itself.
class _History extends HookConsumerWidget {
  const _History({required this.details});

  final DebtDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Swiped rows leave the tree at once (a dismissed Dismissible must not
    // be rebuilt); the reloaded history drops them for real — or brings
    // them back on Undo, hence the reset.
    final hidden = useState(<String>{});
    useEffect(() {
      if (hidden.value.isNotEmpty) hidden.value = <String>{};
      return null;
    }, [details.history]);
    final s = details.summary;
    final debt = s.debt;
    final lent = debt.direction == DebtDirection.lent;
    final notifier = ref.read(debtSheetProvider(debt.id).notifier);

    String walletLabel(String? name, bool deleted) =>
        deleted ? '${name ?? '?'} ${l10n.wallet_deleted_suffix}' : (name ?? '?');

    final principal = s.principal.format();
    final openedText = debt.principalTransactionId == null
        ? (lent ? l10n.debt_history_lent(principal) : l10n.debt_history_borrowed(principal))
        : (lent
            ? l10n.debt_history_lent_from(principal, walletLabel(details.principalWalletName, details.principalWalletDeleted))
            : l10n.debt_history_borrowed_into(
                principal,
                walletLabel(details.principalWalletName, details.principalWalletDeleted),
              ));

    final rows = <Widget>[
      for (final row in details.history)
        if (!hidden.value.contains(row.payment.id))
          _PaymentLine(
            key: ValueKey('payment-${row.payment.id}'),
            row: row,
            lent: lent,
            currency: debt.currency,
            onDelete: () {
              hidden.value = {...hidden.value, row.payment.id};
              notifier.deletePayment(row);
            },
          ),
      _HistoryLine(
        // Money left me when I lent, came in when I borrowed.
        icon: lent ? UIIconToken.icons.arrows.arrowUpRight : UIIconToken.icons.arrows.arrowDownLeft,
        text: openedText,
        date: debt.openedAt,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (details.history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              spacing: 6,
              children: [
                UIIcon(UIIconToken.icons.general.infoCircle, size: 14, color: context.colors.secondContentColor),
                Expanded(
                  child: Text(
                    l10n.debt_history_swipe_hint,
                    style: context.typo.inter.caption.copyWith(color: context.colors.secondContentColor),
                  ),
                ),
              ],
            ),
          ),
        UiGroupCard(children: rows),
      ],
    );
  }
}

class _PaymentLine extends StatelessWidget {
  const _PaymentLine({super.key, required this.row, required this.lent, required this.currency, required this.onDelete});

  final DebtPaymentRow row;
  final bool lent;

  /// Payments are stored in the debt's currency.
  final CurrencyType currency;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = row.payment;
    final amount = Money(p.amountMinor, currency).format();
    final wallet = row.walletName == null
        ? null
        : (row.walletDeleted ? '${row.walletName} ${l10n.wallet_deleted_suffix}' : row.walletName!);
    final text = switch (p.kind) {
      PaymentKind.forgiveness => l10n.debt_history_forgiven(amount),
      PaymentKind.repayment => wallet == null
          ? (lent ? l10n.debt_history_returned(amount) : l10n.debt_history_paid(amount))
          : (lent ? l10n.debt_history_returned_to(amount, wallet) : l10n.debt_history_paid_from(amount, wallet)),
    };
    final icon = switch (p.kind) {
      PaymentKind.forgiveness => UIIconToken.icons.general.heartHand,
      // A return comes in when I lent, goes out when I borrowed.
      PaymentKind.repayment => lent ? UIIconToken.icons.arrows.arrowDownLeft : UIIconToken.icons.arrows.arrowUpRight,
    };
    return Dismissible(
      key: ValueKey('swipe-payment-${p.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: UIColorToken.red, borderRadius: BorderRadius.circular(12)),
        child: UIIcon(UIIconToken.icons.general.trash01, color: UIColorToken.white, size: 20),
      ),
      child: _HistoryLine(icon: icon, text: text, date: p.paidAt),
    );
  }
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.icon, required this.text, required this.date});

  final String icon;
  final String text;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.fgColor, shape: BoxShape.circle),
            child: UIIcon(icon, size: 16),
          ),
          const UISpace.horz(12),
          Expanded(child: Text(text, style: typo.labelMedium)),
          const UISpace.horz(12),
          Text(date.formatShortDate(), style: typo.caption),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- shared bits

/// Rounded tinted label: status, "of €200".
class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, this.dot = false});

  final String text;
  final Color color;

  /// Leading status dot in [color].
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (dot) Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typo.inter.semiBold.copyWith(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
