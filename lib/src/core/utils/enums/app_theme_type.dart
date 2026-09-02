enum AppThemeType {
  system,
  light,
  dark;

  static AppThemeType fromJson(String? type) {
    switch (type) {
      case 'dark':
        return dark;
      case 'light':
        return light;
      default:
        return system;
    }
  }
}
