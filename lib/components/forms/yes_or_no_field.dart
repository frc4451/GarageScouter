import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

enum YesOrNoEnumType {
  yes("Yes"),
  no("No"),
  empty("");

  final String label;

  const YesOrNoEnumType(this.label);

  @override
  String toString() => name;

  String toJson() => name;

  /// Converts a String value to the Enum representation, or returns empty.
  static YesOrNoEnumType fromString(String value) =>
      YesOrNoEnumType.values
          .firstWhereOrNull((element) => value == element.toString()) ??
      YesOrNoEnumType.empty;
}

/// YesOrNoFieldType is a type definition so that we can easily
/// check that `widget` is a `YesOrNoFieldWidget`
typedef YesOrNoFieldType = FormBuilderRadioGroup<YesOrNoEnumType?>;

/// YesOrNoFieldWidget is a wrapper for FormBuilderRadioGroup to
/// make writing multiple Yes or No questions easier
class YesOrNoFieldWidget extends StatefulWidget {
  final String name;

  final String label;

  final dynamic initialValue;

  final String? Function(dynamic)? validators;
  final AutovalidateMode? autovalidateMode;

  final void Function(YesOrNoEnumType?)? onChanged;

  final IconData? icon;

  final void Function(YesOrNoEnumType?)? onSaved;

  const YesOrNoFieldWidget(
      {super.key,
      required this.name,
      required this.label,
      this.initialValue,
      this.validators,
      this.autovalidateMode,
      this.onChanged,
      this.icon,
      this.onSaved});

  @override
  State<YesOrNoFieldWidget> createState() => _YesOrNoFieldWidgetState();
}

class _YesOrNoFieldWidgetState extends State<YesOrNoFieldWidget> {
  final List<YesOrNoEnumType> options = [
    YesOrNoEnumType.yes,
    YesOrNoEnumType.no
  ];

  /// Because of JSON serialization, it's easier to have everythings parsed as
  /// Strings in the data. But when we load the field, we need to know if the
  /// String passed from the JSON, or if a valid Enum was passed, both are
  /// acceptable input. Otherwise, assume that the field will be empty.
  YesOrNoEnumType _handleInitialValue(dynamic initialValue) {
    switch (initialValue.runtimeType) {
      case String:
        return YesOrNoEnumType.fromString(initialValue as String);
      case YesOrNoEnumType:
        return initialValue as YesOrNoEnumType;
      default:
        return YesOrNoEnumType.empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return YesOrNoFieldType(
      name: widget.name,
      initialValue: _handleInitialValue(widget.initialValue),
      options: options
          .map((e) => FormBuilderFieldOption<YesOrNoEnumType>(
                value: e,
                child: Text(e.label),
              ))
          .toList(),
      decoration: InputDecoration(
          label: Text(widget.label),
          icon: widget.icon != null ? Icon(widget.icon) : null),
      validator: widget.validators,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
    );
  }
}
