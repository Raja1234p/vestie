class ContributionRecordModel {
  final String id;
  final String projectId;
  final String membershipId;
  final String walletId;
  final double grossAmount;
  final double platformFeeAmount;
  final double netAmount;
  final String currency;
  final String status;
  final String externalReference;
  final String receivedAtUtc;

  const ContributionRecordModel({
    required this.id,
    required this.projectId,
    required this.membershipId,
    required this.walletId,
    required this.grossAmount,
    required this.platformFeeAmount,
    required this.netAmount,
    required this.currency,
    required this.status,
    required this.externalReference,
    required this.receivedAtUtc,
  });

  factory ContributionRecordModel.fromJson(Map<String, dynamic> json) {
    return ContributionRecordModel(
      id: (json['id'] as String?) ?? '',
      projectId: (json['projectId'] as String?) ?? '',
      membershipId: (json['membershipId'] as String?) ?? '',
      walletId: (json['walletId'] as String?) ?? '',
      grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0.0,
      platformFeeAmount: (json['platformFeeAmount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      externalReference: (json['externalReference'] as String?) ?? '',
      receivedAtUtc: (json['receivedAtUtc'] as String?) ?? '',
    );
  }
}

