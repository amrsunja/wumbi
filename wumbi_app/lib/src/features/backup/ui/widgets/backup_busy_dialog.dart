import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Blocking progress card for work the user must not interrupt (checking or
/// restoring a backup): no barrier dismiss, no back gesture.
abstract class BackupBusyDialog {
  static Future<T> run<T>(BuildContext context, String message, Future<T> Function() task) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    var open = true;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: UIColorToken.overlay,
      builder: (_) => PopScope(canPop: false, child: _BusyCard(message: message)),
    ).whenComplete(() => open = false);
    try {
      return await task();
    } finally {
      if (open) navigator.pop();
    }
  }
}

class _BusyCard extends StatelessWidget {
  const _BusyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.fgColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: UIColorToken.blue),
            ),
            const UISpace.vert(16),
            Text(message, textAlign: TextAlign.center, style: context.typo.inter.paragraph),
          ],
        ),
      ),
    );
  }
}
