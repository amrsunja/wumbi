import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/fx/fx_service.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/providers/data/fx_provider.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/repeat_frequency.dart';
import '../../../core/utils/enums/transaction_type.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../tag/data/tag_repository.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/models/recurring_rule_model.dart';
import '../data/models/transaction_model.dart';
import '../data/transaction_repository.dart';
import 'transaction_state.dart';

final transactionNotifierProvider =
    NotifierProvider.autoDispose.family<TransactionNotifier, TransactionState, TransactionArgs>(
  TransactionNotifier.new,
);

/// Screen state for the Transaction page (spec 8.5). One instance per route.
class TransactionNotifier extends Notifier<TransactionState> {
  TransactionNotifier(this.args);

  final TransactionArgs args;

  TransactionRepository get _repo => ref.read(transactionRepositoryProvider);
  FxService get _fx => ref.read(fxServiceProvider);
  AppEvents get _events => ref.read(appEventProvider);
  AppLocale get _l10n => ref.read(l10nProvider);

  /// Rates fetched during this screen session, keyed by `from:to`.
  final Map<String, FxRate> _sessionRates = {};
  Timer? _validationTimer;
  int _rateRequest = 0;

  @override
  TransactionState build() {
    ref.onDispose(() => _validationTimer?.cancel());

    // Stay live: wallets created / renamed / deleted while this screen is open
    // (e.g. "Add a second wallet" from the transfer dialog) update the header,
    // the pickers and the transfer sheet without touching the typed input.
    ref.listen(walletsProvider, (_, next) {
      final list = next.value;
      if (list != null) _syncWallets(list);
    });

    final wallets = ref.read(walletsProvider).value ?? const <WalletSummary>[];
    WalletSummary? wallet;
    for (final w in wallets) {
      if (w.id == args.walletId) wallet = w;
    }
    wallet ??= ref.read(primaryWalletProvider);

    final today = DateTime.now().onlyDate();
    if (args.isRuleEdit) {
      Future.microtask(_loadRule);
      return TransactionState(
        mode: TransactionMode.editRule,
        isLoading: true,
        wallet: wallet,
        wallets: wallets,
        entryCurrency: wallet?.currency ?? CurrencyType.usd,
        date: today,
      );
    }
    if (args.isEdit) {
      Future.microtask(_loadExisting);
      return TransactionState(
        mode: TransactionMode.edit,
        isLoading: true,
        wallet: wallet,
        wallets: wallets,
        entryCurrency: wallet?.currency ?? CurrencyType.usd,
        date: today,
      );
    }

    return TransactionState(
      wallet: wallet,
      wallets: wallets,
      entryCurrency: wallet?.currency ?? CurrencyType.usd,
      date: today,
    );
  }

  // ------------------------------------------------------------- edit mode

