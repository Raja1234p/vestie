import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';

/// When [ProjectMemberRow] shows the Add Friend CTA.
abstract final class ProjectMemberAddFriendVisibility {
  static bool shouldShow({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (isViewerSelf(project: project, member: member)) return false;

    if (project.isModeratorView) {
      return member.role == MemberRole.member ||
          member.role == MemberRole.coLeader;
    }

    if (project.isMemberView) {
      return member.role == MemberRole.leader;
    }

    return false;
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
