import 'package:flutter/material.dart';

import '../../components/forms/increment_field.dart';

class MatchTeleopScreen extends StatefulWidget {
  const MatchTeleopScreen({super.key});

  @override
  State<MatchTeleopScreen> createState() => _MatchTeleopScreenState();
}

class _MatchTeleopScreenState extends State<MatchTeleopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const Text("TELE-OPERATED"),
      IncrementFormBuilderField(name: "cubes_collected"),
      IncrementFormBuilderField(name: "cones_collected"),
    ]));
  }
}
