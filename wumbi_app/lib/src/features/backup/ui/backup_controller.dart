import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failures/failures.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/providers/data/db_revision_provider.dart';
import '../../../core/utils/state_management/app_events.dart';
import '../../../core/utils/state_management/single_events.dart';
import '../../../core/utils/typedefs.dart';
import '../../settings/ui/state_management/settings_provider.dart';
import '../data/backup_codec.dart';
import '../data/backup_repository.dart';
import 'backup_file_delivery.dart';

/// What the Backup page is busy with (rows show a spinner, all are locked).
enum BackupTask { create, csv, open, restore }

final backupControllerProvider = NotifierProvider<BackupController, BackupTask?>(BackupController.new);

/// When the undo point was taken (null = nothing to undo).
final safetySnapshotDateProvider = FutureProvider.autoDispose<DateTime?>((ref) {
  ref.watch(dbRevisionProvider);
  return ref.read(backupRepositoryProvider).safetySnapshotDate();
});

/// Runs one backup operation at a time. Methods return null when another
/// one is running (or the user cancelled), otherwise the repository result —
/// the page decides how to show errors in context.
class BackupController extends Notifier<BackupTask?> {
  @override
  BackupTask? build() => null;

  BackupRepository get _repo => ref.read(backupRepositoryProvider);

  Future<SuccessOrError<T>?> _run<T>(BackupTask task, Future<SuccessOrError<T>?> Function() call) async {
    if (state != null) return null;
    state = task;
    try {
      return await call();
    } finally {
      state = null;
    }
  }

  Future<SuccessOrError<ExportedFile>?> createBackup({String? password}) =>
      _run(BackupTask.create, () => _repo.createBackup(password: password));

  Future<SuccessOrError<ExportedFile>?> createCsv() => _run(BackupTask.csv, _repo.createCsv);

  /// System file picker → recognised backup envelope.
  Future<SuccessOrError<BackupEnvelope>?> pickBackup() => _run(BackupTask.open, () async {
    final picked = await Failure.exceptionsCatcher(BackupFileDelivery.pick);
    return picked.when(
      (file) => file == null ? Future.value(null) : _repo.readBackup(file.bytes, fileName: file.name),
      (error) => Future.value(SuccessOrError<BackupEnvelope>.error(error)),
    );
  });

  Future<SuccessOrError<BackupPreview>?> openBackup(BackupEnvelope envelope, {String? password}) =>
      _run(BackupTask.open, () => _repo.openBackup(envelope, password: password));

  Future<SuccessOrError<BackupPreview>?> openSafetySnapshot() => _run(BackupTask.open, _repo.openSafetySnapshot);

  Future<SuccessOrError<void>?> restore(BackupPreview preview) =>
      _run(BackupTask.restore, () => _repo.restore(preview));

  /// After a successful [restore]: the whole app re-reads the new data and
  /// opens on the dashboard.
  Future<void> finishRestore({required bool undo}) async {
    final l10n = ref.read(l10nProvider);
    await ref.read(settingsProvider.notifier).reloadAfterRestore();
    ref.read(appEventProvider).send(ShowSuccessMessageEvent(undo ? l10n.backup_undo_done : l10n.backup_restored));
  }
}
