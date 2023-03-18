import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String themeSettingsFileName = "theme.settings.json";

/// Provider model used to help read and manage Themes for the application
class ThemeModel extends ChangeNotifier {
  ThemeMode theme;

  bool highContrast;

  ThemeModel({this.theme = ThemeMode.light, this.highContrast = false});

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    ThemeMode assumedTheme = json['theme'] == 'ThemeMode.light'
        ? ThemeMode.light
        : json['theme'] == 'ThemeMode.dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    return ThemeModel(theme: assumedTheme, highContrast: json['highContrast']);
  }

  Map<String, dynamic> toJson() {
    return {'theme': theme.toString(), 'highContrast': highContrast};
  }

  // Sanity checkers for cleaner comparisons
  bool isDarkMode() => theme == ThemeMode.dark;
  bool isLightMode() => theme == ThemeMode.light;
  bool isHighContrast() => highContrast;

  void setHighContrast(bool value) {
    highContrast = value;
    _writeData();
    notifyListeners();
  }

  // setters
  void setLightMode() {
    theme = ThemeMode.light;
    _writeData();
    notifyListeners();
  }

  void setDarkMode() {
    theme = ThemeMode.dark;
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

  Future<void> _writeData() async {
    final String path = (await getApplicationSupportDirectory()).path;
    final String jsonPath = p.join(path, themeSettingsFileName);
    final File jsonFile = File(jsonPath);

    jsonFile.writeAsStringSync(jsonEncode(toJson()));
  }
}

Future<ThemeModel> getInitialTheme() async {
  final String settingsDirectory =
      (await getApplicationSupportDirectory()).path;
  final String jsonPath = p.join(settingsDirectory, themeSettingsFileName);
  final File jsonFile = File(jsonPath);

  if (!jsonFile.existsSync()) {
    final ThemeModel model = ThemeModel();
    await model._writeData();
    return model;
  }

  final String jsonString = jsonFile.readAsStringSync();
  final dynamic decodedJson = jsonDecode(jsonString);
  return ThemeModel.fromJson(decodedJson);
}
