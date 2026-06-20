import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/viewer_membership_role.dart';
import 'member_detail_actions_visibility.dart';

/// When [ProjectMemberRow] shows “Send VFF Request” — delegates to
/// [MemberDetailActionsVisibility] (same rules for every project category).
abstract final class ProjectMemberAddFriendVisibility {
  static bool shouldShow({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return MemberDetailActionsVisibility.canShowSendVffOnMemberRow(
      project: project,
      member: member,
    );
  }

  /// VFF badge on member rows — connected others only, never the signed-in viewer.
  static bool showsVffBadge({
    required ProjectDetailEntity? project,
    required MemberEntity member,
  }) {
    if (!member.showsVffBadgeOnMemberRow) return false;
    if (project != null && isViewerSelf(project: project, member: member)) {
      return false;
    }
    return true;
  }

  static bool isViewerSelf({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    final viewerUserId = _viewerUserId(project);
    final memberUserId = member.apiUserId.trim();
    if (viewerUserId != null &&
        memberUserId.isNotEmpty &&
        memberUserId == viewerUserId) {
      return true;
    }

    final viewerMembershipId = project.membershipId.trim();
    final memberMembershipId = member.membershipId.trim();
    if (viewerMembershipId.isEmpty || memberMembershipId.isEmpty) {
      return false;
    }
    if (memberMembershipId != viewerMembershipId) return false;

    // Same membership id — require matching user id when both are known.
    if (viewerUserId != null && memberUserId.isNotEmpty) {
      return memberUserId == viewerUserId;
    }
    return true;
  }

  /// Resolves the signed-in viewer's user id (co-leader roster rows may use a
  /// different membership id than [ProjectDetailEntity.membershipId]).
  static String? _viewerUserId(ProjectDetailEntity project) {
    final membershipId = project.membershipId.trim();
    if (membershipId.isNotEmpty) {
      for (final m in project.members) {
        if (m.membershipId.trim() != membershipId) continue;
        final uid = m.apiUserId.trim();
        if (uid.isNotEmpty) return uid;
      }
    }

    final viewerRosterRole = switch (project.viewerRole) {
      ViewerMembershipRole.groupLeader => MemberRole.leader,
      ViewerMembershipRole.coLeader => MemberRole.coLeader,
      ViewerMembershipRole.member => null,
    };
    if (viewerRosterRole == null) return null;

    MemberEntity? match;
    for (final m in project.members) {
      if (m.role != viewerRosterRole) continue;
      if (match != null) return null;
      match = m;
    }
    final uid = match?.apiUserId.trim() ?? '';
    return uid.isEmpty ? null : uid;
  }
}
