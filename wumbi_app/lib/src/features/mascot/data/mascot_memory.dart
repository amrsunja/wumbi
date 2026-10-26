import 'dart:convert';

import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../core/local/database/sqlite/sqlite_config.dart';
import '../../../core/local/database/sqlite/sqlite_services.dart';
import '../domain/mascot_message.dart';

/// When a meaning was last said and on which data.
class MascotShown {
  const MascotShown(this.hash, this.at);

  final String hash;
  final DateTime at;
}

/// What the hamster remembers, locally (spec §3.5): visits, what it already
/// said (id + data hash + when), milestones reached and "quiet today".
class MascotMemory {
  const MascotMemory({
    this.lastVisitAt,
    this.prevVisitAt,
    this.shown = const {},
    this.milestones = const {},
    this.quietDay,
  });

  /// Start of the current session.
  final DateTime? lastVisitAt;

  /// Start of the session before — "since your last visit" counts from here.
  final DateTime? prevVisitAt;
  final Map<String, MascotShown> shown;

  /// One-off events already celebrated (message ids).
  final Set<String> milestones;

  /// `yyyy-mm-dd` of a long-press "keep quiet today".
  final String? quietDay;

  /// Entries older than this are forgotten (longest cooldown is 14 days).
  static const Duration retention = Duration(days: 90);

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isQuiet(DateTime now) => quietDay == dayKey(now);

  /// Whether [m] may be said now: warnings and the summary always (they hold
  /// while true), events once ever, the rest once per data hash unless their
  /// cooldown has passed.
  bool isEligible(MascotMessage m, DateTime now) {
    switch (m.tier) {
      case MascotTier.reaction:
      case MascotTier.warning:
      case MascotTier.summary:
        return true;
      case MascotTier.event:
        return !milestones.contains(m.id);
      case MascotTier.sinceVisit:
      case MascotTier.insight:
      case MascotTier.tip:
      case MascotTier.joke:
      case MascotTier.greeting:
        final last = shown[m.id];
        if (last == null || last.hash != m.hash) return true;
        final cooldown = m.cooldown;
        return cooldown != null && now.difference(last.at) >= cooldown;
    }
  }

  MascotMemory visited(DateTime now) => _copy(prevVisitAt: lastVisitAt, lastVisitAt: now);

  MascotMemory markShown(MascotMessage m, DateTime now) => _copy(
        shown: {
          for (final e in shown.entries)
            if (now.difference(e.value.at) < retention) e.key: e.value,
          m.id: MascotShown(m.hash, now),
        },
        milestones: m.tier == MascotTier.event ? {...milestones, m.id} : milestones,
      );

  MascotMemory quietToday(DateTime now) => _copy(quietDay: dayKey(now));

  MascotMemory _copy({
    DateTime? lastVisitAt,
    DateTime? prevVisitAt,
    Map<String, MascotShown>? shown,
    Set<String>? milestones,
    String? quietDay,
  }) =>
      MascotMemory(
        lastVisitAt: lastVisitAt ?? this.lastVisitAt,
        prevVisitAt: prevVisitAt ?? this.prevVisitAt,
        shown: shown ?? this.shown,
        milestones: milestones ?? this.milestones,
        quietDay: quietDay ?? this.quietDay,
      );

  Map<String, Object?> toJson() => {
        'lastVisitAt': lastVisitAt?.millisecondsSinceEpoch,
        'prevVisitAt': prevVisitAt?.millisecondsSinceEpoch,
        'shown': {
          for (final e in shown.entries) e.key: {'h': e.value.hash, 'at': e.value.at.millisecondsSinceEpoch},
        },
        'milestones': milestones.toList(),
        'quietDay': quietDay,
      };

  factory MascotMemory.fromJson(Map<String, Object?> json) {
    DateTime? time(Object? v) => v is int ? DateTime.fromMillisecondsSinceEpoch(v) : null;
    final shown = <String, MascotShown>{};
    final rawShown = json['shown'];
    if (rawShown is Map) {
      for (final e in rawShown.entries) {
        final v = e.value;
        if (v is Map && v['h'] is String && v['at'] is int) {
          shown['${e.key}'] = MascotShown(v['h'] as String, DateTime.fromMillisecondsSinceEpoch(v['at'] as int));
        }
      }
    }
    final rawMilestones = json['milestones'];
    return MascotMemory(
      lastVisitAt: time(json['lastVisitAt']),
      prevVisitAt: time(json['prevVisitAt']),
      shown: shown,
      milestones: rawMilestones is List ? {for (final m in rawMilestones) '$m'} : const {},
      quietDay: json['quietDay'] as String?,
    );
  }
}

/// One JSON row in `mascot_memory` (key `memory`).
class MascotMemoryStore {
  const MascotMemoryStore(this.sqlite);

  final SQLiteServices sqlite;

  static const _key = 'memory';

  Future<MascotMemory> load() async {
    final rows = await sqlite.db.query(
      SQLiteConfig.mascotMemoryTable,
      where: '${SQLiteConfig.mascotKey} = ?',
      whereArgs: [_key],
      limit: 1,
    );
    if (rows.isEmpty) return const MascotMemory();
    try {
      final decoded = jsonDecode(rows.first[SQLiteConfig.mascotValue] as String);
      return decoded is Map<String, Object?> ? MascotMemory.fromJson(decoded) : const MascotMemory();
    } catch (_) {
      return const MascotMemory();
    }
  }

  Future<void> save(MascotMemory memory) async {
    await sqlite.db.insert(
      SQLiteConfig.mascotMemoryTable,
      {
        SQLiteConfig.mascotKey: _key,
        SQLiteConfig.mascotValue: jsonEncode(memory.toJson()),
        SQLiteConfig.updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
