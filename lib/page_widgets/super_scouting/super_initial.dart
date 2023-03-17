import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:robotz_garage_scouting/validators/custom_text_validators.dart';

/// Initial Input for Match Scouting
class SuperScoutingInitialScreen extends StatefulWidget {
  const SuperScoutingInitialScreen({super.key});

  @override
  State<SuperScoutingInitialScreen> createState() =>
      _SuperScoutingInitialScreenState();
}

class _SuperScoutingInitialScreenState
    extends State<SuperScoutingInitialScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
        body: Column(children: [
      const Text("INITIAL"),
      FormBuilderTextField(
        name: "team_number",
        decoration: const InputDecoration(
            labelText: "Team Number", prefixIcon: Icon(Icons.numbers)),
        textInputAction: TextInputAction.next,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.integer(),
          CustomTextValidators.doesNotHaveCommas()
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      FormBuilderTextField(
        name: "match_number",
        decoration: const InputDecoration(
            labelText: "Match Number", prefixIcon: Icon(Icons.numbers)),
        textInputAction: TextInputAction.done,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.integer(),
          CustomTextValidators.doesNotHaveCommas()
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ]));
  }
}
