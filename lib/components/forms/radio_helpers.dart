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

  final void Function(String?)? onChanged;

  final IconData? icon;

  final void Function(String?)? onSaved;

  const RadioButtonInputs(
      {super.key,
      required this.name,
      required this.options,
      required this.label,
      this.initialValue,
      this.validators,
      this.autovalidateMode,
      this.onChanged,
      this.icon,
      this.onSaved});

  @override
  Widget build(BuildContext context) {
    return FormBuilderRadioGroup(
      name: name,
      decoration: InputDecoration(
          label: Text(label), icon: icon != null ? Icon(icon) : null),
      options: options
          .map((e) => FormBuilderFieldOption(value: e, child: Text(e)))
          .toList(growable: false),
      validator: validators,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}
