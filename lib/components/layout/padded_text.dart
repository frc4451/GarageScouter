import 'package:flutter/material.dart';

class PaddedTextElement extends StatefulWidget {
  final String labelText;

  final double padding;
  final bool isFirstElement;
  const PaddedTextElement(
      {super.key,
      required this.labelText,
      this.padding = 20.0,
      this.isFirstElement = false});
  @override
  State<PaddedTextElement> createState() => _PaddedTextElementState();
}

class _PaddedTextElementState extends State<PaddedTextElement> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.isFirstElement
          ? EdgeInsets.fromLTRB(0, widget.padding, 0, 0)
          : EdgeInsets.all(widget.padding),
      child: Column(
        children: [
          Text(widget.labelText),
        ],
      ),
    );
  }
}
