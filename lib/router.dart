import 'package:flutter/material.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_table.dart';
import 'package:garagescouter/pages/photo_collecting.dart';
import 'package:go_router/go_router.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:garagescouter/pages/event_selection.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_delete.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_details.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_export.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_import/qr_reader/scouting_data_import_qr_reader.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_import/qr_reader/scouting_data_import_qr_reader_confirm.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_import/scouting_data_import.dart';
import 'package:garagescouter/pages/data_explorer/scouting_data_list.dart';
import 'package:garagescouter/pages/home_page.dart';
import 'package:garagescouter/pages/scouting/match_scouting.dart';
import 'package:garagescouter/pages/scouting/pit_scouting.dart';
import 'package:garagescouter/pages/settings.dart';
import 'package:garagescouter/pages/scouting/super_scouting.dart';

enum GarageRouter {
  home(displayName: "Home", urlPath: "/"),
  pitScouting(
      displayName: "Pit Scouting",
      urlPath: "pit-scouting",
      dataType: PitScoutingEntry),
  matchScouting(
      displayName: "Match Scouting",
      urlPath: "match-scouting",
      dataType: MatchScoutingEntry),
  superScouting(
      displayName: "Super Scouting",
      urlPath: "super-scouting",
      dataType: SuperScoutingEntry),
  photoCollection(displayName: "Photo Collection", urlPath: "photo-collection"),
  collectionScreen(displayName: "", urlPath: "collection"),
  displayScreen(displayName: "Display Data", urlPath: "hash"),
  settings(displayName: "Settings", urlPath: "settings"),
  import(displayName: "Import", urlPath: "import"),
  export(displayName: "Export", urlPath: "export"),
  delete(displayName: "Delete", urlPath: "delete"),
  qrReader(displayName: "QR Reader", urlPath: "qr-reader"),
  results(displayName: "Results", urlPath: "results"),
  event(displayName: "Events", urlPath: "event"),
  dataTable(displayName: "Table", urlPath: "table");

  final String displayName;
  final String urlPath;
  final Type? dataType;

  const GarageRouter(
      {required this.displayName, required this.urlPath, this.dataType});

  bool isPitScouting() => this == GarageRouter.pitScouting;
  bool isMatchScouting() => this == GarageRouter.matchScouting;
  bool isSuperScouting() => this == GarageRouter.superScouting;

  String getCollectionRouteName() => "$urlPath-collection";
  String getDisplayRouteName() => "$urlPath-display";
  String getExportRouteName() => "$urlPath-export";
  String getImportRouteName() => "$urlPath-import";
  String getDeleteRouteName() => "$urlPath-delete";
  String getDataTableRouteName() => "$urlPath-table";
  String getQRReaderRouteName() => "${getImportRouteName()}-qrreader";
  String getQRReaderResultsRouteName() => "${getImportRouteName()}-results";
}

