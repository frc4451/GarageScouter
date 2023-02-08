import 'package:flutter/material.dart';

// Eventually we may want to consider a high-contrast mode
// for accessibility, or custom themes per team.
// enum AvailableThemes { kLight, kDark, kHighContrast }

/// Provider model used to help read and manage Themes for the application
class ThemeModel extends ChangeNotifier {
  ThemeMode theme = ThemeMode.light;

  // Sanity checkers for cleaner comparisons
  bool isDarkMode() => theme == ThemeMode.dark;
  bool isLightMode() => theme == ThemeMode.light;

  // setters
  void setLightMode() {
    theme = ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode() {
    theme = ThemeMode.dark;
    notifyListeners();
  }
}
