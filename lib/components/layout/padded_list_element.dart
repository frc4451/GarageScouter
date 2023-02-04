import 'package:flutter/material.dart';

class PaddedListElement extends StatelessWidget {
  final String labelText;
  final String buttonText;
  final Function onPressed;

  final double padding;
  final bool isFirstElement;

  const PaddedListElement(
      {super.key,
      required this.labelText,
      required this.buttonText,
      required this.onPressed,
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
          ElevatedButton(
              onPressed: () => onPressed(),
              // onLongPress: () => onPressed(),
              child: Text(buttonText)),
        ],
      ),
    );
  }
}
