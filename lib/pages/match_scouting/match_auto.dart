import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

/// Automous Page of Match Scouting
class MatchAutonomousScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;
  const MatchAutonomousScreen({super.key, required this.matchData});

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
        initialValue: widget.matchData["auto_high_cubes"] ?? 0,
        label: "High Cubes",
        max: 3,
        spaceBetween: spaceBetween,
        color: cubeColor,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cubes",
        initialValue: widget.matchData["auto_mid_cubes"] ?? 0,
        label: "Mid Cubes",
        max: 3,
        spaceBetween: spaceBetween,
        color: cubeColor,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cubes",
        initialValue: widget.matchData["auto_hybrid_cubes"] ?? 0,
        label: "Hybrid Cubes",
        max: 9,
        spaceBetween: spaceBetween,
        color: cubeColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "auto_high_cones",
        initialValue: widget.matchData["auto_high_cones"] ?? 0,
        label: "High Cones",
        max: 6,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_mid_cones",
        initialValue: widget.matchData["auto_mid_cones"] ?? 0,
        label: "Mid Cones",
        max: 6,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "auto_hybrid_cones",
        initialValue: widget.matchData["auto_hybrid_cones"] ?? 0,
        label: "Hybrid Cones",
        max: 9,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      FormBuilderCheckbox(
        name: "auto_balance",
        title: const Text("Auto Balance"),
        initialValue: widget.matchData["auto_balance"] ?? false,
      ),
      FormBuilderCheckbox(
        name: "auto_dock",
        title: const Text("Auto Dock"),
        initialValue: widget.matchData["auto_dock"] ?? false,
      ),
      FormBuilderCheckbox(
        name: "auto_mobility",
        title: const Text("Auto Mobility"),
        initialValue: widget.matchData["auto_mobility"] ?? false,
      ),
    ]));
  }
}
