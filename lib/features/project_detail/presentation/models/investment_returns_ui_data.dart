import 'package:intl/intl.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/investment/presentation/models/user_investment_ui_snapshot.dart';

/// One row in “Payment History” on My Investment Returns (Figma).
class InvestmentDistributionUi {
  final int distributionNumber;
  final String dateLabel;
  final double leaderDistributionUsd;
  final double myShareUsd;

  /// Left column caption; when null, UI shows “Leader distribution”.
  final String? leftColumnCaption;

  const InvestmentDistributionUi({
    required this.distributionNumber,
    required this.dateLabel,
    required this.leaderDistributionUsd,
    required this.myShareUsd,
    this.leftColumnCaption,
  });
}

/// UI payload for `/user/investment/my-returns` from project detail (dummy until API).
class InvestmentReturnsUiData {
  final String projectId;
  final String projectName;
  final double myContributionUsd;
  final double receivedSoFarUsd;
  final List<InvestmentDistributionUi> distributions;

  const InvestmentReturnsUiData({
    required this.projectId,
    required this.projectName,
    required this.myContributionUsd,
    required this.receivedSoFarUsd,
    required this.distributions,
  });

  static String formatMoney(double value) =>
      NumberFormat('#,##0.00', 'en_US').format(value);

  /// Dummy returns aligned with Figma until investment distributions API exists.
  factory InvestmentReturnsUiData.previewForProject(
    ProjectDetailEntity project,
  ) {
    return InvestmentReturnsUiData(
      projectId: project.id,
      projectName: project.name,
      myContributionUsd: 500,
      receivedSoFarUsd: 208.50,
      distributions: const [
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
      ],
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
    );
  }
}
