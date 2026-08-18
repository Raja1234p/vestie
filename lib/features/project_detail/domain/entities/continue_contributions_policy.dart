/// Group-leader **Continue contribution** gate for an open closure vote.
///
/// Members and co-leaders never pass. 50% of [totalJoinedMember] having
/// already voted (`votesCast * 2 >= totalJoinedMember`) hides and rejects.
bool groupLeaderCanContinueContributions({
  required bool isGroupLeader,
  required bool voteWindowOpen,
  required int totalJoinedMember,
  required int votesCast,
  bool? apiCanContinueContributions,
}) {
  if (!isGroupLeader || !voteWindowOpen) return false;
  if (apiCanContinueContributions == false) return false;
  if (totalJoinedMember <= 0) return false;
  return votesCast * 2 < totalJoinedMember;
}
