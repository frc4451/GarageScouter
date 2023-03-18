import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

/// Page View widget that represents the "Tele-operated" period of the match
class MatchTeleopScreen extends StatefulWidget {
  final Map<String, dynamic> _matchData;

  const MatchTeleopScreen({super.key, required Map<String, dynamic> matchData})
      : _matchData = matchData;

  @override
  State<MatchTeleopScreen> createState() => _MatchTeleopScreenState();
}

class _MatchTeleopScreenState extends State<MatchTeleopScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final double spaceBetween = 10;
  final double spaceOutside = 10;

  final MaterialColor coneColor = Colors.amber;
  final MaterialColor cubeColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(children: [
      const Text("TELE-OPERATED"),
      IncrementFormBuilderField(
        name: "teleop_high_cubes",
        initialValue: widget._matchData["teleop_high_cubes"] ?? 0,
        label: "High Cubes",
        max: 3,
        color: cubeColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "teleop_mid_cubes",
        initialValue: widget._matchData["teleop_mid_cubes"] ?? 0,
        label: "Mid Cubes",
        max: 3,
        color: cubeColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "teleop_hybrid_cubes",
        initialValue: widget._matchData["teleop_hybrid_cubes"] ?? 0,
        label: "Hybrid Cubes",
        max: 9,
        color: cubeColor,
        spaceBetween: spaceBetween,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "teleop_high_cones",
        initialValue: widget._matchData["teleop_high_cones"] ?? 0,
        label: "High Cones",
        max: 6,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "teleop_mid_cones",
        initialValue: widget._matchData["teleop_mid_cones"] ?? 0,
        label: "Mid Cones",
        max: 6,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      IncrementFormBuilderField(
        name: "teleop_hybrid_cones",
        initialValue: widget._matchData["teleop_hybrid_cones"] ?? 0,
        label: "Hybrid Cones",
        max: 9,
        color: coneColor,
        spaceBetween: spaceBetween,
      ),
      FormBuilderCheckbox(
        name: "teleop_shuttle",
        title: const Text("Teleop Shuttle"),
        initialValue: widget._matchData["teleop_shuttle"] ?? false,
        // initialValue: false,
      ),
      FormBuilderCheckbox(
        name: "teleop_defend",
        title: const Text("Teleop Defend"),
        initialValue: widget._matchData["teleop_defend"] ?? false,
        // initialValue: false
      ),
    ]));
  }
}
