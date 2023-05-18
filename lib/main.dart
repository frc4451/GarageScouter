import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:robotz_garage_scouting/constants/platform_check.dart';
import 'package:robotz_garage_scouting/database/test.database.dart';
import 'package:robotz_garage_scouting/models/database_controller_model.dart';
import 'package:robotz_garage_scouting/models/input_helper_model.dart';
import 'package:robotz_garage_scouting/models/retain_info_model.dart';
import 'package:robotz_garage_scouting/pages/database_tester.dart';
import 'package:robotz_garage_scouting/pages/export_manager.dart';
import 'package:robotz_garage_scouting/pages/home_page.dart';
import 'package:robotz_garage_scouting/models/theme_model.dart';
import 'package:robotz_garage_scouting/models/scroll_model.dart';
import 'package:robotz_garage_scouting/pages/import_manager.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_scouting.dart';
import 'package:robotz_garage_scouting/pages/photo_collecting.dart';
import 'package:robotz_garage_scouting/pages/pit_scouting_form.dart';
import 'package:robotz_garage_scouting/pages/settings.dart';
import 'package:robotz_garage_scouting/pages/super_scouting.dart';
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

  final RetainInfoModel retainInfoModel = RetainInfoModel(prefs);
  retainInfoModel.initialize();

  final isar = await Isar.open(
    [TestDatabaseEntrySchema],
    directory: (await getApplicationDocumentsDirectory()).path,
  );

  final IsarModel isarModel = IsarModel(isar);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeModel>(create: (_) => themeModel),
      ChangeNotifierProvider<ScrollModel>(create: (_) => scrollModel),
      ChangeNotifierProvider<RetainInfoModel>(create: (_) => retainInfoModel),
      ChangeNotifierProvider<InputHelperModel>(create: (_) => inputHelperModel),
      ChangeNotifierProvider<IsarModel>(create: (_) => isarModel)
    ],
    child: const RobotzGarageScoutingApp(),
  ));
}

final GoRouter _router = GoRouter(routes: <RouteBase>[
  GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'pit_scouting',
          builder: (context, state) => const PitScoutingPage(),
        ),
        GoRoute(
          path: 'match_scouting',
          builder: (context, state) => const MatchScoutingPage(),
        ),
        GoRoute(
          path: 'super_scouting',
          builder: (context, state) => const SuperScoutingPage(),
        ),
        // These are not available at this time on Web yet because of dart:io
        if (!isWebPlatform()) ...[
          GoRoute(
            path: 'photo_collection',
            builder: (context, state) => const PhotoCollectionPage(),
          ),
          GoRoute(
            path: 'import_manager',
            builder: (context, state) => const ImportManagerPage(),
          ),
          GoRoute(
            path: 'export_manager',
            builder: (context, state) => const ExportManagerPage(),
          ),
        ],
        GoRoute(
          path: 'database_tester',
          builder: (context, state) => const DatabaseTestingPage(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ])
]);

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
        routerConfig: _router,
      );
    });
  }
}
