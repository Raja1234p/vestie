/// Represents a single member inside a project.
enum MemberRole { leader, coLeader, member }

class MemberEntity {
  final String id;
  final String initials;
  final String name;
  final MemberRole role;
  final double contributedAmount;

  const MemberEntity({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.contributedAmount,
  });
}
