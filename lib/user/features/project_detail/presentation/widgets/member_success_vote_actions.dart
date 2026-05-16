import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../models/member_success_vote_ui_data.dart';

/// Vote CTAs or post-vote “Back to Home” (Figma).
class MemberSuccessVoteActions extends StatelessWidget {
  final MemberSuccessVoteChoice choice;
  final bool isLoading;
  final VoidCallback onVoteYes;
  final VoidCallback onVoteNo;

  const MemberSuccessVoteActions({
    super.key,
    required this.choice,
    this.isLoading = false,
    required this.onVoteYes,
    required this.onVoteNo,
  });

  @override
  Widget build(BuildContext context) {
    if (choice != MemberSuccessVoteChoice.pending) {
      return AppOutlineNeutralButton(
        label: AppStrings.btnBackToHome,
        onPressed: () => context.go(AppRoutes.dashboard),
        borderRadius: AppRadius.r8,
        borderColor: AppColors.backToHomeButtonBorder,
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          AppStrings.userSuccessVoteQuestion,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey1100,
            height: 1.3,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: AppOutlineNeutralButton(
                label: AppStrings.userSuccessVoteNotYet,
                onPressed: isLoading ? () {} : onVoteNo,
                borderRadius: AppRadius.r24,
                borderColor: AppColors.primary,
                labelColor: AppColors.grey1100,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AppButton(
                text: AppStrings.userSuccessVoteYes,
                isLoading: isLoading,
                onPressed: isLoading ? null : onVoteYes,
                useGradient: true,
                borderRadius: AppRadius.r24,
                height: AppDimens.buttonHeightLg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
