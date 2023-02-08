// ignore: file_names
import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/components/drawer/navigation_tile.dart';
import 'package:robotz_garage_scouting/archive/csv_loader.dart';
import 'package:robotz_garage_scouting/pages/match_scouting.dart';
import 'package:robotz_garage_scouting/pages/photo_collecting.dart';
import 'package:robotz_garage_scouting/pages/settings.dart';

import 'csv_manager.dart';
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

  void _gotoCsvTestPage() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CsvTestPage()));
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

  void _goToMatchScouting() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MatchScoutingPage()));
  }

  void _goToSettingsPage() {
    (ModalRoute.of(context)?.canPop ?? false) ? Navigator.pop(context) : null;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(child: Text(widget.title)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(
                // child: Image(image: image),
                child: Text("Robotz Garage Scouting App"),
              ),
            ),
            DrawerTile(
                tileText: "Pit Scouting Form", onTap: _navigateToFormsPage),
            // DrawerTile(
            //     tileText: "Supposed to show snack bar", onTap: showSnackbar),
            // DrawerTile(tileText: "CSV Test Page", onTap: _gotoCsvTestPage),
            DrawerTile(
                tileText: "Match Scouting Form", onTap: _goToMatchScouting),
            DrawerTile(tileText: "CSV Manager", onTap: _goToCSVManager),
            DrawerTile(
                tileText: "Photo Collection", onTap: _gotToPhotoCollection),

            DrawerTile(tileText: "Settings", onTap: _goToSettingsPage),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times ashbie:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  icon: const Icon(Icons.exposure_plus_1),
                  // icon: const Icon(Icons.access_alarms),
                ),
                IconButton(
                  onPressed: _decrementCounter,
                  tooltip: 'decrement',
                  style: IconButton.styleFrom(
                      foregroundColor: Colors.purple,
                      backgroundColor: Colors.purpleAccent),
                  icon: const Icon(Icons.exposure_minus_1),
                  // icon: const Icon(Icons.bed),
                ),
              ],
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods. // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
