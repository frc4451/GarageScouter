import 'package:flutter/material.dart';

bool hasPattern(String? value, String pattern) =>
    value != null && value.contains(pattern);

/// Handles all Custom Text Validators not native to FormBuilderValidators that we like to have
class CustomTextValidators {
  /// Checks if the form field has commas, and if not, prevent the user from submitting the form.
  /// This is because we don't want to deal with comma in text issues in CSVs.
  static FormFieldValidator<String> doesNotHaveCommas<T>({
    String? errorText,
  }) {
    return (String? valueCandidate) {
      return hasPattern(valueCandidate, ",")
          ? errorText ?? "No commas allowed in Text Input"
          : null;
    };
  }
}
