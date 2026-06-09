class BorrowVoteResultModel {
  final String borrowRequestId;
  final String callerVote;
  final int upvoteCount;
  final int downvoteCount;

  const BorrowVoteResultModel({
    required this.borrowRequestId,
    required this.callerVote,
    required this.upvoteCount,
    required this.downvoteCount,
  });

  factory BorrowVoteResultModel.fromJson(Map<String, dynamic> json) {
    return BorrowVoteResultModel(
      borrowRequestId: (json['borrowRequestId'] as String?) ?? '',
      callerVote: (json['callerVote'] as String?) ?? '',
      upvoteCount: (json['upvoteCount'] as num?)?.toInt() ?? 0,
      downvoteCount: (json['downvoteCount'] as num?)?.toInt() ?? 0,
    );
  }
}
