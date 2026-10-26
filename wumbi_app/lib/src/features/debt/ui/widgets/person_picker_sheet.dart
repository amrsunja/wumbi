import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/state_management/app_events.dart';
import '../../../../core/utils/state_management/single_events.dart';
import '../../../settings/ui/state_management/settings_provider.dart';
import '../../data/debt_repository.dart';
import '../../data/models/person_model.dart';
import '../../data/person_name.dart';
import '../debt_labels.dart';
import '../person_pick.dart';

/// Search-or-add a person (spec B&D §8.1). People with open debts first,
/// each with their balance; "Add “…”" when the query matches nobody;
/// "No person" to clear. Swipe deletes a person without live debts.
abstract class PersonPickerSheet {
  static Future<PersonPick?> show(BuildContext context, {bool allowClear = false}) =>
      UIModalSheet.modalSheet<PersonPick>(
        context: context,
        title: context.l10n.debt_person_title,
        height: 0.75,
        child: _Body(allowClear: allowClear),
      );
}

class _Body extends HookConsumerWidget {
  const _Body({required this.allowClear});

  final bool allowClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final typo = context.typo.inter;
    final base = ref.watch(baseCurrencyProvider);
    final query = useState('');
    final reload = useState(0);
    final future = useMemoized(
      () => ref.read(debtRepositoryProvider).searchPeople(query.value, base: base),
      [query.value, reload.value, base],
    );
    final snapshot = useFuture(future);
    final people = snapshot.data?.tryGetSuccess() ?? const <PersonSummary>[];

    final typed = PersonName.display(query.value);
    final exact = people.any((p) => p.person.normalizedName == PersonName.normalize(typed));

    Future<void> delete(PersonModel person) async {
      AppVibrations.heavy();
      final failure = (await ref.read(debtRepositoryProvider).deletePerson(person.id)).tryGetError();
      if (failure != null) ref.read(appEventProvider).send(ShowErrorEvent(failure));
      reload.value++;
    }

    String? balanceCaption(PersonBalance b) {
      if (b.owedToMe.isNotEmpty) {
        return l10n.debt_picker_owes_you(DebtLabels.side(b.owedToMe, b.owedToMeBase, incomplete: b.incomplete));
      }
      if (b.iOwe.isNotEmpty) {
        return l10n.debt_picker_you_owe(DebtLabels.side(b.iOwe, b.iOweBase, incomplete: b.incomplete));
      }
      return null;
    }

    return Column(
      children: [
        UISearchField(
          autofocus: true,
          hintText: l10n.debt_person_search,
          maxLength: kMaxPersonNameLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (v) => query.value = v,
          onSubmitted: (_) {
            if (typed.isNotEmpty && !exact) Navigator.of(context).pop(NewPerson(typed));
          },
        ),
        const UISpace.vert(8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (typed.isNotEmpty && !exact)
                UiListRow(
                  leading: UIIcon(UIIconToken.icons.users.userPlus01, size: 20, color: UIColorToken.blue),
                  title: l10n.debt_person_add(typed),
                  onTap: () => Navigator.of(context).pop(NewPerson(typed)),
                ),
              for (final p in people) ...[
                const UIDivider(),
                _PersonRow(
                  summary: p,
                  caption: balanceCaption(p.balance),
                  onTap: () => Navigator.of(context).pop(PickedPerson(p.person)),
                  onDelete: p.balance.hasOpenDebts ? null : () => delete(p.person),
                ),
              ],
              if (snapshot.hasData && people.isEmpty && typed.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.debt_person_empty, textAlign: TextAlign.center, style: typo.hint),
                ),
              if (allowClear) ...[
                const UIDivider(),
                UiListRow(
                  leading: UIIcon(UIIconToken.icons.users.user01, size: 20),
                  title: l10n.debt_person_none,
                  onTap: () => Navigator.of(context).pop(const NoPerson()),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.summary, required this.caption, required this.onTap, this.onDelete});

  final PersonSummary summary;
  final String? caption;
  final VoidCallback onTap;

  /// Null when the person still has open debts (cannot be deleted).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final name = summary.person.name;
    final row = UiListRow(
      leading: _Initial(name: name),
      title: name,
      trailingText: caption,
      onTap: onTap,
    );
    if (onDelete == null) return row;
    return Dismissible(
      key: ValueKey('person-${summary.person.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete!(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: UIColorToken.red, borderRadius: BorderRadius.circular(12)),
        child: UIIcon(UIIconToken.icons.general.trash01, color: UIColorToken.white, size: 22),
      ),
      child: row,
    );
  }
}

/// Initial in a tinted circle (people have no colour of their own).
class _Initial extends StatelessWidget {
  const _Initial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: UIColorToken.blue.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Text(letter, style: context.typo.inter.label.copyWith(color: UIColorToken.blue)),
    );
  }
}
