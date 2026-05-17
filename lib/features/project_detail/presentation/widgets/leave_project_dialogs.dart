import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// Confirm leave on warning screen (Figma — same [AppActionDialog] as borrow cancel).
Future<void> showLeaveProjectConfirmDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.cancelBorrowRequestDialogTitle,
    description: AppStrings.leaveProjectConfirmDialogBody,
    primaryLabel: AppStrings.btnYesLeave,
    secondaryLabel: AppStrings.btnNo,
    primaryColor: AppColors.green800,
    onPrimary: () {
      Navigator.of(context).pop();
      onConfirm();
    },
  );
}

/// Shown after leave API succeeds (Figma — [AppAssets.projectCreatedImage] via [AppActionDialog.showSuccessOk]).
Future<void> showLeaveProjectSuccessDialog(BuildContext context) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.leaveProjectSuccessTitle,
    description: AppStrings.leaveProjectSuccessBody,
    onPrimary: () => Navigator.of(context).pop(),
  );
}
