import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/models/theme_model.dart';
import 'package:settings_ui/settings_ui.dart';

/// Handles Settings for the Scouting App. Heavily relies on formatting from
/// the `settings_ui` package in order to make the UI look consistent with
/// other applications.
class SettingsPage extends StatefulWidget {
  final String title = "Settings";

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Consumer<ThemeModel>(
          builder: (context, model, __) => SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Theme'),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    onToggle: (isDarkMode) {
                      setState(() => isDarkMode
                          ? model.setDarkMode()
                          : model.setLightMode());
                    },
                    initialValue: model.isDarkMode(),
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
