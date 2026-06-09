part of 'project_detail_navigation.dart';

Future<void> _handleLeaderAction(
  BuildContext context, {
  required ProjectDetailEntity project,
  required LeaderMenuAction action,
  bool refreshHomeOnPop = false,
  bool refreshDiscoverOnPop = false,
}) async {
  if (action == LeaderMenuAction.inviteMembers) {
    _openInviteMembers(context, project: project);
    return;
  }

  if (action == LeaderMenuAction.leaveProject) {
    context.push(
      AppRoutes.leaveProjectWarning,
      extra: LeaveProjectRouteArgs(
        projectId: project.id,
        projectName: project.name,
        refreshHomeOnPop: refreshHomeOnPop,
        refreshDiscoverOnPop: refreshDiscoverOnPop,
      ),
    );
    return;
  }

  if (!project.isModeratorView) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return;
  }
  if (action == LeaderMenuAction.markSuccessful &&
      !project.canMarkProjectSuccessful) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return;
  }
  if (action == LeaderMenuAction.stopContributions &&
      !project.canStopContributions) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return;
  }
  if (action == LeaderMenuAction.editProject && !project.canEditProject) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return;
  }
  if (action == LeaderMenuAction.cancelProject && !project.canCancelProject) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return;
  }

  switch (action) {
    case LeaderMenuAction.joinRequests:
      context.push(
        AppRoutes.joinRequests,
        extra: JoinRequestsRouteArgs(
          projectId: project.id,
          onRefreshProjectDetail: () {
            return _reloadProjectDetailAndWait(context, projectId: project.id);
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
      context.read<CreateProjectCubit>().hydrateFromProjectDetail(project);
      context.push(
        AppRoutes.createProjectDetails,
        extra: CreateProjectEntryMode.editFromProjectDetail,
      );
      break;
    case LeaderMenuAction.projectFundsHistory:
      context.push(
        AppRoutes.projectFundsHistory,
        extra: _fundsHistoryArgs(project),
      );
      break;
    case LeaderMenuAction.myBorrows:
      await _openMyBorrowRequestAndRefresh(context, project: project);
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
    case LeaderMenuAction.leaveProject:
      break;
  }
}
