import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/components/forms/question_label.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Generates a Radio group using the list of Strings provided and assigns
/// a name that can be referenced within the FormBuilder context.
class RadioButtonInputs extends StatelessWidget {
  final String name;
  final List<String> options;

  const RadioButtonInputs(
      {super.key, required this.name, required this.options});

  @override
  Widget build(BuildContext context) {
    return FormBuilderRadioGroup(
      name: name,
      decoration: InputDecoration(),
      options: options
          .map((e) => FormBuilderFieldOption(value: e, child: Text(e)))
          .toList(growable: false),
    );
  }
}

/// Quick helper method to generate a simple "yes" or "no" input
class YesOrNoAnswers extends StatelessWidget {
  final String name;

  const YesOrNoAnswers({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return RadioButtonInputs(name: name, options: const ["yes", "no"]);
  }
}

/// Generates a "yes" or "no" input alongside a question label directly
/// attached. This is more for organizational than anything.
class FullYesOrNoField extends StatelessWidget {
  final String name;
  final String question;

  const FullYesOrNoField(
      {super.key, required this.name, required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [QuestionLabel(text: question), YesOrNoAnswers(name: name)],
    );
  }
}
