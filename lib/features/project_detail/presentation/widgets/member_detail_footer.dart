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
  final bool showSendVffRequest;
  final bool vffRequestSent;
  final bool isVffRequestLoading;
  final bool showRemoveMember;
  final VoidCallback onSendVffRequest;
  final VoidCallback onRemoveMember;

  const MemberDetailFooter({
    super.key,
    this.showVffFollowing = false,
    required this.onRemoveVffConnection,
    required this.showSendVffRequest,
    this.vffRequestSent = false,
    this.isVffRequestLoading = false,
    required this.showRemoveMember,
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
              onRemove: onRemoveVffConnection,
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
                  borderRadius: AppRadius.vffHubRequestActionButton,
                  secondaryFillColor: AppColors.vffRequestSentChipBg,
                  secondaryBorderColor: AppColors.vffRequestSentChipBorder,
                  secondaryLabelColor: AppColors.vffRequestSentChipLabel,
                  secondaryLabelFontWeight: FontWeight.w600,
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
              borderRadius: AppRadius.r8,
              backgroundColor: AppColors.red100,
              borderColor: AppColors.red100,
              labelColor: AppColors.red900,
            ),
        ],
      ),
    );
  }
}
