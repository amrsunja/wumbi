import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../data/backup_repository.dart';

/// What the backup contains and what restoring it does. True when the user
/// confirms the replacement.
abstract class RestorePreviewSheet {
  static Future<bool> show(BuildContext context, BackupPreview preview) async {
    final l10n = context.l10n;
    final confirmed = await UIModalSheet.modalSheet<bool>(
      context: context,
      fitContent: true,
      title: preview.isSafetySnapshot ? l10n.backup_preview_undo_title : l10n.backup_preview_title,
      child: _Body(preview: preview),
    );
    return confirmed ?? false;
  }
}

/// `Nov 8, 2026 · 09:30` in the app locale.
String backupDateLabel(DateTime date) {
  final local = date.toLocal();
  final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '${local.formatMediumDate()} · $time';
}

class _Body extends StatelessWidget {
  const _Body({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = preview;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiGroupCard(
            children: [
              UiValueRow(label: l10n.backup_preview_created, value: backupDateLabel(p.createdAt)),
              if (!p.isSafetySnapshot) UiValueRow(label: l10n.backup_preview_app_version, value: p.appVersion),
            ],
          ),
          const UISpace.vert(12),
          UiGroupCard(
            children: [
              UiValueRow(label: l10n.backup_preview_wallets, value: '${p.wallets}'),
              UiValueRow(label: l10n.backup_preview_transactions, value: '${p.transactions}'),
              UiValueRow(label: l10n.backup_preview_tags, value: '${p.tags}'),
              UiValueRow(label: l10n.backup_preview_budgets, value: '${p.budgets}'),
              UiValueRow(label: l10n.backup_preview_debts, value: '${p.debts}'),
              UiValueRow(label: l10n.backup_preview_subscriptions, value: '${p.subscriptions}'),
            ],
          ),
          if (p.encrypted && !p.isSafetySnapshot) ...[
            const UISpace.vert(10),
            UiFormHint(
              text: l10n.backup_encrypted_badge,
              icon: UIIconToken.icons.security.lock01,
              color: UIColorToken.pos500,
            ),
          ],
          const UISpace.vert(12),
          UiFormHint(
            text: p.isSafetySnapshot ? l10n.backup_preview_undo_warning : l10n.backup_preview_warning,
            icon: UIIconToken.icons.alertsFeedback.alertTriangle,
            color: UIColorToken.buttercup,
            maxLines: 4,
          ),
          const UISpace.vert(20),
          UiPrimaryButton(label: l10n.backup_restore_action, onTap: () => Navigator.of(context).pop(true)),
          const UISpace.vert(4),
          Center(
            child: UiTextButton(
              label: l10n.common_cancel,
              style: UiTextButtonStyle.secondary,
              fontSize: 16,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}
