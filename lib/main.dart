import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/models/isar_model.dart';
import 'package:robotz_garage_scouting/models/input_helper_model.dart';
import 'package:robotz_garage_scouting/models/theme_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';
import 'package:robotz_garage_scouting/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();
  final ThemeModel themeModel = ThemeModel(prefs);
  themeModel.initialize();

  final ScrollModel scrollModel = ScrollModel(prefs);
  scrollModel.initialize();

  final InputHelperModel inputHelperModel = InputHelperModel(prefs);
  inputHelperModel.initialize();

  final isar = await Isar.open(
    [
      PitScoutingEntrySchema,
      MatchScoutingEntrySchema,
      SuperScoutingEntrySchema,
      EventSchema
    ],
    directory: (await getApplicationSupportDirectory()).path,
  );

  final IsarModel isarModel = IsarModel(isar, prefs);

  await isarModel.putDefaultEvent();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeModel>(create: (_) => themeModel),
      ChangeNotifierProvider<ScrollModel>(create: (_) => scrollModel),
      ChangeNotifierProvider<InputHelperModel>(create: (_) => inputHelperModel),
      ChangeNotifierProvider<IsarModel>(create: (_) => isarModel)
    ],
    child: const RobotzGarageScoutingApp(),
  ));
}

class RobotzGarageScoutingApp extends StatelessWidget {
  const RobotzGarageScoutingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, model, _) {
      return MaterialApp.router(
        title: 'Robotz Garage Scouting',
        theme: model.getLightTheme(),
        darkTheme: model.getDarkTheme(),
        themeMode: model.theme,
        routerConfig: router,
      );
    });
  }
}
