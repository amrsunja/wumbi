part of '../../app_ui.dart';

class AppThemeData {
	AppThemeData({
		required this.colors,
		required this.borders,
		required this.keyboardTheme,
	});

	factory AppThemeData.light() => AppThemeData(
		colors: UIColorToken.light(),
    borders: UIBorderToken.light(),
		keyboardTheme: Brightness.light,
	);

	factory AppThemeData.dark() => AppThemeData(
		colors: UIColorToken.dark(),
    borders: UIBorderToken.dark(),
		keyboardTheme: Brightness.dark,
	);

	final UIColorToken colors;
	final UIBorderToken borders;
	final Brightness? keyboardTheme;
}
