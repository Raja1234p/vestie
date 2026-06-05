import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

/// **Flow: Member detail / Profile (Following) → remove VFF** — destructive confirmation.
Future<bool?> showUserVffRemoveConnectionDialog(
  BuildContext context, {
  required String usernameWithoutAt,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
      child: AppActionDialog(
        title: AppStrings.userVffRemoveTitle(usernameWithoutAt),
        description: AppStrings.userVffRemoveBody,
        primaryLabel: AppStrings.btnYesRemoveVff,
        secondaryLabel: AppStrings.btnNo,
        showSecondary: true,
        actionsInRow: true,
        primaryColor: AppColors.red800,
        iconAsset: AppAssets.statusFailure,
        onPrimary: () => Navigator.of(dialogCtx).pop(true),
        onSecondary: () => Navigator.of(dialogCtx).pop(false),
      ),
    ),
  );
}
