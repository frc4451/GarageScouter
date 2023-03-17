import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../validators/custom_text_validators.dart';

class OptionalShrinkableField extends FormBuilderField<String> {
// class OptionalShrinkableField extends StatefulWidget {
  /// Name of the field when pulling it from currentState
  final String name;

  /// Display name for the counter. This is optional so we can default to `name`
  final String? label;

  /// Optionally have data prepopulated
  @override
  final String? initialValue;

  /// Maximum length of string input allowed
  final int maxLength;

  /// Maximum lines allowed for text input
  final int maxLines;

  /// Shows when we want to display input for the field
  bool showWhen;

  OptionalShrinkableField(
      {super.key,
      required this.name,
      this.label,
      this.showWhen = true,
      this.initialValue = "",
      this.maxLength = 256,
      this.maxLines = 3})
      : super(
            name: name,
            initialValue: initialValue,
            builder: (FormFieldState<String> field) {
              return Visibility(
                  visible: showWhen,
                  replacement: const SizedBox.shrink(),
                  maintainState: true,
                  child: TextFormField(
                    initialValue: initialValue,
                    decoration: const InputDecoration(
                        labelText:
                            "Describe the Drive Train to the best of your ability"),
                    maxLength: maxLength,
                    maxLines: maxLines,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.compose([
                      // we only mark the field as required
                      // if the field is visible on the form.
                      if (showWhen) FormBuilderValidators.required(),
                      CustomTextValidators.doesNotHaveCommas()
                    ]),
                    onChanged: (String? newValue) {
                      field.didChange(newValue);
                    },
                  ));
            });

  @override
  FormBuilderFieldState<OptionalShrinkableField, String> createState() =>
      _OptionalShrinkableFieldState();
}

class _OptionalShrinkableFieldState
    extends FormBuilderFieldState<OptionalShrinkableField, String> {
  // /// We basically check if it's a null value and give it a default
  // /// empty string in the event that it doesn't get a valid type.
  @override
  void didChange(String? value) {
    setState(() {
      super.didChange(value ?? "");
    });
  }

  /// When we reset, we care about three items:
  /// 1. Clear the value of the String input
  /// 2. Disable showing the form input
  /// 3. Call the parent constructor to reset any internals
  @override
  void reset() {
    super.didChange("");
    super.reset();
  }

  @override
  Widget build(context) {
    return Visibility(
        visible: widget.showWhen,
        replacement: const SizedBox.shrink(),
        maintainState: true,
        child: TextFormField(
          initialValue: initialValue,
          decoration: const InputDecoration(
              labelText:
                  "Describe the Drive Train to the best of your ability"),
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: FormBuilderValidators.compose([
            // we only mark the field as required
            // if the field is visible on the form.
            if (widget.showWhen) FormBuilderValidators.required(),
            CustomTextValidators.doesNotHaveCommas()
          ]),
        ));
  }
}
