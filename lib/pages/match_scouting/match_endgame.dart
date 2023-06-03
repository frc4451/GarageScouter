import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:robotz_garage_scouting/components/forms/increment_field.dart';

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
        FormBuilderCheckbox(
          name: "end_balance",
          title: const Text("End Balance"),
        ),
        FormBuilderCheckbox(
          name: "end_dock",
          title: const Text("End Dock"),
        ),
        FormBuilderCheckbox(
          name: "end_park",
          title: const Text("End Park"),
        ),
        IncrementFormBuilderField(
          name: "end_num_on_station",
          label: "Number on Station",
          max: 3,
        )
      ]),
    ));
  }
}
