/// Optional hint on [Project] (mock) — which member-facing flow opens when
/// the user taps **View** on a joined project. [null] = normal project detail.
enum UserFlowOnOpen {
  /// Leader approved the user’s join request.
  showJoinApproved,

  /// Leader rejected the join request.
  showJoinRejected,

  /// Success vote in progress; member can cast Yes/No.
  showSuccessVote,

  /// Shorthand demo: go straight to “Approved” (user voted success) screen.
  showMarkVoteApprovedResult,

  /// Shorthand demo: go straight to “Not Approved” screen.
  showMarkVoteNotApprovedResult,
}
