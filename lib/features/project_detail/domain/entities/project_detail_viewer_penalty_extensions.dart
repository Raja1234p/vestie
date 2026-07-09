import 'member_entity.dart';
import 'project_detail_entity.dart';

/// Why the viewer cannot cast a closure vote (inline / full-screen cast UI).
enum ClosureVoteCastBlockReason {
  groupLeader,
  defaulted,
  overdue,
}

extension ProjectDetailEntityViewerPenalty on ProjectDetailEntity {
  /// Viewer row from `members[]` / `viewerMembership` (by membership id).
  MemberEntity? get viewerMemberRow {
    final viewerMembershipId = membershipId.trim();
    if (viewerMembershipId.isEmpty) return null;
    for (final member in members) {
      if (member.membershipId.trim() == viewerMembershipId) {
        return member;
      }
    }
    return null;
  }

  bool get viewerIsDefaulted =>
      viewerMemberRow?.isDefaulted ?? viewerApiIsDefaulted;

  /// `overdueAmount` or `badge: Overdue` on the viewer's membership row.
  bool get viewerHasOverduePenalty {
    final row = viewerMemberRow;
    if (row != null && row.showsOverdueBadge) return true;
    final apiOverdue = viewerApiOverdueAmount;
    return apiOverdue != null && apiOverdue > 0;
  }

  /// Defaulted or overdue — cannot cast closure votes.
  bool get viewerIsClosureVoteIneligible =>
      viewerIsDefaulted || viewerHasOverduePenalty;

  bool get viewerCanCastClosureVote =>
      (isDetailMember || isDetailCoLeader) &&
      !viewerIsClosureVoteIneligible;

  ClosureVoteCastBlockReason? get closureVoteCastBlockReason {
    if (isGroupLeader) return ClosureVoteCastBlockReason.groupLeader;
    if (viewerIsDefaulted) return ClosureVoteCastBlockReason.defaulted;
    if (viewerHasOverduePenalty) return ClosureVoteCastBlockReason.overdue;
    return null;
  }
}
