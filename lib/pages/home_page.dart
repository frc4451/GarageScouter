import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:garagescouter/components/drawer/drawer_tile.dart';
import 'package:garagescouter/router.dart';

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
    // final ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: themeData.primaryColor,
        title: const Text("Garage Scouter"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              // image: const DecorationImage(
              //     fit: BoxFit.fitWidth,
              //     image:
              //         AssetImage("assets/garage_scouter_icon_square.png"))
            ),
            child: Image.asset(
              "assets/garage_scouter_icon_square.png",
              // This is a hacky workaround. Please investigate this in a
              // future Flutter release.
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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
                        title: const Text("Event Management"),
                        onTap: () => _route(GarageRouter.event.urlPath)),
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
              child: Text("Welcome to GarageScouter!"),
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
