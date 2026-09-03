class AppConfig {
	String appName = '';
	bool showDebugBanner;

	static const String appVersion = '1.0.0';

	AppConfig(
		this.appName, {
		required this.showDebugBanner,
	});

  factory AppConfig.create({
    String appName = 'Wumbi',
    bool showDebugBanner = false,
  }) => shared = AppConfig(
		appName,
		showDebugBanner: showDebugBanner,
	);

	static AppConfig shared = AppConfig.create();
}
