import '../../domain/entities/investment_returns_entities.dart';

class MyInvestmentReturnsResponseModel {
  final double myContribution;
  final double myContributionPercentage;
  final double totalEntitlement;
  final double receivedSoFar;
  final double remainingToReceive;
  final double roiPercentage;
  final double roiAmount;
  final List<InvestmentPaymentHistoryResponseModel> paymentHistory;

  const MyInvestmentReturnsResponseModel({
    required this.myContribution,
    required this.myContributionPercentage,
    required this.totalEntitlement,
    required this.receivedSoFar,
    required this.remainingToReceive,
    required this.roiPercentage,
    required this.roiAmount,
    required this.paymentHistory,
  });

  factory MyInvestmentReturnsResponseModel.fromJson(Map<String, dynamic> json) {
    final history = json['paymentHistory'];
    return MyInvestmentReturnsResponseModel(
      myContribution: (json['myContribution'] as num?)?.toDouble() ?? 0,
      myContributionPercentage:
          (json['myContributionPercentage'] as num?)?.toDouble() ?? 0,
      totalEntitlement: (json['totalEntitlement'] as num?)?.toDouble() ?? 0,
      receivedSoFar: (json['receivedSoFar'] as num?)?.toDouble() ?? 0,
      remainingToReceive:
          (json['remainingToReceive'] as num?)?.toDouble() ?? 0,
      roiPercentage: (json['roiPercentage'] as num?)?.toDouble() ?? 0,
      roiAmount: (json['roiAmount'] as num?)?.toDouble() ?? 0,
      paymentHistory: history is List
          ? history
                .whereType<Map>()
                .map(
                  (e) => InvestmentPaymentHistoryResponseModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  MyInvestmentReturnsEntity toEntity() {
    return MyInvestmentReturnsEntity(
      myContribution: myContribution,
      myContributionPercentage: myContributionPercentage,
      totalEntitlement: totalEntitlement,
      receivedSoFar: receivedSoFar,
      remainingToReceive: remainingToReceive,
      roiPercentage: roiPercentage,
      roiAmount: roiAmount,
      paymentHistory: paymentHistory.map((e) => e.toEntity()).toList(),
    );
  }
}

class InvestmentPaymentHistoryResponseModel {
  final int distributionNumber;
  final String distributionDate;
  final double leaderDistributionAmount;
  final double myShare;

  const InvestmentPaymentHistoryResponseModel({
    required this.distributionNumber,
    required this.distributionDate,
    required this.leaderDistributionAmount,
    required this.myShare,
  });

  factory InvestmentPaymentHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestmentPaymentHistoryResponseModel(
      distributionNumber: (json['distributionNumber'] as num?)?.toInt() ?? 0,
      distributionDate: _string(json['distributionDate']),
      leaderDistributionAmount:
          (json['leaderDistributionAmount'] as num?)?.toDouble() ?? 0,
      myShare: (json['myShare'] as num?)?.toDouble() ?? 0,
    );
  }

  InvestmentPaymentHistoryEntity toEntity() {
    return InvestmentPaymentHistoryEntity(
      distributionNumber: distributionNumber,
      distributionDate: distributionDate,
      leaderDistributionAmount: leaderDistributionAmount,
      myShare: myShare,
    );
  }
}

class InvestmentDistributionsHistoryResponseModel {
  final double totalDistributedSoFar;
  final double myReceivedShare;
  final int distributionCount;
  final List<InvestmentLeaderDistributionResponseModel> distributions;

  const InvestmentDistributionsHistoryResponseModel({
    required this.totalDistributedSoFar,
    required this.myReceivedShare,
    required this.distributionCount,
    required this.distributions,
  });

  factory InvestmentDistributionsHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final list = json['distributions'];
    return InvestmentDistributionsHistoryResponseModel(
      totalDistributedSoFar:
          (json['totalDistributedSoFar'] as num?)?.toDouble() ?? 0,
      myReceivedShare: (json['myReceivedShare'] as num?)?.toDouble() ?? 0,
      distributionCount: (json['distributionCount'] as num?)?.toInt() ?? 0,
      distributions: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => InvestmentLeaderDistributionResponseModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  InvestmentDistributionsHistoryEntity toEntity() {
    return InvestmentDistributionsHistoryEntity(
      totalDistributedSoFar: totalDistributedSoFar,
      myReceivedShare: myReceivedShare,
      distributionCount: distributionCount,
      distributions: distributions.map((e) => e.toEntity()).toList(),
    );
  }
}

class InvestmentLeaderDistributionResponseModel {
  final int distributionNumber;
  final String distributionDate;
  final double totalAmount;
  final double myShare;

  const InvestmentLeaderDistributionResponseModel({
    required this.distributionNumber,
    required this.distributionDate,
    required this.totalAmount,
    required this.myShare,
  });

  factory InvestmentLeaderDistributionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestmentLeaderDistributionResponseModel(
      distributionNumber: (json['distributionNumber'] as num?)?.toInt() ?? 0,
      distributionDate: _string(json['distributionDate']),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      myShare: (json['myShare'] as num?)?.toDouble() ?? 0,
    );
  }

  InvestmentLeaderDistributionEntity toEntity() {
    return InvestmentLeaderDistributionEntity(
      distributionNumber: distributionNumber,
      distributionDate: distributionDate,
      totalAmount: totalAmount,
      myShare: myShare,
    );
  }
}

class InvestmentDistributionPreviewResponseModel {
  final double distributionAmount;
  final double remainingToDistribute;
  final int memberCount;
  final List<InvestmentDistributionBreakdownResponseModel> breakdown;

  const InvestmentDistributionPreviewResponseModel({
    required this.distributionAmount,
    required this.remainingToDistribute,
    required this.memberCount,
    required this.breakdown,
  });

  factory InvestmentDistributionPreviewResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final list = json['breakdown'];
    return InvestmentDistributionPreviewResponseModel(
      distributionAmount:
          (json['distributionAmount'] as num?)?.toDouble() ?? 0,
      remainingToDistribute:
          (json['remainingToDistribute'] as num?)?.toDouble() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      breakdown: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => InvestmentDistributionBreakdownResponseModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  InvestmentDistributionPreviewEntity toEntity() {
    return InvestmentDistributionPreviewEntity(
      distributionAmount: distributionAmount,
      remainingToDistribute: remainingToDistribute,
      memberCount: memberCount,
      breakdown: breakdown.map((e) => e.toEntity()).toList(),
    );
  }
}

class InvestmentDistributionBreakdownResponseModel {
  final String memberId;
  final String memberName;
  final double contributionAmount;
  final double contributionPercentage;
  final double willReceive;
  final double runningTotalAfter;
  final double totalEntitlement;

  const InvestmentDistributionBreakdownResponseModel({
    required this.memberId,
    required this.memberName,
    required this.contributionAmount,
    required this.contributionPercentage,
    required this.willReceive,
    required this.runningTotalAfter,
    required this.totalEntitlement,
  });

  factory InvestmentDistributionBreakdownResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestmentDistributionBreakdownResponseModel(
      memberId: _string(json['memberId']),
      memberName: _string(json['memberName']),
      contributionAmount:
          (json['contributionAmount'] as num?)?.toDouble() ?? 0,
      contributionPercentage:
          (json['contributionPercentage'] as num?)?.toDouble() ?? 0,
      willReceive: (json['willReceive'] as num?)?.toDouble() ?? 0,
      runningTotalAfter: (json['runningTotalAfter'] as num?)?.toDouble() ?? 0,
      totalEntitlement: (json['totalEntitlement'] as num?)?.toDouble() ?? 0,
    );
  }

  InvestmentDistributionBreakdownEntity toEntity() {
    return InvestmentDistributionBreakdownEntity(
      memberId: memberId,
      memberName: memberName,
      contributionAmount: contributionAmount,
      contributionPercentage: contributionPercentage,
      willReceive: willReceive,
      runningTotalAfter: runningTotalAfter,
      totalEntitlement: totalEntitlement,
    );
  }
}

class InvestmentDistributionResultResponseModel {
  final String distributionId;
  final int distributionNumber;
  final double totalDistributed;
  final int participantCount;

  const InvestmentDistributionResultResponseModel({
    required this.distributionId,
    required this.distributionNumber,
    required this.totalDistributed,
    required this.participantCount,
  });

  factory InvestmentDistributionResultResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvestmentDistributionResultResponseModel(
      distributionId: _string(json['distributionId']),
      distributionNumber: (json['distributionNumber'] as num?)?.toInt() ?? 0,
      totalDistributed: (json['totalDistributed'] as num?)?.toDouble() ?? 0,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
    );
  }

  InvestmentDistributionResultEntity toEntity() {
    return InvestmentDistributionResultEntity(
      distributionId: distributionId,
      distributionNumber: distributionNumber,
      totalDistributed: totalDistributed,
      participantCount: participantCount,
    );
  }
}

Map<String, dynamic> parseInvestmentReturnsResponseMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

String _string(dynamic value) => value?.toString().trim() ?? '';
