import 'package:flutter/material.dart';

/// Dismisses the top [AppActionDialog] route only.
///
/// Host screens (borrow list, member detail, etc.) stay open after the dialog
/// closes — only pop the host when the action itself removes the screen
/// (e.g. remove member).
VoidCallback popDialogAction(BuildContext context) {
  return () => Navigator.of(context).pop();
}
