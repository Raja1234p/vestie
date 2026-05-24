import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_member_add_friend_visibility.dart';

/// Leader / VFF actions on [MemberDetailScreen] — aligned with member-row Add Friend rules.
abstract final class MemberDetailActionsVisibility {
  /// Same audience as Add Friend (role / self), but does not hide pending-outgoing
  /// — member detail still shows Send VFF or Request Sent in the footer.
  static bool isVffActionTarget({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: member,
    )) {
      return false;
    }

    if (project.isModeratorView) {
      return member.role == MemberRole.member ||
          member.role == MemberRole.coLeader;
    }

    if (project.isMemberView) {
      return member.role == MemberRole.leader;
    }

    return false;
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

  /// Resolved VFF state for footer actions (activity API + project member list).
  static VffConnectionState effectiveVffConnectionState({
    required MemberEntity member,
    VffConnectionState activityVffConnectionState = VffConnectionState.none,
  }) {
    if (activityVffConnectionState == VffConnectionState.connected ||
        member.isVffConnected) {
      return VffConnectionState.connected;
    }
    if (activityVffConnectionState != VffConnectionState.none) {
      return activityVffConnectionState;
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
    return _isVffConnected(
      member: member,
      vffConnectionState: vffConnectionState,
    );
  }

  /// Send VFF or “Request Sent” chip — driven by activity API.
  static bool showVffSendOrSent({
    required ProjectDetailEntity project,
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
    bool canSendVffRequest = false,
  }) {
    if (!isVffActionTarget(project: project, member: member)) return false;
    if (_isVffConnected(
      member: member,
      vffConnectionState: vffConnectionState,
    )) {
      return false;
    }
    if (vffConnectionState == VffConnectionState.pendingIncoming) return false;
    return canSendVffRequest ||
        vffConnectionState == VffConnectionState.pendingOutgoing;
  }

  static bool showFooter({
    required ProjectDetailEntity project,
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
    bool canSendVffRequest = false,
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
          canSendVffRequest: canSendVffRequest,
        ) ||
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
