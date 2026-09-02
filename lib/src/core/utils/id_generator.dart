import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// UUID v4 primary keys — generated in Dart, never by SQLite.
String newId() => _uuid.v4();
