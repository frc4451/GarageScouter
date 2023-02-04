import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaddedTextElement extends StatelessWidget {
  final String labelText;

  final double padding;
  final bool isFirstElement;

  const PaddedTextElement(
      {super.key,
      required this.labelText,
      this.padding = 20.0,
      this.isFirstElement = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isFirstElement
          ? EdgeInsets.fromLTRB(0, padding, 0, 0)
          : EdgeInsets.all(padding),
      child: Column(
        children: [
          Text(labelText),
        ],
      ),
    );
  }
}
