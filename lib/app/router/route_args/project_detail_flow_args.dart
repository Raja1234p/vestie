import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/leader_voting_flow_kind.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';
import 'package:vestie/user/features/project_detail/presentation/models/member_vote_outcome_ui_data.dart';

import 'project_wallet_flow_args.dart';

/// History row badge styling on My Borrow Request.
enum MyBorrowHistoryBadgeKind { approved, cancelled, rejected }

/// One row in My Borrow Request — borrow history (Figma).
class MyBorrowHistoryEntry {
  final String id;
  final double amount;
  final String dateLabel;
  final bool isApproved;

  /// API `status` — used to resolve repay when [currentRequest] is null.
  final String status;

  /// API `statusDisplay` — user-facing badge label (e.g. Cancelled, Approved).
  final String statusDisplay;

  const MyBorrowHistoryEntry({
    this.id = '',
    required this.amount,
    required this.dateLabel,
    required this.isApproved,
    this.status = '',
    this.statusDisplay = '',
  });

  bool get isCancelled => status == 'Cancelled';

  bool get isRepayable =>
      status == 'Disbursed' || status == 'Overdue' || status == 'Approved';

  MyBorrowHistoryBadgeKind get badgeKind {
    if (isCancelled) return MyBorrowHistoryBadgeKind.cancelled;
    if (isApproved || status == 'Repaid') {
      return MyBorrowHistoryBadgeKind.approved;
    }
    return MyBorrowHistoryBadgeKind.rejected;
  }
}

/// Member / leader “My Borrow Request” screen (not the group borrow-requests list).
class MyBorrowRequestRouteArgs {
  final String projectId;
  final String projectName;
  final ProjectWalletFlowArgs walletFlowArgs;
  final BorrowRequestEntity? activeRequest;
  final List<MyBorrowHistoryEntry> history;
  final MyBorrowApprovedUiData? approvedBorrow;

  /// Vacation/emergency group leaders cannot borrow until a co-leader exists.
  final bool borrowDisabledForViewer;

  const MyBorrowRequestRouteArgs({
    required this.projectId,
    this.projectName = '',
    required this.walletFlowArgs,
    this.activeRequest,
    this.history = const [],
    this.approvedBorrow,
    this.borrowDisabledForViewer = false,
  });
}

class InvestmentReturnsRouteArgs {
  final InvestmentReturnsUiData data;

  const InvestmentReturnsRouteArgs({required this.data});
}

class InvestmentDistributionRouteArgs {
  final InvestmentDistributionUiData data;

  const InvestmentDistributionRouteArgs({required this.data});
}

class InvestmentDistributionSuccessRouteArgs {
  final String projectId;
  final String? projectName;
  final double amountUsd;
  final int memberCount;

  const InvestmentDistributionSuccessRouteArgs({
    required this.projectId,
    this.projectName,
    required this.amountUsd,
    required this.memberCount,
  });
}

class GroupMembersRouteArgs {
  final List<MemberEntity> members;
  final String projectId;
  final ProjectDetailEntity? project;

  const GroupMembersRouteArgs({
    required this.members,
    required this.projectId,
    this.project,
  });
}

class BorrowRequestsRouteArgs<T> {
  final List<T> requests;
  final bool isLeaderMode;
  final String projectId;
  final String? screenTitle;

  /// Full project context — member profile navigation from borrow cards.
  final ProjectDetailEntity? project;

  const BorrowRequestsRouteArgs({
    required this.requests,
    required this.projectId,
    this.isLeaderMode = false,
    this.screenTitle,
    this.project,
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

  /// Co-leader (and investment) fund history list title — [AppStrings.labelBreakdown].
  final bool useBreakdownSectionTitle;

  const ProjectFundsHistoryRouteArgs({
    required this.projectId,
    required this.currentPotBalance,
    required this.totalContribution,
    required this.activeBorrows,
    this.entries = const [],
    this.isInvestment = false,
    this.useBreakdownSectionTitle = false,
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
  final Future<void> Function()? onRefreshProjectDetail;

  const JoinRequestsRouteArgs({
    required this.projectId,
    this.onRefreshProjectDetail,
  });
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

  /// Viewer project context — leader actions & VFF CTA visibility.
  final ProjectDetailEntity? project;

  /// Leader or co-leader: moderation tools (overdue, borrow context).
  final bool isLeaderView;

  /// Called after co-leader assign/remove so project detail can reload members.
  final Future<void> Function()? onProjectMembersChanged;

  const MemberDetailRouteArgs({
    required this.member,
    required this.projectId,
    required this.projectName,
    this.project,
    this.isLeaderView = false,
    this.onProjectMembersChanged,
  });
}

class MemberPenaltyActionRouteArgs<T> {
  final T member;
  final String projectId;

  /// Viewer project context — same action visibility as [MemberDetailScreen].
  final ProjectDetailEntity? project;

  const MemberPenaltyActionRouteArgs({
    required this.member,
    required this.projectId,
    this.project,
  });
}

/// Popped from [MemberDetailScreen] — tells callers how to update the stack.
enum MemberDetailPopResult {
  /// Member was removed — pop group-members (if open) and refresh project detail.
  memberRemoved,

  /// Co-leader changed — refresh project detail when caller handles the result.
  membersUpdated,
}

/// Popped from penalty screen after a successful remove / mark-defaulted action.
enum MemberPenaltyActionOutcome {
  /// Member remains in the project — caller should reload member activity.
  memberUpdated,

  /// Member was removed — caller should pop member profile and refresh project.
  memberRemoved,
}

class MarkSuccessfulRouteArgs {
  final String projectId;
  final int memberCount;

  const MarkSuccessfulRouteArgs({
    required this.projectId,
    required this.memberCount,
  });
}

class StopContributionsRouteArgs {
  final String projectId;

  const StopContributionsRouteArgs({required this.projectId});
}

class VotingWindowRouteArgs {
  final String projectId;
  final LeaderVotingFlowKind flowKind;

  const VotingWindowRouteArgs({
    required this.projectId,
    this.flowKind = LeaderVotingFlowKind.markProjectSuccessful,
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

/// Member leave-project warning screen (Figma).
class LeaveProjectRouteArgs {
  final String projectId;
  final String projectName;

  /// When true, success navigates to dashboard and reloads home/discover lists.
  final bool refreshHomeOnPop;

  /// When true, success navigates to Discover and reloads the discover list only.
  final bool refreshDiscoverOnPop;

  const LeaveProjectRouteArgs({
    required this.projectId,
    required this.projectName,
    this.refreshHomeOnPop = false,
    this.refreshDiscoverOnPop = false,
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

  const UserStatusFlowArgs({required this.projectName, required this.kind});
}

/// Group leader monitors active success vote (Figma voting window).
class LeaderViewSuccessVotesRouteArgs {
  final String projectName;
  final LeaderSuccessVoteProgressUiData data;

  const LeaderViewSuccessVotesRouteArgs({
    required this.projectName,
    required this.data,
  });
}

/// Success-vote outcome (majority approved / not approved).
class MemberVoteOutcomeRouteArgs {
  final MemberVoteOutcomeUiData data;

  /// Group leader vacation / emergency — Figma CTAs and layout (no amount card).
  final bool isGroupLeaderView;

  /// When set, leader “Start Distributing” opens the distribute-funds preview flow.
  final ProjectDetailEntity? project;

  const MemberVoteOutcomeRouteArgs({
    required this.data,
    this.isGroupLeaderView = false,
    this.project,
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
