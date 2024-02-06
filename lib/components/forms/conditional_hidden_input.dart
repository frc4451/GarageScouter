import 'package:flutter/material.dart';

/// FormBuilder Custom Field to conditionally show Form Input
class ConditionalHiddenField extends StatefulWidget {
  /// Shows when we want to display input for the field
  final bool showWhen;

  /// Widget to be shown when `showWhen` is set to true
  final Widget child;

  const ConditionalHiddenField(
      {super.key, required this.child, this.showWhen = false});

  @override
  State<ConditionalHiddenField> createState() => _ConditionalHiddenFieldState();
}

class _ConditionalHiddenFieldState extends State<ConditionalHiddenField> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: widget.showWhen,
        replacement: const SizedBox.shrink(),
        maintainState: true,
        child: widget.child);
  }
}
