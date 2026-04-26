import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../app/router/route_args/project_wallet_flow_args.dart';
import '../../../../core/widgets/common/app_invite_members_dialog.dart';
import '../../../../core/widgets/common/leader_action_menu.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';

/// Shared navigation/route-arg helpers for project detail screens.
/// Keeps screen widgets focused on layout while preserving identical behavior.
class ProjectDetailNavigationHelpers {
  const ProjectDetailNavigationHelpers._();

  static ProjectWalletFlowArgs walletArgs(ProjectDetailEntity project) {
    return ProjectWalletFlowArgs(
      projectId: project.id,
      projectName: project.name,
    );
  }

  static MemberDetailRouteArgs memberDetailArgs(ProjectDetailEntity project, MemberEntity member) {
    return MemberDetailRouteArgs(
      member: member,
      projectName: project.name,
      isLeaderView: project.isLeader,
    );
  }

  static BorrowRequestsRouteArgs borrowRequestsArgs(
    ProjectDetailEntity project, {
    required bool isLeaderMode,
  }) {
    return BorrowRequestsRouteArgs(
      requests: project.borrowRequests,
      isLeaderMode: isLeaderMode,
    );
  }

  static void handleLeaderAction(
    BuildContext context, {
    required ProjectDetailEntity project,
    required LeaderMenuAction action,
  }) {
    switch (action) {
      case LeaderMenuAction.joinRequests:
        context.push(AppRoutes.joinRequests);
        break;
      case LeaderMenuAction.addAnnouncement:
        context.push(AppRoutes.createAnnouncement);
        break;
      case LeaderMenuAction.editProject:
        context.push(AppRoutes.createProjectDetails, extra: true);
        break;
      case LeaderMenuAction.inviteMembers:
        AppInviteMembersDialog.show(context);
        break;
      case LeaderMenuAction.markSuccessful:
        context.push(
          AppRoutes.markProjectSuccessful,
          extra: MarkSuccessfulRouteArgs(memberCount: project.members.length),
        );
        break;
      case LeaderMenuAction.cancelProject:
        final unpaid = project.members
            .where((m) => m.overdueAmount != null && m.overdueAmount! > 0)
            .length;
        context.push(
          AppRoutes.cancelProject,
          extra: CancelProjectRouteArgs(
            projectName: project.name,
            membersWithUnpaidBorrows: unpaid,
          ),
        );
        break;
    }
  }
}

