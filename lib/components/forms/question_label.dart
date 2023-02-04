import 'package:flutter/material.dart';

/// Label for Questions on the Survey Forms
class QuestionLabel extends StatelessWidget {
  final String text;

  const QuestionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 25),
    );
  }
}
