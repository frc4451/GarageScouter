import 'package:flutter/material.dart';

import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

class MatchAutonomousScreen extends StatefulWidget {
  const MatchAutonomousScreen({super.key});

  @override
  State<MatchAutonomousScreen> createState() => _MatchAutonomousScreenState();
}

class _MatchAutonomousScreenState extends State<MatchAutonomousScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      // Title(color: Colors.blue, child: Text("Autonomous")),

      const Text("Cubes Collected"),
      IncrementFormBuilderField(name: "cubes_collected"),
      const Text("Cones Collected"),
      IncrementFormBuilderField(name: "cones_collected"),
    ]));
  }
}
