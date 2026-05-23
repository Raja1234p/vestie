/// Approved borrow — amount + repayment breakdown (Figma “My Borrow”).
class MyBorrowApprovedUiData {
  final double borrowAmount;
  final String borrowDateLabel;
  final String dueDateLabel;
  /// Shown on My Borrow breakdown card.
  final double totalRepayment;
  /// Shown on repay confirm (may include fees).
  final double totalRepaymentDue;
  final int penaltyPercent;
  final double penaltyAmount;

  const MyBorrowApprovedUiData({
    required this.borrowAmount,
    required this.borrowDateLabel,
    required this.dueDateLabel,
    required this.totalRepayment,
    required this.totalRepaymentDue,
    this.penaltyPercent = 0,
    this.penaltyAmount = 0,
  });
}
