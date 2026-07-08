/// Distinguishes vote-outcome copy when the same screen layout applies to
/// different leader/member vote flows.
enum SuccessVoteOutcomeVariant {
  /// Mark project successful / majority success-vote outcome.
  successVote,

  /// Investment — stop-contributions vote did not pass (leader).
  stopContributionsRejected,

  /// Deadline passed with zero member votes (vacation / emergency / investment stop-contrib).
  noVotesRejected,
}
