import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

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
  final String? photoUrl;
  final bool vffAdded;
  final VffConnectionState vffConnectionState;
  final bool canSendVffRequest;
  final String? pendingVffRequestId;

  /// API `badge` — e.g. `Top Contributor` from `viewerMembership` / `members[]`.
  final String badge;

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
    this.photoUrl,
    this.vffAdded = false,
    this.vffConnectionState = VffConnectionState.none,
    this.canSendVffRequest = false,
    this.pendingVffRequestId,
    this.badge = '',
  });

  bool get isVffConnected => vffConnectionState == VffConnectionState.connected;

  bool get hasPendingVffOutgoing {
    if (isVffConnected) return false;
    if (vffConnectionState == VffConnectionState.pendingOutgoing) return true;
    if (vffConnectionState == VffConnectionState.pendingIncoming) return false;
    final pendingId = pendingVffRequestId?.trim();
    return pendingId != null && pendingId.isNotEmpty;
  }

  /// Connected / VFF on this membership — row UI hides for viewer self via [ProjectMemberAddFriendVisibility].
  bool get showsVffBadgeOnMemberRow => isVffConnected || vffAdded;

  /// Membership contribution pill (e.g. Top Contributor) — not when API badge repeats role.
  bool get showsContributionBadge {
    final label = badge.trim();
    if (label.isEmpty) return false;
    return !_badgeDuplicatesRoleBadge(label);
  }

  static String _normalizeBadgeLabel(String label) =>
      label.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  bool _badgeDuplicatesRoleBadge(String label) {
    final normalized = _normalizeBadgeLabel(label);
    return switch (role) {
      MemberRole.leader => const {'leader', 'groupleader', 'projectleader'}
          .contains(normalized),
      MemberRole.coLeader => const {'coleader'}.contains(normalized),
      MemberRole.member => false,
    };
  }

  MemberEntity copyWith({
    String? id,
    String? membershipId,
    String? userId,
    String? initials,
    String? name,
    String? username,
    String? status,
    MemberRole? role,
    double? contributedAmount,
    double? overdueAmount,
    String? photoUrl,
    bool? vffAdded,
    VffConnectionState? vffConnectionState,
    bool? canSendVffRequest,
    String? pendingVffRequestId,
    String? badge,
    bool clearPendingVffRequestId = false,
  }) {
    return MemberEntity(
      id: id ?? this.id,
      membershipId: membershipId ?? this.membershipId,
      userId: userId ?? this.userId,
      initials: initials ?? this.initials,
      name: name ?? this.name,
      username: username ?? this.username,
      status: status ?? this.status,
      role: role ?? this.role,
      contributedAmount: contributedAmount ?? this.contributedAmount,
      overdueAmount: overdueAmount ?? this.overdueAmount,
      photoUrl: photoUrl ?? this.photoUrl,
      vffAdded: vffAdded ?? this.vffAdded,
      vffConnectionState: vffConnectionState ?? this.vffConnectionState,
      canSendVffRequest: canSendVffRequest ?? this.canSendVffRequest,
      pendingVffRequestId: clearPendingVffRequestId
          ? null
          : (pendingVffRequestId ?? this.pendingVffRequestId),
      badge: badge ?? this.badge,
    );
  }
}
