import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Outlined “Add Friend” CTA on project member rows (Figma).
class ProjectMemberAddFriendButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProjectMemberAddFriendButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.r12);

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.p12,
            vertical: AppDimens.v8,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: AppColors.projectMemberAddFriendBorder,
              width: 1,
            ),
          ),
          child: AppText(
            AppStrings.btnAddFriend,
            style: AppTextStyles.projectMemberAddFriend,
          ),
        ),
      ),
    );
  }
}
