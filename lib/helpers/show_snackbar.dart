import 'package:flutter/material.dart';

enum SnackBarType { info, error }

void showSnackBar(BuildContext context, String message, {SnackBarType type = SnackBarType.info}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: type == SnackBarType.error ? Colors.red : Colors.blue,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// Convenience functions
void showErrorSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, type: SnackBarType.error);
}

void showInfoSnackBar(BuildContext context, String message) {
  showSnackBar(context, message);
}