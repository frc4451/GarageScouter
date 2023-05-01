import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:robotz_garage_scouting/validators/custom_text_validators.dart';

/// Scrollable screen that represents the "end of round/match" survey that scouters can submit
class MatchSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> _matchData;

  const MatchSummaryScreen({super.key, required Map<String, dynamic> matchData})
      : _matchData = matchData;

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen>
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
            name: "no_show",
            title: const Text("Did this robot skip the match (no-show)?"),
            initialValue: widget._matchData["no_show"] ?? false),
        FormBuilderCheckbox(
            name: "broke_down",
            title: const Text("Did they break down or stop moving?"),
            initialValue: widget._matchData["broke_down"] ?? false),
        FormBuilderTextField(
          name: "summary_notes",
          decoration: const InputDecoration(
              labelText: "Notes from the Match you want to share"),
          initialValue: widget._matchData["summary_notes"] ?? "",
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
