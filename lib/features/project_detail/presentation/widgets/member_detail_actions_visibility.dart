import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_member_add_friend_visibility.dart';

/// Leader / VFF actions on [MemberDetailScreen] — aligned with member-row Add Friend rules.
abstract final class MemberDetailActionsVisibility {
  static bool showSendVffRequest({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return ProjectMemberAddFriendVisibility.shouldShow(
      project: project,
      member: member,
    );
  }

  /// Group leader only — promote / demote co-leader (not on self or group leader row).
  static bool showCoLeaderControls({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (!project.supportsCoLeader) return false;
    if (!project.isGroupLeader) return false;
    if (ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: member,
    )) {
      return false;
    }
    return member.role == MemberRole.member ||
        member.role == MemberRole.coLeader;
  }

  /// Group leader only — remove member (not self, not group leader row).
  static bool showRemoveMember({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (!project.isGroupLeader) return false;
    if (ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: member,
    )) {
      return false;
    }
    return member.role != MemberRole.leader;
  }

  static bool showFooter({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return showSendVffRequest(project: project, member: member) ||
        showRemoveMember(project: project, member: member);
  }

  /// Group leader only — mark defaulted (same rules as remove member).
  static bool showMarkAsDefaulted({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return showRemoveMember(project: project, member: member);
  }

  /// Penalty Action footer — remove + mark defaulted.
  static bool showPenaltyFooter({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return showRemoveMember(project: project, member: member) ||
        showMarkAsDefaulted(project: project, member: member);
  }

  /// Overdue banner "Take Action" (group leader, not self, not project leader).
  static bool showOverdueTakeAction({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return showRemoveMember(project: project, member: member);
  }
}
