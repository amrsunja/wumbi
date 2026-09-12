part of '../app_ui.dart';

class AppTheme extends InheritedWidget {
  const AppTheme({
		super.key,
		required this.data,
		required super.child,
	});

	final AppThemeData data;

	/// Return GThemeData
	static AppThemeData of(BuildContext context)
		=> context.dependOnInheritedWidgetOfExactType<AppTheme>()!.data;

  @override
  bool updateShouldNotify(covariant AppTheme oldWidget) {
		return data != oldWidget.data;
  }
}
