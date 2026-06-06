part of 'project_detail_navigation.dart';

void _handleMemberAction(
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
        extra: _fundsHistoryArgs(project),
      );
      break;
    case MemberProjectMenuAction.myBorrows:
      context.push(
        AppRoutes.myBorrowRequest,
        extra: MyBorrowRequestArgsBuilder.fromProject(project),
      );
      break;
    case MemberProjectMenuAction.inviteMembers:
      _openInviteMembers(context, project: project);
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
