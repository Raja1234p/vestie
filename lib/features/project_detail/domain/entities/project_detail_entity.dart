import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'borrow_request_entity.dart';
import 'closure_vote_entities.dart';
import 'member_entity.dart';
import 'project_detail_voting_entities.dart';
import 'project_announcement_entity.dart';
import 'project_invite_entity.dart';
import 'viewer_membership_role.dart';

/// Header ⋯ on project detail (investment, vacation, emergency).
enum ProjectDetailOverflowMenuKind { member, leader }

/// Full project detail entity extending the base Project card data.
class ProjectDetailEntity {
  final String id;
  final String name;
  final ProjectCategory category;
  final ProjectStatus status;
  final double goalAmount;
  final double currentAmount;

  /// From `GET /projects/{id}/pot` (`contributorCount`).
  final int contributorCount;
  final String endsIn;

  /// Legacy field — project `description` from API (not leader announcements).
  final String announcement;
  final List<ProjectAnnouncementEntity> announcements;
  final List<MemberEntity> members;
  final List<BorrowRequestEntity> borrowRequests;

  /// API `project.viewerRole`: `GroupLeader` | `CoLeader` | `Member`.
  final ViewerMembershipRole viewerRole;
  final String membershipId;
  final double borrowLimitAmount;
  final int repaymentWindowDays;
  final int repaymentGraceDays;
  final bool contributionsAreNonRefundable;

  /// From API `displayStatus` (e.g. Draft, On Going) — list/card pills only.
  final String displayStatusLabel;

  /// Raw `project.state` / `lifecycleState` from API (e.g. active, funded).
  final String projectLifecycleState;

  /// Week 11+ `projectStatus` — detail screen status banner.
  final ProjectDetailBannerStatus projectBannerStatus;

  /// Week 11+ `votingStatus` — voting card on detail when [projectBannerStatus] is ongoing.
  final ProjectVotingStatus votingStatus;

  /// Week 11+ top-level `userRole` — prefer for voting UI over [viewerRole].
  final ProjectDetailUserRole detailUserRole;

  /// Week 11+ `voting` — populated when [votingStatus] is pending or done.
  final ProjectVotingSummaryEntity? voting;

  /// Set when `GET /projects/{id}` includes Week 11 envelope fields.
  final bool hasWeek11ProjectDetailEnvelope;

  final bool borrowingEnabled;

  /// From API `project.pendingRequestCount` (join requests awaiting approval).
  final int pendingJoinRequestCount;
  final String projectInviteCode;
  final double? roiPercentage;
  final bool joinApprovalRequired;
  final double minimumContributionAmount;
  final double? penaltyPercentage;
  final int successVoteWindowHours;

  /// Success vote in progress — hide Contribute/Borrow; show View Success Votes.
  final bool hasActiveSuccessVote;

  /// From `GET …/closure-voting/active` when a vote window is open.
  final ActiveClosureVoteEntity? activeClosureVote;

  final List<ProjectInviteEntity> invites;

  /// From API `project.hasCoLeader`.
  final bool hasCoLeader;

  final PaginationInfo membersPagination;
  final PaginationInfo invitesPagination;
  final PaginationInfo announcementsPagination;

