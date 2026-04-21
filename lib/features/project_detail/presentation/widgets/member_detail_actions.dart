import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_action_dialog.dart';
import '../../../../core/widgets/text/app_text.dart';

class LeaderActionOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const LeaderActionOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.red700.withValues(alpha: 0.65)),
        ),
        child: Center(
          child: AppText(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red900,
                ),
          ),
        ),
      ),
    );
  }
}

Future<void> showRemoveMemberConfirm(
  BuildContext context, {
  required String memberName,
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.removeMemberTitle(memberName),
    description: AppStrings.removeMemberBody(memberName),
    primaryLabel: AppStrings.btnRemove,
    primaryColor: AppColors.red800,
    onPrimary: () => Navigator.of(context).pop(),
  );
}

Future<void> showMarkDefaultedConfirm(BuildContext context) {
  return AppActionDialog.show(
    context,
    title: AppStrings.markDefaultedConfirmTitle,
    description: AppStrings.markDefaultedConfirmBody,
    primaryLabel: AppStrings.markAsDefaulted,
    primaryColor: AppColors.red800,
    onPrimary: () => Navigator.of(context).pop(),
  );
}

Future<void> showMakeCoLeaderFlow(
  BuildContext context, {
  required String memberName,
  required String projectName,
}) async {
  await AppActionDialog.show(
    context,
    title: AppStrings.makeCoLeaderConfirmTitle,
    description: AppStrings.makeCoLeaderDescription(memberName),
    primaryLabel: AppStrings.btnMakeCoLeader,
    primaryColor: AppColors.purple800,
    onPrimary: () => Navigator.of(context).pop(),
  );
  if (!context.mounted) return;
  await AppActionDialog.show(
    context,
    title: AppStrings.coLeaderAssignedTitle,
    description: AppStrings.coLeaderAssignedDescription(memberName, projectName),
    primaryLabel: AppStrings.btnOk,
    showSecondary: false,
    primaryColor: Colors.transparent,
    primaryTextColor: AppColors.neutral1200,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.projectCreatedImage,
    onPrimary: () => Navigator.of(context).pop(),
  );
}

Future<void> showRemoveCoLeaderFlow(
  BuildContext context, {
  required String memberName,
  required String projectName,
}) async {
  await AppActionDialog.show(
    context,
    title: AppStrings.removeCoLeaderConfirmTitle,
    description: AppStrings.removeCoLeaderDescription(memberName),
    primaryLabel: AppStrings.btnRemoveCoLeader,
    secondaryLabel: AppStrings.btnCancel,
    primaryColor: AppColors.red800,
    onPrimary: () => Navigator.of(context).pop(),
  );
  if (!context.mounted) return;
  await AppActionDialog.show(
    context,
    title: AppStrings.coLeaderRemovedTitle,
    description: AppStrings.coLeaderRemovedDescription(memberName, projectName),
    primaryLabel: AppStrings.btnOk,
    showSecondary: false,
    primaryColor: Colors.transparent,
    primaryTextColor: AppColors.neutral1200,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.failureIcon,
    onPrimary: () => Navigator.of(context).pop(),
  );
}
