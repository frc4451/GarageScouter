import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:garagescouter/validators/custom_text_validators.dart';

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
          name: "score.trap.end",
          title: const Text("Did they score in the Trap?"),
        ),
        FormBuilderCheckbox(
          name: "high.note.attempt.end",
          title: const Text("Did they attempt the high note?"),
        ),
        FormBuilderCheckbox(
          name: "high.note.score.end",
          title: const Text("Did they score the high note?"),
        ),
        FormBuilderTextField(
          name: "summary.end",
          decoration: const InputDecoration(
              labelText: "Notes from the Match you want to share"),
          maxLength: 256,
          maxLines: 5,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.done,
          validator: FormBuilderValidators.compose([
            CustomTextValidators.doesNotHaveCommas(),
          ]),
        )
      ]),
    ));
  }
}