  Future<void> _loadExisting() async {
    final result = await _repo.byId(args.transactionId!);
    if (!ref.mounted) return;
    await result.when(
      (data) async {
        final t = data.transaction;
        final wallets = state.wallets;
        WalletSummary? wallet;
        TransferCounterpart? counterpart;
        Money shown;

        if (t.isTransfer) {
          // The wallet the user came from is the "target" shown; the other
          // side is a read-only line under the amount.
          final viewedIsSource = args.walletId == null || args.walletId == t.fromWalletId;
          final viewedId = viewedIsSource ? t.fromWalletId! : t.toWalletId!;
          final otherId = viewedIsSource ? t.toWalletId! : t.fromWalletId!;
          wallet = _find(wallets, viewedId) ?? await _fetchWallet(viewedId);
          final other = _find(wallets, otherId);
          final otherName = other?.name ?? await _walletName(otherId);
          final otherCurrency = other?.currency ?? (viewedIsSource ? t.currency : t.currency);
          shown = viewedIsSource
              ? (t.original ?? Money(t.fromAmountMinor ?? 0, t.currency))
              : Money(t.toAmountMinor ?? 0, wallet?.currency ?? t.currency);
          counterpart = TransferCounterpart(
            walletName: otherName,
            walletId: otherId,
            amount: viewedIsSource
                ? Money(t.toAmountMinor ?? 0, other?.currency ?? otherCurrency)
                : Money(t.fromAmountMinor ?? 0, t.currency),
            outgoing: viewedIsSource,
          );
        } else {
          wallet = _find(wallets, t.walletId!) ?? await _fetchWallet(t.walletId!);
          shown = t.original ?? Money(t.amountMinor ?? 0, t.currency);
        }
        if (!ref.mounted) return;

        final entryCurrency = shown.currency;
        state = state.copyWith(
          isLoading: false,
          editingType: t.type,
          existing: t,
          counterpart: counterpart,
          wallet: wallet ?? state.wallet,
          entryCurrency: entryCurrency,
          amountInput: shown.toPlainString(),
          description: t.description,
          tags: data.tags,
          date: t.transactionDate.onlyDate(),
          repeat: data.ruleFrequency ?? RepeatFrequency.never,
          repeatLocked: t.recurringRuleId != null,
          amountPristine: true,
          initialAmountInput: shown.toPlainString(),
          initialTags: data.tags,
          // Reuse the stored rate so the hint matches history until the user
          // re-enters the amount (then a fresh rate is fetched).
          rate: t.exchangeRate != null && wallet != null && entryCurrency != wallet.currency
              ? FxRate(
                  from: entryCurrency,
                  to: wallet.currency,
                  rate: t.exchangeRate!,
                  fetchedAt: t.transactionDate,
                  isStale: false,
                )
              : null,
          rateStatus: wallet != null && entryCurrency != wallet.currency ? RateStatus.ok : RateStatus.none,
        );
      },
      (error) {
        state = state.copyWith(isLoading: false);
        _events.send(ShowErrorEvent(error));
      },
    );
  }

  // -------------------------------------------------- subscription (rule)

  /// Subscription edit: load the rule itself. The viewed wallet is the target
  /// (transfer: the source); the destination is the counterpart line.
  Future<void> _loadRule() async {
    final result = await _repo.ruleById(args.ruleId!);
    if (!ref.mounted) return;
    await result.when(
      (data) async {
        final r = data.rule;
        final wallets = state.wallets;
        WalletSummary? wallet;
        TransferCounterpart? counterpart;
        Money shown;

        if (r.isTransfer) {
          final fromId = r.fromWalletId!;
          final toId = r.toWalletId!;
          wallet = _find(wallets, fromId) ?? await _fetchWallet(fromId);
          final other = _find(wallets, toId);
          final otherName = other?.name ?? await _walletName(toId);
          counterpart = TransferCounterpart(
            walletName: otherName,
            walletId: toId,
            amount: Money(r.toAmountMinor ?? 0, other?.currency ?? r.currency),
            outgoing: true,
          );
          shown = Money(r.fromAmountMinor ?? 0, r.currency);
        } else {
          wallet = _find(wallets, r.walletId!) ?? await _fetchWallet(r.walletId!);
          shown = Money(r.amountMinor ?? 0, r.currency);
        }
        if (!ref.mounted) return;

        final text = shown.toPlainString();
        state = state.copyWith(
          isLoading: false,
          editingType: r.type,
          rule: r,
          counterpart: counterpart,
          wallet: wallet ?? state.wallet,
          // A subscription's currency is fixed: it is always the rule's.
          entryCurrency: r.currency,
          amountInput: text,
          description: r.description,
          tags: data.tags,
          date: r.nextOccurrence.onlyDate(),
          repeat: r.frequency.isNever ? RepeatFrequency.monthly : r.frequency,
          repeatLocked: false,
          amountPristine: true,
          initialAmountInput: text,
          initialTags: data.tags,
          rate: null,
          rateStatus: RateStatus.none,
        );
      },
      (error) {
        state = state.copyWith(isLoading: false);
        _events.send(ShowErrorEvent(error));
      },
    );
  }

