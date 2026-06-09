import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// Member detail / profile — remove VFF with primary-button loader on confirm.
Future<bool> showUserVffRemoveConnectionDialog(
  BuildContext context, {
  required String usernameWithoutAt,
  required Future<bool> Function() onConfirm,
}) {
  return AppActionDialog.showAsync(
    context,
    title: AppStrings.userVffRemoveTitle(usernameWithoutAt),
    description: AppStrings.userVffRemoveBody,
    primaryLabel: AppStrings.btnYesRemoveVff,
    secondaryLabel: AppStrings.btnNo,
    showSecondary: true,
    actionsInRow: true,
    primaryColor: AppColors.red800,
    iconAsset: AppAssets.statusFailure,
    onPrimary: onConfirm,
  );
}
