import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/currency_type.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/enums/budget_period_type.dart';
import '../../../core/utils/enums/rollover_mode.dart';
import '../../../core/utils/extensions/date_time_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../../tag/data/tag_repository.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../wallet/ui/wallets_provider.dart';
import '../data/budget_period.dart';
import '../data/budget_repository.dart';
import '../data/models/budget_model.dart';

part 'budget_form_notifier.freezed.dart';

/// Route arguments: `budgetId` (edit), or a scope to prefill from Wallet
/// Details (`walletId`) / a tag (`tagId`).
class BudgetFormArgs {
  const BudgetFormArgs({this.budgetId, this.walletId, this.tagId});

  final String? budgetId;
  final String? walletId;
  final String? tagId;

  bool get isEdit => budgetId != null;

  @override
  bool operator ==(Object other) =>
      other is BudgetFormArgs && other.budgetId == budgetId && other.walletId == walletId && other.tagId == tagId;

  @override
  int get hashCode => Object.hash(budgetId, walletId, tagId);
}

@freezed
abstract class BudgetFormState with _$BudgetFormState {
  const BudgetFormState._();

  const factory BudgetFormState({
    required bool isEdit,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,

    /// Empty = the auto name is used (shown as the field placeholder).
    @Default('') String name,

    /// Raw numpad input in [currency].
    @Default('') String limitInput,
    required CurrencyType currency,

    /// The user picked the currency by hand: stop following the scope.
    @Default(false) bool currencyTouched,
    @Default(<String>{}) Set<String> walletIds,

    /// Tag display names as typed / picked in the form. New names become tags
    /// on save (`BudgetRepository.create(tagNames:)`).
    @Default(<String>[]) List<String> tags,
    @Default(BudgetPeriodType.monthly) BudgetPeriodType period,

    /// Monthly start day (1–31) — e.g. salary day.
    @Default(1) int monthDay,

    /// Weekly start weekday (`DateTime.monday` … `sunday`).
    @Default(DateTime.monday) int weekday,

    /// Yearly: month / day of the start (the year is ignored).
    required DateTime yearlyStart,

    /// One-time: first and last day (inclusive).
    required DateTime customStart,
    required DateTime customEnd,
    @Default(RolloverMode.none) RolloverMode rollover,
    @Default(true) bool includePlanned,

    /// Average of the last 3 periods (create mode only, never auto-filled).
    Money? suggestion,

    /// Inline validation message (localised).
    String? error,
    BudgetModel? existing,
  }) = _BudgetFormState;

  Money? get limit => AmountInput.toMoney(limitInput, currency);
  bool get canSave => !isSaving && !isLoading && (limit?.isPositive ?? false);
}

final budgetFormProvider =
    NotifierProvider.autoDispose.family<BudgetFormNotifier, BudgetFormState, BudgetFormArgs>(BudgetFormNotifier.new);

/// Budget form (spec B&D §6.6). Validation lives in `BudgetRepository`; this
/// notifier only maps its failures to inline messages.
class BudgetFormNotifier extends Notifier<BudgetFormState> {
  BudgetFormNotifier(this.args);

  final BudgetFormArgs args;

  BudgetRepository get _repo => ref.read(budgetRepositoryProvider);
  AppEvents get _events => ref.read(appEventProvider);
  AppLocale get _l10n => ref.read(l10nProvider);
  List<WalletSummary> get _wallets => ref.read(walletsProvider).value ?? const <WalletSummary>[];

  int _suggestionRequest = 0;

  @override
  BudgetFormState build() {
    final today = DateTime.now().onlyDate();
    final base = ref.read(baseCurrencyProvider);
    final initial = BudgetFormState(
      isEdit: args.isEdit,
      isLoading: args.isEdit,
      currency: base,
      yearlyStart: DateTime(today.year),
      customStart: today,
      customEnd: DateTime(today.year, today.month, today.day + 13),
    );
    if (args.isEdit) {
      Future.microtask(_loadExisting);
      return initial;
    }
    Future.microtask(_prefill);
    return initial;
  }

  /// Create mode: scope from the entry point, then the first suggestion.
  Future<void> _prefill() async {
    final walletId = args.walletId;
    if (walletId != null) {
      final wallet = _wallets.where((w) => w.id == walletId).firstOrNull;
      state = state.copyWith(walletIds: {walletId}, currency: wallet?.currency ?? state.currency);
    }
    final tagId = args.tagId;
    if (tagId != null) {
      final tag = (await ref.read(tagRepositoryProvider).byId(tagId)).tryGetSuccess();
      if (!ref.mounted) return;
      if (tag != null) state = state.copyWith(tags: [tag.displayName]);
    }
    await _refreshSuggestion();
  }

