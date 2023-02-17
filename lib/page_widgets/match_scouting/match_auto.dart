import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

class MatchAutonomousScreen extends StatefulWidget {
  const MatchAutonomousScreen({super.key});

  @override
  State<MatchAutonomousScreen> createState() => _MatchAutonomousScreenState();
}

class _MatchAutonomousScreenState extends State<MatchAutonomousScreen> {
  final double spaceBetween = 10;
  final double spaceOutside = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const Text("Autonomous"),
      IncrementFormBuilderField(
        name: "auto_high_cubes",
        label: "High Cubes",
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_high_cones",
        label: "High Cones",
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cubes",
        label: "Mid Cubes",
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cones",
        label: "Mid Cones",
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cubes",
        label: "Hybrid Cubes",
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cones",
        label: "Hybrid Cones",
        spaceBetween: spaceBetween,
      ),
      FormBuilderCheckbox(
          name: "auto_balance", title: const Text("Auto Balance")),
      FormBuilderCheckbox(name: "auto_dock", title: const Text("Auto Dock")),
      FormBuilderCheckbox(
          name: "auto_mobility", title: const Text("Auto Mobility")),
    ]));
  }
}
