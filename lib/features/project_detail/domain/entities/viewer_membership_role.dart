/// API viewer role on project detail — exactly three values.
///
/// `project.viewerRole`: `GroupLeader` | `CoLeader` | `Member` (or `1` | `2` | `3`).
/// GroupLeader and CoLeader use the same detail UI via [ProjectDetailEntity.isModeratorView].
enum ViewerMembershipRole {
  groupLeader,
  coLeader,
  member;

  /// API label for logging / display.
  String get apiLabel => switch (this) {
        ViewerMembershipRole.groupLeader => 'GroupLeader',
        ViewerMembershipRole.coLeader => 'CoLeader',
        ViewerMembershipRole.member => 'Member',
      };

  static ViewerMembershipRole parse(String? role) {
    final compact =
        (role ?? '').toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    switch (compact) {
      case '1':
      case 'groupleader':
      case 'grouplead':
        return ViewerMembershipRole.groupLeader;
      case '2':
      case 'coleader':
        return ViewerMembershipRole.coLeader;
      case '3':
      case 'member':
        return ViewerMembershipRole.member;
      default:
        return ViewerMembershipRole.member;
    }
  }

  /// Resolves the signed-in viewer's role from `project.viewerRole` and
  /// `viewerMembership.role`, preferring the **highest** privilege.
  ///
  /// Some API payloads send `project.viewerRole: Member` for co-leaders while
  /// `viewerMembership.role` is `CoLeader` — taking project first hid remove-member
  /// and other moderator actions.
  static ViewerMembershipRole forProjectDetail({
    required String projectViewerRole,
    required String membershipRole,
  }) {
    final fromProject = _hasExplicitRole(projectViewerRole)
        ? parse(projectViewerRole)
        : ViewerMembershipRole.member;
    final fromMembership = _hasExplicitRole(membershipRole)
        ? parse(membershipRole)
        : ViewerMembershipRole.member;
    return _higherPrivilege(fromProject, fromMembership);
  }

  static ViewerMembershipRole _higherPrivilege(
    ViewerMembershipRole a,
    ViewerMembershipRole b,
  ) {
    int rank(ViewerMembershipRole role) => switch (role) {
          ViewerMembershipRole.groupLeader => 3,
          ViewerMembershipRole.coLeader => 2,
          ViewerMembershipRole.member => 1,
        };
    return rank(a) >= rank(b) ? a : b;
  }

  static bool _hasExplicitRole(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return false;
    return t == 'groupleader' ||
        t == 'grouplead' ||
        t == 'coleader' ||
        t == 'member' ||
        t == '1' ||
        t == '2' ||
        t == '3';
  }

  bool get isGroupLeader => this == ViewerMembershipRole.groupLeader;

  bool get isCoLeader => this == ViewerMembershipRole.coLeader;

  bool get isMember => this == ViewerMembershipRole.member;

  /// Home “My projects” list — GroupLeader and CoLeader.
  bool get isOwnedListRelation => isGroupLeader || isCoLeader;
}
