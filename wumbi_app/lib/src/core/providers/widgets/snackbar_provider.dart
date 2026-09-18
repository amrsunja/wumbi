import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../design_system/app_ui.dart';
import '../routing/navigation_services_provider.dart';

final snackbarProvider = Provider(SnackbarProvider.new);

/// Top toasts (spec: "snackbar") rendered in the root navigator's [Overlay].
/// One toast at a time — a new one replaces the current instantly.
class SnackbarProvider {
  SnackbarProvider(Ref ref) : _ref = ref;

  final Ref _ref;

  OverlayEntry? _entry;
  GlobalKey<UiToastOverlayState>? _key;

  OverlayState? get _overlay => _ref.read(navigationServicesProvider).router.navigatorKey.currentState?.overlay;

  void _show(UiToast toast, Duration duration) {
    final overlay = _overlay;
    if (overlay == null) return;
    _removeNow();
    final key = GlobalKey<UiToastOverlayState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => UiToastOverlay(
        key: key,
        duration: duration,
        onDismissed: () {
          if (_entry == entry) {
            _entry = null;
            _key = null;
          }
          if (entry.mounted) entry.remove();
        },
        child: toast,
      ),
    );
    _entry = entry;
    _key = key;
    overlay.insert(entry);
  }

  void _removeNow() {
    final e = _entry;
    _entry = null;
    _key = null;
    if (e != null && e.mounted) e.remove();
  }

  /// Animated dismiss of the current toast (if any).
  void hide() {
    final state = _key?.currentState;
    if (state != null) {
      state.dismiss();
    } else {
      _removeNow();
    }
  }

  /// A toast carrying an action stays up long enough to be hit: 4 s instead
  /// of the 1.5 s a read-only confirmation gets. Tapping it always closes the
  /// toast first, so the action's own toast is the one left on screen.
  void _showWith(UiToastKind kind, String message, String? actionLabel, VoidCallback? onAction, Duration? duration) {
    final hasAction = actionLabel != null && onAction != null;
    _show(
      UiToast(
        message: message,
        kind: kind,
        actionLabel: hasAction ? actionLabel : null,
        onAction: hasAction
            ? () {
                hide();
                onAction();
              }
            : null,
      ),
      duration ?? (hasAction ? const Duration(seconds: 4) : const Duration(milliseconds: 1500)),
    );
  }

  void showSuccess(String message, {String? actionLabel, VoidCallback? onAction, Duration? duration}) =>
      _showWith(UiToastKind.success, message, actionLabel, onAction, duration);

  void showInfo(String message, {String? actionLabel, VoidCallback? onAction, Duration? duration}) =>
      _showWith(UiToastKind.info, message, actionLabel, onAction, duration);

  void showError(String message, {Duration duration = const Duration(milliseconds: 2500)}) =>
      _show(UiToast(message: message, kind: UiToastKind.error), duration);

  /// "Transaction deleted — Undo" for 4 s.
  void showUndo(
    String message, {
    required String actionLabel,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) =>
      _showWith(UiToastKind.info, message, actionLabel, onUndo, duration);
}
