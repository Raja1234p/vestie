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

  /// Detail UI uses [projectViewerRole] first, then [membershipRole].
  static ViewerMembershipRole forProjectDetail({
    required String projectViewerRole,
    required String membershipRole,
  }) {
    if (_hasExplicitRole(projectViewerRole)) {
      return parse(projectViewerRole);
    }
    if (_hasExplicitRole(membershipRole)) {
      return parse(membershipRole);
    }
    return ViewerMembershipRole.member;
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
