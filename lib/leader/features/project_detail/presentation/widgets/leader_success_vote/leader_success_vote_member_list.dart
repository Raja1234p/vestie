import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

/// “Member Votes” list with Agreed / Disagreed / Waiting badges (Figma).
class LeaderSuccessVoteMemberList extends StatelessWidget {
  final List<LeaderSuccessVoteMemberRow> members;

  const LeaderSuccessVoteMemberList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          AppStrings.userSuccessVoteMemberVotesLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.grey1100,
              ),
        ),
        SizedBox(height: 10.h),
        ...members.map(
          (m) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _MemberVoteRow(member: m),
          ),
        ),
      ],
    );
  }
}

class _MemberVoteRow extends StatelessWidget {
  final LeaderSuccessVoteMemberRow member;

  const _MemberVoteRow({required this.member});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg, border) = switch (member.status) {
      LeaderMemberVoteStatus.agreed => (
          AppStrings.projectVoteAgreedLabel,
          AppColors.green900,
          AppColors.green100,
          AppColors.green300,
        ),
      LeaderMemberVoteStatus.disagreed => (
          AppStrings.projectVoteDisagreedLabel,
          AppColors.red800,
          AppColors.red100,
          AppColors.red300,
        ),
      LeaderMemberVoteStatus.waiting => (
          AppStrings.leaderSuccessVoteStatusWaiting,
          AppColors.neutral700,
          AppColors.grey100,
          AppColors.neutral500,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              member.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey1100,
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: border),
            ),
            child: AppText(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
