import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';

Future<void> showMemberDetailErrorDialog(
  BuildContext context, {
  required Failure failure,
}) {
  AppToast.showApiFailure(context, failure);
  return Future.value();
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
