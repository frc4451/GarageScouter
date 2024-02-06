import 'package:flutter/material.dart';

/// Since the initial versino, WillPopScope is deprecated.
///
/// However, as of writing, we do not have an asynchronous way to handle user
/// dialogs with `PopScope` or `PopEntry` without a dedicated
/// NavigatorState. This stateless widget aims to resolve that.
///
/// Please follow the following GitHub discussion
/// in case this changes.
/// https://github.com/flutter/flutter/issues/138614
class MayPopScope extends StatelessWidget {
  /// Child widget that's viewable by default.
  final Widget child;

  /// Function to call when the widget is popped. If working with an async
  /// action such as a dialog, you may need to wrap your code such that
  ///
  /// ```
  /// onPop: () async => _onPop()
  /// ```
  final Function onWillPop;

  const MayPopScope({super.key, required this.child, required this.onWillPop});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }

          final NavigatorState navigator = Navigator.of(context);
          final bool shouldPop = await onWillPop();

          if (shouldPop) {
            navigator.pop();
          }
        },
        child: child);
  }
}
