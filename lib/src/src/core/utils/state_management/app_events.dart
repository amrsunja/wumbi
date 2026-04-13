import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'mixins.dart';

final appEventProvider = Provider((ref) => AppEvents());

class AppEvents with SingleEventMixin {
	AppEvents() : super();
}
