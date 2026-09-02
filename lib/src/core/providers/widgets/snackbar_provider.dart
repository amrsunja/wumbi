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

  void showSuccess(String message, {Duration duration = const Duration(milliseconds: 1500)}) =>
      _show(UiToast(message: message, kind: UiToastKind.success), duration);

  void showInfo(String message, {Duration duration = const Duration(milliseconds: 1500)}) =>
      _show(UiToast(message: message, kind: UiToastKind.info), duration);

  void showError(String message, {Duration duration = const Duration(milliseconds: 2500)}) =>
      _show(UiToast(message: message, kind: UiToastKind.error), duration);

  /// "Transaction deleted — Undo" for 4 s.
  void showUndo(
    String message, {
    required String actionLabel,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      UiToast(
        message: message,
        kind: UiToastKind.info,
        actionLabel: actionLabel,
        onAction: () {
          hide();
          onUndo();
        },
      ),
      duration,
    );
  }
}
