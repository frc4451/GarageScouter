import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:robotz_garage_scouting/components/drawer/drawer_tile.dart';
import 'package:robotz_garage_scouting/router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Goes to a given GoRouter path after closing the Drawer.
  void _route(String path) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    // context.go(path);
    context.goNamed(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Garage Scouter",
          textAlign: TextAlign.center,
        )),
      ),
      drawer: Drawer(
        child: Column(children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Center(
              child: Text(
                "Garage Scouter",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ExpansionTile(
                  title: const Text("Data Collection"),
                  initiallyExpanded: true,
                  children: ListTile.divideTiles(context: context, tiles: [
                    ListTile(
                        title: const Text("Pit Scouting"),
                        onTap: () => _route(GarageRouter.pitScouting.urlPath)),
                    ListTile(
                        title: const Text("Match Scouting"),
                        onTap: () =>
                            _route(GarageRouter.matchScouting.urlPath)),
                    ListTile(
                        title: const Text("Super Scouting"),
                        onTap: () =>
                            _route(GarageRouter.superScouting.urlPath)),
                    ListTile(
                        title: const Text("Photo Collection"),
                        onTap: () =>
                            _route(GarageRouter.photoCollection.urlPath)),
                  ]).toList()),
              // ExpansionTile(
              //   title: const Text("Data Management"),
              //   initiallyExpanded: true,
              //   children: [
              //     DrawerTile(
              //       tileText: "Database Tester",
              //       onTap: () => _route("database_tester"),
              //     ),
              //     DrawerTile(
              //       tileText: "Data Explorer",
              //       onTap: () => _route("data"),
              //     ),
              //     if (!isWebPlatform()) ...[
              //       DrawerTile(
              //           tileText: "Export Manager",
              //           onTap: () => _route('export_manager')),
              //       DrawerTile(
              //           tileText: "Import Manager",
              //           onTap: () => _route('import_manager')),
              //     ] else
              //       const DrawerTile(
              //           tileText: "Not available on Web at this time.")
              //   ],
              // ),
              DrawerTile(tileText: "Settings", onTap: () => _route('settings')),
            ],
          ))
        ]),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(25),
              child: Text("Welcome to the Robotz Garage Scouting App!"),
            ),
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                  "Open the Navigation Button in the Top Left to access different parts of the app."),
            ),
          ],
        ),
      ),
    );
  }
}
