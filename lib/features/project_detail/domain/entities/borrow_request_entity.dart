/// Represents a single borrow request inside a project.
class BorrowRequestEntity {
  final String id;
  final String memberId;
  final String initials;
  final String memberName;
  final String? memberPhotoUrl;
  final String loanType;
  final double requestedAmount;
  final int upvotes;
  final int downvotes;

  /// API `callerVote`: `Agree`, `Disagree`, or null.
  final String? callerVote;

  /// API `status`: `Pending`, `Disbursed`, `Rejected`, `Repaid`, etc.
  final String status;

  /// Whether the viewer may `POST …/decide` on this request.
  final bool callerCanDecide;

  final String? requesterRole;
  final String? requiredDecisionBy;

  const BorrowRequestEntity({
    required this.id,
    this.memberId = '',
    required this.initials,
    required this.memberName,
    this.memberPhotoUrl,
    required this.loanType,
    required this.requestedAmount,
    required this.upvotes,
    required this.downvotes,
    this.callerVote,
    this.status = 'Pending',
    this.callerCanDecide = false,
    this.requesterRole,
    this.requiredDecisionBy,
  });

  bool get hasAgreed => callerVote == 'Agree';

  bool get hasDisagreed => callerVote == 'Disagree';

  /// Awaiting member votes / leader decision (`Pending`, `RequestSent`, …).
  bool get isPending => status == 'Pending' || status == 'RequestSent';

  /// Active borrow the member must repay (`GET …/repay`).
  bool get isRepayableBorrow =>
      status == 'Disbursed' || status == 'Overdue' || status == 'Approved';
}
