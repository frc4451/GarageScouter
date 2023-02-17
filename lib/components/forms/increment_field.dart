import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// IncrementFormBuilderField is used for any -1/+1 operations such
/// as score counting for Match Scouting. This extends the
/// flutter_form_builder package so we can use the state management
/// layer when it comes to form validation and converting to DataFrames
class IncrementFormBuilderField extends StatefulWidget {
  /// Name of the field when pulling it from currentState
  final String name;

  /// Display name for the counter. This is optional so we can default to `name`
  final String? label;

  /// Padding between the text and buttons
  final double spaceBetween;

  /// Padding on the outsides of the field
  final double spaceOutside;

  /// Minimum value allowed. Default is 0.
  final int min;

  /// Maximum value allowed. Default is 9.
  final int max;

  // internal state counter to keep track of number of +1's
  int _counter = 0;

  IncrementFormBuilderField({
    super.key,
    required this.name,
    this.label,
    this.spaceBetween = 20,
    this.spaceOutside = 10,
    this.min = 0,
    this.max = 9,
  });

  @override
  State<IncrementFormBuilderField> createState() =>
      _IncrementFormBuilderFieldState();
}

class _IncrementFormBuilderFieldState extends State<IncrementFormBuilderField> {
  void increment(FormFieldState<int> field) {
    setState(() {
      if (widget._counter < widget.max) {
        widget._counter += 1;
        field.didChange(widget._counter);
      }
    });
  }

  void decrement(FormFieldState<int> field) {
    setState(() {
      if (widget._counter > widget.min) {
        widget._counter -= 1;
        field.didChange(widget._counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        initialValue: 0,
        builder: (FormFieldState<int> field) {
          return Padding(
              padding: EdgeInsets.fromLTRB(
                  widget.spaceOutside, 0, widget.spaceOutside, 0),
              child: Row(
                children: [
                  Text(widget.label ?? widget.name),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () => decrement(field),
                      child: const Icon(Icons.exposure_minus_1)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        widget.spaceBetween, 0, widget.spaceBetween, 0),
                    child: Text(field.value.toString()),
                  ),
                  ElevatedButton(
                      onPressed: () => increment(field),
                      child: const Icon(Icons.exposure_plus_1)),
                ],
              ));
        });
  }
}
