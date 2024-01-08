import 'dart:io';

import 'package:flutter/material.dart';

/// Sends a green Snackbar to the ScaffoldMessenger with the `message` provider.
/// This specifically states that a file was saved, and shares the path of the
/// resulting file.
void saveFileSnackbar(BuildContext context, File file) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        "Successfully wrote file to  ${file.path}",
        textAlign: TextAlign.center,
      )));
}

/// Sends a green Snackbar to the ScaffoldMessenger with the `message` provided.
void successMessageSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        message,
        textAlign: TextAlign.center,
      )));
}

/// Sends a red Snackbar to the ScaffoldMessenger with the `toString()`
/// representation of despite the type of the `error` parameter provided. Yes,
/// `String` has a `toString()` method, and it returns the `String` value.
void errorMessageSnackbar(BuildContext context, dynamic error) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        error.toString(),
        textAlign: TextAlign.center,
      )));
}

/// Sends a basic snackbar with the ColorScheme's primary color with whatever
/// message was provided.
void informationSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: Text(
        message,
        textAlign: TextAlign.center,
      )));
}

/// Opens an AlertDialog message to return either a true or false value in order
/// to determine if the user wants to save the current form data as a draft.
Future<bool?> canSaveDraft(BuildContext context, {bool? exists = false}) async {
  bool? response = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        (exists ?? false) ? "Update Draft?" : "Keep Draft?",
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        )
      ],
    ),
  );

  return response;
}
