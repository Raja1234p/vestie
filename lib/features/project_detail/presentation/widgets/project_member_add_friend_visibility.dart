import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';
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
    if (project != null &&
        isViewerSelf(project: project, member: member)) {
      return false;
    }
    return true;
  }

  static bool isViewerSelf({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    final viewerMembershipId = project.membershipId.trim();
    final memberMembershipId = member.membershipId.trim();
    if (viewerMembershipId.isNotEmpty && memberMembershipId.isNotEmpty) {
      return memberMembershipId == viewerMembershipId;
    }

    final viewerUserId = _viewerUserId(project, member);
    if (viewerUserId == null) return false;
    final memberUserId = member.apiUserId;
    if (memberUserId.isNotEmpty && memberUserId == viewerUserId) return true;
    return false;
  }

  static String? _viewerUserId(
    ProjectDetailEntity project,
    MemberEntity member,
  ) {
    for (final m in project.members) {
      if (m.membershipId.trim() == project.membershipId.trim()) {
        final uid = m.userId.trim();
        if (uid.isNotEmpty) return uid;
        return m.id.trim().isEmpty ? null : m.id.trim();
      }
    }
    return null;
  }
}
