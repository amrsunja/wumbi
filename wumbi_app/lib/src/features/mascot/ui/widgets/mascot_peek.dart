import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../settings/ui/state_management/settings_provider.dart';
import '../../domain/mascot_brain.dart';
import '../../domain/mascot_message.dart';
import '../../domain/mascot_screens.dart';
import '../mascot_actions.dart';
import '../mascot_answers.dart';
import '../mascot_conversation.dart';
import 'use_mascot_reaction.dart';

/// Counts every time a hamster slides into a corner: screens with a pool of
/// lines show the next one on each visit.
int _visits = 0;

/// A page with the hamster peeking from its bottom-start corner. Wrap the
/// page's `Scaffold`. [states]: the page's important state alone, or its
/// calm state followed by tips — one is picked per visit. Null (still
/// loading) or [hidden] (the page shows its own big empty-state hamster)
/// leaves the corner empty.
class MascotPeekLayer extends StatelessWidget {
  const MascotPeekLayer({
    super.key,
    required this.child,
    required this.states,
    this.hidden = false,
    this.questions = MascotQuestions.dashboard,
    this.onReturn,
  });

  final Widget child;
  final List<MascotCornerState>? states;
  final bool hidden;

  /// Quick replies offered on the stage, in this order.
  final List<MascotQuestion> questions;

  /// The page came back on top (dashboard: the hamster moves on).
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final s = states;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (s != null && s.isNotEmpty)
          PositionedDirectional(
            start: 8,
            bottom: 0,
            child: MascotPeek(states: s, hidden: hidden, questions: questions, onReturn: onReturn),
          ),
      ],
    );
  }
}

/// The screen's hamster: its head peeks from the corner with the emotion
/// of what it wants to say and slides up again whenever the page comes back
/// on top. A little story (impatient → sad …) plays on the head by itself.
/// Tap → it steps out over everything and talks ([UiMascotStage]): its
/// line, then the user's quick replies. Tap outside → back to the corner.
/// The emotion only ever changes with what it says or does — never on a
/// tap. Reactions to what the user just saved play here (2.5 s, raised).
class MascotPeek extends HookConsumerWidget {
  const MascotPeek({
    super.key,
    required this.states,
    this.hidden = false,
    this.questions = MascotQuestions.dashboard,
    this.onReturn,
  });

  final List<MascotCornerState> states;
  final bool hidden;
  final List<MascotQuestion> questions;
  final VoidCallback? onReturn;

  static const Duration beat = Duration(milliseconds: 2400);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showMascot = ref.watch(showMascotProvider);
    final speaks = ref.watch(mascotTalksProvider);
    final reaction = useMascotReaction(ref, context);
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;

    final replay = useState(0);
    final visit = useState<int>(useMemoized(() => _visits++));
    final wasCurrent = useRef(isCurrent);
    final out = useState(false);
    final heard = useState(false);
    final beatIndex = useState(0);
    final handle = useRef<UiMascotStageHandle?>(null);
    final talk = useRef<MascotConversation?>(null);

    // Back on top after a navigation → the head slides up again, with the
    // next line of the pool.
    useEffect(() {
      if (isCurrent && !wasCurrent.value) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          replay.value++;
          visit.value = _visits++;
          onReturn?.call();
        });
      }
      wasCurrent.value = isCurrent;
      return null;
    }, [isCurrent]);

    // The page goes away while the hamster is out: no stage left behind.
    useEffect(
      () => () {
        handle.value?.close(immediately: true);
        talk.value?.dispose();
      },
      const [],
    );

    final first = states.first;
    final state = first.auto ? first : states[visit.value % states.length];

    // A new line → the dot comes back, and its story replays on the head.
    useEffect(() {
      heard.value = false;
      beatIndex.value = 0;
      return null;
    }, [state.signature]);
    final moods = state.moods;
    useEffect(() {
      if (moods.length < 2 || out.value) return null;
      beatIndex.value = 0;
      final timers = <Timer>[
        for (var i = 1; i < moods.length; i++)
          Timer(UiMascotPeek.enterDelay + beat * i, () {
            if (context.mounted) beatIndex.value = i;
          }),
      ];
      return () {
        for (final t in timers) {
          t.cancel();
        }
      };
    }, [state.signature, replay.value, out.value]);

    if (!showMascot) return const SizedBox.shrink();

    final beatMood = moods[beatIndex.value.clamp(0, moods.length - 1).toInt()];

    void open() {
      if (handle.value?.isOpen ?? false) return;
      AppVibrations.selection();
      heard.value = true;
      out.value = true;
      final conversation = MascotConversation(
        l10n: l10n,
        opening: state,
        questions: questions,
        speaks: speaks,
        answer: MascotAnswers(ref).answer,
        runAction: (action) {
          handle.value?.close();
          runMascotAction(context, ref, action);
        },
      );
      talk.value = conversation;
      handle.value = UiMascotStage.show(
        context,
        state: conversation,
        dismissLabel: l10n.mascot_dismiss,
        onClosed: () {
          handle.value = null;
          talk.value = null;
          conversation.dispose();
          if (context.mounted) out.value = false;
        },
      );
      conversation.start();
    }

    return UiMascotPeek(
      mood: reaction != null ? MascotBrain.reaction(reaction, null).mood : beatMood,
      raised: reaction != null,
      hidden: hidden || out.value,
      replay: replay.value,
      badge: state.auto && state.line != null && speaks && !heard.value,
      semanticLabel: l10n.mascot_label,
      onTap: hidden ? null : open,
    );
  }
}
