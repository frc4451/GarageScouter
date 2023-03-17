// ignore: file_names
import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/components/drawer/navigation_tile.dart';
import 'package:robotz_garage_scouting/pages/export_manager.dart';
import 'package:robotz_garage_scouting/pages/match_scouting.dart';
import 'package:robotz_garage_scouting/pages/photo_collecting.dart';
import 'package:robotz_garage_scouting/pages/settings.dart';
import 'package:robotz_garage_scouting/pages/super_scouting.dart';

import 'csv_manager.dart';
import 'import_manager.dart';
import 'pit_scouting_form.dart';

GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _navigateToFormsPage() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const FormsTest()));
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void showSnackbar() {
    const SnackBar(content: Text("Some Popup"));
  }

  void _goToCSVManager() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CsvManagerPage()));
  }

  void _gotToPhotoCollection() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PhotoCollectionPage()));
  }

  void _gotToExportManager() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ExportManagerPage()));
  }

  void _gotToImportManager() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ImportManagerPage()));
  }

  void _goToMatchScouting() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MatchScoutingPage()));
  }

  void _goToSuperScouting() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SuperScoutingPage()));
  }

  void _goToSettingsPage() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          widget.title,
          textAlign: TextAlign.center,
        )),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(
                child: Text(
                  "Robotz Garage Scouting",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            DrawerTile(
                tileText: "Pit Scouting Form", onTap: _navigateToFormsPage),
            // DrawerTile(
            //     tileText: "Supposed to show snack bar", onTap: showSnackbar),
            // DrawerTile(tileText: "CSV Test Page", onTap: _gotoCsvTestPage),
            DrawerTile(
                tileText: "Match Scouting Form", onTap: _goToMatchScouting),
            DrawerTile(
                tileText: "Super Scouting Form", onTap: _goToSuperScouting),
            // DrawerTile(tileText: "CSV Manager", onTap: _goToCSVManager),
            DrawerTile(tileText: "Export Manager", onTap: _gotToExportManager),
            DrawerTile(tileText: "Import Manager", onTap: _gotToImportManager),
            DrawerTile(
                tileText: "Photo Collection", onTap: _gotToPhotoCollection),

            DrawerTile(tileText: "Settings", onTap: _goToSettingsPage),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
          // children: <Widget>[
          //   const Text(
          //     'You have pushed the button this many times ashbie:',
          //   ),
          //   Text(
          //     '$_counter',
          //     style: Theme.of(context).textTheme.headline4,
          //   ),
          //   ButtonBar(
          //     alignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       IconButton(
          //         onPressed: _incrementCounter,
          //         tooltip: 'Increment',
          //         icon: const Icon(Icons.exposure_plus_1),
          //         // icon: const Icon(Icons.access_alarms),
          //       ),
          //       IconButton(
          //         onPressed: _decrementCounter,
          //         tooltip: 'decrement',
          //         style: IconButton.styleFrom(
          //             foregroundColor: Colors.purple,
          //             backgroundColor: Colors.purpleAccent),
          //         icon: const Icon(Icons.exposure_minus_1),
          //         // icon: const Icon(Icons.bed),
          //       ),
          //     ],
          // ),
          // ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods. // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
