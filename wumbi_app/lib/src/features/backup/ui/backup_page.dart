import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/errors/failures/failures.dart';
import '../../../core/utils/app_vibrations.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/extensions/build_context_extensions.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../../core/utils/typedefs.dart';
import '../data/backup_repository.dart';
import 'backup_controller.dart';
import 'backup_file_delivery.dart';
import 'widgets/backup_busy_dialog.dart';
import 'widgets/create_backup_sheet.dart';
import 'widgets/restore_preview_sheet.dart';
import 'widgets/unlock_backup_sheet.dart';

/// Settings → Backup & Export.
///
/// * **Backup** — the full `.wumbi` file (optionally password-encrypted),
///   restore from one, and undo the last restore.
/// * **Spreadsheet** — transactions as CSV, clearly marked as *not* a
///   backup (a dialog says so again before every export).
@RoutePage()
class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final task = ref.watch(backupControllerProvider);
    final undoDate = ref.watch(safetySnapshotDateProvider).value;
    final controller = ref.read(backupControllerProvider.notifier);
    final events = ref.read(appEventProvider);
    final busy = task != null;

    void showError(Failure failure) {
      AppVibrations.error();
      events.send(ShowErrorEvent(failure));
    }

    T? unwrap<T>(SuccessOrError<T>? result) => result?.when((value) => value, (failure) {
      showError(failure);
      return null;
    });

    Future<void> restorePreview(BackupPreview preview) async {
      if (!await RestorePreviewSheet.show(context, preview) || !context.mounted) return;
      AppVibrations.heavy();
      final result = await BackupBusyDialog.run(context, l10n.backup_restoring, () => controller.restore(preview));
      if (result == null) return;
      final failure = result.when((_) => null, (f) => f);
      if (failure != null) return showError(failure);
      await controller.finishRestore(undo: preview.isSafetySnapshot);
    }

    Future<void> restoreFromFile() async {
      final envelope = unwrap(await controller.pickBackup());
      if (envelope == null || !context.mounted) return;

      final opened = envelope.needsPassword
          ? await UnlockBackupSheet.show(context, envelope)
          : await BackupBusyDialog.run(context, l10n.backup_reading, () => controller.openBackup(envelope));
      final preview = unwrap(opened);
      if (preview == null || !context.mounted) return;
      await restorePreview(preview);
    }

    Future<void> undoRestore() async {
      final opened = await BackupBusyDialog.run(context, l10n.backup_reading, controller.openSafetySnapshot);
      final preview = unwrap(opened);
      if (preview == null || !context.mounted) return;
      await restorePreview(preview);
    }

    Future<void> exportCsv(Rect? origin) async {
      // Say it before every export: a CSV is not a backup.
      final choice = await UIAlertDialog.choose(
        context,
        title: l10n.backup_csv_dialog_title,
        message: l10n.backup_csv_dialog_message,
        actions: [
          UIDialogAction(label: l10n.backup_save_to_device, primary: true),
          UIDialogAction(label: l10n.backup_share, primary: true),
          UIDialogAction(label: l10n.common_cancel),
        ],
      );
      if (choice == null || choice == 2) return;
      final file = unwrap(await controller.createCsv());
      if (file == null) return;
      try {
        if (choice == 0) {
          if (await BackupFileDelivery.save(file)) events.send(ShowSuccessMessageEvent(l10n.backup_csv_saved));
        } else {
          await BackupFileDelivery.share(file, origin: origin);
        }
      } catch (_) {
        events.send(ShowErrorEvent(null, defaultMessage: l10n.error_unknown));
      }
    }

    return Scaffold(
      appBar: UIAppbar(title: l10n.backup_title, backTap: () => context.router.maybePop()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kSettingsHorzPadding, 8, kSettingsHorzPadding, 32),
          children: [
            Row(
              children: [
                const UIWumbi(WumbiMood.tossing, height: 72),
                const UISpace.horz(12),
                Expanded(child: Text(l10n.backup_intro, style: context.typo.inter.paragraph)),
              ],
            ),
            UiSectionLabel(text: l10n.backup_section_backup, padding: const EdgeInsets.fromLTRB(4, 24, 4, 8)),
            UiGroupCard(
              children: [
                _ActionRow(
                  icon: UIIconToken.icons.security.fileShield02,
                  title: l10n.backup_create,
                  subtitle: l10n.backup_create_desc,
                  busy: task == BackupTask.create,
                  enabled: !busy,
                  onTap: (_) => CreateBackupSheet.show(context),
                ),
                _ActionRow(
                  icon: UIIconToken.icons.files.fileDownload02,
                  title: l10n.backup_restore,
                  subtitle: l10n.backup_restore_desc,
                  busy: task == BackupTask.open || task == BackupTask.restore,
                  enabled: !busy,
                  onTap: (_) => restoreFromFile(),
                ),
                if (undoDate != null)
                  _ActionRow(
                    icon: UIIconToken.icons.time.clockRewind,
                    title: l10n.backup_undo,
                    subtitle: l10n.backup_undo_desc(backupDateLabel(undoDate)),
                    enabled: !busy,
                    onTap: (_) => undoRestore(),
                  ),
              ],
            ),
            UiSectionLabel(text: l10n.backup_section_spreadsheet, padding: const EdgeInsets.fromLTRB(4, 24, 4, 8)),
            UiGroupCard(
              children: [
                _ActionRow(
                  icon: UIIconToken.icons.loyout.table,
                  title: l10n.backup_csv,
                  subtitle: l10n.backup_csv_desc,
                  busy: task == BackupTask.csv,
                  enabled: !busy,
                  onTap: exportCsv,
                ),
              ],
            ),
            const UISpace.vert(10),
            UiFormHint(
              text: l10n.backup_csv_hint,
              icon: UIIconToken.icons.alertsFeedback.alertTriangle,
              color: UIColorToken.buttercup,
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon, title, two-line explanation; chevron or spinner on the right.
/// [onTap] gets the row's rect (iPad share popover anchor).
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
    this.enabled = true,
  });

  final String icon;
  final String title;
  final String subtitle;
  final ValueChanged<Rect?> onTap;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return AnimatedOpacity(
      duration: UIAnim.fast,
      opacity: enabled || busy ? 1 : 0.45,
      child: UITap(
        onTap: enabled
            ? () {
                AppVibrations.selection();
                final box = context.findRenderObject() as RenderBox?;
                onTap(box == null ? null : box.localToGlobal(Offset.zero) & box.size);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: UIColorToken.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: UIIcon(icon, size: 18, color: UIColorToken.blue),
              ),
              const UISpace.horz(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.listTitle),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: typo.caption),
                  ],
                ),
              ),
              const UISpace.horz(12),
              SizedBox(
                width: 20,
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: UIColorToken.blue),
                      )
                    : UIIcon(UIIconToken.icons.arrows.chevronRight, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
