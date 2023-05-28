import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:robotz_garage_scouting/constants/platform_check.dart';
import 'package:robotz_garage_scouting/pages/data_explorer/data_explorer.dart';
import 'package:robotz_garage_scouting/pages/data_explorer/scouting_data_details.dart';
import 'package:robotz_garage_scouting/pages/data_explorer/scouting_data_list.dart';
import 'package:robotz_garage_scouting/pages/database_tester.dart';
import 'package:robotz_garage_scouting/pages/export_manager.dart';
import 'package:robotz_garage_scouting/pages/home_page.dart';
import 'package:robotz_garage_scouting/pages/import_manager.dart';
import 'package:robotz_garage_scouting/pages/match_scouting/match_scouting.dart';
import 'package:robotz_garage_scouting/pages/photo_collecting.dart';
import 'package:robotz_garage_scouting/pages/pit_scouting_form.dart';
import 'package:robotz_garage_scouting/pages/settings.dart';
import 'package:robotz_garage_scouting/pages/super_scouting.dart';

enum ScoutingRouter {
  home(displayName: "Home", urlPath: "/"),
  pitScouting(displayName: "Pit Scouting", urlPath: "pit-scouting"),
  matchScouting(displayName: "Match Scouting", urlPath: "match-scouting"),
  superScouting(displayName: "Super Scouting", urlPath: "super-scouting"),
  collectionScreen(displayName: "", urlPath: "collection"),
  displayScreen(displayName: "Display Data", urlPath: ":hash"),
  settings(displayName: "Settings", urlPath: "settings");

  final String displayName;
  final String urlPath;

  const ScoutingRouter({required this.displayName, required this.urlPath});

  bool isPitScouting() => this == ScoutingRouter.pitScouting;
  bool isMatchScouting() => this == ScoutingRouter.matchScouting;
  bool isSuperScouting() => this == ScoutingRouter.superScouting;
}

final GoRouter router = GoRouter(routes: <RouteBase>[
  GoRoute(
      path: ScoutingRouter.home.urlPath,
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
            name: ScoutingRouter.pitScouting.urlPath,
            path: ScoutingRouter.pitScouting.urlPath,
            builder: (context, state) => const ScoutingDataListPage(
                  scoutingRouter: ScoutingRouter.pitScouting,
                ),
            routes: [
              GoRoute(
                name: "${ScoutingRouter.pitScouting.urlPath}-collection",
                path: ScoutingRouter.collectionScreen.urlPath,
                builder: (context, state) => PitScoutingPage(
                    initialData: state.queryParams["initialData"] ?? ""),
              ),
              GoRoute(
                name: "${ScoutingRouter.pitScouting.urlPath}-display",
                path: ScoutingRouter.displayScreen.urlPath,
                builder: (context, state) =>
                    ScoutingDataDetailsPage(hash: state.params['hash']),
              ),
            ]),
        GoRoute(
            name: ScoutingRouter.matchScouting.urlPath,
            path: ScoutingRouter.matchScouting.urlPath,
            builder: (context, state) => const ScoutingDataListPage(
                  scoutingRouter: ScoutingRouter.matchScouting,
                ),
            routes: [
              GoRoute(
                name: "${ScoutingRouter.matchScouting.urlPath}-collection",
                path: ScoutingRouter.collectionScreen.urlPath,
                builder: (context, state) => MatchScoutingPage(
                    initialData: state.queryParams["initialData"] ?? ""),
              ),
              GoRoute(
                name: "${ScoutingRouter.matchScouting.urlPath}-display",
                path: ScoutingRouter.displayScreen.urlPath,
                builder: (context, state) =>
                    ScoutingDataDetailsPage(hash: state.params['hash']),
              ),
            ]),
        GoRoute(
            name: ScoutingRouter.superScouting.urlPath,
            path: ScoutingRouter.superScouting.urlPath,
            builder: (context, state) => const ScoutingDataListPage(
                  scoutingRouter: ScoutingRouter.superScouting,
                ),
            routes: [
              GoRoute(
                name: "${ScoutingRouter.superScouting.urlPath}-collection",
                path: ScoutingRouter.collectionScreen.urlPath,
                builder: (context, state) => SuperScoutingPage(
                    initialData: state.queryParams["initialData"] ?? ""),
              ),
              GoRoute(
                name: "${ScoutingRouter.superScouting.urlPath}-display",
                path: ScoutingRouter.displayScreen.urlPath,
                builder: (context, state) =>
                    ScoutingDataDetailsPage(hash: state.params['hash']),
              ),
            ]),
        // These are not available at this time on Web yet because of dart:io
        if (!isWebPlatform()) ...[
          GoRoute(
            name: 'photo_collection',
            path: 'photo_collection',
            builder: (context, state) => const PhotoCollectionPage(),
          ),
          GoRoute(
            name: 'import_manager',
            path: 'import_manager',
            builder: (context, state) => const ImportManagerPage(),
          ),
          GoRoute(
            name: 'export_manager',
            path: 'export_manager',
            builder: (context, state) => const ExportManagerPage(),
          ),
        ],
        GoRoute(
          name: 'database_tester',
          path: 'database_tester',
          builder: (context, state) => const DatabaseTestingPage(),
        ),
        GoRoute(
            name: 'data',
            path: 'data',
            builder: (context, state) => const DataExplorerPage(),
            routes: [
              GoRoute(
                  path: 'pit-scouting',
                  builder: (context, state) => const ScoutingDataListPage(
                        scoutingRouter: ScoutingRouter.pitScouting,
                      ),
                  routes: [
                    GoRoute(
                      path: ':hash',
                      builder: (context, state) =>
                          ScoutingDataDetailsPage(hash: state.params['hash']),
                    ),
                  ]),
              GoRoute(
                  path: 'match-scouting',
                  builder: (context, state) => const ScoutingDataListPage(
                        scoutingRouter: ScoutingRouter.matchScouting,
                      ),
                  routes: [
                    GoRoute(
                      path: ':hash',
                      builder: (context, state) =>
                          ScoutingDataDetailsPage(hash: state.params['hash']),
                    ),
                  ]),
              GoRoute(
                  path: 'super-scouting',
                  builder: (context, state) => const ScoutingDataListPage(
                        scoutingRouter: ScoutingRouter.superScouting,
                      ),
                  routes: [
                    GoRoute(
                      path: ':hash',
                      builder: (context, state) =>
                          ScoutingDataDetailsPage(hash: state.params['hash']),
                    ),
                  ]),
            ]),
        GoRoute(
          name: ScoutingRouter.settings.urlPath,
          path: ScoutingRouter.settings.urlPath,
          builder: (context, state) => const SettingsPage(),
        ),
      ])
]);
