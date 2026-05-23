import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Agreed / Disagreed / Not yet voted summary row (Figma leader success vote).
class LeaderSuccessVoteTallyCards extends StatelessWidget {
  final int agreedCount;
  final int disagreedCount;
  final int notVotedCount;

  const LeaderSuccessVoteTallyCards({
    super.key,
    required this.agreedCount,
    required this.disagreedCount,
    required this.notVotedCount,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.grey800,
        );

    return Row(
      children: [
        Expanded(
          child: _TallyCard(
            label: AppStrings.projectVoteAgreedLabel,
            count: agreedCount,
            backgroundColor: AppColors.green100,
            borderColor: AppColors.green300,
            countColor: AppColors.green800,
            labelStyle: labelStyle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _TallyCard(
            label: AppStrings.projectVoteDisagreedLabel,
            count: disagreedCount,
            backgroundColor: AppColors.red100,
            borderColor: AppColors.red300,
            countColor: AppColors.red900,
            labelStyle: labelStyle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _TallyCard(
            label: AppStrings.leaderSuccessVoteNotYetVoted,
            count: notVotedCount,
            backgroundColor: AppColors.searchBarBg,
            borderColor: AppColors.border,
            countColor: AppColors.grey800,
            labelStyle: labelStyle,
          ),
        ),
      ],
    );
  }
}

class _TallyCard extends StatelessWidget {
  final String label;
  final int count;
  final Color backgroundColor;
  final Color borderColor;
  final Color countColor;
  final TextStyle? labelStyle;

  const _TallyCard({
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.borderColor,
    required this.countColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          AppText(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: labelStyle,
          ),
          SizedBox(height: 6.h),
          AppText(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  color: countColor,
                ),
          ),
        ],
      ),
    );
  }
}
