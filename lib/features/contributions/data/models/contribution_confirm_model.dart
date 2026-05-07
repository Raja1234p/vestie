class ContributionConfirmModel {
  final String contributionId;
  final String paymentTransactionId;
  final String projectId;
  final double contributionAmount;
  final double platformFeeAmount;
  final double walletDeductionAmount;
  final double projectPotCreditAmount;
  final double walletBalanceAfter;
  final double projectPotBalanceAfter;
  final String currency;
  final String receivedAtUtc;
  final String message;

  const ContributionConfirmModel({
    required this.contributionId,
    required this.paymentTransactionId,
    required this.projectId,
    required this.contributionAmount,
    required this.platformFeeAmount,
    required this.walletDeductionAmount,
    required this.projectPotCreditAmount,
    required this.walletBalanceAfter,
    required this.projectPotBalanceAfter,
    required this.currency,
    required this.receivedAtUtc,
    required this.message,
  });

  factory ContributionConfirmModel.fromJson(Map<String, dynamic> json) {
    return ContributionConfirmModel(
      contributionId: (json['contributionId'] as String?) ?? '',
      paymentTransactionId: (json['paymentTransactionId'] as String?) ?? '',
      projectId: (json['projectId'] as String?) ?? '',
      contributionAmount:
          (json['contributionAmount'] as num?)?.toDouble() ?? 0.0,
      platformFeeAmount:
          (json['platformFeeAmount'] as num?)?.toDouble() ?? 0.0,
      walletDeductionAmount:
          (json['walletDeductionAmount'] as num?)?.toDouble() ?? 0.0,
      projectPotCreditAmount:
          (json['projectPotCreditAmount'] as num?)?.toDouble() ?? 0.0,
      walletBalanceAfter:
          (json['walletBalanceAfter'] as num?)?.toDouble() ?? 0.0,
      projectPotBalanceAfter:
          (json['projectPotBalanceAfter'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? '',
      receivedAtUtc: (json['receivedAtUtc'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
    );
  }
}

