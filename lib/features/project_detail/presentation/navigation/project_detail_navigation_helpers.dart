import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/leader/features/create_project/presentation/create_project_entry_mode.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../app/router/route_args/project_wallet_flow_args.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_invite_members_dialog.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/member_project_action_menu.dart';
import '../../domain/entities/member_entity.dart';
import '../widgets/project_member_vff_send_actions.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/create_announcement_route_args.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../models/investment_distribution_ui_data.dart';
import '../models/investment_returns_ui_data.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/project_detail/presentation/models/member_vote_outcome_ui_data.dart';
import '../widgets/distribute_funds_amount_sheet.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/user/features/contributions/data/models/contribution_submit_result_model.dart';
import 'package:vestie/user/features/vff/presentation/mappers/invite_members_mapper.dart';
import '../data/project_funds_history_ledger_builder.dart';
import 'package:vestie/user/features/borrow/presentation/data/my_borrow_request_args_builder.dart';

/// Shared navigation/route-arg helpers for project detail screens.
/// Keeps screen widgets focused on layout while preserving identical behavior.
class ProjectDetailNavigationHelpers {
  const ProjectDetailNavigationHelpers._();

  static ProjectWalletFlowArgs walletArgs(ProjectDetailEntity project) {
    final dueBy = project.repaymentWindowDays > 0
        ? 'In ${project.repaymentWindowDays} days'
        : ProjectWalletFlowArgs.defaultBorrowDueByLabel;
    return ProjectWalletFlowArgs(
      projectId: project.id,
      projectName: project.name,
      borrowLimit: project.borrowLimitAmount > 0
          ? project.borrowLimitAmount
          : ProjectWalletFlowArgs.defaultBorrowLimit,
      borrowDueByLabel: dueBy,
      membershipId: project.membershipId.isEmpty ? null : project.membershipId,
    );
  }

  static MemberDetailRouteArgs memberDetailArgs(
    ProjectDetailEntity project,
    MemberEntity member, {
    VoidCallback? onProjectMembersChanged,
  }) {
    return MemberDetailRouteArgs(
      member: member,
      projectId: project.id,
      projectName: project.name,
      project: project,
      isLeaderView: project.isModeratorView,
      onProjectMembersChanged: onProjectMembersChanged,
    );
  }

  /// Member / CoLeader / GroupLeader — opens project member profile.
  static Future<MemberDetailPopResult?> openMemberProfile(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) async {
    if (!project.canReviewMemberProfiles) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return null;
    }
    void reloadProjectDetail() {
      _reloadProjectDetailBloc(context, projectId: project.id);
    }

