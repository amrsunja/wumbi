import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/config/app_config.dart';
import 'src/config/app_runner.dart';
import 'src/core/utils/constants/constants.dart';
import 'src/core/utils/screen_rotation.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      AppConfig.create(appName: kAppName, showDebugBanner: false);

      // Lock screen rotation
      ScreenRotation.toPortrait();

      AppRunner.runApplication();
    },
    (error, stack) {
      if (kDebugMode) debugPrint('Uncaught: $error\n$stack');
    },
  );
}
