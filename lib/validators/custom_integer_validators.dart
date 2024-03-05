import 'package:flutter/material.dart';

/// Handles all Custom Integer Validators not native to FormBuilderValidators that we like to have
class CustomIntegerValidators {
  /// We don't want negative numbers, simple as that.
  static FormFieldValidator<String> notNegative<T>({
    String? errorText,
  }) {
    return (String? valueCandidate) {
      return (int.tryParse(valueCandidate ?? "0") ?? 0) < 0
          ? errorText ?? "Numerical input cannot be less than 0."
          : null;
    };
  }
}