  Future<void> _loadExisting() async {
    final result = await _repo.byId(args.budgetId!);
    if (!ref.mounted) return;
    final b = result.tryGetSuccess();
    if (b == null) {
      state = state.copyWith(isLoading: false);
      result.whenError((e) => _events.send(ShowErrorEvent(e)));
      return;
    }
    final tagRepo = ref.read(tagRepositoryProvider);
    final tags = <String>[];
    for (final id in b.tagIds) {
      final t = (await tagRepo.byId(id)).tryGetSuccess();
      if (t != null) tags.add(t.displayName);
    }
    if (!ref.mounted) return;
    final anchor = b.anchorDate;
    final end = b.endDate;
    state = state.copyWith(
      isLoading: false,
      existing: b,
      name: b.name,
      limitInput: b.limit.toPlainString(),
      currency: b.currency,
      currencyTouched: true,
      walletIds: b.walletIds,
      tags: tags,
      period: b.period,
      monthDay: anchor.day,
      weekday: anchor.weekday,
      yearlyStart: anchor,
      customStart: anchor,
      customEnd: end == null ? state.customEnd : DateTime(end.year, end.month, end.day - 1),
      rollover: b.rollover,
      includePlanned: b.includePlanned,
    );
  }

  /// Create mode default: the locale's first day of the week.
  void initWeekday(int weekday) {
    if (state.isEdit) return;
    state = state.copyWith(weekday: weekday);
  }

  // ------------------------------------------------------------------ edits

  void setName(String value) {
    final v = value.length > kMaxBudgetNameLength ? value.substring(0, kMaxBudgetNameLength) : value;
    state = state.copyWith(name: v, error: null);
  }

  void setLimitInput(String raw) => state = state.copyWith(limitInput: AmountInput.reScale(raw, state.currency), error: null);

  // On-page numpad (same rules as the Transaction screen).
  void onDigit(String d) => _applyInput(AmountInput.digit(state.limitInput, d, state.currency));

  void onDot() => _applyInput(AmountInput.dot(state.limitInput, state.currency));

  void onBackspace() {
    if (state.limitInput.isEmpty) return;
    state = state.copyWith(limitInput: AmountInput.backspace(state.limitInput), error: null);
  }

  void onClear() {
    if (state.limitInput.isEmpty) return;
    state = state.copyWith(limitInput: AmountInput.clear(), error: null);
  }

  void _applyInput(AmountInputResult r) {
    if (r.rejected) {
      AppVibrations.error();
      return;
    }
    state = state.copyWith(limitInput: r.value, error: null);
  }

  void setCurrency(CurrencyType c) {
    state = state.copyWith(
      currency: c,
      currencyTouched: true,
      limitInput: AmountInput.reScale(state.limitInput, c),
    );
    _refreshSuggestion();
  }

  /// Exactly one wallet → follow its currency until the user picks one.
  void setWallets(Set<String> ids) {
    var currency = state.currency;
    if (!state.currencyTouched && ids.length == 1) {
      currency = _wallets.where((w) => w.id == ids.single).firstOrNull?.currency ?? currency;
    } else if (!state.currencyTouched && ids.isEmpty) {
      currency = ref.read(baseCurrencyProvider);
    }
    state = state.copyWith(
      walletIds: ids,
      currency: currency,
      limitInput: AmountInput.reScale(state.limitInput, currency),
      error: null,
    );
    _refreshSuggestion();
  }

  void setTags(List<String> tags) {
    if (tags.length > kMaxBudgetTags) {
      onTagLimitReached();
      return;
    }
    state = state.copyWith(tags: tags, error: null);
    _refreshSuggestion();
  }

  void onTagLimitReached() => state = state.copyWith(error: _l10n.validation_up_to_tags(kMaxBudgetTags));

  /// Keyboard tag bar / autocomplete.
  Future<List<String>> suggestTags(String query) => ref.read(tagRepositoryProvider).suggest(query, limit: 20);

  void setPeriod(BudgetPeriodType p) {
    state = state.copyWith(
      period: p,
      rollover: p.isCustom ? RolloverMode.none : state.rollover,
      error: null,
    );
    _refreshSuggestion();
  }

  void setMonthDay(int day) {
    state = state.copyWith(monthDay: day);
    _refreshSuggestion();
  }

  void setWeekday(int weekday) {
    state = state.copyWith(weekday: weekday);
    _refreshSuggestion();
  }

  void setYearlyStart(DateTime d) {
    state = state.copyWith(yearlyStart: d.onlyDate());
    _refreshSuggestion();
  }

  /// One-time range; the other edge follows so the range is never inverted.
  void setCustomStart(DateTime d) {
    final start = d.onlyDate();
    state = state.copyWith(
      customStart: start,
      customEnd: state.customEnd.isBefore(start) ? start : state.customEnd,
      error: null,
    );
  }

  void setCustomEnd(DateTime d) {
    final end = d.onlyDate();
    state = state.copyWith(
      customEnd: end,
      customStart: state.customStart.isAfter(end) ? end : state.customStart,
      error: null,
    );
  }

  void setRollover(RolloverMode m) => state = state.copyWith(rollover: m);

  void setIncludePlanned(bool v) => state = state.copyWith(includePlanned: v);

  /// Tap on the suggestion chip: fill the limit (never automatic).
  void applySuggestion() {
    final s = state.suggestion;
    if (s == null) return;
    state = state.copyWith(limitInput: s.toPlainString(), error: null);
  }

