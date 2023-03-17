import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/models/retain_info_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';
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
          title: const Text(
            "Settings",
            textAlign: TextAlign.center,
          ),
        ),
        body: Consumer3<ThemeModel, ScrollModel, RetainInfoModel>(
          builder: (context, theme, scroll, retainInfo, __) => SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Appearance'),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    onToggle: (isDarkMode) {
                      setState(() => isDarkMode
                          ? theme.setDarkMode()
                          : theme.setLightMode());
                    },
                    initialValue: theme.isDarkMode(),
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (isHighContrast) {
                      setState(() => theme.setHighContrast(isHighContrast));
                    },
                    initialValue: theme.isHighContrast(),
                    leading: const Icon(Icons.contrast),
                    title: const Text('High Contrast'),
                  ),
                ],
              ),
              SettingsSection(
                  title: const Text('Usability'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        setState(() => scroll.setDisableSwiping(value));
                      },
                      initialValue: scroll.canSwipe(),
                      leading: const Icon(Icons.swipe),
                      title: const Text('Disable Swiping'),
                      description: const Text(
                          "Disables the swipe to navigate feature of Scouting Pages. Uses the bottom buttons to navigate between pages."),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        setState(() => retainInfo.setRetainInfo(value));
                      },
                      initialValue: retainInfo.doesRetainInfo(),
                      leading: const Icon(Icons.cached),
                      title: const Text('Retain Form Data'),
                      description: const Text(
                          "Retains data from forms when you press the back button. Enables the 'Clear' button."),
                    )
                  ]),
            ],
          ),
        ));
  }
}
