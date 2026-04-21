import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_action_dialog.dart';
import '../../../../core/widgets/text/app_text.dart';

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
}) {
  return AppActionDialog.show(
    context,
    title: AppStrings.joinRequestApprovedTitle,
    description: '',
    descriptionWidget: _descriptionWithHighlightedName(
      context,
      prefix: 'You’ve approved the join request from ',
      memberName: memberName,
    ),
    primaryLabel: AppStrings.btnOk,
    showSecondary: false,
    primaryColor: Colors.transparent,
    primaryTextColor: Colors.black,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.projectCreatedImage,
    onPrimary: () => Navigator.of(context).pop(),
  );
}

Future<void> showJoinRequestDeclinedDialog(
  BuildContext context, {
  required String memberName,
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
    primaryTextColor: Colors.black,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.failureIcon,
    onPrimary: () => Navigator.of(context).pop(),
  );
}
