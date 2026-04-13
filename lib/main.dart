import 'dart:async';

import 'package:fiin/src/src/core/utils/constants/constants.dart';
import 'package:fiin/src/src/core/utils/screen_rotation.dart';
import 'package:flutter/material.dart';

import 'src/config/app_config.dart';
import 'src/config/app_runner.dart';

void main() {
	runZonedGuarded<Future<void>>(
		() async {
			WidgetsFlutterBinding.ensureInitialized();

			// App configuration
			AppConfig.create(
				appName: kAppName,
        showDebugBanner: false
			);

			// Lock screen rotation
			ScreenRotation.toPortrait();

  		AppRunner.runApplication();

		}, (error, stack) {

		}
	);
}