  const ProjectDetailEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.goalAmount,
    required this.currentAmount,
    this.contributorCount = 0,
    required this.endsIn,
    required this.announcement,
    this.announcements = const [],
    required this.members,
    required this.borrowRequests,
    this.viewerRole = ViewerMembershipRole.member,
    this.membershipId = '',
    this.borrowLimitAmount = 0,
    this.repaymentWindowDays = 0,
    this.repaymentGraceDays = 0,
    this.contributionsAreNonRefundable = false,
    this.displayStatusLabel = '',
    this.projectLifecycleState = '',
    this.projectBannerStatus = ProjectDetailBannerStatus.ongoing,
    this.votingStatus = ProjectVotingStatus.notStarted,
    this.detailUserRole = ProjectDetailUserRole.member,
    this.voting,
    this.hasWeek11ProjectDetailEnvelope = false,
    this.borrowingEnabled = false,
    this.pendingJoinRequestCount = 0,
    this.projectInviteCode = '',
    this.roiPercentage,
    this.joinApprovalRequired = false,
    this.minimumContributionAmount = 0,
    this.penaltyPercentage,
    this.successVoteWindowHours = 0,
    this.hasActiveSuccessVote = false,
    this.activeClosureVote,
    this.invites = const [],
    this.hasCoLeader = false,
    this.membersPagination = const PaginationInfo(
      page: 1,
      pageSize: 20,
      totalCount: 0,
      totalPages: 0,
    ),
    this.invitesPagination = const PaginationInfo(
      page: 1,
      pageSize: 20,
      totalCount: 0,
      totalPages: 0,
    ),
    this.announcementsPagination = const PaginationInfo(
      page: 1,
      pageSize: 20,
      totalCount: 0,
      totalPages: 0,
    ),
  });

  double get progress =>
      goalAmount > 0 ? (currentAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  bool get isGroupLeader => viewerRole.isGroupLeader;

  bool get isCoLeader => viewerRole.isCoLeader;

  bool get isMember => viewerRole.isMember;

  /// `viewerRole: Member` — participant detail UI.
  bool get isMemberView => isMember;

  /// `viewerRole: CoLeader` — same as [isModeratorView] for now.
  bool get isCoLeaderView => isCoLeader;

  /// `viewerRole: GroupLeader` — same as [isModeratorView] for now.
  bool get isGroupLeaderView => isGroupLeader;

  /// GroupLeader and CoLeader share the same detail UI (until product splits them).
  bool get isModeratorView => isGroupLeader || isCoLeader;

  /// Mark successful / initiate success vote — leader menu (legacy); card uses [canStartVotingOnDetail].
  bool get canMarkProjectSuccessful => isGroupLeader;

  /// Stop contributions vote — group leader on investment projects only (not VAC / emergency).
  bool get canStopContributions => isGroupLeader && category.isInvestment;

  bool get isDetailLeader =>
      resolvedDetailUserRole == ProjectDetailUserRole.leader;

  bool get isDetailCoLeader =>
      resolvedDetailUserRole == ProjectDetailUserRole.coLeader;

  bool get isDetailMember =>
      resolvedDetailUserRole == ProjectDetailUserRole.member;

  /// Prefer Week 11 `userRole`; fall back to nested `project.viewerRole` for legacy paths.
  ProjectDetailUserRole get resolvedDetailUserRole {
    if (hasWeek11ProjectDetailEnvelope) return detailUserRole;
    return projectDetailUserRoleFromViewerRole(
      switch (viewerRole) {
        ViewerMembershipRole.groupLeader => 'leader',
        ViewerMembershipRole.coLeader => 'co_leader',
        ViewerMembershipRole.member => 'member',
      },
    );
  }

  /// Leader and co-leader share the same voting card actions (Week 11+).
  bool get isDetailModeratorForVoting =>
      isDetailLeader || isDetailCoLeader;

  bool get showsProjectDetailStatusBanner => hasWeek11ProjectDetailEnvelope;

  /// True when `GET /projects/{id}` includes Week 11 voting fields.
  bool get hasWeek11VotingPayload => hasWeek11ProjectDetailEnvelope;

  /// Voting card only when project is ongoing and Week 11 voting data is present.
  bool get showsProjectDetailVotingCard =>
      projectBannerStatus == ProjectDetailBannerStatus.ongoing &&
      hasWeek11VotingPayload;

  bool get votingIsInProgress =>
      votingStatus == ProjectVotingStatus.pending ||
      votingStatus == ProjectVotingStatus.done;

  /// Week 11+: start vote from detail card (leader + co-leader).
  bool get canStartVotingOnDetail =>
      isDetailModeratorForVoting &&
      votingStatus == ProjectVotingStatus.notStarted;

  bool get canViewVotesOnDetail =>
      isDetailModeratorForVoting && votingIsInProgress;

  bool get canCloseVotingOnDetail =>
      isDetailModeratorForVoting &&
      votingStatus == ProjectVotingStatus.pending &&
      voting != null &&
      !voting!.isFinalized;

  bool get canFinalizeVotingOnDetail =>
      isDetailLeader &&
      votingStatus == ProjectVotingStatus.done &&
      voting != null &&
      !voting!.isFinalized;

  /// Member inline cast on project detail (Week 11+).
  bool get showsInlineMemberCastVote =>
      isDetailMember &&
      votingStatus == ProjectVotingStatus.pending &&
      voting != null &&
      !voting!.hasVoted;

  bool get showsMemberVoteSubmittedLabel =>
      isDetailMember &&
      votingIsInProgress &&
      voting != null &&
      voting!.hasVoted;

  /// Edit project / cancel project — GroupLeader only (CoLeader popup Figma).
  bool get canEditProject => isGroupLeader;

  bool get canCancelProject => isGroupLeader;

  /// Leader tabs / borrow-management panels (GroupLeader + CoLeader).
  bool get usesLeaderDetailPanels => isModeratorView;

  String get categoryLabel {
    return category.detailLabel;
  }

  String get statusBadgeLabel {
    if (displayStatusLabel.trim().isNotEmpty) {
      return displayStatusLabel.trim();
    }
    return status == ProjectStatus.ongoing
        ? AppStrings.statusOnGoing
        : AppStrings.statusCompleted;
  }

  String get projectBannerLabel => switch (projectBannerStatus) {
    ProjectDetailBannerStatus.ongoing => AppStrings.projectBannerOngoing,
    ProjectDetailBannerStatus.completed => AppStrings.projectBannerCompleted,
    ProjectDetailBannerStatus.cancelled => AppStrings.projectBannerCancelled,
  };

  bool get isDraftStatus => displayStatusLabel.toLowerCase() == 'draft';

  /// Investment projects: Contribute only (Figma). Others: Contribute + Borrow when enabled.
  bool get showsBorrowAction => !category.isInvestment && borrowingEnabled;

  /// Vacation / emergency group leaders cannot borrow until a co-leader is assigned.
  bool get isBorrowDisabledForViewer =>
      isVacationOrEmergency && isGroupLeader && !hasCoLeader;

  /// Whether the current viewer may open the borrow flow.
  bool get canViewerBorrow => showsBorrowAction && !isBorrowDisabledForViewer;

  bool get isVacationOrEmergency =>
      category == ProjectCategory.vacations ||
      category == ProjectCategory.emergency;

  /// Member success-vote dev previews — all project categories.
  bool get showsMemberSuccessVoteDevPreviews => true;

  /// Leader / co-leader success-vote dev previews — vacation and emergency.
  bool get showsSuccessVoteDevPreviews => isVacationOrEmergency;

  /// Investment group leader — vote outcome dev previews (approve / reject).
  bool get showsInvestmentVoteOutcomeDevPreviews =>
      isModeratorView && category.isInvestment;

  /// Legacy wallet CTA — superseded by [ProjectDetailVotingCard] when Week 11 fields are active.
  bool get showsViewSuccessVotesAction =>
      hasActiveSuccessVote &&
      usesLeaderDetailPanels &&
      !hasWeek11VotingPayload;

  /// Legacy navigation cast button when Week 11 card is not active.
  bool get showsCastVoteAction =>
      hasActiveSuccessVote &&
      isMemberView &&
      !hasWeek11VotingPayload;

  /// Hide Contribute/Borrow while a vote is in progress on the detail card.
  bool get hidesWalletActionsForVoting =>
      hasWeek11VotingPayload && votingIsInProgress;

  /// Promote / demote co-leader — vacation and emergency only (see [ProjectCategoryX.supportsCoLeader]).
  bool get supportsCoLeader => category.supportsCoLeader;

  /// Remove member — group leader only (co-leaders cannot remove members).
  bool get canRemoveMembers => isGroupLeader;

  /// Which ⋯ menu to show — same rules on investment, vacation, and emergency.
  ProjectDetailOverflowMenuKind get overflowMenuKind {
    if (isModeratorView) return ProjectDetailOverflowMenuKind.leader;
    return ProjectDetailOverflowMenuKind.member;
  }

  bool get showsMemberProjectActionsMenu =>
      overflowMenuKind == ProjectDetailOverflowMenuKind.member;

  bool get showsLeaderProjectActionsMenu =>
      overflowMenuKind == ProjectDetailOverflowMenuKind.leader;

  /// Join-requests pill — GroupLeader and CoLeader only.
  bool get showsJoinRequestsHeaderChip => isModeratorView;

  bool get showsProjectDetailOverflowMenu => isMemberView || isModeratorView;

  /// GroupLeader, CoLeader, and Member can open the invite-members sheet.
  bool get canInviteMembers => showsProjectDetailOverflowMenu;

  /// Any active participant can open another member's profile and send VFF
  /// to anyone except themselves (same for all project categories).
  bool get canReviewMemberProfiles => isMember || isModeratorView;

  /// Vacation / emergency members: 4 items; investment members: 3 (no My Borrows).
  bool get memberProjectMenuIncludesMyBorrows => isVacationOrEmergency;
}
