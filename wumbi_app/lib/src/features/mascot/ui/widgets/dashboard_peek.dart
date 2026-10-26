import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/mascot_screens.dart';
import '../mascot_answers.dart';
import '../mascot_providers.dart';
import 'mascot_peek.dart';

/// Dashboard: the hamster interprets the numbers (spec §4.3). Its thought
/// follows [mascotDashboardProvider] — a new one each session and each time
/// the dashboard comes back on top — with the emotion that belongs to it.
class DashboardPeekLayer extends ConsumerWidget {
  const DashboardPeekLayer({super.key, required this.child, this.hidden = false});

  final Widget child;
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(mascotDashboardProvider);
    return MascotPeekLayer(
      states: message == null ? null : [MascotCornerState.of(message)],
      hidden: hidden,
      questions: MascotQuestions.dashboard,
      onReturn: () => ref.read(mascotDashboardProvider.notifier).rotate(),
      child: child,
    );
  }
}
