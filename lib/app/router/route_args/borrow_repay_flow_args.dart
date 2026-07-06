import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';

/// Confirm + success payloads for the borrow repay flow.
class BorrowRepayConfirmRouteArgs {
  final String projectId;
  final String projectName;
  final String borrowRequestId;
  final double repayAmount;
  final double totalRepayment;
  final String dueDateLabel;
  final String paymentMethodLabel;
  final String paymentSourceType;
  final String? paymentMethodId;
  final int penaltyPercent;
  final double penaltyAmount;
  final String? successMessage;

  const BorrowRepayConfirmRouteArgs({
    required this.projectId,
    required this.projectName,
    required this.borrowRequestId,
    required this.repayAmount,
    required this.totalRepayment,
    required this.dueDateLabel,
    required this.paymentMethodLabel,
    required this.paymentSourceType,
    this.paymentMethodId,
    this.penaltyPercent = 0,
    this.penaltyAmount = 0,
    this.successMessage,
  });

  bool get showsPenalty => penaltyAmount > 0;
}

/// Payment method picker for borrow repay (Week 8 API).
class BorrowRepayPaymentOptionsRouteArgs {
  final String projectId;
  final String projectName;
  final String borrowRequestId;
  final BorrowRepayPaymentOptionsEntity? preloadedOptions;

  const BorrowRepayPaymentOptionsRouteArgs({
    required this.projectId,
    required this.projectName,
    required this.borrowRequestId,
    this.preloadedOptions,
  });

  BorrowRepayPaymentOptionsRouteArgs copyWith({
    BorrowRepayPaymentOptionsEntity? preloadedOptions,
  }) {
    return BorrowRepayPaymentOptionsRouteArgs(
      projectId: projectId,
      projectName: projectName,
      borrowRequestId: borrowRequestId,
      preloadedOptions: preloadedOptions ?? this.preloadedOptions,
    );
  }
}
