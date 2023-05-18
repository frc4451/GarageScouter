import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DataExplorerPage extends StatefulWidget {
  const DataExplorerPage({super.key});

  @override
  State<DataExplorerPage> createState() => _DataExplorerPageState();
}

class _DataExplorerPageState extends State<DataExplorerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Scouting Data",
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Pit Scouting"),
            onTap: () {
              context.go("/data/pit-scouting");
            },
          ),
          ListTile(
            title: const Text("Match Scouting"),
            onTap: () {
              context.go("/data/match-scouting");
            },
          ),
          ListTile(
            title: const Text("Super Scouting"),
            onTap: () {
              context.go("/data/super-scouting");
            },
          ),
        ],
      ),
    );
  }
}
