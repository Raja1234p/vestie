part of 'project_detail_navigation.dart';

Future<MemberDetailPopResult?> _openMemberProfile(
  BuildContext context, {
  required ProjectDetailEntity project,
  required MemberEntity member,
}) async {
  if (!project.canReviewMemberProfiles) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return null;
  }
  Future<void> reloadProjectDetail() {
    return _reloadProjectDetailAndWait(context, projectId: project.id);
  }

  return context.push<MemberDetailPopResult>(
    AppRoutes.memberDetail,
    extra: _memberDetailArgs(
      project,
      member,
      onProjectMembersChanged: reloadProjectDetail,
    ),
  );
}

Future<void> _openGroupMembers(
  BuildContext context, {
  required ProjectDetailEntity project,
}) async {
  await context.push(AppRoutes.groupMembers, extra: _groupMembersArgs(project));
  if (!context.mounted) return;
  _reloadProjectDetailBloc(context, projectId: project.id);
}

void _popAfterVoteStarted(
  BuildContext context, {
  required String projectId,
}) {
  final router = GoRouter.of(context);
  const routesAboveDetail = 2;
  for (var i = 0; i < routesAboveDetail; i++) {
    if (!router.canPop()) break;
    router.pop();
    if (!context.mounted) return;
  }
}

void _popAfterFundsDistributed(
  BuildContext context, {
  required String projectId,
  String? projectName,
}) {
  final router = GoRouter.of(context);
  const routesAboveDetail = 3;
  for (var i = 0; i < routesAboveDetail; i++) {
    if (!router.canPop()) break;
    router.pop();
    if (!context.mounted) return;
  }
  if (!context.mounted) return;

  if (GoRouterState.of(context).matchedLocation ==
      AppRoutes.leaderInvestmentDistributionSuccess) {
    router.go(
      AppRoutes.investmentProjectDetail,
      extra: ProjectDetailRouteArgs(
        projectId: projectId,
        initialProjectName: ProjectDetailRouteArgs.normalizedName(projectName),
      ),
    );
  }
}

