import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'mixins.dart';
import 'single_events.dart';

final appEventProvider = Provider((ref) => AppEvents());

/// App-wide single-shot effects (snackbars, navigation). Notifiers `send`
/// events; `App` listens and performs them.
class AppEvents with SingleEventMixin<SingleEvent> {
  AppEvents();
}
