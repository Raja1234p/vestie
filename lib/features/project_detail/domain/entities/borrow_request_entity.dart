/// Represents a single borrow request inside a project.
class BorrowRequestEntity {
  final String id;
  final String initials;
  final String memberName;
  final String loanType;
  final double requestedAmount;
  final int upvotes;
  final int downvotes;

  const BorrowRequestEntity({
    required this.id,
    required this.initials,
    required this.memberName,
    required this.loanType,
    required this.requestedAmount,
    required this.upvotes,
    required this.downvotes,
  });
}
