import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/design_system/app_ui.dart';

/// The hamster's face in a notification. The OS cannot read Flutter assets,
/// so every mood ships as a 256 px PNG (rendered from the same SVGs as the
/// in-app mascot) and is copied to a real file on first use.
///
/// * Android `largeIcon` reads a path at delivery time → one shared file per
///   mood, reused forever.
/// * iOS *moves* an attachment into its own store when the request is
///   added → one throwaway copy per scheduled notification.
class NotificationArt {
  NotificationArt({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;

  static String assetOf(WumbiMood mood) => 'assets/mascot/notification/${mood.name}.png';

  Future<Directory> _dir(String name) async {
    final root = await _directory();
    final dir = Directory('${root.path}/notification_art/$name');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _write(WumbiMood mood, File file) async {
    final data = await rootBundle.load(assetOf(mood));
    await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
  }

  /// Stable path, written once (Android).
  Future<String?> shared(WumbiMood mood) async {
    try {
      final file = File('${(await _dir('shared')).path}/${mood.name}.png');
      if (!file.existsSync()) await _write(mood, file);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Fresh copy for one request (iOS).
  Future<String?> single(WumbiMood mood, int id) async {
    try {
      final file = File('${(await _dir('single')).path}/$id-${mood.name}.png');
      await _write(mood, file);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Copies left behind by requests that were cancelled before iOS took them.
  Future<void> clearSingles() async {
    try {
      final dir = await _dir('single');
      for (final f in dir.listSync()) {
        if (f is File) f.deleteSync();
      }
    } catch (_) {}
  }
}
