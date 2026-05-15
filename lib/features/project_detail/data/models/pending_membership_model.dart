import '../../domain/entities/member_entity.dart';
import '../../domain/entities/pending_join_request_entity.dart';

class PendingMembershipModel {
  final String membershipId;
  final String userId;
  final String status;
  final String? userName;
  final String? firstName;
  final String? lastName;

  const PendingMembershipModel({
    required this.membershipId,
    required this.userId,
    required this.status,
    this.userName,
    this.firstName,
    this.lastName,
  });

  factory PendingMembershipModel.fromJson(Map<String, dynamic> json) {
    return PendingMembershipModel(
      membershipId: (json['membershipId'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'Pending',
      userName: json['userName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  PendingJoinRequestEntity toEntity() {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    final handle = (userName ?? '').trim();
    final fullName = '$first $last'.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (handle.isNotEmpty ? handle : 'Member');

    return PendingJoinRequestEntity(
      membershipId: membershipId,
      userId: userId,
      status: status,
      displayName: displayName,
      username: handle,
      initials: _initials(displayName),
    );
  }

  /// Enrich from [MemberEntity] when detail aggregate includes pending rows.
  PendingJoinRequestEntity enrichFromMember(MemberEntity member) {
    return PendingJoinRequestEntity(
      membershipId: membershipId.isNotEmpty ? membershipId : member.membershipId,
      userId: userId.isNotEmpty ? userId : member.userId,
      status: status,
      displayName: member.name,
      username: member.username,
      initials: member.initials,
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'NA';
    String c(String s) => s.isEmpty ? 'N' : s[0].toUpperCase();
    return '${c(parts.first)}${c(parts.length > 1 ? parts.last : parts.first)}';
  }
}
