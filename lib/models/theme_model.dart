import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kThemeKey = 'theme';
const String kHighContrastKey = 'isHighContrast';

/// Provider model used to help read and manage Themes for the application
class ThemeModel extends ChangeNotifier {
  final SharedPreferences prefs;

  ThemeMode _theme = ThemeMode.light;
  bool _highContrast = false;

  ThemeMode get theme => _theme;
  bool get highContrast => _highContrast;

  ThemeModel(this.prefs);

  void initialize() {
    _theme = prefs.getString(kThemeKey) == 'ThemeMode.light'
        ? ThemeMode.light
        : prefs.getString(kThemeKey) == 'ThemeMode.dark'
            ? ThemeMode.dark
            : ThemeMode.light;

    _highContrast = prefs.getBool(kHighContrastKey) ?? false;
  }

  // Sanity checkers for cleaner comparisons
  bool isDarkMode() => theme == ThemeMode.dark;
  bool isLightMode() => theme == ThemeMode.light;
  bool isHighContrast() => highContrast;

  void setHighContrast(bool value) {
    _highContrast = value;
    _writeData();
    notifyListeners();
  }

  // setters
  void setLightMode() {
    _theme = ThemeMode.light;
    _writeData();
    notifyListeners();
  }

  void setDarkMode() {
    _theme = ThemeMode.dark;
    _writeData();
    notifyListeners();
  }

  ThemeData getCurrentTheme() =>
      isDarkMode() ? getDarkTheme() : getLightTheme();

  ThemeData getLightTheme() => ThemeData.from(
      colorScheme: highContrast
          ? const ColorScheme.highContrastLight()
          : const ColorScheme.light(primary: Colors.red));

  ThemeData getDarkTheme() => ThemeData.from(
      colorScheme: highContrast
          ? const ColorScheme.highContrastDark()
          : const ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
            ));

  /// Writes data to Shared Preferences to make life easy.
  void _writeData() {
    prefs.setString(kThemeKey, _theme.toString());
    prefs.setBool(kHighContrastKey, _highContrast);
  }

  /// Handles Light/Dark Theme Colors for things like TabViews.
  Color getLabelColor() => isDarkMode() ? Colors.white : Colors.black;
}
