/// Member view from `GET …/investment/my-returns`.
class MyInvestmentReturnsEntity {
  final double myContribution;
  final double myContributionPercentage;
  final double totalEntitlement;
  final double receivedSoFar;
  final double remainingToReceive;
  final double roiPercentage;
  final double roiAmount;
  final List<InvestmentPaymentHistoryEntity> paymentHistory;

  const MyInvestmentReturnsEntity({
    required this.myContribution,
    required this.myContributionPercentage,
    required this.totalEntitlement,
    required this.receivedSoFar,
    required this.remainingToReceive,
    required this.roiPercentage,
    required this.roiAmount,
    required this.paymentHistory,
  });
}

class InvestmentPaymentHistoryEntity {
  final int distributionNumber;
  final String distributionDate;
  final double leaderDistributionAmount;
  final double myShare;

  const InvestmentPaymentHistoryEntity({
    required this.distributionNumber,
    required this.distributionDate,
    required this.leaderDistributionAmount,
    required this.myShare,
  });
}

/// Group leader view from `GET …/investment/distributions`.
class InvestmentDistributionsHistoryEntity {
  final double totalDistributedSoFar;
  final double myReceivedShare;
  final int distributionCount;
  final List<InvestmentLeaderDistributionEntity> distributions;

  const InvestmentDistributionsHistoryEntity({
    required this.totalDistributedSoFar,
    required this.myReceivedShare,
    required this.distributionCount,
    required this.distributions,
  });
}

class InvestmentLeaderDistributionEntity {
  final int distributionNumber;
  final String distributionDate;
  final double totalAmount;
  final double myShare;

  const InvestmentLeaderDistributionEntity({
    required this.distributionNumber,
    required this.distributionDate,
    required this.totalAmount,
    required this.myShare,
  });
}

/// `POST …/investment/distribute/preview`.
class InvestmentDistributionPreviewEntity {
  final double distributionAmount;
  final double remainingToDistribute;
  final int memberCount;
  final List<InvestmentDistributionBreakdownEntity> breakdown;

  const InvestmentDistributionPreviewEntity({
    required this.distributionAmount,
    required this.remainingToDistribute,
    required this.memberCount,
    required this.breakdown,
  });
}

class InvestmentDistributionBreakdownEntity {
  final String memberId;
  final String memberName;
  final double contributionAmount;
  final double contributionPercentage;
  final double willReceive;
  final double runningTotalAfter;
  final double totalEntitlement;

  const InvestmentDistributionBreakdownEntity({
    required this.memberId,
    required this.memberName,
    required this.contributionAmount,
    required this.contributionPercentage,
    required this.willReceive,
    required this.runningTotalAfter,
    required this.totalEntitlement,
  });
}

/// `POST …/investment/distribute`.
class InvestmentDistributionResultEntity {
  final String distributionId;
  final int distributionNumber;
  final double totalDistributed;
  final int participantCount;

  const InvestmentDistributionResultEntity({
    required this.distributionId,
    required this.distributionNumber,
    required this.totalDistributed,
    required this.participantCount,
  });
}
