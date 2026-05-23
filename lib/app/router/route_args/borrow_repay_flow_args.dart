/// Confirm + success payloads for the borrow repay flow.
class BorrowRepayConfirmRouteArgs {
  final String projectId;
  final String projectName;
  final double repayAmount;
  final double totalRepayment;
  final String dueDateLabel;
  final String paymentMethodLabel;
  final int penaltyPercent;
  final double penaltyAmount;

  const BorrowRepayConfirmRouteArgs({
    required this.projectId,
    required this.projectName,
    required this.repayAmount,
    required this.totalRepayment,
    required this.dueDateLabel,
    required this.paymentMethodLabel,
    this.penaltyPercent = 0,
    this.penaltyAmount = 0,
  });

  bool get showsPenalty => penaltyPercent > 0 && penaltyAmount > 0;
}
