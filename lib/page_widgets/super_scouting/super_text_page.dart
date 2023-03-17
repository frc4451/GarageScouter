import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:robotz_garage_scouting/validators/custom_text_validators.dart';

class SuperScoutingTextInputPage extends StatefulWidget {
  final String label;
  final String name;
  final int maxLength;
  final int maxLines;

  const SuperScoutingTextInputPage(
      {super.key,
      required this.label,
      required this.name,
      this.maxLength = 1024,
      this.maxLines = 5});

  @override
  State<SuperScoutingTextInputPage> createState() =>
      _SuperScoutingTextInputPageState();
}

class _SuperScoutingTextInputPageState
    extends State<SuperScoutingTextInputPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
        body: Center(
      child: Column(children: [
        Text(widget.label),
        FormBuilderTextField(
            name: widget.name,
            initialValue: "",
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            validator: CustomTextValidators.doesNotHaveCommas())
      ]),
    ));
  }
}
