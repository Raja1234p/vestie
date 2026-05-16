import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// Confirm cancel on My Borrow Request (Figma — [AppActionDialog]).
Future<void> showCancelBorrowRequestDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.cancelBorrowRequestDialogTitle,
    description: AppStrings.cancelBorrowRequestDialogBody,
    primaryLabel: AppStrings.btnYesLeave,
    secondaryLabel: AppStrings.btnNo,
    primaryColor: AppColors.green800,
    onPrimary: () async {
      Navigator.of(context).pop();
      if (!context.mounted) return;
      await showBorrowRequestCancelledDialog(context);
      if (!context.mounted) return;
      onConfirm();
    },
  );
}

/// Shown after user confirms cancel (Figma — badge icon + OK).
Future<void> showBorrowRequestCancelledDialog(BuildContext context) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.borrowRequestCancelledTitle,
    description: AppStrings.borrowRequestCancelledBody,
    onPrimary: () => Navigator.of(context).pop(),
  );
}
