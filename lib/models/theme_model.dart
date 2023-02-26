import 'package:flutter/material.dart';

/// Provider model used to help read and manage Themes for the application
class ThemeModel extends ChangeNotifier {
  ThemeMode theme = ThemeMode.light;

  bool highContrast = false;

  // Sanity checkers for cleaner comparisons
  bool isDarkMode() => theme == ThemeMode.dark;
  bool isLightMode() => theme == ThemeMode.light;
  bool isHighContrast() => highContrast;

  void setHighContrast(bool value) {
    highContrast = value;
    notifyListeners();
  }

  // setters
  void setLightMode() {
    theme = ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode() {
    theme = ThemeMode.dark;
    notifyListeners();
  }

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
}
