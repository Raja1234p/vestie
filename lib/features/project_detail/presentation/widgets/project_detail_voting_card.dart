import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/project_detail_voting_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';

/// Week 11+ voting card on project detail — switches on [ProjectVotingStatus].
class ProjectDetailVotingCard extends StatelessWidget {
  final ProjectDetailEntity project;
  final Future<void> Function() onRefresh;

  const ProjectDetailVotingCard({
    super.key,
    required this.project,
    required this.onRefresh,
  });

  void _onStartVoting(BuildContext context) {
    final flowKind = project.resolveLeaderVotingFlowKindForStart();
    context.push(
      AppRoutes.votingWindow,
      extra: VotingWindowRouteArgs(
        projectId: project.id,
        flowKind: flowKind,
        projectCategory: project.category,
      ),
    );
  }

  void _onViewVotes(BuildContext context) {
    ProjectDetailNavigation.openLeaderViewSuccessVotes(
      context,
      project: project,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            AppStrings.projectDetailVotingCardTitle,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.grey1100,
            ),
          ),
          SizedBox(height: 12.h),
          switch (project.votingStatus) {
            ProjectVotingStatus.notStarted => _NotStartedBody(
              project: project,
              onStartVoting: () => _onStartVoting(context),
            ),
            ProjectVotingStatus.pending => _PendingOrDoneBody(
              project: project,
              showResultSummary: false,
              onViewVotes: () => _onViewVotes(context),
            ),
            ProjectVotingStatus.done => _PendingOrDoneBody(
              project: project,
              showResultSummary: true,
              onViewVotes: () => _onViewVotes(context),
            ),
          },
        ],
      ),
    );
  }
}

class _NotStartedBody extends StatelessWidget {
  final ProjectDetailEntity project;
  final VoidCallback onStartVoting;

  const _NotStartedBody({
    required this.project,
    required this.onStartVoting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          AppStrings.projectVotingNotStartedMessage,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            color: AppColors.grey900,
            height: 1.4,
          ),
        ),
        if (project.canStartVotingOnDetail) ...[
          SizedBox(height: 14.h),
          AppButton(
            text: AppStrings.btnStartVoting,
            useGradient: false,
            hasShadow: false,
            color: AppColors.green800,
            borderRadius: AppRadius.r100,
            onPressed: onStartVoting,
          ),
        ],
      ],
    );
  }
}

class _PendingOrDoneBody extends StatelessWidget {
  final ProjectDetailEntity project;
  final bool showResultSummary;
  final VoidCallback onViewVotes;

  const _PendingOrDoneBody({
    required this.project,
    required this.showResultSummary,
    required this.onViewVotes,
  });

  @override
  Widget build(BuildContext context) {
    final voting = project.voting;
    if (voting == null) return const SizedBox.shrink();

    final started = formatProjectVotingDateTime(voting.startedAtUtc);
    final deadline = formatProjectVotingDateTime(voting.deadlineAtUtc);
    final daysRemaining = projectVotingDaysRemaining(voting.deadlineAtUtc);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScheduleRow(
          label: AppStrings.projectVotingStartedLabel,
          value: started,
        ),
        SizedBox(height: 8.h),
        _ScheduleRow(
          label: AppStrings.projectVotingDeadlineLabel,
          value: AppStrings.projectVotingEndsOn(deadline, daysRemaining),
        ),
        SizedBox(height: 14.h),
        if (showResultSummary) ...[
          _VoteProgressBar(
            label: AppStrings.projectVotingAgreedLabel,
            value: voting.agreedPercent,
            color: AppColors.green600,
          ),
          SizedBox(height: 8.h),
          _VoteProgressBar(
            label: AppStrings.projectVotingDisagreedLabel,
            value: voting.disagreedPercent,
            color: AppColors.red600,
          ),
          SizedBox(height: 8.h),
          _VoteProgressBar(
            label: AppStrings.projectVotingPendingLabel,
            value: voting.pendingPercent,
            color: AppColors.grey500,
          ),
          SizedBox(height: 14.h),
        ],
        _VoteCountRow(
          agreed: voting.agreedCount,
          disagreed: voting.disagreedCount,
          pending: voting.pendingCount,
        ),
        if (project.showsMemberVoteSubmittedLabel) ...[
          SizedBox(height: 14.h),
          AppText(
            AppStrings.projectVotingVoteSubmitted,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.green800,
            ),
          ),
        ],
        if (project.isDetailModeratorForVoting) ...[
          SizedBox(height: 14.h),
          AppButton(
            text: AppStrings.btnViewVotes,
            onPressed: onViewVotes,
            useGradient: false,
            hasShadow: false,
            color: AppColors.grey1200,
            borderRadius: AppRadius.r100,
          ),
        ],
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScheduleRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: AppText(
            label,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
        ),
        Expanded(
          child: AppText(
            value,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey1100,
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteCountRow extends StatelessWidget {
  final int agreed;
  final int disagreed;
  final int pending;

  const _VoteCountRow({
    required this.agreed,
    required this.disagreed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountChip(
            label: AppStrings.projectVotingAgreedLabel,
            count: agreed,
            color: AppColors.green800,
            background: AppColors.green100,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _CountChip(
            label: AppStrings.projectVotingDisagreedLabel,
            count: disagreed,
            color: AppColors.red800,
            background: AppColors.red100,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _CountChip(
            label: AppStrings.projectVotingPendingLabel,
            count: pending,
            color: AppColors.grey900,
            background: AppColors.grey100,
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color background;

  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          AppText(
            '$count',
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          AppText(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _VoteProgressBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              label,
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
            AppText(
              '${(value * 100).round()}%',
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey1100,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8.h,
            backgroundColor: AppColors.grey200,
            color: color,
          ),
        ),
      ],
    );
  }
}
