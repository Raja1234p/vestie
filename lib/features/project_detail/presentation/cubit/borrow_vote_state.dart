/// Vote state for a single borrow request card.
class BorrowVoteState {
  final bool hasUpvoted;
  final bool hasDownvoted;
  final int upvotes;
  final int downvotes;
  final bool isVoting;

  const BorrowVoteState({
    required this.upvotes,
    required this.downvotes,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
    this.isVoting = false,
  });

  BorrowVoteState copyWith({
    bool? hasUpvoted,
    bool? hasDownvoted,
    int? upvotes,
    int? downvotes,
    bool? isVoting,
  }) => BorrowVoteState(
    hasUpvoted: hasUpvoted ?? this.hasUpvoted,
    hasDownvoted: hasDownvoted ?? this.hasDownvoted,
    upvotes: upvotes ?? this.upvotes,
    downvotes: downvotes ?? this.downvotes,
    isVoting: isVoting ?? this.isVoting,
  );
}
