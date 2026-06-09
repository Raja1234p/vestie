import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import 'member_detail_result_dialogs.dart';

/// Full-width red-outline row action (penalty / legacy leader screens).
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

/// Confirm remove member — primary button loader, then success dialog.
Future<bool> showRemoveMemberFlow(
  BuildContext context, {
  required String memberName,
  required Future<bool> Function() onConfirm,
}) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.removeMemberTitle(memberName),
    description: AppStrings.removeMemberBody(memberName),
    primaryLabel: AppStrings.btnRemove,
    primaryColor: AppColors.red800,
    onPrimary: onConfirm,
  );
  if (!context.mounted || !ok) return false;
  await showMemberRemovedSuccess(
    context,
    onOk: () => Navigator.of(context).pop(),
  );
  return true;
}

/// Confirm mark defaulted — primary button loader, then success dialog.
Future<bool> showMarkDefaultedFlow(
  BuildContext context, {
  required Future<bool> Function() onConfirm,
}) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.markDefaultedConfirmTitle,
    description: AppStrings.markDefaultedConfirmBody,
    primaryLabel: AppStrings.markAsDefaulted,
    primaryColor: AppColors.red800,
    onPrimary: onConfirm,
  );
  if (!context.mounted || !ok) return false;
  await showMemberMarkedDefaultedSuccess(
    context,
    onOk: () => Navigator.of(context).pop(),
  );
  return true;
}

/// Confirm assign co-leader — primary button loader, then success dialog.
Future<bool> showMakeCoLeaderFlow(
  BuildContext context, {
  required String memberName,
  required String projectName,
  required Future<bool> Function() onConfirm,
}) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.makeCoLeaderConfirmTitle,
    description: AppStrings.makeCoLeaderDescription(memberName),
    primaryLabel: AppStrings.btnMakeCoLeader,
    primaryColor: AppColors.makeCoLeaderDialogButton,
    primaryBorderColor: AppColors.makeCoLeaderDialogButton,
    onPrimary: onConfirm,
  );
  if (!context.mounted || !ok) return false;
  await showCoLeaderAssignedSuccess(
    context,
    memberName: memberName,
    projectName: projectName,
    onOk: () => Navigator.of(context).pop(),
  );
  return true;
}

/// Confirm remove co-leader — primary button loader, then success dialog.
Future<bool> showRemoveCoLeaderFlow(
  BuildContext context, {
  required String memberName,
  required String projectName,
  required Future<bool> Function() onConfirm,
}) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.removeCoLeaderConfirmTitle,
    description: AppStrings.removeCoLeaderDescription(memberName),
    primaryLabel: AppStrings.btnRemoveCoLeader,
    secondaryLabel: AppStrings.btnCancel,
    primaryColor: AppColors.red800,
    onPrimary: onConfirm,
  );
  if (!context.mounted || !ok) return false;
  await showCoLeaderRemovedSuccess(
    context,
    memberName: memberName,
    projectName: projectName,
    onOk: () => Navigator.of(context).pop(),
  );
  return true;
}
