import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// Confirmation before starting the success vote (leader flow).
Future<void> showStartSuccessVoteDialog(
  BuildContext context, {
  required int memberCount,
  required VoidCallback onStarted,
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.startSuccessVoteDialogTitle,
    description: AppStrings.startSuccessVoteDialogBody(memberCount),
    primaryLabel: AppStrings.btnStartVoting,
    primaryColor: AppColors.green800,
    onPrimary: () {
      Navigator.of(context).pop();
      onStarted();
    },
  );
}
