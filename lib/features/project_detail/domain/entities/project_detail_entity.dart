import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'borrow_request_entity.dart';
import 'member_entity.dart';
import 'viewer_membership_role.dart';

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
  /// From `viewerMembership.role` — drives leader / co-leader / member UI.
  final ViewerMembershipRole viewerRole;
  final String membershipId;
  final double borrowLimitAmount;
  final int repaymentWindowDays;
  final int repaymentGraceDays;
  final bool contributionsAreNonRefundable;

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
  });

  double get progress =>
      goalAmount > 0 ? (currentAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  bool get isLeader => viewerRole.isPrimaryLeader;

  bool get isCoLeader => viewerRole.isCoLeader;

  /// Leader or co-leader: borrow approvals, member list management, announcements, invites.
  bool get hasManagementPrivileges => viewerRole.hasManagementPrivileges;

  int get pendingJoinRequestCount =>
      members.where((m) => m.status.toLowerCase().contains('pending')).length;

  String get categoryLabel {
    return category.detailLabel;
  }
}
