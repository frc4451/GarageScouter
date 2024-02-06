import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:garagescouter/validators/custom_text_validators.dart';

/// Text Field component that utilizes Visibility to show in the display
/// only when `showWhen` passed to the component is `true`.
/// Does not extend the FormBuilderState, but uses FormBuilderTextField
/// in the child to Visitbility.
class ConditionalHiddenTextField extends StatefulWidget {
  /// Name of the field when pulling it from currentState
  final String name;

  /// Display name for the counter. This is optional so we can default to `name`
  final String? label;

  /// Optionally have data prepopulated
  final String? initialValue;

  /// Maximum length of string input allowed
  final int maxLength;

  /// Maximum lines allowed for text input
  final int maxLines;

  /// Shows when we want to display input for the field
  final bool showWhen;

  const ConditionalHiddenTextField(
      {super.key,
      required this.name,
      this.label,
      this.initialValue,
      this.maxLength = 1024,
      this.maxLines = 3,
      this.showWhen = false});

  @override
  State<ConditionalHiddenTextField> createState() =>
      _ConditionalHiddenTextFieldState();
}

class _ConditionalHiddenTextFieldState
    extends State<ConditionalHiddenTextField> {
  @override
  Widget build(context) {
    return Visibility(
        visible: widget.showWhen,
        replacement: const SizedBox.shrink(),
        maintainState: true,
        child: FormBuilderTextField(
          name: widget.name,
          initialValue: widget.initialValue,
          decoration: InputDecoration(
              labelText: widget.label ??
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