final GoRouter router = GoRouter(routes: <RouteBase>[
  GoRoute(
      path: GarageRouter.home.urlPath,
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
            name: GarageRouter.pitScouting.urlPath,
            path: GarageRouter.pitScouting.urlPath,
            builder: (context, state) => const ScoutingDataListPage(
                  scoutingRouter: GarageRouter.pitScouting,
                ),
            routes: [
              GoRoute(
                name: GarageRouter.pitScouting.getCollectionRouteName(),
                path: GarageRouter.collectionScreen.urlPath,
                builder: (context, state) => PitScoutingPage(
                    uuid: state.uri.queryParameters["uuid"] ?? ""),
              ),
              GoRoute(
                name: GarageRouter.pitScouting.getExportRouteName(),
                path: GarageRouter.export.urlPath,
                builder: (context, state) => const ScoutingDataExportPage(
                    scoutingRouter: GarageRouter.pitScouting),
              ),
              GoRoute(
                name: GarageRouter.pitScouting.getDeleteRouteName(),
                path: GarageRouter.delete.urlPath,
                builder: (context, state) => const ScoutingDataDeletePage(
                    scoutingRouter: GarageRouter.pitScouting),
              ),
              GoRoute(
                name: GarageRouter.pitScouting.getDataTableRouteName(),
                path: GarageRouter.dataTable.urlPath,
                builder: (context, state) => const ScoutingDataTablePage(
                    scoutingRouter: GarageRouter.pitScouting),
              ),
              GoRoute(
                  name: GarageRouter.pitScouting.getImportRouteName(),
                  path: GarageRouter.import.urlPath,
                  builder: (context, state) => const ScoutingDataImportPage(
                      scoutingRouter: GarageRouter.pitScouting),
                  routes: [
                    GoRoute(
                        name: GarageRouter.pitScouting.getQRReaderRouteName(),
                        path: GarageRouter.qrReader.urlPath,
                        builder: (context, state) =>
                            const ScoutingDataQRReaderPage(
                                scoutingRouter: GarageRouter.pitScouting),
                        routes: [
                          GoRoute(
                              name: GarageRouter.pitScouting
                                  .getQRReaderResultsRouteName(),
                              path: GarageRouter.results.urlPath,
                              builder: (context, state) =>
                                  ScoutingDataQRConfirmationPage(
                                      scoutingRouter: GarageRouter.pitScouting,
                                      qrCodeData:
                                          state.uri.queryParameters['data']))
                        ])
                  ]),
              GoRoute(
                name: GarageRouter.pitScouting.getDisplayRouteName(),
                path: GarageRouter.displayScreen.urlPath,
                builder: (context, state) => ScoutingDataDetailsPage(
                    scoutingRouter: GarageRouter.pitScouting,
                    uuid: state.uri.queryParameters['uuid']),
              ),
            ]),
        GoRoute(
            name: GarageRouter.matchScouting.urlPath,
            path: GarageRouter.matchScouting.urlPath,
            builder: (context, state) => const ScoutingDataListPage(
                  scoutingRouter: GarageRouter.matchScouting,
                ),
            routes: [
              GoRoute(
                name: GarageRouter.matchScouting.getCollectionRouteName(),
                path: GarageRouter.collectionScreen.urlPath,
                builder: (context, state) => MatchScoutingPage(
                    uuid: state.uri.queryParameters["uuid"] ?? ""),
              ),
              GoRoute(
                name: GarageRouter.matchScouting.getExportRouteName(),
                path: GarageRouter.export.urlPath,
                builder: (context, state) => const ScoutingDataExportPage(
                    scoutingRouter: GarageRouter.matchScouting),
              ),
              GoRoute(
                name: GarageRouter.matchScouting.getDeleteRouteName(),
                path: GarageRouter.delete.urlPath,
                builder: (context, state) => const ScoutingDataDeletePage(
                    scoutingRouter: GarageRouter.matchScouting),
              ),
              GoRoute(
                name: GarageRouter.matchScouting.getDataTableRouteName(),
                path: GarageRouter.dataTable.urlPath,
                builder: (context, state) => const ScoutingDataTablePage(
                    scoutingRouter: GarageRouter.matchScouting),
              ),
              GoRoute(
                  name: GarageRouter.matchScouting.getImportRouteName(),
                  path: GarageRouter.import.urlPath,
                  builder: (context, state) => const ScoutingDataImportPage(
                      scoutingRouter: GarageRouter.matchScouting),
                  routes: [
                    GoRoute(
                        name: GarageRouter.matchScouting.getQRReaderRouteName(),
                        path: GarageRouter.qrReader.urlPath,
                        builder: (context, state) =>
                            const ScoutingDataQRReaderPage(
                                scoutingRouter: GarageRouter.matchScouting),
                        routes: [
                          GoRoute(
                              name: GarageRouter.matchScouting
                                  .getQRReaderResultsRouteName(),
                              path: GarageRouter.results.urlPath,
                              builder: (context, state) =>
                                  ScoutingDataQRConfirmationPage(
                                      scoutingRouter:
                                          GarageRouter.matchScouting,
                                      qrCodeData:
                                          state.uri.queryParameters['data']))
                        ])
                  ]),
              GoRoute(
                name: GarageRouter.matchScouting.getDisplayRouteName(),
                path: GarageRouter.displayScreen.urlPath,
                builder: (context, state) => ScoutingDataDetailsPage(
                    scoutingRouter: GarageRouter.matchScouting,
                    uuid: state.uri.queryParameters['uuid']),
              ),
            ]),
        GoRoute(
            name: GarageRouter.superScouting.urlPath,
            path: GarageRouter.superScouting.urlPath,
            builder: (context, state) => const ScoutingDataListPage(
                  scoutingRouter: GarageRouter.superScouting,
                ),
            routes: [
              GoRoute(
                name: GarageRouter.superScouting.getCollectionRouteName(),
                path: GarageRouter.collectionScreen.urlPath,
                builder: (context, state) => SuperScoutingPage(
                    uuid: state.uri.queryParameters["uuid"] ?? ""),
              ),
              GoRoute(
                name: GarageRouter.superScouting.getExportRouteName(),
                path: GarageRouter.export.urlPath,
                builder: (context, state) => const ScoutingDataExportPage(
                    scoutingRouter: GarageRouter.superScouting),
              ),
              GoRoute(
                name: GarageRouter.superScouting.getDeleteRouteName(),
                path: GarageRouter.delete.urlPath,
                builder: (context, state) => const ScoutingDataDeletePage(
                    scoutingRouter: GarageRouter.superScouting),
              ),
              GoRoute(
                name: GarageRouter.superScouting.getDataTableRouteName(),
                path: GarageRouter.dataTable.urlPath,
                builder: (context, state) => const ScoutingDataTablePage(
                    scoutingRouter: GarageRouter.pitScouting),
              ),
              GoRoute(
                  name: GarageRouter.superScouting.getImportRouteName(),
                  path: GarageRouter.import.urlPath,
                  builder: (context, state) => const ScoutingDataImportPage(
                      scoutingRouter: GarageRouter.superScouting),
                  routes: [
                    GoRoute(
                        name: GarageRouter.superScouting.getQRReaderRouteName(),
                        path: GarageRouter.qrReader.urlPath,
                        builder: (context, state) =>
                            const ScoutingDataQRReaderPage(
                                scoutingRouter: GarageRouter.superScouting),
                        routes: [
                          GoRoute(
                              name: GarageRouter.superScouting
                                  .getQRReaderResultsRouteName(),
                              path: GarageRouter.results.urlPath,
                              builder: (context, state) =>
                                  ScoutingDataQRConfirmationPage(
                                      scoutingRouter:
                                          GarageRouter.superScouting,
                                      qrCodeData:
                                          state.uri.queryParameters['data']))
                        ])
                  ]),
              GoRoute(
                name: GarageRouter.superScouting.getDisplayRouteName(),
                path: GarageRouter.displayScreen.urlPath,
                builder: (context, state) => ScoutingDataDetailsPage(
                    scoutingRouter: GarageRouter.superScouting,
                    uuid: state.uri.queryParameters['uuid']),
              ),
            ]),
        GoRoute(
          name: GarageRouter.event.urlPath,
          path: GarageRouter.event.urlPath,
          builder: (context, state) => const EventSelectionPage(),
        ),
        GoRoute(
          name: GarageRouter.photoCollection.urlPath,
          path: GarageRouter.photoCollection.urlPath,
          builder: (context, state) => const PhotoCollectionPage(),
        ),
        GoRoute(
          name: GarageRouter.settings.urlPath,
          path: GarageRouter.settings.urlPath,
          builder: (context, state) => const SettingsPage(),
        ),
      ])
]);
