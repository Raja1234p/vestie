import 'package:intl/intl.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/features/project_detail/domain/entities/investment_returns_entities.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

String _formatApiDateLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return trimmed;
  return DateFormat('MMM d, yyyy').format(parsed.toLocal());
}

InvestmentReturnsUiData investmentReturnsUiDataFromMyReturns({
  required String projectId,
  required String projectName,
  required MyInvestmentReturnsEntity entity,
}) {
  return InvestmentReturnsUiData(
    projectId: projectId,
    projectName: projectName,
    myContributionUsd: entity.myContribution,
    receivedSoFarUsd: entity.receivedSoFar,
    distributions: entity.paymentHistory
        .map(
          (row) => InvestmentDistributionUi(
            distributionNumber: row.distributionNumber,
            dateLabel: _formatApiDateLabel(row.distributionDate),
            leaderDistributionUsd: row.leaderDistributionAmount,
            myShareUsd: row.myShare,
          ),
        )
        .toList(growable: false),
    primarySummaryLabel: AppStrings.userInvestmentMyContributionLabel,
    receivedCardLabel: AppStrings.userInvestmentReceivedSoFarLabel,
    defaultLeftColumnLabel: AppStrings.investmentLeaderDistributionLabel,
  );
}

InvestmentReturnsUiData investmentReturnsUiDataFromDistributions({
  required String projectId,
  required String projectName,
  required InvestmentDistributionsHistoryEntity entity,
}) {
  return InvestmentReturnsUiData(
    projectId: projectId,
    projectName: projectName,
    myContributionUsd: entity.totalDistributedSoFar,
    receivedSoFarUsd: entity.myReceivedShare,
    distributions: entity.distributions
        .map(
          (row) => InvestmentDistributionUi(
            distributionNumber: row.distributionNumber,
            dateLabel: _formatApiDateLabel(row.distributionDate),
            leaderDistributionUsd: row.totalAmount,
            myShareUsd: row.myShare,
          ),
        )
        .toList(growable: false),
    primarySummaryLabel: AppStrings.investmentTotalDistributionsLabel,
    receivedCardLabel: AppStrings.investmentReceivedShareLabel,
    defaultLeftColumnLabel: AppStrings.investmentDistributionAmountLabel,
    receivedCardAmountColor: AppColors.green900,
  );
}

InvestmentDistributionUiData investmentDistributionUiDataFromPreview({
  required String projectId,
  required String? projectName,
  required InvestmentDistributionPreviewEntity entity,
}) {
  return InvestmentDistributionUiData(
    projectId: projectId,
    projectName: projectName,
    distributeAmountUsd: entity.distributionAmount,
    remainingUsd: entity.remainingToDistribute,
    members: entity.breakdown
        .map(
          (row) => DistributionMemberRowUi(
            name: row.memberName,
            contributedUsd: row.contributionAmount,
            sharePercent: row.contributionPercentage,
            receivesUsd: row.willReceive,
          ),
        )
        .toList(growable: false),
  );
}
