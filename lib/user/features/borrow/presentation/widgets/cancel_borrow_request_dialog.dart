import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/navigation/success_dialog_navigation.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// Confirm cancel on My Borrow Request (Figma — [AppActionDialog]).
Future<bool> showCancelBorrowRequestDialog(
  BuildContext context, {
  required Future<bool> Function() onConfirm,
}) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.cancelBorrowRequestDialogTitle,
    description: AppStrings.cancelBorrowRequestDialogBody,
    primaryLabel: AppStrings.btnYesLeave,
    secondaryLabel: AppStrings.btnNo,
    primaryColor: AppColors.green800,
    onPrimary: onConfirm,
  );
  if (!context.mounted || !ok) return false;
  await showBorrowRequestCancelledDialog(context);
  return true;
}

/// Shown after cancel API succeeds (Figma — badge icon + OK).
Future<void> showBorrowRequestCancelledDialog(BuildContext context) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.borrowRequestCancelledTitle,
    description: AppStrings.borrowRequestCancelledBody,
    onPrimary: popDialogAction(context),
  );
}
