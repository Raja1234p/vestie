import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card_rows.dart';

import '../models/success_vote_cast_choice.dart';
import '../models/success_vote_cast_copy.dart';
import '../models/success_vote_cast_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_voting_member_vote_list.dart';
import 'success_vote_cast_member_votes.dart';

/// Banner, deadline, member votes, and financial summary (cast vote).
class SuccessVoteCastBody extends StatelessWidget {
  final SuccessVoteCastUiData data;
  final SuccessVoteCastCopy copy;
  final SuccessVoteCastChoice choice;
  final bool showPerMemberVoteRoster;

  const SuccessVoteCastBody({
    super.key,
    required this.data,
    required this.copy,
    required this.choice,
    this.showPerMemberVoteRoster = false,
  });

  @override
  Widget build(BuildContext context) {
    final g = formatProjectInfoAmount(data.goalAmount);
    final r = formatProjectInfoAmount(data.totalRaised);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusBanner(choice: choice, copy: copy),
        if (choice == SuccessVoteCastChoice.pending) ...[
          SizedBox(height: 12.h),
          _DeadlineCard(
            label: copy.deadlineLabel,
            value:
                '${data.deadlineLabel} (${data.daysRemaining} days remaining)',
          ),
        ],
        SizedBox(height: 12.h),
        SuccessVoteCastMemberVotes(
          copy: copy,
          thumbsUp: data.thumbsUp,
          thumbsDown: data.thumbsDown,
          notVoted: data.notVoted,
        ),
        if (showPerMemberVoteRoster && data.memberVotes.isNotEmpty) ...[
          SizedBox(height: 20.h),
          ProjectVotingMemberVoteList(members: data.memberVotes),
        ],
        SizedBox(height: 20.h),
        _FinancialSummaryCard(
          copy: copy,
          goal: g,
          members: data.memberCount,
          raised: r,
        ),
      ],
    );
  }
}

/// @deprecated Use [SuccessVoteCastBody].
typedef MemberSuccessVoteBody = SuccessVoteCastBody;

class _StatusBanner extends StatelessWidget {
  final SuccessVoteCastChoice choice;
  final SuccessVoteCastCopy copy;

  const _StatusBanner({required this.choice, required this.copy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.grey1100,
    );
    final bodyStyle = choice == SuccessVoteCastChoice.pending
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
      SuccessVoteCastChoice.pending => (
        copy.pendingBannerTitle,
        copy.pendingBannerBody,
      ),
      SuccessVoteCastChoice.agreed => (copy.agreedTitle, copy.agreedBody),
      SuccessVoteCastChoice.disagreed => (
        copy.disagreedTitle,
        copy.disagreedBody,
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
          AppText(title, textAlign: TextAlign.center, style: titleStyle),
          SizedBox(height: 6.h),
          AppText(body, textAlign: TextAlign.center, style: bodyStyle),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String label;
  final String value;

  const _DeadlineCard({required this.label, required this.value});

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
            label,
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
  final SuccessVoteCastCopy copy;
  final String goal;
  final int members;
  final String raised;

  const _FinancialSummaryCard({
    required this.copy,
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
            label: copy.statGoalLabel,
            value: '\$$goal',
            labelStyle: statLabelStyle,
            valueStyle: statValueStyle,
          ),
          SizedBox(height: 15.h),
          _SummaryRow(
            label: copy.statMembersLabel,
            value: '$members',
            labelStyle: statLabelStyle,
            valueStyle: statValueStyle,
          ),
          _divider(),
          _SummaryRow(
            label: copy.totalRaisedLabel,
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
