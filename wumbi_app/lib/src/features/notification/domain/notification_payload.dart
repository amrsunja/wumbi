import 'package:collection/collection.dart';

import '../../mascot/domain/mascot_message.dart';

/// A notification's tap target travels through the OS as a string:
/// `openDebt|<id>`, `addTransaction`, …
abstract class NotificationPayload {
  static const String _sep = '|';

  static String encode(MascotAction action) {
    final id = action.id;
    return id == null ? action.kind.name : '${action.kind.name}$_sep$id';
  }

  /// Null for an unknown / missing payload (then the app just opens).
  static MascotAction? decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    final i = payload.indexOf(_sep);
    final name = i < 0 ? payload : payload.substring(0, i);
    final kind = MascotActionKind.values.firstWhereOrNull((k) => k.name == name);
    if (kind == null) return null;
    final id = i < 0 ? null : payload.substring(i + 1);
    return MascotAction(kind, id == null || id.isEmpty ? null : id);
  }
}
