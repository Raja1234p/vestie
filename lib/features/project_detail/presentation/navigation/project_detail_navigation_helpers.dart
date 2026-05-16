import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/leader/features/create_project/presentation/create_project_entry_mode.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../app/router/route_args/project_wallet_flow_args.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_invite_members_dialog.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../../../core/widgets/common/member_project_action_menu.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_lookup.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
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

  static MemberDetailRouteArgs memberDetailArgs(ProjectDetailEntity project, MemberEntity member) {
    return MemberDetailRouteArgs(
      member: member,
      projectId: project.id,
      projectName: project.name,
      isLeaderView: project.usesLeaderDetailPanels,
      isPrimaryLeaderView: project.isModeratorView,
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
      isLeaderMode: isLeaderMode,
      screenTitle: screenTitle,
    );
  }

  static void handleLeaderAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required LeaderMenuAction action,
  }) {
    if (!project.isModeratorView) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }
    if (action == LeaderMenuAction.markSuccessful &&
        !project.canMarkProjectSuccessful) {
      AppSnackBar.showError(context, AppStrings.errorForbidden);
      return;
    }

    switch (action) {
      case LeaderMenuAction.joinRequests:
        context.push(
          AppRoutes.joinRequests,
          extra: JoinRequestsRouteArgs(projectId: project.id),
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
        ServiceLocator.instance.createInviteUseCase(
          projectId: project.id,
          requiresApproval: true,
          expiresInDays: 30,
          maxUses: 10,
        ).then((result) {
          if (!context.mounted) return;
          result.fold(
            (failure) => AppSnackBar.showError(context, failure.message),
            (inviteCode) => AppInviteMembersDialog.show(
              context,
              inviteLink: inviteCode,
            ),
          );
        });
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
        handleLeaderAction(
          context,
          project: project,
          action: LeaderMenuAction.inviteMembers,
        );
        break;
      case MemberProjectMenuAction.leaveProject:
        context.push(
          AppRoutes.leaveProjectWarning,
          extra: LeaveProjectRouteArgs(
            projectId: project.id,
            projectName: project.name,
          ),
        );
        break;
    }
  }
}

