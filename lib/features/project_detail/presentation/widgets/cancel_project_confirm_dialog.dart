import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_action_dialog.dart';

Future<void> showCancelProjectConfirmDialog(
  BuildContext context, {
  required String projectName,
  required VoidCallback onConfirm,
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.cancelProjectConfirmTitle(projectName),
    description: '',
    descriptionWidget: const SizedBox.shrink(),
    primaryLabel: AppStrings.btnYesCancel,
    primaryColor: AppColors.red800,
    onPrimary: () {
      Navigator.of(context).pop();
      onConfirm();
    },
  );
}
