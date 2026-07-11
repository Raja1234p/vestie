import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/widgets/common/leader_action_menu.dart';
import 'package:vestie/core/widgets/common/member_project_action_menu.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'project_detail_join_requests_chip.dart';

/// Header trailing for investment, vacation, and emergency detail — driven by
/// [ProjectDetailEntity.overflowMenuKind] (`project.viewerRole`).
class ProjectDetailTrailingActions extends StatelessWidget {
  final ProjectDetailEntity project;
  final int pendingJoinRequestCount;
  final void Function(LeaderMenuAction action) onLeaderMenuSelected;
  final void Function(MemberProjectMenuAction action) onMemberMenuSelected;

  /// Profile → Completed Projects → View Details: join chip off, funds history only.
  final bool completedProjectsProfileDetail;

  const ProjectDetailTrailingActions({
    super.key,
    required this.project,
    required this.pendingJoinRequestCount,
    required this.onLeaderMenuSelected,
    required this.onMemberMenuSelected,
    this.completedProjectsProfileDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!project.showsProjectDetailOverflowMenu) {
      return const SizedBox.shrink();
    }

    final showJoinChip = !completedProjectsProfileDetail &&
        project.showsJoinRequestsHeaderChip;

    final fundsHistoryOnly = completedProjectsProfileDetail;

    final Widget menu = switch (project.overflowMenuKind) {
      ProjectDetailOverflowMenuKind.member => MemberProjectActionMenu(
        onSelected: onMemberMenuSelected,
        fundsHistoryOnly: fundsHistoryOnly,
        includeMyBorrows:
            fundsHistoryOnly ? false : project.memberProjectMenuIncludesMyBorrows,
        showInviteMembers: fundsHistoryOnly ? false : project.canInviteMembers,
      ),
      ProjectDetailOverflowMenuKind.leader => LeaderActionMenu(
        audience: project.isGroupLeader
            ? LeaderMenuAudience.primaryLeader
            : LeaderMenuAudience.coLeader,
        fundsHistoryOnly: fundsHistoryOnly,
        includeMyBorrows: fundsHistoryOnly
            ? false
            : project.isVacationOrEmergency &&
                !project.hasActiveClosureVotingWindow,
        showMarkAsSuccessful: fundsHistoryOnly ? false : project.canMarkProjectSuccessful,
        showStopContributions: fundsHistoryOnly ? false : project.canStopContributions,
        showCancelProject: fundsHistoryOnly ? false : project.canCancelProject,
        showEditProject: fundsHistoryOnly ? false : project.canEditProject,
        showInviteMembers: fundsHistoryOnly ? false : project.canInviteMembers,
        onSelected: onLeaderMenuSelected,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showJoinChip) ...[
          ProjectDetailJoinRequestsChip(
            count: pendingJoinRequestCount,
            onTap: () => ProjectDetailNavigation.handleLeaderAction(
              context,
              project: project,
              action: LeaderMenuAction.joinRequests,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        menu,
      ],
    );
  }
}
