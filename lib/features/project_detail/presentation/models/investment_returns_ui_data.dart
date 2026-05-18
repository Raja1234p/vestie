import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/investment/presentation/models/user_investment_ui_snapshot.dart';

/// One row in “Payment History” on investment returns / distribute funds (Figma).
class InvestmentDistributionUi {
  final int distributionNumber;
  final String dateLabel;
  final double leaderDistributionUsd;
  final double myShareUsd;

  /// Left column caption; when null, UI uses [InvestmentReturnsUiData.defaultLeftColumnLabel].
  final String? leftColumnCaption;

  const InvestmentDistributionUi({
    required this.distributionNumber,
    required this.dateLabel,
    required this.leaderDistributionUsd,
    required this.myShareUsd,
    this.leftColumnCaption,
  });
}

/// UI payload for member returns and leader distribute-funds screens (dummy until API).
class InvestmentReturnsUiData {
  final String projectId;
  final String projectName;
  final double myContributionUsd;
  final double receivedSoFarUsd;
  final List<InvestmentDistributionUi> distributions;
  final String primarySummaryLabel;
  final String receivedCardLabel;
  final String defaultLeftColumnLabel;
  final Color receivedCardAmountColor;

  const InvestmentReturnsUiData({
    required this.projectId,
    required this.projectName,
    required this.myContributionUsd,
    required this.receivedSoFarUsd,
    required this.distributions,
    required this.primarySummaryLabel,
    required this.receivedCardLabel,
    required this.defaultLeftColumnLabel,
    this.receivedCardAmountColor = AppColors.neutral1200,
  });

  static String formatMoney(double value) =>
      NumberFormat('#,##0.00', 'en_US').format(value);

  static const List<InvestmentDistributionUi> _previewDistributions = [
    InvestmentDistributionUi(
      distributionNumber: 3,
      dateLabel: 'Apr 01, 2026',
      leaderDistributionUsd: 500,
      myShareUsd: 83.33,
    ),
    InvestmentDistributionUi(
      distributionNumber: 2,
      dateLabel: 'Feb 22, 2026',
      leaderDistributionUsd: 1400,
      myShareUsd: 240,
    ),
    InvestmentDistributionUi(
      distributionNumber: 1,
      dateLabel: 'Apr 01, 2026',
      leftColumnCaption: 'Jan 15, 2026',
      leaderDistributionUsd: 900,
      myShareUsd: 83.33,
    ),
  ];

  /// Member “My Investment Returns” preview (Figma).
  factory InvestmentReturnsUiData.previewForProject(
    ProjectDetailEntity project,
  ) {
    return InvestmentReturnsUiData(
      projectId: project.id,
      projectName: project.name,
      myContributionUsd: 500,
      receivedSoFarUsd: 208.50,
      distributions: _previewDistributions,
      primarySummaryLabel: AppStrings.userInvestmentMyContributionLabel,
      receivedCardLabel: AppStrings.userInvestmentReceivedSoFarLabel,
      defaultLeftColumnLabel: AppStrings.investmentLeaderDistributionLabel,
    );
  }

  /// Leader “Distribute Funds” preview (Figma).
  factory InvestmentReturnsUiData.previewLeaderForProject(
    ProjectDetailEntity project,
  ) {
    return InvestmentReturnsUiData(
      projectId: project.id,
      projectName: project.name,
      myContributionUsd: 4500,
      receivedSoFarUsd: 1208.50,
      distributions: _previewDistributions
          .map(
            (d) => InvestmentDistributionUi(
              distributionNumber: d.distributionNumber,
              dateLabel: d.dateLabel,
              leaderDistributionUsd: d.leaderDistributionUsd,
              myShareUsd: d.myShareUsd,
            ),
          )
          .toList(growable: false),
      primarySummaryLabel: AppStrings.investmentTotalDistributionsLabel,
      receivedCardLabel: AppStrings.investmentReceivedShareLabel,
      defaultLeftColumnLabel: AppStrings.investmentDistributionAmountLabel,
      receivedCardAmountColor: AppColors.green900,
    );
  }

  factory InvestmentReturnsUiData.fromLegacySnapshot(
    UserInvestmentUiSnapshot snapshot,
  ) {
    return InvestmentReturnsUiData(
      projectId: snapshot.projectName,
      projectName: snapshot.projectName,
      myContributionUsd: snapshot.investedAmountUsd,
      receivedSoFarUsd: snapshot.totalReturnsUsd,
      distributions: snapshot.returnsHistory
          .asMap()
          .entries
          .map(
            (e) => InvestmentDistributionUi(
              distributionNumber: snapshot.returnsHistory.length - e.key,
              dateLabel: e.value.periodLabel,
              leaderDistributionUsd: e.value.amount * 6,
              myShareUsd: e.value.amount,
            ),
          )
          .toList(growable: false),
      primarySummaryLabel: AppStrings.userInvestmentMyContributionLabel,
      receivedCardLabel: AppStrings.userInvestmentReceivedSoFarLabel,
      defaultLeftColumnLabel: AppStrings.investmentLeaderDistributionLabel,
    );
  }
}
