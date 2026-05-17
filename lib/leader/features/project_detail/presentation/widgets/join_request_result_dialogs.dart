import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';

Widget _descriptionWithHighlightedName(
  BuildContext context, {
  required String prefix,
  required String memberName,
}) {
  final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 16.sp,
        color: AppColors.grey900,
        height: 1.5,
      );
  final highlighted = base?.copyWith(
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: base,
      children: [
        TextSpan(text: prefix),
        TextSpan(text: memberName, style: highlighted),
      ],
    ),
  );
}

Future<void> showJoinRequestApprovedDialog(
  BuildContext context, {
  required String memberName,
  required VoidCallback onOk,
}) {
  return AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.joinRequestApprovedTitle,
    descriptionWidget: _descriptionWithHighlightedName(
      context,
      prefix: AppStrings.joinRequestApprovedPrefix,
      memberName: memberName,
    ),
    onPrimary: onOk,
  );
}

Future<void> showJoinRequestDeclinedDialog(
  BuildContext context, {
  required String memberName,
  required VoidCallback onOk,
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.joinRequestDeclinedTitle,
    description: '',
    descriptionWidget: _descriptionWithHighlightedName(
      context,
      prefix: 'You’ve declined the join request from ',
      memberName: memberName,
    ),
    primaryLabel: AppStrings.btnOk,
    showSecondary: false,
    primaryColor: Colors.transparent,
    primaryTextColor: AppColors.neutral1200,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.failureIcon,
    onPrimary: onOk,
  );
}
