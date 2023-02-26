import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/pages/home_page.dart';
import 'package:robotz_garage_scouting/models/theme_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeModel>(create: (_) => ThemeModel()),
      ChangeNotifierProvider<ScrollModel>(create: (_) => ScrollModel()),
    ],
    child: const RobotzGarageScoutingApp(),
  ));
}

class RobotzGarageScoutingApp extends StatelessWidget {
  const RobotzGarageScoutingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => ThemeModel(),
        child: Consumer<ThemeModel>(builder: (context, model, _) {
          return MaterialApp(
            title: 'Robotz Garage Scouting',
            theme: model.getLightTheme(),
            darkTheme: model.getDarkTheme(),
            themeMode: model.theme,
            home: const MyHomePage(title: 'Robotz Garage Test'),
          );
        }));
  }
}
