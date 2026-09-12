import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/locale/l10n.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../transaction/data/models/transaction_filter.dart';

/// "Newest first" etc. (toolbar button + radio rows).
String transactionSortLabel(AppLocale l10n, TransactionSort sort) => switch (sort) {
      TransactionSort.dateDesc => l10n.sort_date_newest,
      TransactionSort.dateAsc => l10n.sort_date_oldest,
      TransactionSort.amountDesc => l10n.sort_amount_high,
      TransactionSort.amountAsc => l10n.sort_amount_low,
    };

/// 4 radio rows; pops with the chosen [TransactionSort] (null when dismissed).
abstract class TransactionSortSheet {
  static Future<TransactionSort?> show(BuildContext context, {required TransactionSort selected}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<TransactionSort>(
      context: context,
      title: l10n.wallet_sort_title,
      fitContent: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in TransactionSort.values) ...[
              UiRadioRow(
                label: transactionSortLabel(l10n, s),
                selected: s == selected,
                onTap: () => Navigator.of(context).pop(s),
              ),
              if (s != TransactionSort.values.last) const UIDivider(),
            ],
          ],
        ),
      ),
    );
  }
}
