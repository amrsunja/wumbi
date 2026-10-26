import 'package:flutter/foundation.dart';

import '../../../core/design_system/app_ui.dart';
import '../../../core/locale/l10n.dart';
import '../domain/mascot_message.dart';
import '../domain/mascot_screens.dart';
import 'mascot_answers.dart';
import 'mascot_phrases.dart';

/// The little chat on the stage. The hamster opens with the screen's line
/// (playing its story beats by itself, each with its emotion), then the
/// user picks quick replies and it answers — its emotion always follows
/// what it says.
class MascotConversation extends ValueNotifier<UiMascotStageState> {
  MascotConversation({
    required this.l10n,
    required this.opening,
    required List<MascotQuestion> questions,
    required this.answer,
    required this.runAction,
    required this.speaks,
  })  : _pool = [...questions],
        super(UiMascotStageState(mood: opening.mood));

  final AppLocale l10n;
  final MascotCornerState opening;
  final Future<MascotAnswer> Function(MascotQuestion) answer;
  final void Function(MascotAction) runAction;

  /// Settings → "Wumbi talks" off: emotions only, no chat.
  final bool speaks;

  /// Quick replies shown at once.
  static const int visibleReplies = 3;
  static const Duration typing = Duration(milliseconds: 850);

  /// How long a face holds before it settles into its `afterMood`.
  static const Duration settle = Duration(milliseconds: 2500);

  final List<MascotQuestion> _pool;
  final List<UiMascotLine> _lines = [];
  late WumbiMood _mood = opening.mood;
  int _nextId = 0;

  /// Bumped on every new line: a pending settle never overrides a newer face.
  int _said = 0;
  bool _busy = false;
  bool _disposed = false;

  /// Says the opening line, then its story beats one by one.
  Future<void> start() async {
    if (!speaks) {
      _emit();
      return;
    }
    _busy = true;
    _say(opening.mood, opening.line, opening.action);
    for (final step in opening.steps) {
      await _think(typing);
      if (_disposed) return;
      _say(step.mood, step.line, step.action);
    }
    _busy = false;
    _emit();
    _settleLater(opening.afterMood);
  }

  /// The user taps a quick reply.
  Future<void> ask(MascotQuestion q) async {
    if (_busy || _disposed) return;
    _busy = true;
    // Tips and jokes can be asked again (they go to the back of the line).
    _pool.remove(q);
    if (q == MascotQuestion.tip || q == MascotQuestion.joke) _pool.add(q);
    _lines.add(UiMascotLine(id: _nextId++, text: MascotPhrases.question(l10n, q), fromUser: true));
    _emit();

    final started = DateTime.now();
    final typingId = _nextId++;
    _lines.add(UiMascotLine(id: typingId, typing: true));
    _emit();
    MascotAnswer reply;
    try {
      reply = await answer(q);
    } catch (_) {
      reply = const MascotAnswer(WumbiMood.shrug, MascotLine(MascotPhrase.ansReserveUnknown));
    }
    final waited = DateTime.now().difference(started);
    if (waited < typing) await Future<void>.delayed(typing - waited);
    if (_disposed) return;
    _lines.removeWhere((l) => l.id == typingId);
    _busy = false;
    _say(reply.mood, reply.line, reply.action);
    _settleLater(reply.afterMood);
  }

  /// Switches to [mood] after [settle], unless something newer was said.
  void _settleLater(WumbiMood? mood) {
    if (mood == null) return;
    final said = _said;
    Future<void>.delayed(settle, () {
      if (_disposed || said != _said) return;
      _mood = mood;
      _emit();
    });
  }

  Future<void> _think(Duration d) async {
    final id = _nextId++;
    _lines.add(UiMascotLine(id: id, typing: true));
    _emit();
    await Future<void>.delayed(d);
    _lines.removeWhere((l) => l.id == id);
  }

  void _say(WumbiMood mood, MascotLine? line, MascotAction? action) {
    _said++;
    _mood = mood;
    if (line != null) {
      _lines.add(UiMascotLine(
        id: _nextId++,
        text: MascotPhrases.text(l10n, line),
        actionLabel: MascotPhrases.actionLabel(l10n, action),
        onAction: action == null ? null : () => runAction(action),
      ));
    }
    _emit();
  }

  void _emit() {
    if (_disposed) return;
    value = UiMascotStageState(
      mood: _mood,
      lines: List.unmodifiable(_lines),
      replies: !speaks || _busy
          ? const []
          : [
              for (final q in _pool.take(visibleReplies))
                UiMascotReply(label: MascotPhrases.question(l10n, q), onTap: () => ask(q)),
            ],
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
