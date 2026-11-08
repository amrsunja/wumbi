import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/errors/exceptions/domain/domain_exceptions.dart';
import '../data/backup_codec.dart';
import '../data/backup_repository.dart';

/// Gets files in and out of the app through the system UI only: no storage
/// permission is needed and Wumbi never sees the rest of the file system.
abstract class BackupFileDelivery {
  /// The system "save" dialog (Files on iOS, the document picker on
  /// Android). True when the user saved it.
  static Future<bool> save(ExportedFile file) async {
    try {
      final uri = await FilePicker.saveFile(fileName: file.fileName, bytes: file.bytes, mimeType: file.mimeType);
      return uri != null;
    } finally {
      // On iOS the plugin stages the bytes in NSTemporaryDirectory() under
      // the same name and leaves them there; the export dialog has made its
      // own copy by now, so nothing of the backup stays inside the app.
      if (Platform.isIOS) {
        try {
          // `Directory.systemTemp` is TMPDIR = NSTemporaryDirectory() (path_provider's
          // temp directory is Caches on iOS).
          final staged = File('${Directory.systemTemp.path}${Platform.pathSeparator}${file.fileName}');
          if (await staged.exists()) await staged.delete();
        } catch (_) {}
      }
    }
  }

  /// The share sheet (AirDrop, mail, cloud drives…). The file only exists
  /// in a private temp folder for the duration of the share. [origin]
  /// anchors the popover on iPad.
  static Future<void> share(ExportedFile file, {Rect? origin}) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}${Platform.pathSeparator}wumbi_export');
    // Leftovers of an interrupted share.
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    final temp = File('${dir.path}${Platform.pathSeparator}${file.fileName}');
    try {
      await temp.writeAsBytes(file.bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(temp.path, mimeType: file.mimeType, name: file.fileName)],
          sharePositionOrigin: origin,
        ),
      );
    } finally {
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  }

  /// Lets the user choose a file to restore. Null when cancelled. The
  /// picker's own temporary copy is removed right after reading.
  static Future<({String name, Uint8List bytes})?> pick() async {
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return null;
    try {
      final length = await file.length();
      if (length != null && length > BackupFormat.maxFileBytes) {
        throw const BackupException(BackupErrorReason.tooLarge);
      }
      return (name: file.name, bytes: await file.readAsBytes());
    } finally {
      try {
        await FilePicker.clearTemporaryFiles();
      } catch (_) {}
    }
  }
}
