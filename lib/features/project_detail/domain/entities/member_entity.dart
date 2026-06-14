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

  /// API `badge` — `Top Contributor` or `Overdue` (mutually exclusive contribution pills).
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

  /// Viewer is VFF-linked to this member — `Connected` + `VFFAdded` from project detail.
  bool get isViewerVffLinked {
    if (hasPendingVffOutgoing ||
        vffConnectionState == VffConnectionState.pendingIncoming) {
      return false;
    }
    return isVffConnected && vffAdded;
  }

  bool get hasPendingVffOutgoing {
    if (isVffConnected) return false;
    if (vffConnectionState == VffConnectionState.pendingOutgoing) return true;
    if (vffConnectionState == VffConnectionState.pendingIncoming) return false;
    final pendingId = pendingVffRequestId?.trim();
    return pendingId != null && pendingId.isNotEmpty;
  }

  /// VFF pill — `vffConnectionState: Connected` and `VFFAdded: true` on `members[]`.
  bool get showsVffBadgeOnMemberRow => isViewerVffLinked;

  /// Top Contributor pill — `badge: Top Contributor` on any role (member, leader, co-leader).
  bool get showsContributionBadge => badge == topContributorBadgeLabel;

  /// Overdue pill — `badge: Overdue` plus a positive `overdueAmount` (no icon).
  bool get showsOverdueBadge =>
      badge == overdueBadgeLabel &&
      overdueAmount != null &&
      overdueAmount! > 0;

  /// Amount for [ProjectMemberOverdueBadge] — only valid when [showsOverdueBadge].
  double get overdueBadgeDisplayAmount => overdueAmount ?? 0;

  static const topContributorBadgeLabel = 'Top Contributor';
  static const overdueBadgeLabel = 'Overdue';

  static bool isTopContributorBadge(String label) {
    return _normalizeBadgeLabel(label) == 'topcontributor';
  }

  static bool isOverdueBadge(String label) {
    return _normalizeBadgeLabel(label) == 'overdue';
  }

  /// Keeps only Top Contributor or Overdue from API; all other badge values are ignored.
  static String memberBadgeFromApi(String raw) {
    if (isTopContributorBadge(raw)) return topContributorBadgeLabel;
    if (isOverdueBadge(raw)) return overdueBadgeLabel;
    return '';
  }

  static String _normalizeBadgeLabel(String label) =>
      label.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

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
