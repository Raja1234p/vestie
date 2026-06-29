import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/domain/entities/cancel_project_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/leader_voting_flow_kind.dart';
import 'package:vestie/features/project_detail/domain/entities/member_activity_penalty_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';

export 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
export 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
export 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';

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
  final InvestmentReturnsUiData? data;
  final String? projectId;
  final String? projectName;
  final bool isLeaderView;
  final bool isPreview;

  const InvestmentReturnsRouteArgs({
    this.data,
    this.projectId,
    this.projectName,
    this.isLeaderView = false,
    this.isPreview = false,
  });
}

class InvestmentDistributionRouteArgs {
  final InvestmentDistributionUiData? data;
  final String projectId;
  final String? projectName;
  final double distributeAmountUsd;
  final bool isPreview;

  const InvestmentDistributionRouteArgs({
    required this.projectId,
    this.projectName,
    this.distributeAmountUsd = 0,
    this.data,
    this.isPreview = false,
  });
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

  /// Penalty payload from member activity API (`penalty` object).
  final MemberActivityPenaltyEntity? penalty;

  const MemberPenaltyActionRouteArgs({
    required this.member,
    required this.projectId,
    this.project,
    this.penalty,
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
  final ProjectCategory projectCategory;

  const MarkSuccessfulRouteArgs({
    required this.projectId,
    required this.memberCount,
    required this.projectCategory,
  });
}

class StopContributionsRouteArgs {
  final String projectId;
  final ProjectCategory projectCategory;

  const StopContributionsRouteArgs({
    required this.projectId,
    this.projectCategory = ProjectCategory.investment,
  });
}

class VotingWindowRouteArgs {
  final String projectId;
  final LeaderVotingFlowKind flowKind;
  final ProjectCategory projectCategory;

  const VotingWindowRouteArgs({
    required this.projectId,
    this.flowKind = LeaderVotingFlowKind.markProjectSuccessful,
    required this.projectCategory,
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
  final int refundedMemberCount;
  final int defaultedMemberCount;
  final double totalRefunded;

  const ProjectCancelledRouteArgs({
    required this.projectName,
    this.refundedMemberCount = 0,
    this.defaultedMemberCount = 0,
    this.totalRefunded = 0,
  });

  factory ProjectCancelledRouteArgs.fromCancelResult({
    required String projectName,
    required CancelProjectResultEntity result,
  }) {
    return ProjectCancelledRouteArgs(
      projectName: projectName,
      refundedMemberCount: result.refundedMemberCount,
      defaultedMemberCount: result.defaultedMemberCount,
      totalRefunded: result.totalRefunded,
    );
  }

  bool get hasRefundSummary =>
      refundedMemberCount > 0 ||
      defaultedMemberCount > 0 ||
      totalRefunded > 0;
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
  final String? projectId;
  final bool isPreview;
  final LeaderSuccessVoteProgressUiData data;

  /// Production context for navigating to vote outcome after finalize.
  final ProjectDetailEntity? project;

  const LeaderViewSuccessVotesRouteArgs({
    required this.projectName,
    required this.data,
    this.projectId,
    this.isPreview = false,
    this.project,
  });
}
