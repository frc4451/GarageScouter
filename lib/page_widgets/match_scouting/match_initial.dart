import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class MatchInitialScreen extends StatefulWidget {
  const MatchInitialScreen({super.key});

  @override
  State<MatchInitialScreen> createState() => _MatchInitialScreenState();
}

class _MatchInitialScreenState extends State<MatchInitialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const Text("INITIAL"),
      FormBuilderTextField(
        name: "team_number",
        decoration: const InputDecoration(
            labelText: "Team Number", prefixIcon: Icon(Icons.numbers)),
      ),
      FormBuilderTextField(
        name: "team_name",
        decoration: const InputDecoration(
            labelText: "Team Name", prefixIcon: Icon(Icons.abc)),
      ),
      FormBuilderDropdown(
          name: "team_alliance",
          decoration: const InputDecoration(
              hintText: "Team Alliance", prefixIcon: Icon(Icons.color_lens)),
          items: ["red", "blue"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList()),
      FormBuilderDropdown(
          name: "team_position",
          decoration: const InputDecoration(
              hintText: "Team Position", prefixIcon: Icon(Icons.map)),
          items: [0, 1, 2]
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList())
    ]));
  }
}
