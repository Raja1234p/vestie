/// Parsed from `GET /projects/{id}` → `viewerMembership.role`.
///
/// Week 3 API roles: `Leader` (primary), `CoLeader` / `Co-Leader`, `Member`.
/// Drives leader vs co-leader vs member detail UI after project load.
enum ViewerMembershipRole {
  leader,
  coLeader,
  member,
  unknown;

  /// Normalizes API values such as `Leader`, `CoLeader`, `Co-Leader`, `Member`.
  static ViewerMembershipRole parse(String? role) {
    final compact =
        (role ?? '').toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (compact == 'leader' || compact == 'owner') {
      return ViewerMembershipRole.leader;
    }
    if (compact == 'coleader') {
      return ViewerMembershipRole.coLeader;
    }
    if (compact == 'member') {
      return ViewerMembershipRole.member;
    }
    return ViewerMembershipRole.unknown;
  }

  bool get isPrimaryLeader => this == ViewerMembershipRole.leader;

  bool get isCoLeader => this == ViewerMembershipRole.coLeader;

  /// Borrow approvals, join requests, invites, announcements (not ownership actions).
  bool get hasManagementPrivileges =>
      isPrimaryLeader || isCoLeader;

  /// Home list grouping: leaders and co-leaders appear under “My projects”.
  bool get isOwnedListRelation => hasManagementPrivileges;
}
