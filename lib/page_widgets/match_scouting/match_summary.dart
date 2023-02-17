import 'package:flutter/material.dart';

/// Scrollable screen that represents the "end of round/match" survey that scouters can submit
class MatchSummaryScreen extends StatefulWidget {
  const MatchSummaryScreen({super.key});

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(children: const [
        Text("SUMMARY"),
      ]),
    ));
  }
}