    return context.push<MemberDetailPopResult>(
      AppRoutes.memberDetail,
      extra: memberDetailArgs(
        project,
        member,
        onProjectMembersChanged: reloadProjectDetail,
      ),
    );
  }

  /// Reloads `GET /projects/{id}` after member profile changes (remove, co-leader, etc.).
  static void refreshProjectDetailAfterMemberFlow(
    BuildContext context, {
    required String projectId,
    required MemberDetailPopResult? result,
  }) {
    if (result == null) return;
    if (!context.mounted) return;
    _reloadProjectDetailBloc(context, projectId: projectId);
  }

  static void _reloadProjectDetailBloc(
    BuildContext context, {
    required String projectId,
  }) {
    if (!context.mounted) return;
    try {
      context.read<ProjectDetailBloc>().add(
            LoadProjectDetailEvent(projectId: projectId),
          );
    } on ProviderNotFoundException {
      // Opened outside project detail.
    }
  }

  /// Merges contribute 201 `projectPot` / VFF ids, then refreshes pot for contributor count.
  static void refreshAfterContribution(
    BuildContext context, {
    required String projectId,
    required ContributionSubmitResultModel submitResult,
  }) {
    if (!context.mounted) return;
    try {
      context.read<ProjectDetailBloc>().add(
            ApplyContributionSubmitResultEvent(
              projectId: projectId,
              projectPot: submitResult.projectPot,
              vffMemberUserIds: submitResult.vffMemberUserIds,
            ),
          );
    } on ProviderNotFoundException {
      // Opened outside project detail.
    }
  }

  /// Sends a VFF request from a project member row (no profile screen).
  static void sendVffRequestFromMemberRow(
    BuildContext context, {
    required MemberEntity member,
  }) {
    sendMemberVffFromProjectDetail(context, member: member);
  }

  static BorrowRequestsRouteArgs borrowRequestsArgs(
    ProjectDetailEntity project, {
    required bool isLeaderMode,
    String? screenTitle,
  }) {
    return BorrowRequestsRouteArgs(
      requests: project.borrowRequests,
      projectId: project.id,
      project: project,
      isLeaderMode: isLeaderMode,
      screenTitle: screenTitle,
    );
  }

  static GroupMembersRouteArgs groupMembersArgs(ProjectDetailEntity project) {
    return GroupMembersRouteArgs(
      members: project.members,
      projectId: project.id,
      project: project,
    );
  }

  static Future<void> openGroupMembers(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) async {
    await context.push(
      AppRoutes.groupMembers,
      extra: groupMembersArgs(project),
    );
    if (!context.mounted) return;
    _reloadProjectDetailBloc(context, projectId: project.id);
  }

  /// Pops success → distribution → distribute funds so the existing detail
  /// screen (and its bloc) is restored — avoids a full reload shimmer.
  ///
  /// Uses a fixed pop count (not [uri.path] matching) so we never pop past
  /// detail or replace the stack with [GoRouter.go] (which would leave nothing
  /// to pop when the user taps back on detail).
  static void popAfterFundsDistributed(
    BuildContext context, {
    required String projectId,
    String? projectName,
  }) {
    final router = GoRouter.of(context);
    // detail → distribute funds → distribution → success
    const routesAboveDetail = 3;
    for (var i = 0; i < routesAboveDetail; i++) {
      if (!router.canPop()) break;
      router.pop();
      if (!context.mounted) return;
    }
    if (!context.mounted) return;

    // Deep link / unexpected stack: still on success with nothing left to pop.
    if (GoRouterState.of(context).matchedLocation ==
        AppRoutes.leaderInvestmentDistributionSuccess) {
      router.go(
        AppRoutes.investmentProjectDetail,
        extra: ProjectDetailRouteArgs(
          projectId: projectId,
          initialProjectName:
              ProjectDetailRouteArgs.normalizedName(projectName),
        ),
      );
    }
  }

  static void openFundsDistributedSuccess(
    BuildContext context, {
    required InvestmentDistributionUiData distributionData,
  }) {
    context.push(
      AppRoutes.leaderInvestmentDistributionSuccess,
      extra: InvestmentDistributionSuccessRouteArgs(
        projectId: distributionData.projectId,
        projectName: distributionData.projectName,
        amountUsd: distributionData.distributeAmountUsd,
        memberCount: distributionData.memberCount,
      ),
    );
  }

  static Future<void> openDistributeFundsFlow(
    BuildContext context, {
    required InvestmentReturnsUiData returnsData,
  }) async {
    final amountUsd = await showDistributeFundsAmountSheet(context);
    if (!context.mounted || amountUsd == null || amountUsd <= 0) return;
    context.push(
      AppRoutes.leaderInvestmentDistribution,
      extra: InvestmentDistributionRouteArgs(
        data: InvestmentDistributionUiData.preview(
          projectId: returnsData.projectId,
          projectName: returnsData.projectName,
          distributeAmountUsd: amountUsd,
        ),
      ),
    );
  }

  static void openInvestmentReturns(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) {
    if (project.isModeratorView) {
      context.push(
        AppRoutes.leaderDistributeFunds,
        extra: InvestmentReturnsRouteArgs(
          data: InvestmentReturnsUiData.previewLeaderForProject(project),
        ),
      );
      return;
    }
    context.push(
      AppRoutes.userInvestmentReturns,
      extra: InvestmentReturnsRouteArgs(
        data: InvestmentReturnsUiData.previewForProject(project),
      ),
    );
  }

  /// Group leader — active success vote monitor (Figma voting window).
  /// Vacation and emergency projects only.
  static void openLeaderViewSuccessVotes(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) {
    if (!project.showsSuccessVoteDevPreviews) return;

    context.push(
      AppRoutes.leaderViewSuccessVotes,
      extra: LeaderViewSuccessVotesRouteArgs(
        projectName: project.name,
        data: LeaderSuccessVoteProgressUiData.preview(project: project),
      ),
    );
  }

  /// Temporary preview — member success vote screen ([UserSuccessVoteScreen]).
  static void openSuccessVoteScreenPreview(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) {
    if (!project.showsMemberSuccessVoteDevPreviews) return;

    final memberCount =
        project.members.isNotEmpty ? project.members.length : 7;
    context.push(
      AppRoutes.userSuccessVote,
      extra: UserSuccessVoteArgs(
        projectId: project.id,
        projectName: project.name,
        goalAmount: project.goalAmount > 0 ? project.goalAmount : 5000,
        memberCount: memberCount,
        totalRaised: project.currentAmount > 0
            ? project.currentAmount
            : project.goalAmount * 0.96,
        deadlineLabel:
            project.endsIn.trim().isNotEmpty ? project.endsIn : 'May 12, 2025',
        daysRemaining: 21,
      ),
    );
  }

  /// Temporary preview — member vote outcome (approved / rejected).
  static void openMemberVoteOutcomePreview(
    BuildContext context, {
    required ProjectDetailEntity project,
    required bool approved,
  }) {
    if (!project.showsMemberSuccessVoteDevPreviews) return;

    context.push(
      AppRoutes.userVoteOutcome,
      extra: MemberVoteOutcomeRouteArgs(
        data: MemberVoteOutcomeUiData.preview(
          isApproved: approved,
          project: project,
        ),
        isGroupLeaderView: project.isGroupLeader,
        project: project.isGroupLeader ? project : null,
      ),
    );
  }

  static void openInviteMembers(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) {
    if (!project.canInviteMembers) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }
    final excludeUserIds =
        InviteMembersMapper.excludeUserIdsForProject(project);
  // TODO(api): restore POST /projects/{id}/invites for share-outside link.
    AppInviteMembersDialog.show(
      context,
      projectId: project.id,
      projectName: project.name,
      excludeUserIds: excludeUserIds,
      inviteLink: AppStrings.inviteLinkSample,
    );
  }

  static Future<void> handleLeaderAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required LeaderMenuAction action,
  }) async {
    if (action == LeaderMenuAction.inviteMembers) {
      openInviteMembers(context, project: project);
      return;
    }

    if (!project.isModeratorView) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }
    if (action == LeaderMenuAction.markSuccessful &&
        !project.canMarkProjectSuccessful) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }
    if (action == LeaderMenuAction.stopContributions &&
        !project.canStopContributions) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }
    if (action == LeaderMenuAction.editProject && !project.canEditProject) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }
    if (action == LeaderMenuAction.cancelProject && !project.canCancelProject) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }

    switch (action) {
      case LeaderMenuAction.joinRequests:
        context.push(
          AppRoutes.joinRequests,
          extra: JoinRequestsRouteArgs(
            projectId: project.id,
            onRefreshProjectDetail: () {
              if (!context.mounted) return;
              context.read<ProjectDetailBloc>().add(
                    LoadProjectDetailEvent(projectId: project.id),
                  );
            },
          ),
        );
        break;
      case LeaderMenuAction.addAnnouncement:
        final created = await context.push<bool>(
          AppRoutes.createAnnouncement,
          extra: CreateAnnouncementRouteArgs(projectId: project.id),
        );
        if (created == true && context.mounted) {
          context.read<ProjectDetailBloc>().add(
                LoadProjectDetailEvent(projectId: project.id),
              );
        }
        break;
      case LeaderMenuAction.editProject:
        context.push(
          AppRoutes.createProjectDetails,
          extra: CreateProjectEntryMode.editFromProjectDetail,
        );
        break;
      case LeaderMenuAction.projectFundsHistory:
        context.push(
          AppRoutes.projectFundsHistory,
          extra: fundsHistoryArgs(project),
        );
        break;
      case LeaderMenuAction.myBorrows:
        context.push(
          AppRoutes.myBorrowRequest,
          extra: MyBorrowRequestArgsBuilder.fromProject(project),
        );
        break;
      case LeaderMenuAction.inviteMembers:
        break;
      case LeaderMenuAction.markSuccessful:
        context.push(
          AppRoutes.markProjectSuccessful,
          extra: MarkSuccessfulRouteArgs(
            projectId: project.id,
            memberCount: project.members.length,
          ),
        );
        break;
      case LeaderMenuAction.stopContributions:
        context.push(
          AppRoutes.stopContributions,
          extra: StopContributionsRouteArgs(projectId: project.id),
        );
        break;
      case LeaderMenuAction.cancelProject:
        final unpaid = project.members
            .where((m) => m.overdueAmount != null && m.overdueAmount! > 0)
            .length;
        context.push(
          AppRoutes.cancelProject,
          extra: CancelProjectRouteArgs(
            projectId: project.id,
            projectName: project.name,
            membersWithUnpaidBorrows: unpaid,
          ),
        );
        break;
    }
  }

  static ProjectFundsHistoryRouteArgs fundsHistoryArgs(
    ProjectDetailEntity project,
  ) {
    return ProjectFundsHistoryLedgerBuilder.fromProject(project);
  }

  static void handleMemberAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberProjectMenuAction action,
    bool refreshHomeOnPop = false,
    bool refreshDiscoverOnPop = false,
  }) {
    switch (action) {
      case MemberProjectMenuAction.projectFundsHistory:
        context.push(
          AppRoutes.projectFundsHistory,
          extra: fundsHistoryArgs(project),
        );
        break;
      case MemberProjectMenuAction.myBorrows:
        context.push(
          AppRoutes.myBorrowRequest,
          extra: MyBorrowRequestArgsBuilder.fromProject(project),
        );
        break;
      case MemberProjectMenuAction.inviteMembers:
        openInviteMembers(context, project: project);
        break;
      case MemberProjectMenuAction.leaveProject:
        context.push(
          AppRoutes.leaveProjectWarning,
          extra: LeaveProjectRouteArgs(
            projectId: project.id,
            projectName: project.name,
            refreshHomeOnPop: refreshHomeOnPop,
            refreshDiscoverOnPop: refreshDiscoverOnPop,
          ),
        );
        break;
    }
  }
}

