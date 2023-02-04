import 'package:flutter/material.dart';
import 'package:robotz_garage_scouting/components/forms/question_label.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Helper to make Chip inputs somewhat usable and reusable over the course
/// of the application.
class ChipHelpers extends StatelessWidget {
  final String question;
  final String name;
  final String labelText;
  final IconData prefixIcon;
  final List<String> options;

  final double fontSize;

  const ChipHelpers(
      {super.key,
      required this.question,
      required this.name,
      required this.labelText,
      required this.prefixIcon,
      required this.options,
      this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionLabel(text: question),
        FormBuilderChoiceChip(
            name: name,
            decoration: InputDecoration(
                labelText: labelText, prefixIcon: Icon(prefixIcon)),
            options: options
                .map((option) => FormBuilderChipOption(
                    value: option,
                    child: Text(
                      option,
                      style: TextStyle(fontSize: fontSize),
                    )))
                .toList(growable: false)),
      ],
    );
  }
}
