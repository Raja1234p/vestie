class BorrowTermsModel {
  final double amount;
  final String currency;
  final String dueAtUtc;
  final String dueByDisplay;
  final int repaymentWindowDays;
  final double penaltyPercentage;
  final String penaltyIfMissedDisplay;
  final String penaltyAppliesDisplay;
  final String agreementText;
  final double availablePotAmount;
  final double? maxBorrowAmount;
  final String requesterRole;
  final bool hasCoLeader;
  final bool requiresCoLeaderToBorrow;
  final bool canBorrow;
  final String requiredDecisionBy;

  const BorrowTermsModel({
    required this.amount,
    required this.currency,
    required this.dueAtUtc,
    required this.dueByDisplay,
    required this.repaymentWindowDays,
    required this.penaltyPercentage,
    required this.penaltyIfMissedDisplay,
    required this.penaltyAppliesDisplay,
    required this.agreementText,
    required this.availablePotAmount,
    this.maxBorrowAmount,
    required this.requesterRole,
    required this.hasCoLeader,
    required this.requiresCoLeaderToBorrow,
    required this.canBorrow,
    required this.requiredDecisionBy,
  });

  factory BorrowTermsModel.fromJson(Map<String, dynamic> json) {
    return BorrowTermsModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'USD',
      dueAtUtc: (json['dueAtUtc'] as String?) ?? '',
      dueByDisplay: (json['dueByDisplay'] as String?) ?? '',
      repaymentWindowDays: (json['repaymentWindowDays'] as num?)?.toInt() ?? 0,
      penaltyPercentage: (json['penaltyPercentage'] as num?)?.toDouble() ?? 0,
      penaltyIfMissedDisplay:
          (json['penaltyIfMissedDisplay'] as String?) ?? '',
      penaltyAppliesDisplay: (json['penaltyAppliesDisplay'] as String?) ?? '',
      agreementText: (json['agreementText'] as String?) ?? '',
      availablePotAmount: (json['availablePotAmount'] as num?)?.toDouble() ?? 0,
      maxBorrowAmount: (json['maxBorrowAmount'] as num?)?.toDouble(),
      requesterRole: (json['requesterRole'] as String?) ?? '',
      hasCoLeader: json['hasCoLeader'] == true,
      requiresCoLeaderToBorrow: json['requiresCoLeaderToBorrow'] == true,
      canBorrow: json['canBorrow'] != false,
      requiredDecisionBy: (json['requiredDecisionBy'] as String?) ?? '',
    );
  }
}
