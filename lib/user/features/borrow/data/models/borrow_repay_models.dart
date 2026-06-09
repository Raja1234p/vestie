import 'package:intl/intl.dart';

class BorrowRepaySummaryModel {
  final String borrowRequestId;
  final String projectId;
  final String projectName;
  final double borrowAmount;
  final String? borrowDate;
  final String? dueDate;
  final double principalAmount;
  final double penaltyAmount;
  final double totalRepayment;
  final String status;
  final bool canRepay;

  const BorrowRepaySummaryModel({
    required this.borrowRequestId,
    required this.projectId,
    required this.projectName,
    required this.borrowAmount,
    this.borrowDate,
    this.dueDate,
    required this.principalAmount,
    required this.penaltyAmount,
    required this.totalRepayment,
    required this.status,
    required this.canRepay,
  });

  factory BorrowRepaySummaryModel.fromJson(Map<String, dynamic> json) {
    return BorrowRepaySummaryModel(
      borrowRequestId: (json['borrowRequestId'] as String?) ?? '',
      projectId: (json['projectId'] as String?) ?? '',
      projectName: (json['projectName'] as String?) ?? '',
      borrowAmount: (json['borrowAmount'] as num?)?.toDouble() ?? 0,
      borrowDate: json['borrowDate'] as String?,
      dueDate: json['dueDate'] as String?,
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0,
      penaltyAmount: (json['penaltyAmount'] as num?)?.toDouble() ?? 0,
      totalRepayment: (json['totalRepayment'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as String?) ?? '',
      canRepay: json['canRepay'] == true,
    );
  }
}

class BorrowRepayPaymentOptionsModel {
  final String borrowRequestId;
  final double totalRepayment;
  final String currency;
  final BorrowRepayWalletOptionModel wallet;
  final List<BorrowRepayCardOptionModel> cards;

  const BorrowRepayPaymentOptionsModel({
    required this.borrowRequestId,
    required this.totalRepayment,
    required this.currency,
    required this.wallet,
    required this.cards,
  });

  factory BorrowRepayPaymentOptionsModel.fromJson(Map<String, dynamic> json) {
    final walletJson =
        (json['wallet'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final cardsJson =
        (json['cards'] as List?)
            ?.whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList() ??
        const <Map<String, dynamic>>[];

    return BorrowRepayPaymentOptionsModel(
      borrowRequestId: (json['borrowRequestId'] as String?) ?? '',
      totalRepayment: (json['totalRepayment'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      wallet: BorrowRepayWalletOptionModel.fromJson(walletJson),
      cards: cardsJson
          .map(BorrowRepayCardOptionModel.fromJson)
          .toList(growable: false),
    );
  }
}

class BorrowRepayWalletOptionModel {
  final double availableBalance;
  final bool hasSufficientBalance;
  final String balanceTone;

  const BorrowRepayWalletOptionModel({
    required this.availableBalance,
    required this.hasSufficientBalance,
    required this.balanceTone,
  });

  factory BorrowRepayWalletOptionModel.fromJson(Map<String, dynamic> json) {
    return BorrowRepayWalletOptionModel(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      hasSufficientBalance: json['hasSufficientBalance'] == true,
      balanceTone: (json['balanceTone'] as String?) ?? '',
    );
  }
}

class BorrowRepayCardOptionModel {
  final String id;
  final String brand;
  final String last4;
  final String displayLabel;
  final bool isDefault;

  const BorrowRepayCardOptionModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.displayLabel,
    required this.isDefault,
  });

  factory BorrowRepayCardOptionModel.fromJson(Map<String, dynamic> json) {
    return BorrowRepayCardOptionModel(
      id: (json['id'] as String?) ?? '',
      brand: (json['brand'] as String?) ?? '',
      last4: (json['last4'] as String?) ?? '',
      displayLabel: (json['displayLabel'] as String?) ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class BorrowRepayPreviewModel {
  final String borrowRequestId;
  final String projectId;
  final String projectName;
  final double repayAmount;
  final String currency;
  final String paymentSourceType;
  final String paymentMethodDisplay;
  final String? dueDate;
  final double principalAmount;
  final BorrowRepayPenaltyModel? penalty;
  final double totalRepayment;

  const BorrowRepayPreviewModel({
    required this.borrowRequestId,
    required this.projectId,
    required this.projectName,
    required this.repayAmount,
    required this.currency,
    required this.paymentSourceType,
    required this.paymentMethodDisplay,
    this.dueDate,
    required this.principalAmount,
    this.penalty,
    required this.totalRepayment,
  });

  factory BorrowRepayPreviewModel.fromJson(Map<String, dynamic> json) {
    final penaltyJson = json['penalty'];
    return BorrowRepayPreviewModel(
      borrowRequestId: (json['borrowRequestId'] as String?) ?? '',
      projectId: (json['projectId'] as String?) ?? '',
      projectName: (json['projectName'] as String?) ?? '',
      repayAmount: (json['repayAmount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      paymentSourceType: (json['paymentSourceType'] as String?) ?? '',
      paymentMethodDisplay: (json['paymentMethodDisplay'] as String?) ?? '',
      dueDate: json['dueDate'] as String?,
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0,
      penalty: penaltyJson is Map
          ? BorrowRepayPenaltyModel.fromJson(penaltyJson.cast())
          : null,
      totalRepayment: (json['totalRepayment'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BorrowRepayPenaltyModel {
  final double percentage;
  final double amount;
  final String display;

  const BorrowRepayPenaltyModel({
    required this.percentage,
    required this.amount,
    required this.display,
  });

  factory BorrowRepayPenaltyModel.fromJson(Map<String, dynamic> json) {
    return BorrowRepayPenaltyModel(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      display: (json['display'] as String?) ?? '',
    );
  }
}

class BorrowRepaymentResultModel {
  final String repaymentId;
  final String borrowRequestId;
  final String projectId;
  final String projectName;
  final double totalRepaid;
  final double principalAmount;
  final double penaltyAmount;
  final String currency;
  final String message;

  const BorrowRepaymentResultModel({
    required this.repaymentId,
    required this.borrowRequestId,
    required this.projectId,
    required this.projectName,
    required this.totalRepaid,
    required this.principalAmount,
    required this.penaltyAmount,
    required this.currency,
    required this.message,
  });

  factory BorrowRepaymentResultModel.fromJson(Map<String, dynamic> json) {
    return BorrowRepaymentResultModel(
      repaymentId: (json['repaymentId'] as String?) ?? '',
      borrowRequestId: (json['borrowRequestId'] as String?) ?? '',
      projectId: (json['projectId'] as String?) ?? '',
      projectName: (json['projectName'] as String?) ?? '',
      totalRepaid: (json['totalRepaid'] as num?)?.toDouble() ?? 0,
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0,
      penaltyAmount: (json['penaltyAmount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      message: (json['message'] as String?) ?? '',
    );
  }
}

class MyBorrowMineItemModel {
  final String id;
  final String status;

  const MyBorrowMineItemModel({required this.id, required this.status});

  factory MyBorrowMineItemModel.fromJson(Map<String, dynamic> json) {
    return MyBorrowMineItemModel(
      id: (json['id'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
    );
  }

  bool get isRepayable =>
      status == 'Disbursed' || status == 'Overdue' || status == 'Approved';
}

String formatBorrowRepayDateLabel(String? utc) {
  if (utc == null || utc.isEmpty) return '';
  final parsed = DateTime.tryParse(utc);
  if (parsed == null) return utc;
  return DateFormat('MMM d, yyyy').format(parsed.toLocal());
}
