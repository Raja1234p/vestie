import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/project_detail/presentation/models/member_vote_outcome_ui_data.dart';

/// Mint status card with amount (Figma vote outcome).
class MemberVoteOutcomeAmountCard extends StatelessWidget {
  final MemberVoteOutcomeUiData data;

  const MemberVoteOutcomeAmountCard({super.key, required this.data});

  static BoxDecoration _cardDecoration({
    required BorderRadius radius,
    required bool isApproved,
  }) => BoxDecoration(
    color: isApproved ? AppColors.green100 : AppColors.red100,
    borderRadius: radius,
    border: Border.all(
      color: isApproved ? AppColors.green300 : AppColors.red300,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final caption = data.isApproved
        ? AppStrings.projectVoteFundsReleasedToGlWallet
        : AppStrings.projectVoteContributionsRefunding;
    final radius = BorderRadius.circular(12.r);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(radius: radius, isApproved: data.isApproved),
      child: Column(
        children: [
          AppText(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 6.h),
          AppText(
            '\$${data.formattedAmountUsd}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: data.isApproved ? AppColors.green900 : AppColors.red900,
            ),
          ),
        ],
      ),
    );
  }
}