  /// Transfer subscription: keep the counterpart line in step with the typed
  /// amount (the stored rate is kept, so the received side follows it).
  void _syncRuleCounterpart() {
    final r = state.rule;
    final c = state.counterpart;
    if (r == null || c == null || !r.isTransfer) return;
    final sent = state.entryMoney;
    if (sent == null) return;
    final rate = r.exchangeRate;
    final received =
        rate == null ? Money(sent.minor, c.amount.currency) : convertMoney(sent, c.amount.currency, rate);
    if (received.minor != c.amount.minor) {
      state = state.copyWith(counterpart: c.copyWith(amount: received));
    }
  }

  /// Transfer subscription: re-point the destination wallet (same currency).
  void setRuleToWallet(WalletSummary w) {
    final c = state.counterpart;
    if (!state.isRuleEdit || c == null) return;
    if (w.id == state.wallet?.id || w.currency != c.amount.currency) return;
    state = state.copyWith(counterpart: c.copyWith(walletName: w.name, walletId: w.id));
  }

  /// Re-point [state.wallet] at the fresh summary (same id); if it vanished,
  /// fall back to the primary in create mode, keep the stale one in edit mode.
  void _syncWallets(List<WalletSummary> wallets) {
    final current = state.wallet;
    var wallet = current == null ? null : _find(wallets, current.id);
    if (wallet == null && !state.isEdit) {
      for (final w in wallets) {
        if (w.isPrimary) wallet = w;
      }
      wallet ??= wallets.isEmpty ? null : wallets.first;
    }
    wallet ??= current;
    final changed = wallet?.id != current?.id || wallet?.currency != current?.currency;
    state = state.copyWith(wallets: wallets, wallet: wallet);
    if (changed) {
      state = state.copyWith(rate: null, rateStatus: RateStatus.none);
      _ensureRate();
    }
  }

