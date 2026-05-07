/// Represents a single member inside a project.
enum MemberRole { leader, coLeader, member }

class MemberEntity {
  final String id;
  final String membershipId;
  final String userId;
  final String initials;
  final String name;
  final String username;
  final String status;
  final MemberRole role;
  final double contributedAmount;
  final double? overdueAmount;

  const MemberEntity({
    required this.id,
    this.membershipId = '',
    this.userId = '',
    required this.initials,
    required this.name,
    this.username = '',
    this.status = '',
    required this.role,
    required this.contributedAmount,
    this.overdueAmount,
  });
}
