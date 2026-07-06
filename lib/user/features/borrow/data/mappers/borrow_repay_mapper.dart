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
    final penaltyAmount = penalty?.amount ?? 0;
    return BorrowRepayPreviewEntity(
      borrowRequestId: model.borrowRequestId,
      projectId: model.projectId,
      projectName: model.projectName,
      repayAmount: model.repayAmount,
      paymentSourceType: model.paymentSourceType,
      paymentMethodDisplay: model.paymentMethodDisplay,
      dueDateLabel: formatBorrowRepayDateLabel(model.dueDate),
      principalAmount: model.principalAmount,
      penaltyAmount: penaltyAmount,
      penaltyPercent: _previewPenaltyPercent(
        penaltyAmount: penaltyAmount,
        penaltyPercentage: penalty?.percentage ?? 0,
        principalAmount: model.principalAmount,
      ),
      totalRepayment: model.totalRepayment,
    );
  }

  static int _previewPenaltyPercent({
    required double penaltyAmount,
    required double penaltyPercentage,
    required double principalAmount,
  }) {
    if (penaltyAmount <= 0) return 0;
    if (penaltyPercentage > 0) return penaltyPercentage.round();
    if (principalAmount <= 0) return 0;
    return ((penaltyAmount / principalAmount) * 100).round();
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
