import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Initial Input for Match Scouting
class MatchInitialScreen extends StatefulWidget {
  const MatchInitialScreen({super.key});

  @override
  State<MatchInitialScreen> createState() => _MatchInitialScreenState();
}

class _MatchInitialScreenState extends State<MatchInitialScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(children: [
      const Text("INITIAL"),
      FormBuilderTextField(
        name: "team_number",
        decoration: const InputDecoration(
            labelText: "Team Number", prefixIcon: Icon(Icons.numbers)),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.integer()
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      FormBuilderTextField(
        name: "match_number",
        decoration: const InputDecoration(
            labelText: "Match Number", prefixIcon: Icon(Icons.numbers)),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.integer()
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      FormBuilderDropdown(
          name: "team_alliance",
          decoration: const InputDecoration(
              labelText: "Team Alliance", prefixIcon: Icon(Icons.color_lens)),
          validator: FormBuilderValidators.required(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          items: ["red", "blue"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList()),
      FormBuilderDropdown(
          name: "team_position",
          decoration: const InputDecoration(
              labelText: "Team Position", prefixIcon: Icon(Icons.map)),
          validator: FormBuilderValidators.required(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          items: [1, 2, 3]
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList())
    ]));
  }
}
