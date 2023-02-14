import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// IncrementFormBuilderField is used for any -1/+1 operations such
/// as score counting for Match Scouting. This extends the
/// flutter_form_builder package so we can use the state management
/// layer when it comes to form validation and converting to DataFrames
class IncrementFormBuilderField extends StatefulWidget {
  final String name;
  final double padding;
  final int min;
  final int max;

  int counter;

  IncrementFormBuilderField({
    super.key,
    required this.name,
    this.padding = 20,
    this.counter = 0,
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
      if (widget.counter < widget.max) {
        widget.counter += 1;
        field.didChange(widget.counter);
      }
    });
  }

  void decrement(FormFieldState<int> field) {
    setState(() {
      if (widget.counter > widget.min) {
        widget.counter -= 1;
        field.didChange(widget.counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        initialValue: 0,
        builder: (FormFieldState<int> field) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(widget.padding),
                child: ElevatedButton(
                    onPressed: () => decrement(field),
                    child: const Icon(Icons.exposure_minus_1)),
              ),
              Text(field.value.toString()),
              Padding(
                  padding: EdgeInsets.all(widget.padding),
                  child: ElevatedButton(
                      onPressed: () => increment(field),
                      child: const Icon(Icons.exposure_plus_1))),
            ],
          );
        });
  }
}
