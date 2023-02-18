import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

/// Automous Page of Match Scouting
class MatchAutonomousScreen extends StatefulWidget {
  const MatchAutonomousScreen({super.key});

  @override
  State<MatchAutonomousScreen> createState() => _MatchAutonomousScreenState();
}

class _MatchAutonomousScreenState extends State<MatchAutonomousScreen>
    with AutomaticKeepAliveClientMixin {
  final double spaceBetween = 10;
  final double spaceOutside = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(children: [
      const Text("AUTONOMOUS"),
      IncrementFormBuilderField(
        name: "auto_high_cubes",
        label: "High Cubes",
        max: 3,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_high_cones",
        label: "High Cones",
        max: 3,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cubes",
        label: "Mid Cubes",
        max: 3,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cones",
        label: "Mid Cones",
        max: 3,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cubes",
        label: "Hybrid Cubes",
        max: 3,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cones",
        label: "Hybrid Cones",
        max: 3,
        spaceBetween: spaceBetween,
      ),
      FormBuilderCheckbox(
          name: "auto_balance",
          title: const Text("Auto Balance"),
          initialValue: false),
      FormBuilderCheckbox(
          name: "auto_dock",
          title: const Text("Auto Dock"),
          initialValue: false),
      FormBuilderCheckbox(
          name: "auto_mobility",
          title: const Text("Auto Mobility"),
          initialValue: false),
    ]));
  }
}
