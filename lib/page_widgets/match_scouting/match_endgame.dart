import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../components/forms/increment_field.dart';

class MatchEndgameScreen extends StatefulWidget {
  const MatchEndgameScreen({super.key});

  @override
  State<MatchEndgameScreen> createState() => _MatchEndgameScreenState();
}

class _MatchEndgameScreenState extends State<MatchEndgameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(children: const [
        Text("END GAME"),
      ]),
    ));
  }
}
