import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../../app/router/route_args/project_joined_success_route_args.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/features/dashboard/presentation/models/dashboard_shell_args.dart';
import 'package:vestie/features/projects/domain/entities/created_project_entity.dart';
import 'package:vestie/features/projects/domain/entities/invite_preview_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'package:vestie/user/features/project_detail/presentation/models/member_vote_outcome_ui_data.dart';
import '../../domain/entities/project_detail_route_args.dart';

void _openMemberVoteOutcome(
  BuildContext context,
  Project project, {
  required bool isApproved,
}) {
  context.push(
    AppRoutes.userVoteOutcome,
    extra: MemberVoteOutcomeRouteArgs(
      data: MemberVoteOutcomeUiData.fromProject(
        project,
        isApproved: isApproved,
      ),
    ),
  );
}

/// Profile → Completed Projects: **View** opens vote outcome (approved / rejected).
void openCompletedProjectView(BuildContext context, Project project) {
  if (project.userFlow != null) {
    openProjectFromCard(context, project);
    return;
  }
  _openMemberVoteOutcome(
    context,
    project,
    isApproved: project.isSuccessVoteApproved,
  );
}

/// Pops detail or returns to dashboard with a fresh project list.
void popProjectDetailNavigation(
  BuildContext context, {
  bool refreshHomeOnPop = false,
  bool refreshDiscoverOnPop = false,
}) {
  refreshHomeOnPop =
      refreshHomeOnPop || HomeProjectListSync.consumeRefreshHomeOnPop();
  if (refreshHomeOnPop) {
    context.go(
      AppRoutes.dashboard,
      extra: DashboardShellArgs(
        reloadHomeProjectList: true,
        reloadDiscoverProjectList: true,
        navigationMark: DateTime.now().microsecondsSinceEpoch,
      ),
    );
    return;
  }
  if (refreshDiscoverOnPop) {
    context.go(
      AppRoutes.dashboard,
      extra: DashboardShellArgs(
        reloadDiscoverProjectList: true,
        initialTabIndex: 1,
        navigationMark: DateTime.now().microsecondsSinceEpoch,
      ),
    );
    return;
  }
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(AppRoutes.dashboard);
}

/// After leave-project success — uses the same shell reload flags as detail back.
void popAfterLeaveProjectSuccess(
  BuildContext context, {
  bool refreshHomeOnPop = false,
  bool refreshDiscoverOnPop = false,
}) {
  if (refreshHomeOnPop || refreshDiscoverOnPop) {
    popProjectDetailNavigation(
      context,
      refreshHomeOnPop: refreshHomeOnPop,
      refreshDiscoverOnPop: refreshDiscoverOnPop,
    );
    return;
  }
  context.pop();
  if (context.mounted) context.pop();
}

ProjectDetailRouteArgs _routeArgs({
  required String projectId,
  String? initialProjectName,
  bool refreshHomeOnPop = false,
  bool refreshDiscoverOnPop = false,
}) {
  return ProjectDetailRouteArgs(
    projectId: projectId,
    initialProjectName: ProjectDetailRouteArgs.normalizedName(initialProjectName),
    refreshHomeOnPop: refreshHomeOnPop,
    refreshDiscoverOnPop: refreshDiscoverOnPop,
  );
}

/// Home / Discover list card.
ProjectDetailRouteArgs projectDetailRouteArgsForProject(
  Project project, {
  bool refreshHomeOnPop = false,
}) {
  return _routeArgs(
    projectId: project.id,
    initialProjectName: project.name,
    refreshHomeOnPop: refreshHomeOnPop,
  );
}

/// After `POST /projects` (create wizard).
ProjectDetailRouteArgs projectDetailRouteArgsForCreated(
  CreatedProjectEntity created, {
  bool refreshHomeOnPop = false,
}) {
  return _routeArgs(
    projectId: created.id,
    initialProjectName: created.name,
    refreshHomeOnPop: refreshHomeOnPop,
  );
}

/// Invite-code preview before join (name available before detail GET).
ProjectDetailRouteArgs projectDetailRouteArgsForInvitePreview(
  InvitePreviewEntity preview, {
  bool refreshHomeOnPop = false,
}) {
  return _routeArgs(
    projectId: preview.projectId,
    initialProjectName: preview.projectName,
    refreshHomeOnPop: refreshHomeOnPop,
  );
}

/// When navigating from an already-loaded detail screen.
ProjectDetailRouteArgs projectDetailRouteArgsForDetail(
  ProjectDetailEntity project, {
  bool refreshHomeOnPop = false,
}) {
  return _routeArgs(
    projectId: project.id,
    initialProjectName: project.name,
    refreshHomeOnPop: refreshHomeOnPop,
  );
}

void _pushProjectDetail(
  BuildContext context, {
  required ProjectDetailRouteArgs args,
  required bool isInvestment,
}) {
  final route = isInvestment
      ? AppRoutes.investmentProjectDetail
      : AppRoutes.projectDetail;
  context.push(route, extra: args);
}

