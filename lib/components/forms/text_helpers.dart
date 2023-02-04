import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/components/forms/question_label.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Helps with making Text Fields more accessible
class GeneralTextInputField extends StatelessWidget {
  final String question;
  final String name;
  final String labelText;
  final IconData prefixIcon;

  String? initialValue;

  FormFieldValidator<String>? validator;

  GeneralTextInputField({
    super.key,
    this.validator,
    this.initialValue,
    required this.question,
    required this.name,
    required this.labelText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionLabel(text: question),
        FormBuilderTextField(
          name: name,
          validator: validator,
          initialValue: initialValue,
          decoration: InputDecoration(
              labelText: labelText, prefixIcon: Icon(prefixIcon)),
        ),
      ],
    );
  }
}
