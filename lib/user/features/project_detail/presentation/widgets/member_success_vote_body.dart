import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card_rows.dart';
import '../models/member_success_vote_ui_data.dart';
import 'member_success_vote_member_votes.dart';

/// Banner, deadline, member votes, and financial summary (Figma success vote).
class MemberSuccessVoteBody extends StatelessWidget {
  final MemberSuccessVoteUiData data;
  final MemberSuccessVoteChoice choice;

  const MemberSuccessVoteBody({
    super.key,
    required this.data,
    required this.choice,
  });

  @override
  Widget build(BuildContext context) {
    final g = formatProjectInfoAmount(data.goalAmount);
    final r = formatProjectInfoAmount(data.totalRaised);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusBanner(choice: choice),
        if (choice == MemberSuccessVoteChoice.pending) ...[
          SizedBox(height: 12.h),
          _DeadlineCard(
            value:
                '${data.deadlineLabel} (${data.daysRemaining} days remaining)',
          ),
        ],
        SizedBox(height: 12.h),
        MemberSuccessVoteMemberVotes(
          thumbsUp: data.thumbsUp,
          thumbsDown: data.thumbsDown,
          notVoted: data.notVoted,
        ),
        SizedBox(height: 20.h),
        _FinancialSummaryCard(goal: g, members: data.memberCount, raised: r),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final MemberSuccessVoteChoice choice;

  const _StatusBanner({required this.choice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.grey1100,
    );
    final bodyStyle = choice == MemberSuccessVoteChoice.pending
        ? theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey800,
            height: 1.45,
          )
        : theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey900,
            height: 1.5,
          );

    final (title, body) = switch (choice) {
      MemberSuccessVoteChoice.pending => (
          AppStrings.userSuccessVoteBannerTitle,
          AppStrings.userSuccessVoteBannerBody,
        ),
      MemberSuccessVoteChoice.agreed => (
          AppStrings.userSuccessVoteAgreedTitle,
          AppStrings.userSuccessVoteAgreedBody,
        ),
      MemberSuccessVoteChoice.disagreed => (
          AppStrings.userSuccessVoteDisagreedTitle,
          AppStrings.userSuccessVoteDisagreedBody,
        ),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          SizedBox(height: 6.h),
          AppText(
            body,
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String value;

  const _DeadlineCard({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.userSuccessVoteDeadlineLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 5.h),
          AppText(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey1100,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  final String goal;
  final int members;
  final String raised;

  const _FinancialSummaryCard({
    required this.goal,
    required this.members,
    required this.raised,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.neutral700,
    );
    final statValueStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.grey1100,
    );
    final totalRaisedLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.grey1100,
    );
    final totalRaisedValueStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.green900,
    );
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: AppStrings.userSuccessVoteStatGoal,
            value: '\$$goal',
            labelStyle: statLabelStyle,
            valueStyle: statValueStyle,
          ),
          SizedBox(height: 15.h),
          _SummaryRow(
            label: AppStrings.userSuccessVoteStatMembers,
            value: '$members',
            labelStyle: statLabelStyle,
            valueStyle: statValueStyle,
          ),
          _divider(),
          _SummaryRow(
            label: AppStrings.userSuccessVoteTotalRaised,
            value: '\$$raised',
            labelStyle: totalRaisedLabelStyle,
            valueStyle: totalRaisedValueStyle,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppText(label, style: labelStyle)),
        AppText(value, style: valueStyle),
      ],
    );
  }
}

Widget _divider() => Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Divider(height: 1, color: AppColors.neutral400),
    );
