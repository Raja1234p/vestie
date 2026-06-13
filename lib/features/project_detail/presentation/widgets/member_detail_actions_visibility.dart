import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_member_add_friend_visibility.dart';

/// VFF send / following / footer rules — same for every project category.
/// Only restriction: never on the signed-in user’s own member row/card.
abstract final class MemberDetailActionsVisibility {
  /// Any project member except the current viewer (group leader, co-leader, or member).
  static bool isVffActionTarget({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return !ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: member,
    );
  }

  /// Member list “Send VFF Request” — same audience and connection rules everywhere.
  static bool canShowSendVffOnMemberRow({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (!isVffActionTarget(project: project, member: member)) return false;
    if (member.isViewerVffLinked) return false;
    if (member.hasPendingVffOutgoing) return false;
    if (member.vffConnectionState == VffConnectionState.pendingIncoming) {
      return false;
    }
    return true;
  }

  static bool showSendVffRequest({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return isVffActionTarget(project: project, member: member);
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

  /// Group leader or co-leader — remove member on any project type (not self, not project leader).
  static bool showRemoveMember({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (!project.canRemoveMembers) return false;
    if (ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: member,
    )) {
      return false;
    }
    return !_isProjectGroupLeader(project: project, member: member);
  }

  /// Leader row from `project.members` (stable); falls back to [MemberEntity.role] when list empty.
  static bool _isProjectGroupLeader({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    for (final m in project.members) {
      if (m.role == MemberRole.leader && member.matchesIdentity(m)) {
        return true;
      }
    }
    if (project.members.isEmpty && member.role == MemberRole.leader) {
      return true;
    }
    return false;
  }

  /// Resolved VFF state for footer actions (activity API + project member list).
  static VffConnectionState effectiveVffConnectionState({
    required MemberEntity member,
    VffConnectionState activityVffConnectionState = VffConnectionState.none,
  }) {
    if (activityVffConnectionState == VffConnectionState.connected &&
        member.vffAdded) {
      return VffConnectionState.connected;
    }
    if (activityVffConnectionState == VffConnectionState.pendingOutgoing ||
        member.hasPendingVffOutgoing) {
      return VffConnectionState.pendingOutgoing;
    }
    if (activityVffConnectionState != VffConnectionState.none) {
      return activityVffConnectionState;
    }
    if (member.isViewerVffLinked) return VffConnectionState.connected;
    if (member.vffConnectionState == VffConnectionState.connected) {
      return VffConnectionState.none;
    }
    return member.vffConnectionState;
  }

  static bool _isVffConnected({
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
  }) {
    return effectiveVffConnectionState(
          member: member,
          activityVffConnectionState: vffConnectionState,
        ) ==
        VffConnectionState.connected;
  }

  /// VFF connection accepted — Following menu (not Send / Sent).
  static bool showVffFollowing({
    required ProjectDetailEntity project,
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
  }) {
    if (!isVffActionTarget(project: project, member: member)) return false;
    return member.isViewerVffLinked ||
        (vffConnectionState == VffConnectionState.connected && member.vffAdded);
  }

  /// Member detail footer: Send VFF or “Request Sent” (uses activity VFF state).
  static bool showVffSendOrSent({
    required ProjectDetailEntity project,
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
  }) {
    if (!isVffActionTarget(project: project, member: member)) return false;
    if (_isVffConnected(
      member: member,
      vffConnectionState: vffConnectionState,
    )) {
      return false;
    }
    if (vffConnectionState == VffConnectionState.pendingIncoming) return false;
    if (vffConnectionState == VffConnectionState.pendingOutgoing) return true;
    if (member.hasPendingVffOutgoing) return true;
    return canShowSendVffOnMemberRow(project: project, member: member);
  }

  static bool showFooter({
    required ProjectDetailEntity project,
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
  }) {
    return showVffFollowing(
          project: project,
          member: member,
          vffConnectionState: vffConnectionState,
        ) ||
        showVffSendOrSent(
          project: project,
          member: member,
          vffConnectionState: vffConnectionState,
        ) ||
        showRemoveMember(project: project, member: member);
  }

  /// Group leader or co-leader — mark defaulted (same rules as remove member).
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

  /// Overdue banner "Take Action" (moderator, not self, not project leader).
  static bool showOverdueTakeAction({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return showRemoveMember(project: project, member: member);
  }
}
