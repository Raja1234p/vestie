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
      data: InvestmentDistributionUiData.preview(
        projectId: returnsData.projectId,
        projectName: returnsData.projectName,
        distributeAmountUsd: amountUsd,
      ),
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

void _openLeaderViewSuccessVotes(
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

void _openSuccessVoteScreenPreview(
  BuildContext context, {
  required ProjectDetailEntity project,
}) {
  if (!project.showsMemberSuccessVoteDevPreviews) return;

  final memberCount = project.members.isNotEmpty ? project.members.length : 7;
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
      deadlineLabel: project.endsIn.trim().isNotEmpty
          ? project.endsIn
          : 'May 12, 2025',
      daysRemaining: 21,
    ),
  );
}

void _openMemberVoteOutcomePreview(
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
