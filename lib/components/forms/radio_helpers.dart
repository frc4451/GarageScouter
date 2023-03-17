import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Generates a Radio group using the list of Strings provided and assigns
/// a name that can be referenced within the FormBuilder context.
class RadioButtonInputs extends StatelessWidget {
  final String name;
  final List<String> options;
  final String label;

  final String? initialValue;

  final String? Function(dynamic)? validators;
  final AutovalidateMode? autovalidateMode;

  const RadioButtonInputs(
      {super.key,
      required this.name,
      required this.options,
      required this.label,
      this.initialValue,
      this.validators,
      this.autovalidateMode});

  @override
  Widget build(BuildContext context) {
    return FormBuilderRadioGroup(
      name: name,
      decoration: InputDecoration(label: Text(label)),
      options: options
          .map((e) => FormBuilderFieldOption(value: e, child: Text(e)))
          .toList(growable: false),
      validator: validators,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
    );
  }
}

/// Quick helper method to generate a simple "yes" or "no" input
class YesOrNoAnswers extends StatelessWidget {
  final String name;
  final String label;
  final String? initialValue;
  final String? Function(dynamic)? validators;
  final AutovalidateMode? autovalidateMode;

  const YesOrNoAnswers(
      {super.key,
      required this.name,
      required this.label,
      this.initialValue,
      this.validators,
      this.autovalidateMode});

  @override
  Widget build(BuildContext context) {
    return RadioButtonInputs(
      name: name,
      options: const ["yes", "no"],
      label: label,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode,
      validators: validators,
    );
  }
}

/// Generates a "yes" or "no" input alongside a question label directly
/// attached. This is more for organizational than anything.
class FullYesOrNoField extends StatelessWidget {
  final String name;
  final String label;

  final String? initialValue;

  const FullYesOrNoField(
      {super.key, required this.name, required this.label, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YesOrNoAnswers(name: name, label: label, initialValue: initialValue)
      ],
    );
  }
}
