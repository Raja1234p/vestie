import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';

/// Per-member vote rows from `GET /projects/{id}` → `voting.memberVotes[]`.
class ProjectVotingMemberVoteList extends StatelessWidget {
  final List<ProjectVotingMemberVoteEntity> members;

  const ProjectVotingMemberVoteList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          AppStrings.successVoteCastMemberVotesLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.grey1100,
          ),
        ),
        SizedBox(height: 10.h),
        ...members.map(
          (member) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _MemberVoteRow(member: member),
          ),
        ),
      ],
    );
  }
}

class _MemberVoteRow extends StatelessWidget {
  final ProjectVotingMemberVoteEntity member;

  const _MemberVoteRow({required this.member});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg, border) = switch (member.status) {
      ProjectMemberVoteStatus.agreed => (
        AppStrings.projectVoteAgreedLabel,
        AppColors.green900,
        AppColors.green100,
        AppColors.green300,
      ),
      ProjectMemberVoteStatus.disagreed => (
        AppStrings.projectVoteDisagreedLabel,
        AppColors.red800,
        AppColors.red100,
        AppColors.red300,
      ),
      ProjectMemberVoteStatus.waiting => (
        AppStrings.leaderSuccessVoteStatusWaiting,
        AppColors.neutral700,
        AppColors.grey100,
        AppColors.neutral500,
      ),
    };

    final name = member.displayName.isNotEmpty
        ? member.displayName
        : AppStrings.tabMember;

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
              name,
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
