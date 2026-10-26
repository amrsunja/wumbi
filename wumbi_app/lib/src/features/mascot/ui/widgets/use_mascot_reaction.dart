import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/mascot_reaction.dart';
import '../mascot_providers.dart';

/// The reaction this slot is playing, if any (spec §1.4): a pending action
/// is taken by the first mascot slot whose route is on top — the screen the
/// user came back to — and played for [MascotReaction.playFor].
MascotReaction? useMascotReaction(WidgetRef ref, BuildContext context) {
  final pending = ref.watch(mascotReactionProvider);
  final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
  final playing = useState<MascotReaction?>(null);

  useEffect(() {
    if (pending == null || !isCurrent) return null;
    var cancelled = false;
    Future.microtask(() {
      if (cancelled || !context.mounted) return;
      if (ref.read(mascotReactionProvider.notifier).consume(pending) && pending.isFresh(DateTime.now())) {
        playing.value = pending;
      }
    });
    return () {
      cancelled = true;
    };
  }, [pending, isCurrent]);

  final current = playing.value;
  useEffect(() {
    if (current == null) return null;
    final timer = Timer(MascotReaction.playFor, () => playing.value = null);
    return timer.cancel;
  }, [current]);

  return current;
}
