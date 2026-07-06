import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';

abstract final class BorrowRepayConfirmRouteArgsMapper {
  BorrowRepayConfirmRouteArgsMapper._();

  static BorrowRepayConfirmRouteArgs fromPreview({
    required BorrowRepayPreviewEntity preview,
    required String fallbackProjectName,
    required String paymentSourceType,
    String? paymentMethodId,
  }) {
    return BorrowRepayConfirmRouteArgs(
      projectId: preview.projectId,
      projectName: preview.projectName.isNotEmpty
          ? preview.projectName
          : fallbackProjectName,
      borrowRequestId: preview.borrowRequestId,
      repayAmount: preview.principalAmount > 0
          ? preview.principalAmount
          : preview.repayAmount,
      totalRepayment: preview.totalRepayment,
      dueDateLabel: preview.dueDateLabel,
      paymentMethodLabel: preview.paymentMethodDisplay,
      paymentSourceType: paymentSourceType,
      paymentMethodId: paymentMethodId,
      penaltyPercent: preview.penaltyPercent,
      penaltyAmount: preview.penaltyAmount,
    );
  }
}
