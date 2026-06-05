import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
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

/// Shown after leave API succeeds — [AppAssets.projectCreatedImage] + Back to Home.
Future<void> showLeaveProjectSuccessDialog(BuildContext context) {
  return AppActionDialog.show(
    context,
    title: AppStrings.leaveProjectSuccessTitle,
    description: AppStrings.leaveProjectSuccessBody,
    primaryLabel: AppStrings.btnBackToHome,
    showSecondary: false,
    primaryColor: AppColors.neutral1200,
    primaryTextColor: AppColors.surface,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.projectCreatedImage,
    onPrimary: () => Navigator.of(context).pop(),
  );
}
