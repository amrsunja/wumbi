import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import '../../errors/failures/failures.dart';
import '../../locale/l10n.dart';

abstract class SingleEvent {
  const SingleEvent();
}

class ShowSuccessMessageEvent extends SingleEvent {
  final String message;
  const ShowSuccessMessageEvent(this.message);
}

class ShowInfoMessageEvent extends SingleEvent {
  final String message;
  const ShowInfoMessageEvent(this.message);
}

class ShowErrorEvent extends SingleEvent {
  final Failure? error;
  final String defaultMessage;
  const ShowErrorEvent(this.error, {this.defaultMessage = ''});

  String message(AppLocale locale) => error?.toMessage(locale) ?? defaultMessage;
}

/// Snackbar with an action ("Transaction deleted — Undo").
class ShowUndoEvent extends SingleEvent {
  final String message;
  final String actionLabel;
  final VoidCallback onUndo;
  const ShowUndoEvent(this.message, {required this.actionLabel, required this.onUndo});
}

// Navigation EVENTS -----------------
class NavigateRouteEvent extends SingleEvent {
  final String routePath;
  const NavigateRouteEvent(this.routePath);
}

class PushRouteEvent extends SingleEvent {
  final String routePath;
  const PushRouteEvent(this.routePath);
}

class ReplaceRouteEvent extends SingleEvent {
  final String routePath;
  const ReplaceRouteEvent(this.routePath);
}

class PushRouteInfoEvent extends SingleEvent {
  final PageRouteInfo<Object?> route;
  const PushRouteInfoEvent(this.route);
}

class ReplaceAllRoutesEvent extends SingleEvent {
  final List<PageRouteInfo<Object?>> routes;
  const ReplaceAllRoutesEvent(this.routes);
}

class PopRouteEvent extends SingleEvent {
  final int times;
  const PopRouteEvent({this.times = 1});
}
