import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/amount_input.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/enums/debt_direction.dart';
import '../../../../core/utils/enums/payment_kind.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../transaction/ui/widgets/amount_numpad_sheet.dart';
import '../../../transaction/ui/widgets/date_picker_sheet.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../wallet/ui/wallets_provider.dart';
import '../../data/models/debt_model.dart';
import '../debt_labels.dart';
import '../debt_sheet_notifier.dart';
import '../debts_provider.dart';
import 'debt_wallet_sheet.dart';
import 'text_entry_sheet.dart';

/// One debt (spec B&D §8.4): what is left, close it in two taps ("Returned
/// in full"), pay part, forgive, remind, and its history. Closed debts open
/// read-only (Delete stays in the overflow menu).
abstract class DebtSheet {
  static Future<void> show(BuildContext context, {required String debtId}) =>
      UIModalSheet.modalSheet<void>(
        context: context,
        fitContent: true,
        child: _Body(debtId: debtId),
      );
}

class _Body extends ConsumerWidget {
  const _Body({required this.debtId});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(debtDetailsProvider(debtId));
    final details = async.value;
    if (details == null) {
      if (async.hasError) {
        // Deleted meanwhile (undo elsewhere, cascade…): nothing to show.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) Navigator.of(context).maybePop();
        });
      }
      return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: UiSkeletonList(rows: 3));
    }
    return _Content(details: details);
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.details});

  final DebtDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo;
    final s = details.summary;
    final debt = s.debt;
    final lent = debt.direction == DebtDirection.lent;
    final state = ref.watch(debtSheetProvider(debt.id));
    final notifier = ref.read(debtSheetProvider(debt.id).notifier);
    final wallets = ref.watch(walletsProvider).value ?? const <WalletSummary>[];

    WalletSummary? walletById(String? id) => id == null ? null : wallets.where((w) => w.id == id).firstOrNull;
    final defaultWallet = (details.principalWalletDeleted ? null : walletById(details.principalWalletId)) ??
        wallets.where((w) => w.isPrimary).firstOrNull ??
        wallets.firstOrNull;
    final target = state.walletPicked ? walletById(state.walletId) : defaultWallet;

    Future<void> close(bool ok) async {
      if (ok && context.mounted) Navigator.of(context).maybePop();
    }

    Future<void> repayAll() async => close(await notifier.repay(details, s.remaining, wallet: target));

    Future<void> repayPart() async {
      final raw = await AmountNumpadSheet.show(context, currency: debt.currency, initial: '');
      if (raw == null) return;
      final amount = AmountInput.toMoney(raw, debt.currency);
      if (amount == null) return;
      await close(await notifier.repay(details, amount, wallet: target));
    }

    Future<void> forgive() async {
      final ok = await UIAlertDialog.confirm(
        context,
        title: l10n.debt_forgive_title(s.person.name),
        message: l10n.debt_forgive_message(s.remaining.format()),
        confirmLabel: l10n.debt_forgive,
        cancelLabel: l10n.common_cancel,
      );
      if (ok) await close(await notifier.forgive(details));
    }

    Future<void> remind() async {
      final date = debt.openedAt.formatShortDate();
      final text = debt.description.isEmpty
          ? l10n.debt_remind_message_no_note(s.person.name, s.remaining.format(), date)
          : l10n.debt_remind_message(s.person.name, s.remaining.format(), debt.description, date);
      await SharePlus.instance.share(ShareParams(text: text));
    }

    Future<void> pickWallet() async {
      final picked = await DebtWalletSheet.show(context, wallets: wallets, selectedId: target?.id);
      if (picked != null) notifier.pickWallet(picked.wallet);
    }

    Future<void> pickDue() async {
      if (debt.dueDate != null) {
        final choice = await UIAlertDialog.choose(
          context,
          title: l10n.debt_due_title,
          actions: [
            UIDialogAction(label: l10n.debt_due_change, primary: true),
            UIDialogAction(label: l10n.debt_due_remove, destructive: true),
            UIDialogAction(label: l10n.common_cancel),
          ],
        );
        if (choice == 1) await notifier.setDueDate(null);
        if (choice != 0) return;
      }
      if (!context.mounted) return;
      final picked = await DatePickerSheet.show(context, initial: debt.dueDate ?? DateTime.now(), minDate: debt.openedAt);
      if (picked != null) await notifier.setDueDate(picked);
    }

    Future<void> overflow() async {
      final choice = await UIAlertDialog.choose(
        context,
        title: s.person.name,
        actions: [
          UIDialogAction(label: l10n.debt_edit_note),
          UIDialogAction(label: l10n.debt_rename_person),
          UIDialogAction(label: l10n.debt_delete, destructive: true),
          UIDialogAction(label: l10n.common_cancel),
        ],
      );
      if (!context.mounted) return;
      switch (choice) {
        case 0:
          final note = await TextEntrySheet.show(
            context,
            title: l10n.debt_edit_note,
            initial: debt.description,
            maxLength: kMaxDebtDescriptionLength,
            hint: l10n.debt_note_hint,
            allowEmpty: true,
          );
          if (note != null) await notifier.updateDescription(note);
        case 1:
          final name = await TextEntrySheet.show(
            context,
            title: l10n.debt_rename_person,
            initial: s.person.name,
            maxLength: kMaxPersonNameLength,
          );
          if (name != null) await notifier.renamePerson(s.person.id, name);
        case 2:
          final moved = (debt.principalTransactionId == null ? 0 : 1) +
              details.history.where((h) => h.payment.transactionId != null).length;
          final ok = await UIAlertDialog.confirm(
            context,
            title: l10n.debt_delete_title,
            message: moved == 0 ? null : l10n.debt_delete_message(moved),
            confirmLabel: l10n.common_delete,
            cancelLabel: l10n.common_cancel,
            destructive: true,
          );
          if (ok) await close(await notifier.deleteDebt());
      }
    }

    // "Overall Ahmed owes you €130" — only when this debt is not the whole story.
    final b = details.personBalance;
    final mine = lent ? b.owedToMe : b.iOwe;
    final other = lent ? b.iOwe : b.owedToMe;
    final soleDebt = other.isEmpty && mine.length == 1 && mine[debt.currency] == s.remaining.minor;
    String? overall;
    if (s.isOpen && !soleDebt && b.hasOpenDebts) {
      final owed = DebtLabels.side(b.owedToMe, b.owedToMeBase, incomplete: b.incomplete);
      final owe = DebtLabels.side(b.iOwe, b.iOweBase, incomplete: b.incomplete);
      overall = b.owedToMe.isNotEmpty && b.iOwe.isNotEmpty
          ? l10n.debt_overall_both(s.person.name, owed, owe)
          : l10n.debt_overall(b.owedToMe.isNotEmpty
              ? DebtLabels.owes(l10n, DebtDirection.lent, s.person.name, owed)
              : DebtLabels.owes(l10n, DebtDirection.borrowed, s.person.name, owe));
    }

    final meta = [
      if (debt.description.isNotEmpty) debt.description,
      debt.openedAt.formatShortDate(),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(s.person.name, style: typo.inter.title)),
              UIIcon(UIIconToken.icons.general.dotsHorizontal, size: 22, onTap: overflow),
            ],
          ),
          Row(
            children: [
              Flexible(child: Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.inter.caption)),
              const UISpace.horz(4),
              UiChip(
                icon: UIIconToken.icons.time.calendar,
                label: debt.dueDate == null ? l10n.debt_add_due : l10n.debt_due(debt.dueDate!.formatShortDate()),
                highlighted: s.overdue,
                readOnly: !s.isOpen,
                onTap: pickDue,
              ),
            ],
          ),
          const UISpace.vert(12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              s.isOpen ? s.remaining.format() : DebtLabels.remaining(l10n, s),
              style: typo.montserrat.total.copyWith(fontSize: 36),
            ),
          ),
          Text(
            s.isOpen ? l10n.debt_left_of(s.principal.format()) : l10n.debt_of(s.principal.format()),
            textAlign: TextAlign.center,
            style: typo.inter.subtitle,
          ),
          const UISpace.vert(12),
          UiBudgetBar(spentRatio: s.paidRatio, color: UIColorToken.blue),
          if (overall != null) ...[
            const UISpace.vert(8),
            Text(overall, textAlign: TextAlign.center, style: typo.inter.caption),
          ],
          if (s.isOpen) ...[
            const UISpace.vert(20),
            UiPrimaryButton(
              label: lent ? l10n.debt_returned_in_full : l10n.debt_paid_in_full,
              loading: state.isSaving,
              onTap: repayAll,
            ),
            Center(
              child: UiSelectButton(
                title: target == null ? l10n.debt_not_in_wallet : (lent ? l10n.debt_to_wallet(target.name) : l10n.debt_from_wallet(target.name)),
                trailingIcon: UIIconToken.icons.arrows.chevronRight,
                onTap: pickWallet,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UiTextButton(label: l10n.debt_part, fontSize: 15, onTap: repayPart),
                Text('·', style: typo.inter.caption),
                UiTextButton(label: l10n.debt_forgive, fontSize: 15, onTap: forgive),
                if (lent) ...[
                  Text('·', style: typo.inter.caption),
                  UiTextButton(label: l10n.debt_remind, fontSize: 15, onTap: remind),
                ],
              ],
            ),
          ],
          UiSectionLabel(text: l10n.debt_history, padding: const EdgeInsets.only(top: 16, bottom: 4)),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final row in details.history)
                  _PaymentRow(
                    key: ValueKey('payment-${row.payment.id}'),
                    row: row,
                    lent: lent,
                    currency: debt.currency,
                    onDelete: () => notifier.deletePayment(row),
                  ),
                _HistoryLine(
                  date: debt.openedAt,
                  text: debt.principalTransactionId == null
                      ? (lent ? l10n.debt_history_lent(s.principal.format()) : l10n.debt_history_borrowed(s.principal.format()))
                      : (lent
                          ? l10n.debt_history_lent_from(s.principal.format(), _walletLabel(context, details.principalWalletName, details.principalWalletDeleted))
                          : l10n.debt_history_borrowed_into(s.principal.format(), _walletLabel(context, details.principalWalletName, details.principalWalletDeleted))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _walletLabel(BuildContext context, String? name, bool deleted) =>
      deleted ? '${name ?? '?'} ${context.l10n.wallet_deleted_suffix}' : (name ?? '?');
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({super.key, required this.row, required this.lent, required this.currency, required this.onDelete});

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
    return Dismissible(
      key: ValueKey('swipe-payment-${p.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: UIColorToken.red, borderRadius: BorderRadius.circular(12)),
        child: UIIcon(UIIconToken.icons.general.trash01, color: UIColorToken.white, size: 20),
      ),
      child: _HistoryLine(date: p.paidAt, text: text),
    );
  }
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.date, required this.text});

  final DateTime date;
  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(date.formatShortDate(), style: typo.caption)),
          Expanded(child: Text(text, style: typo.labelMedium)),
        ],
      ),
    );
  }
}
