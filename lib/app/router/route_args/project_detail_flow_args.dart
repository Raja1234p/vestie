import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';

import 'project_wallet_flow_args.dart';

/// One row in My Borrow Request — borrow history (Figma).
class MyBorrowHistoryEntry {
  final double amount;
  final String dateLabel;
  final bool isApproved;

  const MyBorrowHistoryEntry({
    required this.amount,
    required this.dateLabel,
    required this.isApproved,
  });
}

/// Member / leader “My Borrow Request” screen (not the group borrow-requests list).
class MyBorrowRequestRouteArgs {
  final String projectId;
  final ProjectWalletFlowArgs walletFlowArgs;
  final BorrowRequestEntity? activeRequest;
  final List<MyBorrowHistoryEntry> history;

  const MyBorrowRequestRouteArgs({
    required this.projectId,
    required this.walletFlowArgs,
    this.activeRequest,
    this.history = const [],
  });
}

class BorrowRequestsRouteArgs<T> {
  final List<T> requests;
  final bool isLeaderMode;
  final String projectId;
  final String? screenTitle;

  const BorrowRequestsRouteArgs({
    required this.requests,
    required this.projectId,
    this.isLeaderMode = false,
    this.screenTitle,
  });
}

class ProjectFundsHistoryRouteArgs {
  final String projectId;
  final double currentPotBalance;
  final double totalContribution;
  final double activeBorrows;
  final List<ProjectFundsHistoryEntryArgs> entries;
  /// Investment projects: balance + Breakdown only (Figma).
  final bool isInvestment;

  const ProjectFundsHistoryRouteArgs({
    required this.projectId,
    required this.currentPotBalance,
    required this.totalContribution,
    required this.activeBorrows,
    this.entries = const [],
    this.isInvestment = false,
  });

  /// Legacy alias — same as [currentPotBalance].
  double get totalFundsUsd => currentPotBalance;
}

class ProjectFundsHistoryEntryArgs {
  final String memberName;
  final String dateLabel;
  final double amount;

  const ProjectFundsHistoryEntryArgs({
    required this.memberName,
    required this.dateLabel,
    required this.amount,
  });
}

class JoinRequestsRouteArgs {
  final String projectId;

  const JoinRequestsRouteArgs({required this.projectId});
}

/// Storyboard “Project settings” hub (leader + co-leader; rows vary by role).
class LeaderProjectSettingsRouteArgs {
  final String projectId;

  const LeaderProjectSettingsRouteArgs({required this.projectId});
}

class MemberDetailRouteArgs<T> {
  final T member;
  final String projectId;
  final String projectName;
  /// Leader or co-leader: moderation tools (overdue, borrow context).
  final bool isLeaderView;
  /// Primary owner only: remove member, assign / remove co-leader.
  final bool isPrimaryLeaderView;

  const MemberDetailRouteArgs({
    required this.member,
    required this.projectId,
    required this.projectName,
    this.isLeaderView = false,
    this.isPrimaryLeaderView = false,
  });
}

class MemberPenaltyActionRouteArgs<T> {
  final T member;
  final String projectId;

  const MemberPenaltyActionRouteArgs({
    required this.member,
    required this.projectId,
  });
}

class MarkSuccessfulRouteArgs {
  final String projectId;
  final int memberCount;

  const MarkSuccessfulRouteArgs({
    required this.projectId,
    required this.memberCount,
  });
}

class CancelProjectRouteArgs {
  final String projectId;
  final String projectName;
  final int membersWithUnpaidBorrows;

  const CancelProjectRouteArgs({
    required this.projectId,
    required this.projectName,
    this.membersWithUnpaidBorrows = 0,
  });
}

class ProjectCancelledRouteArgs {
  final String projectName;

  const ProjectCancelledRouteArgs({required this.projectName});
}

/// Full-screen join / mark-vote outcomes (member flows).
enum UserStatusFlowKind {
  joinApproved,
  joinRejected,
  markVotedSuccess,
  markVotedIncomplete,
}

class UserStatusFlowArgs {
  final String projectName;
  final UserStatusFlowKind kind;

  const UserStatusFlowArgs({
    required this.projectName,
    required this.kind,
  });
}

/// Member success-vote screen (leader has started a vote).
class UserSuccessVoteArgs {
  final String? projectId;
  final String projectName;
  final double goalAmount;
  final int memberCount;
  final double totalRaised;
  final String deadlineLabel;
  final int daysRemaining;

  const UserSuccessVoteArgs({
    this.projectId,
    required this.projectName,
    required this.goalAmount,
    required this.memberCount,
    required this.totalRaised,
    required this.deadlineLabel,
    required this.daysRemaining,
  });
}

