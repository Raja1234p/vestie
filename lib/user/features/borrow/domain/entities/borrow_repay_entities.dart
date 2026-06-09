import 'package:vestie/features/profile/domain/entities/payment_card.dart';

class BorrowRepaySummaryEntity {
  final String borrowRequestId;
  final String projectId;
  final String projectName;
  final double borrowAmount;
  final String borrowDateLabel;
  final String dueDateLabel;
  final double principalAmount;
  final double penaltyAmount;
  final double totalRepayment;
  final String status;
  final bool canRepay;

  const BorrowRepaySummaryEntity({
    required this.borrowRequestId,
    required this.projectId,
    required this.projectName,
    required this.borrowAmount,
    required this.borrowDateLabel,
    required this.dueDateLabel,
    required this.principalAmount,
    required this.penaltyAmount,
    required this.totalRepayment,
    required this.status,
    required this.canRepay,
  });

  int get penaltyPercent {
    if (principalAmount <= 0 || penaltyAmount <= 0) return 0;
    return ((penaltyAmount / principalAmount) * 100).round();
  }
}

class BorrowRepayCardOptionEntity {
  final String id;
  final String displayLabel;
  final String last4;
  final CardBrand brand;
  final bool isDefault;

  const BorrowRepayCardOptionEntity({
    required this.id,
    required this.displayLabel,
    required this.last4,
    required this.brand,
    this.isDefault = false,
  });
}

class BorrowRepayPaymentOptionsEntity {
  final String borrowRequestId;
  final double totalRepayment;
  final String currency;
  final double walletAvailableBalance;
  final bool walletHasSufficientBalance;
  final List<BorrowRepayCardOptionEntity> cards;

  const BorrowRepayPaymentOptionsEntity({
    required this.borrowRequestId,
    required this.totalRepayment,
    required this.currency,
    required this.walletAvailableBalance,
    required this.walletHasSufficientBalance,
    required this.cards,
  });

  bool get preferWallet => walletHasSufficientBalance;

  String? get preferredCardId {
    if (cards.isEmpty) return null;
    if (cards.length == 1) return cards.first.id;
    for (final card in cards) {
      if (card.isDefault) return card.id;
    }
    return null;
  }
}

class BorrowRepayPreviewEntity {
  final String borrowRequestId;
  final String projectId;
  final String projectName;
  final double repayAmount;
  final String paymentSourceType;
  final String paymentMethodDisplay;
  final String dueDateLabel;
  final double principalAmount;
  final double penaltyAmount;
  final int penaltyPercent;
  final double totalRepayment;

  const BorrowRepayPreviewEntity({
    required this.borrowRequestId,
    required this.projectId,
    required this.projectName,
    required this.repayAmount,
    required this.paymentSourceType,
    required this.paymentMethodDisplay,
    required this.dueDateLabel,
    required this.principalAmount,
    required this.penaltyAmount,
    required this.penaltyPercent,
    required this.totalRepayment,
  });
}

class BorrowRepaymentResultEntity {
  final String repaymentId;
  final double totalRepaid;
  final String projectName;
  final String message;

  const BorrowRepaymentResultEntity({
    required this.repaymentId,
    required this.totalRepaid,
    required this.projectName,
    required this.message,
  });
}
