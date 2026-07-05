part of 'project_detail_navigation.dart';

ProjectWalletFlowArgs _walletArgs(ProjectDetailEntity project) {
  final dueBy = project.repaymentWindowDays > 0
      ? 'In ${project.repaymentWindowDays} days'
      : ProjectWalletFlowArgs.defaultBorrowDueByLabel;
  final cachedBalance = WalletBalanceCache.value?.availableBalance;
  return ProjectWalletFlowArgs(
    projectId: project.id,
    projectName: project.name,
    walletBalance: cachedBalance ?? 0,
    borrowLimit: project.borrowLimitAmount > 0
        ? project.borrowLimitAmount
        : ProjectWalletFlowArgs.defaultBorrowLimit,
    borrowDueByLabel: dueBy,
    membershipId: project.membershipId.isEmpty ? null : project.membershipId,
    goalAmount: project.goalAmount,
    currentAmount: project.currentAmount,
  );
}

MemberDetailRouteArgs _memberDetailArgs(
  ProjectDetailEntity project,
  MemberEntity member, {
  Future<void> Function()? onProjectMembersChanged,
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

BorrowRequestsRouteArgs _borrowRequestsArgs(
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

GroupMembersRouteArgs _groupMembersArgs(ProjectDetailEntity project) {
  return GroupMembersRouteArgs(
    members: project.members,
    projectId: project.id,
    project: project,
  );
}

ProjectFundsHistoryRouteArgs _fundsHistoryArgs(ProjectDetailEntity project) {
  return ProjectFundsHistoryRouteArgs(
    projectId: project.id,
    isInvestment: project.category.isInvestment,
    useBreakdownSectionTitle:
        project.category.isInvestment || project.isCoLeader,
  );
}
