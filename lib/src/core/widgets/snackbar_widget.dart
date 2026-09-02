import 'package:flutter/material.dart';

import '../design_system/app_ui.dart';

class AppSnackbarWidget extends SnackBar {
  AppSnackbarWidget.sucess(String message, {super.key, super.duration})
      : super(
          content: UIAlert.success(label: message),
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
        );

  AppSnackbarWidget.info(
    String message, {
    super.key,
    super.duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) : super(
          content: UIAlert.info(label: message, actionLabel: actionLabel, onAction: onAction),
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
        );

  AppSnackbarWidget.error(String message, {super.key, super.duration})
      : super(
          content: UIAlert.error(label: message),
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
        );
}
