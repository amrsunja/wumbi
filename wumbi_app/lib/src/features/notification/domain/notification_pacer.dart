import 'notification_kind.dart';
import 'notification_message.dart';
import 'notification_planner.dart';

/// One platform notification: the winning message of a slot and how many
/// other money matters wait inside the app.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.fireAt,
    required this.slot,
    required this.message,
    this.extraCount = 0,
  });

  /// Stable per day × slot.
  final int id;
  final DateTime fireAt;
  final NotificationSlot slot;
  final NotificationMessage message;
  final int extraCount;
}

/// drafts → at most one notification per slot (2 a day max), never in the
/// past, never at night. Pure.
abstract class NotificationPacer {
  /// Far under iOS's 64 pending requests.
  static const int maxPending = 40;

  static List<ScheduledNotification> pace(
    List<NotificationDraft> drafts, {
    required DateTime now,
    required NotificationTimes times,
  }) {
    final earliest = now.add(const Duration(minutes: 1));
    final today = NotificationPlanner.dayOf(now);
    final groups = <int, ({DateTime at, NotificationSlot slot, List<NotificationMessage> items})>{};

    for (final d in drafts) {
      var slot = d.message.kind.slot;
      var at = times.at(d.day, slot);
      if (!at.isAfter(earliest) &&
          d.message.kind.lateFallback &&
          slot == NotificationSlot.morning &&
          d.day == today) {
        slot = NotificationSlot.evening;
        at = times.at(d.day, slot);
      }
      if (!at.isAfter(earliest)) continue;
      final id = _epochDay(d.day) * NotificationSlot.values.length + slot.index;
      groups.putIfAbsent(id, () => (at: at, slot: slot, items: <NotificationMessage>[])).items.add(d.message);
    }

    final out = <ScheduledNotification>[];
    groups.forEach((id, g) {
      // Same thing planned twice for one slot counts once.
      final unique = <String, NotificationMessage>{};
      for (final m in g.items) {
        final current = unique[m.key];
        if (current == null || m.priority > current.priority) unique[m.key] = m;
      }
      final list = unique.values.toList()..sort((a, b) => b.priority.compareTo(a.priority));
      final main = list.first;
      out.add(ScheduledNotification(
        id: id,
        fireAt: g.at,
        slot: g.slot,
        message: main,
        extraCount: list.skip(1).where((m) => m.kind.isMoney).length,
      ));
    });
    out.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    return out.length > maxPending ? out.sublist(0, maxPending) : out;
  }

  static int _epochDay(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}
