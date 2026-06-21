import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import '../models/success_vote_cast_copy.dart';

/// Three-column member vote tally on the cast-vote screen.
class SuccessVoteCastMemberVotes extends StatelessWidget {
  final SuccessVoteCastCopy copy;
  final int thumbsUp;
  final int thumbsDown;
  final int notVoted;

  const SuccessVoteCastMemberVotes({
    super.key,
    required this.copy,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notVoted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.grey800,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          copy.memberVotesLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.grey1100,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _VoteStatCard(
                label: copy.thumbsUpLabel,
                count: thumbsUp,
                backgroundColor: AppColors.green100,
                borderColor: AppColors.green300,
                countColor: AppColors.green800,
                labelStyle: labelStyle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _VoteStatCard(
                label: copy.thumbsDownLabel,
                count: thumbsDown,
                backgroundColor: AppColors.borrowVoteDownBg,
                borderColor: AppColors.red300,
                countColor: AppColors.red900,
                labelStyle: labelStyle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _VoteStatCard(
                label: copy.notVotedLabel,
                count: notVoted,
                backgroundColor: AppColors.searchBarBg,
                borderColor: AppColors.border,
                countColor: AppColors.grey800,
                labelStyle: labelStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// @deprecated Use [SuccessVoteCastMemberVotes].
typedef MemberSuccessVoteMemberVotes = SuccessVoteCastMemberVotes;

class _VoteStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color backgroundColor;
  final Color borderColor;
  final Color countColor;
  final TextStyle? labelStyle;

  const _VoteStatCard({
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
