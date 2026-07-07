import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';

/// Vote summary block — same layout for every viewer role.
class SuccessVoteOutcomeVoteSummary extends StatelessWidget {
  final SuccessVoteOutcomeUiData data;
  final SuccessVoteOutcomeCopy copy;

  const SuccessVoteOutcomeVoteSummary({
    super.key,
    required this.data,
    required this.copy,
  });

  @override
  Widget build(BuildContext context) {
    final rows = data.isApproved
        ? [
            _VoteRow.agreed(data: data, copy: copy),
            SizedBox(height: 10.h),
            _VoteRow.disagreed(data: data, copy: copy),
          ]
        : [
            _VoteRow.disagreed(data: data, copy: copy),
            SizedBox(height: 10.h),
            _VoteRow.agreed(data: data, copy: copy),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          copy.voteSummaryLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.grey1100,
          ),
        ),
        SizedBox(height: 12.h),
        ...rows,
      ],
    );
  }
}

class _VoteRow extends StatelessWidget {
  final String label;
  final int memberCount;
  final int totalMembers;
  final int percent;
  final Color labelColor;
  final Color percentColor;

  const _VoteRow({
    required this.label,
    required this.memberCount,
    required this.totalMembers,
    required this.percent,
    required this.labelColor,
    required this.percentColor,
  });

  factory _VoteRow.agreed({
    required SuccessVoteOutcomeUiData data,
    required SuccessVoteOutcomeCopy copy,
  }) {
    return _VoteRow(
      label: copy.agreedLabel,
      memberCount: data.agreedCount,
      totalMembers: data.totalMemberCount,
      percent: data.agreedPercent,
      labelColor: AppColors.green900,
      percentColor: AppColors.green900,
    );
  }

  factory _VoteRow.disagreed({
    required SuccessVoteOutcomeUiData data,
    required SuccessVoteOutcomeCopy copy,
  }) {
    return _VoteRow(
      label: copy.disagreedLabel,
      memberCount: data.disagreedCount,
      totalMembers: data.totalMemberCount,
      percent: data.disagreedPercent,
      labelColor: AppColors.red800,
      percentColor: AppColors.red800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  AppStrings.projectVoteMembersOfTotal(
                    memberCount,
                    totalMembers,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
          AppText(
            '$percent%',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: percentColor,
            ),
          ),
        ],
      ),
    );
  }
}
