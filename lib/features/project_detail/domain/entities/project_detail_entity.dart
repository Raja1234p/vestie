import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'borrow_request_entity.dart';
import 'member_entity.dart';
import 'project_invite_entity.dart';
import 'viewer_membership_role.dart';

/// Header ⋯ on project detail (investment, vacation, emergency).
enum ProjectDetailOverflowMenuKind {
  member,
  leader,
}

/// Full project detail entity extending the base Project card data.
class ProjectDetailEntity {
  final String id;
  final String name;
  final ProjectCategory category;
  final ProjectStatus status;
  final double goalAmount;
  final double currentAmount;
  final String endsIn;
  final String announcement;
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
  final List<ProjectInviteEntity> invites;

  const ProjectDetailEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.goalAmount,
    required this.currentAmount,
    required this.endsIn,
    required this.announcement,
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
    this.invites = const [],
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
  bool get showsBorrowAction =>
      !category.isInvestment && borrowingEnabled;

  bool get isVacationOrEmergency =>
      category == ProjectCategory.vacations ||
      category == ProjectCategory.emergency;

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

  /// Vacation / emergency members: 4 items; investment members: 3 (no My Borrows).
  bool get memberProjectMenuIncludesMyBorrows => isVacationOrEmergency;
}
