class BorrowRequestModel {
  final String id;
  final String projectId;
  final String requesterMembershipId;
  final double requestedAmount;
  final String currency;
  final String reason;
  final String status;
  final String dueAtUtc;

  const BorrowRequestModel({
    required this.id,
    required this.projectId,
    required this.requesterMembershipId,
    required this.requestedAmount,
    required this.currency,
    required this.reason,
    required this.status,
    required this.dueAtUtc,
  });

  factory BorrowRequestModel.fromJson(Map<String, dynamic> json) {
    return BorrowRequestModel(
      id: (json['id'] as String?) ?? '',
      projectId: (json['projectId'] as String?) ?? '',
      requesterMembershipId: (json['requesterMembershipId'] as String?) ?? '',
      requestedAmount: (json['requestedAmount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? '',
      reason: (json['reason'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      dueAtUtc: (json['dueAtUtc'] as String?) ?? '',
    );
  }
}

