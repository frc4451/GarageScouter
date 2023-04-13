import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/models/input_helper_model.dart';
import 'package:robotz_garage_scouting/models/retain_info_model.dart';
import 'package:robotz_garage_scouting/pages/home_page.dart';
import 'package:robotz_garage_scouting/models/theme_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final ThemeModel themeModel = ThemeModel(prefs);
  themeModel.initialize();

  final ScrollModel scrollModel = ScrollModel(prefs);
  scrollModel.initialize();

  final InputHelperModel inputHelperModel = InputHelperModel(prefs);
  inputHelperModel.initialize();

  final RetainInfoModel retainInfoModel = RetainInfoModel(prefs);
  retainInfoModel.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeModel>(create: (_) => themeModel),
      ChangeNotifierProvider<ScrollModel>(create: (_) => scrollModel),
      ChangeNotifierProvider<RetainInfoModel>(create: (_) => retainInfoModel),
      ChangeNotifierProvider<InputHelperModel>(create: (_) => inputHelperModel),
    ],
    child: const RobotzGarageScoutingApp(),
  ));
}

class RobotzGarageScoutingApp extends StatelessWidget {
  const RobotzGarageScoutingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, model, _) {
      return MaterialApp(
        title: 'Robotz Garage Scouting',
        theme: model.getLightTheme(),
        darkTheme: model.getDarkTheme(),
        themeMode: model.theme,
        home: const MyHomePage(title: 'Robotz Garage Scouting'),
      );
    });
  }
}