  WalletSummary? _find(List<WalletSummary> wallets, String id) {
    for (final w in wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  Future<WalletSummary?> _fetchWallet(String id) async =>
      (await ref.read(walletRepositoryProvider).byId(id)).tryGetSuccess();

  Future<String> _walletName(String id) async {
    final w = (await ref.read(walletRepositoryProvider).rawById(id)).tryGetSuccess();
    if (w == null) return '?';
    return w.deletedAt == null ? w.name : '${w.name} ${_l10n.wallet_deleted_suffix}';
  }

  // ---------------------------------------------------------------- numpad

  /// Edit mode: the first key replaces the prefilled amount.
  String get _inputBase => state.isEdit && state.amountPristine ? '' : state.amountInput;

  void _applyInput(AmountInputResult r) {
    if (r.rejected) {
      AppVibrations.error();
      return;
    }
    state = state.copyWith(amountInput: r.value, validationError: null, amountPristine: false);
    _syncRuleCounterpart();
    // Edit mode: re-entering a foreign-currency amount fetches a fresh rate
    // (the stored one is only reused while the amount is untouched).
    final w = state.wallet;
    if (state.isEdit && w != null && !state.sameCurrency) {
      final key = '${state.entryCurrency.code}:${w.currency.code}';
      if (!_sessionRates.containsKey(key)) _ensureRate();
    }
  }

  void onDigit(String d) => _applyInput(AmountInput.digit(_inputBase, d, state.entryCurrency));

  void onDot() => _applyInput(AmountInput.dot(_inputBase, state.entryCurrency));

  void onBackspace() {
    if (state.amountInput.isEmpty) return;
    state = state.copyWith(amountInput: AmountInput.backspace(state.amountInput), amountPristine: false);
    _syncRuleCounterpart();
  }

  void onClear() {
    if (state.amountInput.isEmpty) return;
    state = state.copyWith(amountInput: AmountInput.clear(), amountPristine: false);
    _syncRuleCounterpart();
  }

  /// Edit mode: switch income ↔ expense (transfer cannot change).
  void setEditingType(TransactionType type) {
    // A subscription's type never changes.
    if (state.isRuleEdit) return;
    if (!state.isEdit || state.isTransferEdit || type == TransactionType.transfer) return;
    if (type == state.editingType) return;
    AppVibrations.selection();
    state = state.copyWith(editingType: type);
  }

  // ------------------------------------------------------------- selectors

  Future<void> setEntryCurrency(CurrencyType c) async {
    // A subscription's currency is fixed.
    if (state.isRuleEdit || c == state.entryCurrency) return;
    state = state.copyWith(
      entryCurrency: c,
      amountInput: AmountInput.reScale(state.amountInput, c),
      rate: null,
      rateStatus: RateStatus.none,
    );
    await _ensureRate();
  }

  /// D3 — change the target wallet in place.
  Future<void> setWallet(WalletSummary w) async {
    if (w.id == state.wallet?.id) return;
    // Transfer *occurrences* are locked to their wallets; a transfer
    // subscription may re-point its source (same currency, not the target).
    if (state.isTransferEdit && !state.isRuleEdit) return;
    if (state.isEdit && w.currency != state.wallet?.currency) return;
    if (state.isRuleEdit && w.id == state.counterpart?.walletId) return;
    state = state.copyWith(wallet: w, rate: null, rateStatus: RateStatus.none);
    await _ensureRate();
  }

  void setDescription(String value) {
    final v = value.length > kMaxDescriptionLength ? value.substring(0, kMaxDescriptionLength) : value;
    state = state.copyWith(description: v);
  }

  void setTags(List<String> tags) {
    if (tags.length > kMaxTagsPerTransaction) {
      _showValidation(_l10n.validation_up_to_tags(kMaxTagsPerTransaction));
      return;
    }
    state = state.copyWith(tags: tags);
  }

  void onTagLimitReached() => _showValidation(_l10n.validation_up_to_tags(kMaxTagsPerTransaction));

  void setDate(DateTime day) => state = state.copyWith(date: day.onlyDate());

  void setRepeat(RepeatFrequency f) {
    if (state.repeatLocked) return;
    // A subscription always repeats.
    if (state.isRuleEdit && f.isNever) return;
    state = state.copyWith(repeat: f);
  }

  Future<List<String>> suggestTags(String query) => ref.read(tagRepositoryProvider).suggest(query);

  /// Fetch (once per pair per screen session) the entry → wallet rate.
  Future<void> _ensureRate() async {
    final w = state.wallet;
    if (w == null || state.entryCurrency == w.currency) {
      state = state.copyWith(rate: null, rateStatus: RateStatus.none);
      return;
    }
    final key = '${state.entryCurrency.code}:${w.currency.code}';
    final cached = _sessionRates[key];
    if (cached != null) {
      state = state.copyWith(rate: cached, rateStatus: cached.isStale ? RateStatus.stale : RateStatus.ok);
      return;
    }
    final request = ++_rateRequest;
    state = state.copyWith(rateStatus: RateStatus.loading);
    try {
      final rate = await _fx.rate(state.entryCurrency, w.currency);
      if (!ref.mounted || request != _rateRequest) return;
      _sessionRates[key] = rate;
      state = state.copyWith(rate: rate, rateStatus: rate.isStale ? RateStatus.stale : RateStatus.ok);
    } catch (_) {
      if (!ref.mounted || request != _rateRequest) return;
      state = state.copyWith(rate: null, rateStatus: RateStatus.error);
    }
  }

  /// Retry after "Rate unavailable".
  Future<void> retryRate() => _ensureRate();

  // ------------------------------------------------------------ validation

  void _showValidation(String message) {
    state = state.copyWith(validationError: message);
    _validationTimer?.cancel();
    _validationTimer = Timer(const Duration(seconds: 2), () {
      if (ref.mounted) state = state.copyWith(validationError: null);
    });
  }

  /// Public entry for the page: surfaces the validation message when a
  /// commit is not possible (amount shake is done by the page).
  bool validateForCommit() => _guardCommit();

  /// Returns false (and surfaces the reason) when a commit is not possible.
  bool _guardCommit() {
    if (state.isSaving || state.isLoading) return false;
    final m = state.walletMoney;
    if (state.entryMoney == null) {
      _showValidation(_l10n.validation_enter_amount);
      return false;
    }
    if (!state.rateReady || m == null) {
      _showValidation(_l10n.validation_rate_unavailable);
      return false;
    }
    if (state.tags.length > kMaxTagsPerTransaction) {
      _showValidation(_l10n.validation_up_to_tags(kMaxTagsPerTransaction));
      return false;
    }
    return true;
  }

  /// Spec 11.2: today → now; other day → 12:00 local; edit keeps the
  /// existing time when the day is unchanged.
  DateTime _resolvedDate() {
    final day = state.date;
    final existing = state.existing;
    if (existing != null && existing.transactionDate.onlyDate() == day) {
      return existing.transactionDate;
    }
    if (day.isToday) return DateTime.now();
    return DateTime(day.year, day.month, day.day, 12);
  }

  // ---------------------------------------------------------------- commit

  /// D4 — one-tap INCOME / EXPENSE: save, stay open, clear the amount.
  Future<bool> commit(TransactionType type) async {
    if (!_guardCommit()) return false;
    final wallet = state.wallet!;
    final amount = state.walletMoney!;
    final draft = type == TransactionType.income
        ? TransactionDraft.income(
            walletId: wallet.id,
            amount: amount,
            original: state.originalForStorage,
            rate: state.rateForStorage,
            description: state.description.trim(),
            tags: state.tags,
            date: _resolvedDate(),
            repeat: state.repeat,
          )
        : TransactionDraft.expense(
            walletId: wallet.id,
            amount: amount,
            original: state.originalForStorage,
            rate: state.rateForStorage,
            description: state.description.trim(),
            tags: state.tags,
            date: _resolvedDate(),
            repeat: state.repeat,
          );

    state = state.copyWith(isSaving: true);
    final result = await _repo.create(draft);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (saved) {
        ok = true;
        AppVibrations.medium();
        final signed = type == TransactionType.income ? '+${amount.format()}' : '-${amount.format()}';
        final cancel = _cancelAction(saved);
        if (saved.isUpcoming) {
          // Future-dated → stored as upcoming; not counted until its day.
          _events.send(ShowInfoMessageEvent(
            _l10n.transaction_scheduled(signed, state.date.formatMediumDate()),
            actionLabel: cancel.$1,
            onAction: cancel.$2,
          ));
        } else {
          _events.send(ShowSuccessMessageEvent(
            _l10n.transaction_saved(signed, wallet.name),
            actionLabel: cancel.$1,
            onAction: cancel.$2,
          ));
        }
        _resetAfterCommit();
      },
      (error) => _onSaveError(error),
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }

  /// D5 — TRANSFER confirmed from the sheet.
  Future<bool> transfer({
    required WalletSummary target,
    required Money received,
    double? rate,
  }) async {
    if (!_guardCommit()) return false;
    final source = state.wallet!;
    final sent = state.walletMoney!;
    final draft = TransactionDraft.transfer(
      fromWalletId: source.id,
      toWalletId: target.id,
      sent: sent,
      received: received,
      original: state.originalForStorage,
      rate: source.currency == target.currency ? null : rate,
      description: state.description.trim(),
      tags: state.tags,
      date: _resolvedDate(),
      repeat: state.repeat,
    );

    state = state.copyWith(isSaving: true);
    final result = await _repo.create(draft);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (saved) {
        ok = true;
        AppVibrations.medium();
        final cancel = _cancelAction(saved);
        if (saved.isUpcoming) {
          _events.send(ShowInfoMessageEvent(
            _l10n.transaction_scheduled(sent.format(), state.date.formatMediumDate()),
            actionLabel: cancel.$1,
            onAction: cancel.$2,
          ));
        } else {
          _events.send(ShowSuccessMessageEvent(
            _l10n.transaction_moved(sent.format(), target.name),
            actionLabel: cancel.$1,
            onAction: cancel.$2,
          ));
        }
        _resetAfterCommit();
      },
      (error) => _onSaveError(error),
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }

  /// The CANCEL button on the just-saved toast. Everything it needs is read
  /// off `ref` now and captured, because this screen is `autoDispose` and the
  /// toast outlives a pop — the closure must never touch `ref` again.
  (String, VoidCallback) _cancelAction(TransactionModel saved) {
    final repo = _repo;
    final events = _events;
    final l10n = _l10n;
    return (l10n.common_cancel, () => _cancelCreated(saved, repo, events, l10n));
  }

  /// Undoing a write that is one second old: the row goes straight out, no
  /// confirmation, and the removal reports itself with its own toast. A repeat
  /// minted its rule inside the same write, so the rule goes with it — pausing
  /// it (`stopRule`) would leave a dead rule in Subscriptions.
  static Future<void> _cancelCreated(
    TransactionModel saved,
    TransactionRepository repo,
    AppEvents events,
    AppLocale l10n,
  ) async {
    final failure = (await repo.softDelete(saved.id)).tryGetError();
    if (failure != null) {
      events.send(ShowErrorEvent(failure));
      return;
    }
    final ruleId = saved.recurringRuleId;
    if (ruleId != null) await repo.deleteRule(ruleId);
    events.send(ShowInfoMessageEvent(l10n.transaction_deleted));
  }

  /// [A1] keep wallet, currency, rate; clear amount, description, tags, repeat;
  /// date resets to today only if it was today (back-filling keeps the day).
  void _resetAfterCommit() {
    final today = DateTime.now().onlyDate();
    state = state.copyWith(
      amountInput: '',
      description: '',
      tags: const [],
      repeat: RepeatFrequency.never,
      date: state.date.isToday ? today : state.date,
      validationError: null,
    );
  }

  void _onSaveError(Failure error) {
    if (error is ValidationFailure) {
      _showValidation(error.message ?? _l10n.error_validation);
    } else {
      _events.send(ShowErrorEvent(error));
    }
  }

  // ------------------------------------------------------------ edit: save

  /// D8 — Save in edit mode. Returns true when the screen should pop.
  Future<bool> saveEdit() async {
    if (state.isRuleEdit) return saveRule();
    if (!state.isEdit || !_guardCommit()) return false;
    final existing = state.existing!;
    final wallet = state.wallet!;
    final amount = state.walletMoney!;

    final TransactionDraft draft;
    final type = existing.isTransfer ? TransactionType.transfer : (state.editingType ?? existing.type);
    switch (type) {
      case TransactionType.income:
        draft = TransactionDraft.income(
          walletId: wallet.id,
          amount: amount,
          original: state.originalForStorage,
          rate: state.rateForStorage,
          description: state.description.trim(),
          tags: state.tags,
          date: _resolvedDate(),
          repeat: RepeatFrequency.never,
        );
      case TransactionType.expense:
        draft = TransactionDraft.expense(
          walletId: wallet.id,
          amount: amount,
          original: state.originalForStorage,
          rate: state.rateForStorage,
          description: state.description.trim(),
          tags: state.tags,
          date: _resolvedDate(),
          repeat: RepeatFrequency.never,
        );
      case TransactionType.transfer:
        final viewedIsSource = state.counterpart?.outgoing ?? true;
        final storedRate = existing.exchangeRate;
        Money sent;
        Money received;
        if (viewedIsSource) {
          sent = amount;
          final sameCcy = existing.fromAmountMinor == existing.toAmountMinor && storedRate == null;
          received = sameCcy
              ? Money(sent.minor, state.counterpart!.amount.currency)
              : (storedRate == null
                  ? Money(existing.toAmountMinor ?? 0, state.counterpart!.amount.currency)
                  : convertMoney(sent, state.counterpart!.amount.currency, storedRate));
        } else {
          received = amount;
          sent = storedRate == null
              ? Money(received.minor, existing.currency)
              : Money(convertMinor(received.minor, received.currency, existing.currency, 1 / storedRate), existing.currency);
        }
        draft = TransactionDraft.transfer(
          fromWalletId: existing.fromWalletId!,
          toWalletId: existing.toWalletId!,
          sent: sent,
          received: received,
          original: viewedIsSource ? state.originalForStorage : null,
          rate: storedRate,
          description: state.description.trim(),
          tags: state.tags,
          date: _resolvedDate(),
          repeat: RepeatFrequency.never,
        );
    }

    state = state.copyWith(isSaving: true);
    final result = await _repo.update(existing.id, draft);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (_) {
        ok = true;
        AppVibrations.medium();
      },
      (error) => _onSaveError(error),
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }

  // ------------------------------------------------- subscription: save

  /// Subscription edit save. The date shown is the next due date, so the rule
  /// is re-anchored on it. Existing occurrences are never touched.
  Future<bool> saveRule() async {
    final r = state.rule;
    if (r == null || !state.isRuleEdit || !_guardCommit()) return false;
    final sent = state.entryMoney!;

    int? received;
    if (r.isTransfer) {
      final c = state.counterpart!;
      received = r.exchangeRate == null
          ? sent.minor
          : convertMinor(sent.minor, sent.currency, c.amount.currency, r.exchangeRate!);
    }

    state = state.copyWith(isSaving: true);
    final result = await _repo.updateRule(
      r.id,
      RecurringRuleDraft(
        amountMinor: sent.minor,
        receivedAmountMinor: received,
        exchangeRate: r.exchangeRate,
        description: state.description.trim(),
        frequency: state.repeat,
        nextOccurrence: _resolvedRuleDate(r),
        walletId: r.isTransfer ? null : state.wallet?.id,
        fromWalletId: r.isTransfer ? state.wallet?.id : null,
        toWalletId: r.isTransfer ? state.counterpart?.walletId : null,
        tags: state.tags,
      ),
    );
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (_) {
        ok = true;
        AppVibrations.medium();
        _events.send(ShowInfoMessageEvent(_l10n.subscriptions_saved));
      },
      (error) => _onSaveError(error),
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }

  /// Keep the rule's time of day; only the calendar day is user-editable.
  DateTime _resolvedRuleDate(RecurringRuleModel r) {
    final day = state.date;
    final at = r.nextOccurrence;
    if (at.onlyDate() == day) return at;
    return DateTime(day.year, day.month, day.day, at.hour, at.minute, at.second);
  }

  /// Stop the subscription (soft delete). Existing occurrences stay.
  Future<bool> stopSubscription() async {
    final r = state.rule;
    if (r == null || state.isSaving) return false;
    state = state.copyWith(isSaving: true);
    final result = await _repo.deleteRule(r.id);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (_) {
        ok = true;
        AppVibrations.heavy();
        _events.send(ShowInfoMessageEvent(_l10n.subscriptions_stopped));
      },
      (error) => _events.send(ShowErrorEvent(error)),
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }

  /// Edit-mode delete. Returns true when the screen should pop.
  Future<bool> delete({bool stopRule = false}) async {
    final existing = state.existing;
    if (existing == null) return false;
    state = state.copyWith(isSaving: true);
    final result = await _repo.softDelete(existing.id, stopRule: stopRule);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (_) {
        ok = true;
        AppVibrations.heavy();
        _events.send(ShowInfoMessageEvent(_l10n.transaction_deleted));
      },
      (error) => _events.send(ShowErrorEvent(error)),
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }
}
