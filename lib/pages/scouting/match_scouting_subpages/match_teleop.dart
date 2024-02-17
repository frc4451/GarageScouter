import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:garagescouter/components/forms/increment_field.dart';

/// Page View widget that represents the "Tele-operated" period of the match
class MatchTeleopScreen extends StatefulWidget {
  const MatchTeleopScreen({super.key});
  @override
  State<MatchTeleopScreen> createState() => _MatchTeleopScreenState();
}

class _MatchTeleopScreenState extends State<MatchTeleopScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final double spaceBetween = 10;
  final double spaceOutside = 10;

  final MaterialColor noteColor = Colors.orange;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Widget> list = [
      IncrementFormBuilderField(
        name: "subwoofer.completed.teleop",
        label: "Subwoofer Notes Scored",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "subwoofer.attempted.teleop",
        label: "Subwoofer Notes Missed",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "podium.completed.teleop",
        label: "Podium Notes Scored",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "podium.attempted.teleop",
        label: "Podium Notes Missed",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "wing.completed.teleop",
        label: "Wing Notes Scored",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "wing.attempted.teleop",
        label: "Wing Notes Missed",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "midfield.completed.teleop",
        label: "Midfield Notes Scored",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "midfield.attempted.teleop",
        label: "Midfield Notes Missed",
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FormBuilderCheckbox(
              name: "coopertition",
              controlAffinity: ListTileControlAffinity.trailing,
              title: const Text("Did they hit the coopertition button?"))),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FormBuilderCheckbox(
              name: "disabled",
              controlAffinity: ListTileControlAffinity.trailing,
              title: const Text("Did the robot get disabled?"))),
    ];

    return Scaffold(
        body: ListView(
            children: list
                .map((child) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: child,
                    ))
                .toList()));
  }
}
