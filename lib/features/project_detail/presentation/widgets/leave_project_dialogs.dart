import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/navigation/success_dialog_navigation.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// Confirm leave — primary button loader while leave API runs.
Future<bool> showLeaveProjectConfirmDialog(
  BuildContext context, {
  required Future<bool> Function() onConfirm,
}) {
  return AppActionDialog.showAsync(
    context,
    title: AppStrings.cancelBorrowRequestDialogTitle,
    description: AppStrings.leaveProjectConfirmDialogBody,
    primaryLabel: AppStrings.btnYesLeave,
    secondaryLabel: AppStrings.btnNo,
    primaryColor: AppColors.green800,
    onPrimary: onConfirm,
  );
}

/// Shown after leave API succeeds — success image + Back to Home.
Future<void> showLeaveProjectSuccessDialog(BuildContext context) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.leaveProjectSuccessTitle,
    description: AppStrings.leaveProjectSuccessBody,
    primaryLabel: AppStrings.btnBackToHome,
    onPrimary: popDialogAction(context),
  );
}
