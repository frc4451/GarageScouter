import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:robotz_garage_scouting/utils/enums.dart';

/// IncrementFormBuilderField is used for any -1/+1 operations such
/// as score counting for Match Scouting. This extends the
/// flutter_form_builder package so we can use the state management
/// layer when it comes to form validation and converting to DataFrames
class IncrementFormBuilderField extends FormBuilderField<int> {
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

  /// defalt color allowed. default is amber.
  final MaterialColor? color;

  IncrementFormBuilderField({
    super.key,
    super.initialValue,
    required super.name,
    this.label,
    this.spaceBetween = 20,
    this.spaceOutside = 10,
    this.min = 0,
    this.max = 9,
    this.color,
  }) : super(builder: (FormFieldState<int> field) {
          final Color background =
              color ?? Theme.of(field.context).colorScheme.primary;

          return Padding(
              padding: EdgeInsets.fromLTRB(spaceOutside, 0, spaceOutside, 0),
              child: Row(
                children: [
                  Text(label ?? name),
                  const Spacer(),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(background)),
                      onPressed: () {
                        field.didChange(PageDirection.left.value);
                      },
                      child: const Icon(Icons.exposure_minus_1)),
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(spaceBetween, 0, spaceBetween, 0),
                    child: Text(field.value.toString()),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(background)),
                      onPressed: () {
                        field.didChange(PageDirection.right.value);
                      },
                      child: const Icon(Icons.exposure_plus_1)),
                ],
              ));
        });

  @override
  FormBuilderFieldState<IncrementFormBuilderField, int> createState() =>
      _IncrementFormBuilderFieldState();
}

class _IncrementFormBuilderFieldState
    extends FormBuilderFieldState<IncrementFormBuilderField, int> {
  /// We had to override `didChange` in order to support the native FormBuilder
  /// state life cycle, which allows us to keep the data in order to reset the
  /// form easily.
  @override
  void didChange(int? change) {
    setState(() {
      if (change == PageDirection.right.value && value! < widget.max) {
        setValue(value! + PageDirection.right.value);
      } else if (change == PageDirection.left.value && value! > widget.min) {
        setValue(value! + PageDirection.left.value);
      } else if (change == PageDirection.none.value) {
        setValue(value! + PageDirection.none.value);
      }
    });
  }

  /// There is an edge case where we don't actually reset the value of the
  /// counter to zero when we clear the form. Since we know the configuration
  /// of the widget will change by calling `patchValues`, we can force the value
  /// of the widget to go to zero when the initialValue changes.
  @override
  void didUpdateWidget(covariant FormBuilderField<int> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        setValue(0);
      });
    }
  }

  /// Overrides the counter to reset to zero, regardless of what the temp
  /// value in the RetainInfoModel specifies.
  @override
  void reset() {
    setState(() {
      didChange(PageDirection.none.value);
    });
  }

  /// Enforces that the initial value cannot be null.
  @override
  void initState() {
    super.initState();
    if (value == null) {
      setValue(0);
    }
  }
}