  // ---------------------------------------------------------------- derived

  /// Auto name when the field is empty: tags → `#food, #market`; else
  /// wallets → `Card, Cash`; else "All spending".
  String autoName() {
    if (state.tags.isNotEmpty) return state.tags.map((t) => '#$t').join(', ');
    final names = _wallets.where((w) => state.walletIds.contains(w.id)).map((w) => w.name).toList();
    if (names.isNotEmpty) return names.join(', ');
    return _l10n.budget_all_spending;
  }

  /// First day of the first period. Editing a budget keeps its anchor while
  /// the start settings are unchanged (rollover history is index-based).
  DateTime _anchor(DateTime today) {
    final e = state.existing;
    if (e != null && e.period == state.period) {
      final a = e.anchorDate;
      final same = switch (state.period) {
        BudgetPeriodType.monthly => a.day == state.monthDay,
        BudgetPeriodType.weekly => a.weekday == state.weekday,
        BudgetPeriodType.yearly => a.month == state.yearlyStart.month && a.day == state.yearlyStart.day,
        BudgetPeriodType.custom => a == state.customStart,
      };
      if (same) return a;
    }
    return switch (state.period) {
      BudgetPeriodType.monthly => monthlyAnchor(state.monthDay, today),
      BudgetPeriodType.weekly => weeklyAnchor(state.weekday, today),
      BudgetPeriodType.yearly => yearlyAnchor(state.yearlyStart.month, state.yearlyStart.day, today),
      BudgetPeriodType.custom => state.customStart,
    };
  }

  Future<void> _refreshSuggestion() async {
    if (state.isEdit) return;
    final request = ++_suggestionRequest;
    final tagIds = await ref.read(tagRepositoryProvider).idsOfNames(state.tags);
    if (!ref.mounted || request != _suggestionRequest) return;
    // Only brand-new tags: no history to average (and an empty id set would
    // mean "any tag").
    if (state.tags.isNotEmpty && tagIds.isEmpty) {
      state = state.copyWith(suggestion: null);
      return;
    }
    final result = await _repo.suggestLimit(
      walletIds: state.walletIds,
      tagIds: tagIds,
      period: state.period,
      anchorDate: _anchor(DateTime.now().onlyDate()),
      currency: state.currency,
    );
    if (!ref.mounted || request != _suggestionRequest) return;
    state = state.copyWith(suggestion: result.tryGetSuccess());
  }

  // ----------------------------------------------------------------- writes

  /// Returns true when the form should close.
  Future<bool> save() async {
    final limit = state.limit;
    if (limit == null || !limit.isPositive) {
      state = state.copyWith(error: _l10n.validation_enter_amount);
      return false;
    }
    if (state.isSaving) return false;
    final c = state.customEnd;
    final draft = BudgetDraft(
      name: state.name.trim().isEmpty ? autoName() : state.name.trim(),
      limit: limit,
      period: state.period,
      anchorDate: _anchor(DateTime.now().onlyDate()),
      endDate: state.period.isCustom ? DateTime(c.year, c.month, c.day + 1) : null,
      rollover: state.period.isCustom ? RolloverMode.none : state.rollover,
      includePlanned: state.includePlanned,
      walletIds: state.walletIds,
    );
    state = state.copyWith(isSaving: true, error: null);
    final result = args.isEdit
        ? await _repo.update(args.budgetId!, draft, tagNames: state.tags)
        : await _repo.create(draft, tagNames: state.tags);
    if (!ref.mounted) return false;
    var ok = false;
    result.when(
      (_) => ok = true,
      (error) {
        if (error is ValidationFailure) {
          state = state.copyWith(error: _validationMessage(error));
        } else {
          _events.send(ShowErrorEvent(error));
        }
      },
    );
    state = state.copyWith(isSaving: false);
    return ok;
  }

  String _validationMessage(ValidationFailure f) => switch (f.field) {
        'limit' => _l10n.validation_enter_amount,
        'name' => _l10n.budget_error_name,
        'endDate' => _l10n.budget_error_dates,
        'tags' => _l10n.validation_up_to_tags(kMaxBudgetTags),
        _ => _l10n.error_validation,
      };

  /// Soft delete. Resolves with the `deleted_at` stamp (for Undo), or null.
  Future<int?> delete() async {
    final id = args.budgetId;
    if (id == null) return null;
    state = state.copyWith(isSaving: true);
    final result = await _repo.delete(id);
    if (!ref.mounted) return null;
    state = state.copyWith(isSaving: false);
    return result.when((deletedAt) => deletedAt, (error) {
      _events.send(ShowErrorEvent(error));
      return null;
    });
  }

  /// Undo of [delete]; captured values only (the form is gone by then).
  static Future<void> restore(BudgetRepository repo, AppEvents events, String id, int deletedAt) async {
    final failure = (await repo.restore(id, deletedAt)).tryGetError();
    if (failure != null) events.send(ShowErrorEvent(failure));
  }
}
