import 'package:flutter/material.dart';

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

  final MaterialColor noteColor = Colors.orange;
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Widget> list = [
      IncrementFormBuilderField(
        name: "subwoofer.completed.auto",
        label: "Subwoofer Notes Scored",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "subwoofer.attempted.auto",
        label: "Subwoofer Notes Missed",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "podium.completed.auto",
        label: "Podium Notes Scored",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "podium.attempted.auto",
        label: "Podium Notes Missed",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "wing.completed.auto",
        label: "Wing Notes Scored",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "wing.attempted.auto",
        label: "Wing Notes Missed",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      const Divider(),
      IncrementFormBuilderField(
        name: "midfield.completed.auto",
        label: "Midfield Notes Scored",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
      IncrementFormBuilderField(
        name: "midfield.attempted.auto",
        label: "Midfield Notes Missed",
        max: 8,
        spaceBetween: spaceBetween,
        color: noteColor,
      ),
    ];

    return Scaffold(
        body: ListView(
            children: list
                .map((child) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: child))
                .toList()));
  }
}