/// Opens detail when only id (and optional name) are known — e.g. notifications later.
void openProjectDetailById(
  BuildContext context, {
  required String projectId,
  required bool isInvestment,
  String? initialProjectName,
  bool refreshHomeOnPop = false,
  bool refreshDiscoverOnPop = false,
}) {
  _pushProjectDetail(
    context,
    args: _routeArgs(
      projectId: projectId,
      initialProjectName: initialProjectName,
      refreshHomeOnPop: refreshHomeOnPop,
      refreshDiscoverOnPop: refreshDiscoverOnPop,
    ),
    isInvestment: isInvestment,
  );
}

/// After create-project success — dashboard is root; detail opens on top; back refreshes home.
void openProjectDetailAfterCreateSuccess(
  BuildContext context, {
  required String projectId,
  required bool isInvestment,
  String? projectName,
}) {
  context.go(
    AppRoutes.dashboard,
    extra: DashboardShellArgs(
      reloadHomeProjectList: true,
      reloadDiscoverProjectList: true,
      navigationMark: DateTime.now().microsecondsSinceEpoch,
    ),
  );
  // Push after [go] settles — synchronous push is dropped and leaves only home.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    openProjectDetailById(
      context,
      projectId: projectId,
      isInvestment: isInvestment,
      initialProjectName: projectName,
      refreshHomeOnPop: true,
    );
  });
}

/// Opens project detail for any viewer role. UI is driven by
/// `GET /projects/{id}` → `project.viewerRole` (`GroupLeader` / `Member`, …).
void openProjectFromCard(BuildContext context, Project p) {
  if (p.relation == ProjectRelation.joined && p.userFlow != null) {
    final name = p.name;
    switch (p.userFlow!) {
      case UserFlowOnOpen.showJoinApproved:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.joinApproved,
          ),
        );
        return;
      case UserFlowOnOpen.showJoinRejected:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.joinRejected,
          ),
        );
        return;
      case UserFlowOnOpen.showSuccessVote:
        context.push(
          AppRoutes.userSuccessVote,
          extra: UserSuccessVoteArgs(
            projectId: p.id,
            projectName: name,
            goalAmount: p.goalAmount ?? 5000,
            memberCount: 5,
            totalRaised: p.currentAmount ?? 4800,
            deadlineLabel: 'May 12, 2025',
            daysRemaining: 21,
          ),
        );
        return;
      case UserFlowOnOpen.showMarkVoteApprovedResult:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.markVotedSuccess,
          ),
        );
        return;
      case UserFlowOnOpen.showMarkVoteNotApprovedResult:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.markVotedIncomplete,
          ),
        );
        return;
      case UserFlowOnOpen.showVoteOutcomeApproved:
        _openMemberVoteOutcome(context, p, isApproved: true);
        return;
      case UserFlowOnOpen.showVoteOutcomeRejected:
        _openMemberVoteOutcome(context, p, isApproved: false);
        return;
    }
  }

  _pushProjectDetail(
    context,
    args: projectDetailRouteArgsForProject(p),
    isInvestment: p.category.isInvestment,
  );
}

/// Immediate join success — shared [ProjectJoinedSuccessScreen] / [AppSuccessScreen].
void openProjectJoinedSuccess(
  BuildContext context, {
  required String projectId,
  required String projectName,
  required bool isInvestment,
  bool fromInviteLink = false,
}) {
  context.go(
    AppRoutes.projectJoinedSuccess,
    extra: ProjectJoinedSuccessRouteArgs(
      projectId: projectId,
      projectName: projectName,
      isInvestment: isInvestment,
      fromInviteLink: fromInviteLink,
    ),
  );
}

/// Pending membership (`status: pending`) — “Request Sent” on [AppSuccessScreen].
void openProjectJoinRequestSentSuccess(
  BuildContext context, {
  required String projectId,
  required String projectName,
  bool isInvestment = false,
  bool fromInviteLink = false,
}) {
  context.go(
    AppRoutes.projectJoinedSuccess,
    extra: ProjectJoinedSuccessRouteArgs(
      projectId: projectId,
      projectName: projectName,
      isInvestment: isInvestment,
      kind: ProjectJoinSuccessKind.requestPending,
      fromInviteLink: fromInviteLink,
    ),
  );
}

/// Discover (or home) — immediate join (`status: active`).
void openProjectDetailAfterJoinSuccess(
  BuildContext context, {
  required String projectId,
  required String projectName,
  required bool isInvestment,
}) {
  openProjectDetailById(
    context,
    projectId: projectId,
    isInvestment: isInvestment,
    initialProjectName: projectName,
    refreshDiscoverOnPop: true,
  );
}

/// Use after a successful invite join when opening detail immediately.
void openProjectDetailFromInvitePreview(
  BuildContext context,
  InvitePreviewEntity preview,
) {
  final type = preview.projectType.toLowerCase();
  final isInvestment = type.contains('invest');
  _pushProjectDetail(
    context,
    args: projectDetailRouteArgsForInvitePreview(preview),
    isInvestment: isInvestment,
  );
}
