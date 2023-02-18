import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../components/forms/increment_field.dart';

/// End Game Page for Match Scouting
class MatchEndgameScreen extends StatefulWidget {
  const MatchEndgameScreen({super.key});

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
        const Text("END GAME"),
        FormBuilderCheckbox(
            name: "end_balance",
            title: const Text("End Balance"),
            initialValue: false),
        FormBuilderCheckbox(
            name: "end_dock",
            title: const Text("End Dock"),
            initialValue: false),
        FormBuilderCheckbox(
            name: "end_park",
            title: const Text("End Park"),
            initialValue: false),
        IncrementFormBuilderField(
          name: "end_num_on_station",
          max: 3,
        )
      ]),
    ));
  }
}
