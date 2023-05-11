import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

/// End Game Page for Match Scouting
class MatchEndgameScreen extends StatefulWidget {
  final Map<String, dynamic> _matchData;

  const MatchEndgameScreen({super.key, required Map<String, dynamic> matchData})
      : _matchData = matchData;

  @override
  State<MatchEndgameScreen> createState() => _MatchEndgameScreenState();
}

class _MatchEndgameScreenState extends State<MatchEndgameScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Center(
      child: Column(children: [
        FormBuilderCheckbox(
            name: "end_balance",
            title: const Text("End Balance"),
            initialValue: widget._matchData["end_balance"] ?? false),
        FormBuilderCheckbox(
            name: "end_dock",
            title: const Text("End Dock"),
            initialValue: widget._matchData["end_dock"] ?? false),
        FormBuilderCheckbox(
            name: "end_park",
            title: const Text("End Park"),
            initialValue: widget._matchData["end_park"] ?? false),
        IncrementFormBuilderField(
          name: "end_num_on_station",
          label: "Number on Station",
          initialValue: widget._matchData["end_num_on_station"] ?? 0,
          max: 3,
        )
      ]),
    ));
  }
}
