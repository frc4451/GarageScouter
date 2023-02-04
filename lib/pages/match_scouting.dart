import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:robotz_garage_scouting/components/layout/match_counter.dart';
import 'package:robotz_garage_scouting/components/layout/padded_text.dart';

class MatchScoutingPage extends StatefulWidget {
  const MatchScoutingPage({super.key});

  @override
  State<MatchScoutingPage> createState() => _MatchScoutingPageState();
}

class _MatchScoutingPageState extends State<MatchScoutingPage> {
  final String title = "Match Scouting Form";

  int cubesAutonomous = 0;
  int conesAutonomous = 0;

  void _incrementCubes() {
    print("_incrementCubes");
    cubesAutonomous += 1;
  }

  void _decrementCubes() {
    print("_decrementCubes");
    cubesAutonomous -= 1;
  }

  void _incrementCones() {
    print("_incrementCones");
    conesAutonomous += 1;
  }

  void _decrementCones() {
    print("_decrementCones");
    conesAutonomous -= 1;

    setState() {
      conesAutonomous -= 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: true,
        title: Center(child: Text(title)),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            // Text("Number of Cubes Collected"),
            const PaddedTextElement(
              labelText: "Number of Cubes Collected",
            ),
            MatchCounter(
                // labelText: "Number of Cubes Collected",
                counter: cubesAutonomous),
            const PaddedTextElement(labelText: "Number of Cones Collected"),
            MatchCounter(
              // labelText: "Number of Cones Collected",
              counter: conesAutonomous,
            ),
          ],
        ),
      )
    ]));
  }
}
