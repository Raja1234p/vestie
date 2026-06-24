import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_member_add_friend_visibility.dart';

/// Member profile footer / penalty / co-leader action visibility.
///
/// Rules:
/// - VFF: any member except self.
/// - Remove member on profile: never (leader uses penalty / manage flows).
/// - Remove / mark defaulted / overdue take action elsewhere: **group leader only**,
///   not self, not the project group leader.
/// - Co-leader promote/demote: group leader only, vacation/emergency, not self,
///   not the project group leader.
abstract final class MemberDetailActionsVisibility {
  static MemberEntity _memberForRules({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return member.withProjectRoster(project);
  }

  /// Any project member except the signed-in viewer.
  static bool isVffActionTarget({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return !ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: member,
    );
  }

  /// Member list “Send VFF Request”.
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

  /// Group leader only — promote when no co-leader exists; demote on co-leader row.
  static bool showCoLeaderControls({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (!project.supportsCoLeader || !project.isGroupLeader) return false;
    final target = _memberForRules(project: project, member: member);
    if (ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: target,
    )) {
      return false;
    }
    if (target.isProjectGroupLeaderOn(project)) return false;

    if (target.role == MemberRole.coLeader) return true;

    if (target.role == MemberRole.member) {
      return !_projectHasCoLeader(project);
    }

    return false;
  }

  static bool _projectHasCoLeader(ProjectDetailEntity project) {
    if (project.hasCoLeader) return true;
    return project.members.any((m) => m.role == MemberRole.coLeader);
  }

  /// Group leader only — remove member in penalty / overdue flows (not on profile).
  static bool showRemoveMember({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return _canModerateMemberTarget(project: project, member: member);
  }

  /// Member profile footer — remove is not offered here (penalty / manage flows only).
  static bool showRemoveMemberOnMemberProfile({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return false;
  }

  static bool _canModerateMemberTarget({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    if (!project.isGroupLeader) return false;
    final target = _memberForRules(project: project, member: member);
    if (ProjectMemberAddFriendVisibility.isViewerSelf(
      project: project,
      member: target,
    )) {
      return false;
    }
    return !target.isProjectGroupLeaderOn(project);
  }

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
      if (activityVffConnectionState == VffConnectionState.connected &&
          !member.vffAdded &&
          !member.isViewerVffLinked) {
        return VffConnectionState.none;
      }
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
    return member.isViewerVffLinked;
  }

  static bool showVffFollowing({
    required ProjectDetailEntity project,
    required MemberEntity member,
    VffConnectionState vffConnectionState = VffConnectionState.none,
  }) {
    if (!isVffActionTarget(project: project, member: member)) return false;
    return member.isViewerVffLinked ||
        (vffConnectionState == VffConnectionState.connected && member.vffAdded);
  }

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
        );
  }

  static bool showMarkAsDefaulted({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return _canModerateMemberTarget(project: project, member: member);
  }

  static bool showPenaltyFooter({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return _canModerateMemberTarget(project: project, member: member);
  }

  static bool showOverdueTakeAction({
    required ProjectDetailEntity project,
    required MemberEntity member,
  }) {
    return _canModerateMemberTarget(project: project, member: member);
  }
}
