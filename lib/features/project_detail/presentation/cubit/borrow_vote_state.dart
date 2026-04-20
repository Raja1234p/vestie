/// Vote state for a single borrow request card.
class BorrowVoteState {
  final bool hasUpvoted;
  final bool hasDownvoted;
  final int upvotes;
  final int downvotes;

  const BorrowVoteState({
    required this.upvotes,
    required this.downvotes,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
  });

  BorrowVoteState copyWith({
    bool? hasUpvoted,
    bool? hasDownvoted,
    int? upvotes,
    int? downvotes,
  }) =>
      BorrowVoteState(
        hasUpvoted: hasUpvoted ?? this.hasUpvoted,
        hasDownvoted: hasDownvoted ?? this.hasDownvoted,
        upvotes: upvotes ?? this.upvotes,
        downvotes: downvotes ?? this.downvotes,
      );
}
