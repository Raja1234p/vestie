import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'borrow_request_entity.dart';
import 'member_entity.dart';
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

  /// From API `displayStatus` (e.g. Draft, On Going).
  final String displayStatusLabel;
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

  final List<ProjectInviteEntity> invites;

  /// From API `project.hasCoLeader`.
  final bool hasCoLeader;

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
    this.borrowingEnabled = false,
    this.pendingJoinRequestCount = 0,
    this.projectInviteCode = '',
    this.roiPercentage,
    this.joinApprovalRequired = false,
    this.minimumContributionAmount = 0,
    this.penaltyPercentage,
    this.successVoteWindowHours = 0,
    this.hasActiveSuccessVote = false,
    this.invites = const [],
    this.hasCoLeader = false,
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

  /// Mark successful / initiate success vote — GroupLeader only.
  bool get canMarkProjectSuccessful => isGroupLeader;

  /// Stop contributions vote — group leader on investment projects only (not VAC / emergency).
  bool get canStopContributions => isGroupLeader && category.isInvestment;

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

  /// Leader / co-leader success-vote dev previews — vacation and emergency only.
  bool get showsSuccessVoteDevPreviews => isVacationOrEmergency;

  /// Leader / co-leader: replace wallet CTAs while a success vote is open.
  bool get showsViewSuccessVotesAction =>
      hasActiveSuccessVote &&
      usesLeaderDetailPanels &&
      showsSuccessVoteDevPreviews;

  /// Promote / demote co-leader — vacation and emergency only (see [ProjectCategoryX.supportsCoLeader]).
  bool get supportsCoLeader => category.supportsCoLeader;

  /// Remove member — group leader and co-leader on every project category.
  bool get canRemoveMembers => isModeratorView;

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
