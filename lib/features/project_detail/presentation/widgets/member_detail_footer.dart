import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/user/features/vff/presentation/widgets/vff_following_menu_button.dart';

/// Pinned footer actions on [MemberDetailScreen].
class MemberDetailFooter extends StatelessWidget {
  final bool showVffFollowing;
  final VoidCallback onRemoveVffConnection;
  final bool isRemoveVffLoading;
  final bool showSendVffRequest;
  final bool vffRequestSent;
  final bool isVffRequestLoading;
  final bool showRemoveMember;
  final bool isRemoveMemberLoading;
  final VoidCallback onSendVffRequest;
  final VoidCallback onRemoveMember;

  const MemberDetailFooter({
    super.key,
    this.showVffFollowing = false,
    required this.onRemoveVffConnection,
    this.isRemoveVffLoading = false,
    required this.showSendVffRequest,
    this.vffRequestSent = false,
    this.isVffRequestLoading = false,
    required this.showRemoveMember,
    this.isRemoveMemberLoading = false,
    required this.onSendVffRequest,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    final showSendCta = showSendVffRequest && !showVffFollowing;

    return FlowScreenFooter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showVffFollowing) ...[
            VffFollowingMenuButton(
              onRemove: isRemoveVffLoading ? null : onRemoveVffConnection,
              isRemoveLoading: isRemoveVffLoading,
            ),
            if (showRemoveMember) SizedBox(height: 12.h),
          ],
          if (showSendCta) ...[
            if (vffRequestSent)
              IgnorePointer(
                child: AppButton(
                  text: AppStrings.btnVffRequestSent,
                  onPressed: () {},
                  isSecondary: true,
                  useGradient: false,
                  hasShadow: false,
                  borderRadius: AppRadius.r8,
                  secondaryFillColor: AppColors.vffRequestSentChipBg,
                  secondaryBorderColor: Colors.transparent,
                  secondaryLabelColor: AppColors.neutral1200,
                  secondaryLabelFontWeight: FontWeight.w700,
                  labelFontSize: 18.sp,
                ),
              )
            else
              AppButton(
                text: AppStrings.btnSendVffRequest,
                onPressed: isVffRequestLoading ? null : onSendVffRequest,
                isLoading: isVffRequestLoading,
                useGradient: false,
                hasShadow: false,
                color: AppColors.neutral1200,
                borderRadius: AppRadius.r8,
                labelFontSize: 14.sp,
              ),
            if (showRemoveMember) SizedBox(height: 12.h),
          ],
          if (showRemoveMember)
            AppOutlineNeutralButton(
              label: AppStrings.btnRemoveMember,
              onPressed: onRemoveMember,
              isLoading: isRemoveMemberLoading,
              borderRadius: AppRadius.r8,
              borderColor: AppColors.red900,
              labelColor: AppColors.red900,
            ),
        ],
      ),
    );
  }
}
