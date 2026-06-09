import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';

abstract final class BorrowRepayUiMapper {
  static MyBorrowApprovedUiData toApprovedUiData(BorrowRepaySummaryEntity summary) {
    return MyBorrowApprovedUiData(
      borrowAmount: summary.borrowAmount,
      borrowDateLabel: summary.borrowDateLabel,
      dueDateLabel: summary.dueDateLabel,
      totalRepayment: summary.principalAmount,
      totalRepaymentDue: summary.totalRepayment,
      penaltyPercent: summary.penaltyPercent,
      penaltyAmount: summary.penaltyAmount,
    );
  }
}
