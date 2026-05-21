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
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_lookup.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../models/investment_distribution_ui_data.dart';
import '../models/investment_returns_ui_data.dart';
import 'package:vestie/user/features/project_detail/presentation/models/member_vote_outcome_ui_data.dart';
import '../widgets/distribute_funds_amount_sheet.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
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
    MemberEntity member,
  ) {
    return MemberDetailRouteArgs(
      member: member,
      projectId: project.id,
      projectName: project.name,
      project: project,
      isLeaderView: project.isModeratorView,
    );
  }

  /// Member / CoLeader / GroupLeader — opens project member profile.
  /// Returns `true` when co-leader / remove-member / penalty-remove succeeded (caller may reload).
  static Future<bool?> openMemberProfile(
    BuildContext context, {
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) async {
    if (!project.canReviewMemberProfiles) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return null;
    }
    return context.push<bool>(
      AppRoutes.memberDetail,
      extra: memberDetailArgs(project, member),
    );
  }

  /// VFF peer profile — prototype lookup until project-member VFF API exists.
  static void openAddFriendFlow(BuildContext context, MemberEntity member) {
    final key = member.userId.isNotEmpty ? member.userId : member.username;
    context.push(
      AppRoutes.userVffProfile,
      extra: UserVffProfileRouteArgs(
        profile: lookupUserVffProfileForConnection(
          key,
          outboundRequestPending: true,
        ),
      ),
    );
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

  static void openGroupMembers(
    BuildContext context, {
    required ProjectDetailEntity project,
  }) {
    context.push(
      AppRoutes.groupMembers,
      extra: groupMembersArgs(project),
    );
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

  /// Temporary preview — member vote outcome (approved / rejected).
  static void openMemberVoteOutcomePreview(
    BuildContext context, {
    required ProjectDetailEntity project,
    required bool approved,
  }) {
    context.push(
      AppRoutes.userVoteOutcome,
      extra: MemberVoteOutcomeRouteArgs(
        data: MemberVoteOutcomeUiData.preview(
          isApproved: approved,
          project: project,
        ),
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
    // TODO(api): restore POST /projects/{id}/invites via createInviteUseCase.
    AppInviteMembersDialog.show(
      context,
      projectName: project.name,
      inviteLink: AppStrings.inviteLinkSample,
    );
  }

  static void handleLeaderAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required LeaderMenuAction action,
  }) {
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
        context.push(AppRoutes.createAnnouncement);
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

