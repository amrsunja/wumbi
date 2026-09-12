part of '../../app_ui.dart';

class AppThemeData {
  AppThemeData({
    required this.colors,
    required this.borders,
    required this.typo,
    required this.keyboardTheme,
  });

  factory AppThemeData.light() => AppThemeData(
        colors: UIColorToken.light(),
        borders: UIBorderToken.light(),
        typo: UITypographyToken.light(),
        keyboardTheme: Brightness.light,
      );

  factory AppThemeData.dark() => AppThemeData(
        colors: UIColorToken.dark(),
        borders: UIBorderToken.dark(),
        typo: UITypographyToken.dark(),
        keyboardTheme: Brightness.dark,
      );

  final UIColorToken colors;
  final UIBorderToken borders;
  final UITypographyToken typo;
  final Brightness keyboardTheme;

  bool get isDark => keyboardTheme == Brightness.dark;
}
