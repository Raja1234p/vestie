import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Outlined “Send VFF Request” CTA on project member rows (Figma).
class ProjectMemberAddFriendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool requestSent;

  const ProjectMemberAddFriendButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.requestSent = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.r12);
    final sent = requestSent;

    return Material(
      color: sent ? AppColors.vffRequestSentChipBg : AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: isLoading || sent ? null : onPressed,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.p12,
            vertical: AppDimens.v8,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: sent
                ? null
                : Border.all(
                    color: AppColors.projectMemberAddFriendBorder,
                    width: 1,
                  ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.purple700,
                  ),
                )
              : AppText(
                  sent
                      ? AppStrings.btnVffRequestSent
                      : AppStrings.btnSendVffRequest,
                  style: AppTextStyles.projectMemberAddFriend.copyWith(
                    fontWeight: sent ? FontWeight.w600 : FontWeight.w600,
                    color: AppColors.neutral1200,
                  ),
                ),
        ),
      ),
    );
  }
}
