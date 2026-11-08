import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/locale/gen/app_localizations.dart';
import '../../../../core/money/currency_names.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../state_management/settings_provider.dart';

/// Settings → Currency. Browsing shows every [CurrencyType] as wrapped chips
/// (symbol + code), the current one and the majors first, then grouped by
/// region. Typing in the search field (code, name or symbol) switches to
/// rows with the full name so the match is easy to confirm.
@RoutePage()
class BaseCurrencyPage extends HookConsumerWidget {
  const BaseCurrencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(baseCurrencyProvider);
    final query = useState('');
    final q = query.value.trim().toLowerCase();

    Future<void> select(CurrencyType c) async {
      AppVibrations.selection();
      FocusScope.of(context).unfocus();
      await ref.read(settingsProvider.notifier).changeBaseCurrency(c);
      if (context.mounted) context.router.maybePop();
    }

    return Scaffold(
      appBar: UIAppbar(title: l10n.currency_base_title, backTap: () => context.router.maybePop()),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(kSettingsHorzPadding, 8, kSettingsHorzPadding, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(l10n.currency_base_hint, style: context.typo.inter.caption),
                  UISearchField(
                    hintText: l10n.currency_search_hint,
                    textInputAction: TextInputAction.done,
                    onChanged: (v) => query.value = v,
                  ),
                ],
              ),
            ),
            Expanded(
              child: UIScrollEdgeFade(
                top: 16,
                child: q.isEmpty
                    ? _CurrencyChips(current: current, onSelect: select)
                    : _SearchResults(query: q, current: current, onSelect: select),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Browse mode: one wrapped chip group per section.
class _CurrencyChips extends StatelessWidget {
  const _CurrencyChips({required this.current, required this.onSelect});

  final CurrencyType current;
  final ValueChanged<CurrencyType> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final popular = [
      if (_regionOf(current) != _Region.popular) current,
      ...CurrencyType.values.where((c) => _regionOf(c) == _Region.popular),
    ];

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(kSettingsHorzPadding, 0, kSettingsHorzPadding, 32),
      children: [
        for (final region in _Region.values)
          _ChipSection(
            label: region.label(l10n),
            first: region == _Region.popular,
            currencies:
                region == _Region.popular ? popular : CurrencyType.values.where((c) => _regionOf(c) == region).toList(),
            current: current,
            onSelect: onSelect,
          ),
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.label,
    required this.currencies,
    required this.current,
    required this.onSelect,
    this.first = false,
  });

  final String label;
  final List<CurrencyType> currencies;
  final CurrencyType current;
  final ValueChanged<CurrencyType> onSelect;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiSectionLabel(text: label, padding: EdgeInsets.only(top: first ? 4 : 24, bottom: 10)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in currencies)
              UiChoiceChip(
                leading: c.symbol == c.code ? null : c.symbol,
                label: c.code,
                selected: c == current,
                onTap: () => onSelect(c),
              ),
          ],
        ),
      ],
    );
  }
}

/// Search mode: matching currencies as rows with their localised name; exact
/// and prefix code matches first.
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query, required this.current, required this.onSelect});

  final String query;
  final CurrencyType current;
  final ValueChanged<CurrencyType> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    int rank(CurrencyType c) {
      final code = c.code.toLowerCase();
      if (code == query) return 0;
      if (code.startsWith(query)) return 1;
      return 2;
    }

    final matches = CurrencyType.values.where((c) => c.nameMatches(l10n.localeName, query)).toList()
      ..sort((a, b) => rank(a).compareTo(rank(b)));

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSettingsHorzPadding, vertical: 24),
        child: Text(l10n.currency_no_results, textAlign: TextAlign.center, style: context.typo.inter.hint),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(kSettingsHorzPadding, 0, kSettingsHorzPadding, 32),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const UIDivider(),
      itemBuilder: (context, index) {
        final c = matches[index];
        return UiListRow(
          title: c.code,
          subtitle: c.nameIn(l10n.localeName),
          trailingText: c.symbol,
          selected: c == current,
          onTap: () => onSelect(c),
        );
      },
    );
  }
}

enum _Region {
  popular,
  europe,
  americas,
  asiaPacific,
  middleEastAfrica,
  crypto;

  String label(AppLocalizations l10n) => switch (this) {
        popular => l10n.currency_section_popular,
        europe => l10n.currency_region_europe,
        americas => l10n.currency_region_americas,
        asiaPacific => l10n.currency_region_asia_pacific,
        middleEastAfrica => l10n.currency_region_middle_east_africa,
        crypto => l10n.currency_region_crypto,
      };
}

/// Exhaustive so a new [CurrencyType] has to be placed in a section.
_Region _regionOf(CurrencyType c) => switch (c) {
      CurrencyType.usd ||
      CurrencyType.eur ||
      CurrencyType.gbp ||
      CurrencyType.jpy ||
      CurrencyType.chf ||
      CurrencyType.cad ||
      CurrencyType.aud ||
      CurrencyType.cny ||
      CurrencyType.rub ||
      CurrencyType.tryLira ||
      CurrencyType.inr =>
        _Region.popular,
      CurrencyType.sek ||
      CurrencyType.nok ||
      CurrencyType.dkk ||
      CurrencyType.pln ||
      CurrencyType.czk ||
      CurrencyType.huf ||
      CurrencyType.ron ||
      CurrencyType.bgn ||
      CurrencyType.uah ||
      CurrencyType.isk ||
      CurrencyType.rsd ||
      CurrencyType.gel ||
      CurrencyType.kzt ||
      CurrencyType.byn ||
      CurrencyType.uzs ||
      CurrencyType.amd ||
      CurrencyType.azn =>
        _Region.europe,
      CurrencyType.mxn ||
      CurrencyType.brl ||
      CurrencyType.ars ||
      CurrencyType.clp ||
      CurrencyType.cop ||
      CurrencyType.pen =>
        _Region.americas,
      CurrencyType.krw ||
      CurrencyType.hkd ||
      CurrencyType.sgd ||
      CurrencyType.nzd ||
      CurrencyType.twd ||
      CurrencyType.thb ||
      CurrencyType.idr ||
      CurrencyType.myr ||
      CurrencyType.php ||
      CurrencyType.vnd ||
      CurrencyType.pkr ||
      CurrencyType.bdt ||
      CurrencyType.lkr =>
        _Region.asiaPacific,
      CurrencyType.aed ||
      CurrencyType.sar ||
      CurrencyType.qar ||
      CurrencyType.kwd ||
      CurrencyType.bhd ||
      CurrencyType.omr ||
      CurrencyType.jod ||
      CurrencyType.ils ||
      CurrencyType.egp ||
      CurrencyType.mad ||
      CurrencyType.dzd ||
      CurrencyType.tnd ||
      CurrencyType.ngn ||
      CurrencyType.zar ||
      CurrencyType.kes ||
      CurrencyType.ghs =>
        _Region.middleEastAfrica,
      CurrencyType.btc || CurrencyType.eth || CurrencyType.usdt => _Region.crypto,
    };
