import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_choice.dart';

extension ProjectDetailEntityMemberVoteFlow on ProjectDetailEntity {
  /// Full-screen cast UI while the member / co-leader still needs to vote.
  bool get showsInlineMemberVoteCastView => showsInlineMemberCastVote;

  /// Figma post-vote UI — agreed / disagreed banner, tallies, summary, Back to Home.
  bool get showsInlineMemberVoteSubmittedView {
    if (!(isDetailMember || isDetailCoLeader)) return false;
    if (!votingIsInProgress) return false;
    if (!memberHasSubmittedClosureVote) return false;
    if (!hasOpenMemberClosureVotePayload) return false;
    return memberSubmittedVoteChoice != SuccessVoteCastChoice.pending;
  }

  /// Replaces normal project-detail scroll while a member vote window is active.
  bool get showsInlineMemberVoteFlow =>
      showsInlineMemberVoteCastView || showsInlineMemberVoteSubmittedView;

  /// Which post-vote banner to show after the member has cast a vote.
  SuccessVoteCastChoice get memberSubmittedVoteChoice {
    final closureVote = activeClosureVote?.callerVote;
    if (closureVote == ClosureVoteValue.yes) {
      return SuccessVoteCastChoice.agreed;
    }
    if (closureVote == ClosureVoteValue.no) {
      return SuccessVoteCastChoice.disagreed;
    }

    return switch (_viewerMemberVoteStatus()) {
      ProjectMemberVoteStatus.agreed => SuccessVoteCastChoice.agreed,
      ProjectMemberVoteStatus.disagreed => SuccessVoteCastChoice.disagreed,
      ProjectMemberVoteStatus.waiting => SuccessVoteCastChoice.pending,
      null => SuccessVoteCastChoice.pending,
    };
  }

  ProjectMemberVoteStatus? _viewerMemberVoteStatus() {
    final votes = voting?.memberVotes;
    if (votes == null || votes.isEmpty) return null;

    final viewerMembershipId = membershipId.trim();
    if (viewerMembershipId.isNotEmpty) {
      for (final vote in votes) {
        if (vote.membershipId == viewerMembershipId) return vote.status;
      }
    }

    final viewerUserId = _viewerUserId();
    if (viewerUserId != null && viewerUserId.isNotEmpty) {
      for (final vote in votes) {
        if (vote.userId == viewerUserId) return vote.status;
      }
    }

    return null;
  }

  String? _viewerUserId() {
    final viewerMembershipId = membershipId.trim();
    if (viewerMembershipId.isEmpty) return null;
    for (final member in members) {
      if (member.membershipId == viewerMembershipId) {
        return member.userId.trim().isNotEmpty ? member.userId : null;
      }
    }
    return null;
  }
}

/// Maps Week 11 `voting` to synthetic closure caller vote for the viewer.
ClosureVoteValue? closureCallerVoteFromVotingSummary({
  required ProjectDetailEntity project,
  required ProjectVotingSummaryEntity summary,
}) {
  if (!(project.isDetailMember || project.isDetailCoLeader) ||
      !summary.hasVoted) {
    return null;
  }

  final membershipId = project.membershipId.trim();
  final viewerUserId = _viewerUserIdFromProject(project);
  for (final vote in summary.memberVotes) {
    if (membershipId.isNotEmpty && vote.membershipId == membershipId) {
      return _closureVoteFromMemberStatus(vote.status);
    }
    if (viewerUserId != null &&
        viewerUserId.isNotEmpty &&
        vote.userId == viewerUserId) {
      return _closureVoteFromMemberStatus(vote.status);
    }
  }

  return null;
}

ClosureVoteValue? _closureVoteFromMemberStatus(ProjectMemberVoteStatus status) {
  return switch (status) {
    ProjectMemberVoteStatus.agreed => ClosureVoteValue.yes,
    ProjectMemberVoteStatus.disagreed => ClosureVoteValue.no,
    ProjectMemberVoteStatus.waiting => null,
  };
}

String? _viewerUserIdFromProject(ProjectDetailEntity project) {
  final membershipId = project.membershipId.trim();
  if (membershipId.isEmpty) return null;
  for (final member in project.members) {
    if (member.membershipId == membershipId) {
      final userId = member.userId.trim();
      return userId.isNotEmpty ? userId : null;
    }
  }
  return null;
}
