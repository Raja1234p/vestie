import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

Future<void> showMemberDetailErrorDialog(
  BuildContext context, {
  required Failure failure,
}) {
  return AppActionDialog.show(
    context,
    title: FailureMapper.dialogTitle(failure),
    description: FailureMapper.userMessage(failure),
    primaryLabel: AppStrings.btnOk,
    showSecondary: false,
    primaryColor: Colors.transparent,
    primaryTextColor: AppColors.neutral1200,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.failureIcon,
    onPrimary: () => Navigator.of(context).pop(),
  );
}

Future<void> showCoLeaderAssignedSuccess(
  BuildContext context, {
  required String memberName,
  required String projectName,
  required VoidCallback onOk,
}) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.coLeaderAssignedTitle,
    description: AppStrings.coLeaderAssignedDescription(memberName, projectName),
    onPrimary: onOk,
  );
}

Future<void> showCoLeaderRemovedSuccess(
  BuildContext context, {
  required String memberName,
  required String projectName,
  required VoidCallback onOk,
}) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.coLeaderRemovedTitle,
    description: AppStrings.coLeaderRemovedDescription(memberName, projectName),
    onPrimary: onOk,
  );
}

Future<void> showMemberRemovedSuccess(
  BuildContext context, {
  required VoidCallback onOk,
}) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.removeMemberSuccessTitle,
    description: AppStrings.removeMemberSuccessBody,
    onPrimary: onOk,
  );
}

Future<void> showMemberMarkedDefaultedSuccess(
  BuildContext context, {
  required VoidCallback onOk,
}) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.markDefaultedSuccessTitle,
    description: AppStrings.markDefaultedSuccessBody,
    onPrimary: onOk,
  );
}
