import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';

/// Viewer role for success-vote outcome copy and primary actions.
enum SuccessVoteOutcomeRole {
  groupLeader,
  coLeader,
  member;

  static SuccessVoteOutcomeRole fromViewerRole(ViewerMembershipRole role) {
    return switch (role) {
      ViewerMembershipRole.groupLeader => SuccessVoteOutcomeRole.groupLeader,
      ViewerMembershipRole.coLeader => SuccessVoteOutcomeRole.coLeader,
      ViewerMembershipRole.member => SuccessVoteOutcomeRole.member,
    };
  }

  bool get isModerator =>
      this == SuccessVoteOutcomeRole.groupLeader ||
      this == SuccessVoteOutcomeRole.coLeader;
}
