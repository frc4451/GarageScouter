import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:garagescouter/components/forms/increment_field.dart';

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

  final MaterialColor coneColor = Colors.amber;
  final MaterialColor cubeColor = Colors.deepPurple;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        body: Column(children: [
      IncrementFormBuilderField(
        name: "auto_high_cubes",
        label: "High Cubes",
        max: 3,
        spaceBetween: spaceBetween,
        color: cubeColor,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cubes",
        label: "Mid Cubes",
        max: 3,
        spaceBetween: spaceBetween,
        color: cubeColor,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cubes",
        label: "Hybrid Cubes",
        max: 9,
        spaceBetween: spaceBetween,
        color: cubeColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "auto_high_cones",
        label: "High Cones",
        max: 6,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cones",
        label: "Mid Cones",
        max: 6,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cones",
        label: "Hybrid Cones",
        max: 9,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      FormBuilderCheckbox(
        name: "auto_balance",
        title: const Text("Auto Balance"),
      ),
      FormBuilderCheckbox(
        name: "auto_dock",
        title: const Text("Auto Dock"),
      ),
      FormBuilderCheckbox(
        name: "auto_mobility",
        title: const Text("Auto Mobility"),
      ),
    ]));
  }
}
