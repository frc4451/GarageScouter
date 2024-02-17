import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:garagescouter/validators/custom_integer_validators.dart';
import 'package:garagescouter/validators/custom_text_validators.dart';

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
      FormBuilderTextField(
        name: "team.number",
        decoration: const InputDecoration(
            labelText: "Team Number", prefixIcon: Icon(Icons.numbers)),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.integer(),
          CustomTextValidators.doesNotHaveCommas(),
          CustomIntegerValidators.notNegative()
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      FormBuilderTextField(
        name: "match.number",
        decoration: const InputDecoration(
            labelText: "Match Number", prefixIcon: Icon(Icons.numbers)),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.integer(),
          CustomTextValidators.doesNotHaveCommas(),
          CustomIntegerValidators.notNegative()
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      FormBuilderDropdown(
        name: "team.alliance",
        decoration: const InputDecoration(
            labelText: "Team Alliance", prefixIcon: Icon(Icons.color_lens)),
        validator: FormBuilderValidators.required(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        items: ["red", "blue"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
      ),
      FormBuilderTextField(
        name: "initials",
        decoration: const InputDecoration(
            labelText: "Initials for Record Keeping",
            prefixIcon: Icon(Icons.account_circle)),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        maxLength: 3,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          CustomTextValidators.doesNotHaveCommas(),
        ]),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
      FormBuilderCheckbox(
        name: "team.present",
        title: const Text("Team is Present"),
        decoration:
            const InputDecoration(prefixIcon: Icon(Icons.present_to_all)),
      ),
      FormBuilderDropdown(
        name: "starting.position",
        decoration: const InputDecoration(
            labelText: "Field Position", prefixIcon: Icon(Icons.map)),
        validator: FormBuilderValidators.required(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        items: [
          "Touching Subwoofer, Centered",
          "Touching Subwoofer, Facing AMP",
          "Touching Subwoofer, Facing Human Player",
          "In front of single Driver Station",
          "In front of double Driver Station",
          "Other"
        ]
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
      ),
    ]));
  }
}
