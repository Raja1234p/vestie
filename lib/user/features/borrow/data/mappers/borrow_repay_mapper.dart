import 'package:vestie/features/profile/domain/entities/payment_card.dart';

import '../../domain/entities/borrow_repay_entities.dart';
import '../models/borrow_repay_models.dart';

abstract final class BorrowRepayMapper {
  static BorrowRepaySummaryEntity toSummaryEntity(BorrowRepaySummaryModel model) {
    return BorrowRepaySummaryEntity(
      borrowRequestId: model.borrowRequestId,
      projectId: model.projectId,
      projectName: model.projectName,
      borrowAmount: model.borrowAmount,
      borrowDateLabel: formatBorrowRepayDateLabel(model.borrowDate),
      dueDateLabel: formatBorrowRepayDateLabel(model.dueDate),
      principalAmount: model.principalAmount,
      penaltyAmount: model.penaltyAmount,
      totalRepayment: model.totalRepayment,
      status: model.status,
      canRepay: model.canRepay,
    );
  }

  static BorrowRepayPaymentOptionsEntity toPaymentOptionsEntity(
    BorrowRepayPaymentOptionsModel model,
  ) {
    return BorrowRepayPaymentOptionsEntity(
      borrowRequestId: model.borrowRequestId,
      totalRepayment: model.totalRepayment,
      currency: model.currency,
      walletAvailableBalance: model.wallet.availableBalance,
      walletHasSufficientBalance: model.wallet.hasSufficientBalance,
      cards: model.cards
          .map(
            (c) => BorrowRepayCardOptionEntity(
              id: c.id,
              displayLabel: c.displayLabel,
              last4: c.last4,
              brand: _mapCardBrand(c.brand),
              isDefault: c.isDefault,
            ),
          )
          .toList(growable: false),
    );
  }

  static BorrowRepayPreviewEntity toPreviewEntity(BorrowRepayPreviewModel model) {
    final penalty = model.penalty;
    return BorrowRepayPreviewEntity(
      borrowRequestId: model.borrowRequestId,
      projectId: model.projectId,
      projectName: model.projectName,
      repayAmount: model.repayAmount,
      paymentSourceType: model.paymentSourceType,
      paymentMethodDisplay: model.paymentMethodDisplay,
      dueDateLabel: formatBorrowRepayDateLabel(model.dueDate),
      principalAmount: model.principalAmount,
      penaltyAmount: penalty?.amount ?? 0,
      penaltyPercent: penalty != null ? penalty.percentage.round() : 0,
      totalRepayment: model.totalRepayment,
    );
  }

  static CardBrand _mapCardBrand(String raw) {
    final b = raw.toLowerCase();
    if (b.contains('visa')) return CardBrand.visa;
    if (b.contains('master')) return CardBrand.mastercard;
    return CardBrand.other;
  }

  static BorrowRepaymentResultEntity toResultEntity(
    BorrowRepaymentResultModel model,
  ) {
    return BorrowRepaymentResultEntity(
      repaymentId: model.repaymentId,
      totalRepaid: model.totalRepaid,
      projectName: model.projectName,
      message: model.message,
    );
  }
}