void _openFundsDistributedSuccess(
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

Future<void> _openDistributeFundsFlow(
  BuildContext context, {
  required InvestmentReturnsUiData returnsData,
}) async {
  final amountUsd = await showDistributeFundsAmountSheet(context);
  if (!context.mounted || amountUsd == null || amountUsd <= 0) return;
  context.push(
    AppRoutes.leaderInvestmentDistribution,
    extra: InvestmentDistributionRouteArgs(
      projectId: returnsData.projectId,
      projectName: returnsData.projectName,
      distributeAmountUsd: amountUsd,
    ),
  );
}

void _openInvestmentReturns(
  BuildContext context, {
  required ProjectDetailEntity project,
}) {
  if (project.isModeratorView) {
    context.push(
      AppRoutes.leaderDistributeFunds,
      extra: InvestmentReturnsRouteArgs(
        projectId: project.id,
        projectName: project.name,
        isLeaderView: true,
      ),
    );
    return;
  }
  context.push(
    AppRoutes.userInvestmentReturns,
    extra: InvestmentReturnsRouteArgs(
      projectId: project.id,
      projectName: project.name,
    ),
  );
}

void _openLeaderViewSuccessVotes(
  BuildContext context, {
  required ProjectDetailEntity project,
}) {
  if (project.hasActiveSuccessVote && project.activeClosureVote != null) {
    final vote = project.activeClosureVote!;
    context.push(
      AppRoutes.leaderViewSuccessVotes,
      extra: LeaderViewSuccessVotesRouteArgs(
        projectName: project.name,
        projectId: project.id,
        project: project,
        data: leaderSuccessVoteProgressFromActiveVote(
          vote: vote,
          project: project,
        ),
      ),
    );
    return;
  }

  if (!kDebugMode || !project.showsSuccessVoteDevPreviews) return;

  context.push(
    AppRoutes.leaderViewSuccessVotes,
    extra: LeaderViewSuccessVotesRouteArgs(
      projectName: project.name,
      isPreview: true,
      data: LeaderSuccessVoteProgressUiData.preview(project: project),
    ),
  );
}

void _openCastVote(
  BuildContext context, {
  required ProjectDetailEntity project,
}) {
  if (!project.showsCastVoteAction || project.activeClosureVote == null) {
    return;
  }

  context.push(
    AppRoutes.userSuccessVote,
    extra: successVoteCastRouteArgsFromProject(project),
  );
}

void _openCastVotePreview(
  BuildContext context, {
  required ProjectDetailEntity project,
}) {
  if (!kDebugMode) return;
  if (!project.showsMemberSuccessVoteDevPreviews) return;
  if (!project.isMemberView && !project.isCoLeader) return;

  final memberCount = project.members.isNotEmpty ? project.members.length : 7;
  context.push(
    AppRoutes.userSuccessVote,
    extra: SuccessVoteCastRouteArgs(
      projectId: project.id,
      projectName: project.name,
      projectCategory: project.category,
      isCoLeader: project.isCoLeader,
      goalAmount: project.goalAmount > 0 ? project.goalAmount : 5000,
      memberCount: memberCount,
      totalRaised: project.currentAmount > 0
          ? project.currentAmount
          : project.goalAmount * 0.96,
      deadlineLabel: project.endsIn.trim().isNotEmpty
          ? project.endsIn
          : 'May 12, 2025',
      daysRemaining: 21,
      isPreview: true,
    ),
  );
}

void _openMemberVoteOutcomePreview(
  BuildContext context, {
  required ProjectDetailEntity project,
  required bool approved,
}) {
  if (!kDebugMode) return;
  final canPreview = project.showsMemberSuccessVoteDevPreviews ||
      (project.isModeratorView &&
          (project.showsSuccessVoteDevPreviews ||
              project.showsInvestmentVoteOutcomeDevPreviews));
  if (!canPreview) return;

  final role = SuccessVoteOutcomeRole.fromViewerRole(project.viewerRole);
  context.push(
    AppRoutes.userVoteOutcome,
    extra: SuccessVoteOutcomeRouteArgs(
      data: SuccessVoteOutcomeUiData.preview(
        isApproved: approved,
        project: project,
      ),
      viewerRole: role,
      project: role.isModerator ? project : null,
    ),
  );
}

void _openStopContributionsVoteRejectedPreview(
  BuildContext context, {
  required ProjectDetailEntity project,
}) {
  if (!kDebugMode) return;
  final isInvestmentMember =
      project.isMemberView && project.category.isInvestment;
  if (!project.canStopContributions && !isInvestmentMember) return;

  final role = SuccessVoteOutcomeRole.fromViewerRole(project.viewerRole);
  context.push(
    AppRoutes.userVoteOutcome,
    extra: SuccessVoteOutcomeRouteArgs(
      data: SuccessVoteOutcomeUiData.preview(
        isApproved: false,
        project: project,
      ),
      viewerRole: role,
      variant: SuccessVoteOutcomeVariant.stopContributionsRejected,
      project: project,
    ),
  );
}

void _openClosureVoteOutcome(
  BuildContext context, {
  required ProjectDetailEntity project,
  required FinalizeClosureVoteResultEntity finalizeResult,
  bool popCurrentRoute = false,
}) {
  if (popCurrentRoute && context.canPop()) {
    context.pop();
  }
  if (!context.mounted) return;

  context.push(
    AppRoutes.userVoteOutcome,
    extra: successVoteOutcomeRouteArgsFromFinalize(
      project: project,
      result: finalizeResult,
    ),
  );
}

Future<void> _openInviteMembers(
  BuildContext context, {
  required ProjectDetailEntity project,
}) async {
  if (!project.canInviteMembers) {
    AppToast.showError(context, AppStrings.errorForbidden);
    return;
  }

  AppLoadingDialog.show(context);
  final result = await ServiceLocator.instance.createInviteUseCase(
    projectId: project.id,
    requiresApproval: project.joinApprovalRequired,
    expiresInDays: 30,
    maxUses: 25,
  );

  if (!context.mounted) return;
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) nav.pop();

  final inviteLink = result.fold(
    (failure) {
      AppToast.showError(context, failure.message);
      return null;
    },
    (value) {
      final link = resolveInviteShareLink(value);
      if (link.isEmpty) {
        AppToast.showError(context, AppStrings.errorGeneric);
        return null;
      }
      return link;
    },
  );

  if (!context.mounted || inviteLink == null) return;

  final excludeUserIds = InviteMembersMapper.excludeUserIdsForProject(project);
  await AppInviteMembersDialog.show(
    context,
    projectId: project.id,
    projectName: project.name,
    excludeUserIds: excludeUserIds,
    inviteLink: inviteLink,
  );
}
