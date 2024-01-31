import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garagescouter/models/input_helper_model.dart';
import 'package:garagescouter/models/scroll_model.dart';
import 'package:garagescouter/models/theme_model.dart';
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
          centerTitle: true,
        ),
        body: Consumer3<ThemeModel, ScrollModel, InputHelperModel>(
          builder: (context, theme, scroll, inputHelperModel, __) =>
              SettingsList(
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
                        setState(() =>
                            inputHelperModel.setIterativeMatchInput(value));
                      },
                      initialValue: inputHelperModel.isIterativeMatchInput(),
                      leading: const Icon(Icons.repeat_one),
                      title: const Text('Iterative Match Input'),
                      description: const Text(
                          "On Match Scouting, retain Team Alliance and Position, increment Match Number. Does not apply when editing drafts."),
                    )
                  ]),
            ],
          ),
        ));
  }
}
