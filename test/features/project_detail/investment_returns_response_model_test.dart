import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/project_detail/data/models/investment_returns_response_models.dart';
import 'package:vestie/features/project_detail/presentation/mappers/investment_returns_ui_mappers.dart';

void main() {
  group('MyInvestmentReturnsResponseModel', () {
    test('parses member returns payload', () {
      const json = {
        'myContribution': 3000.00,
        'myContributionPercentage': 30.00,
        'totalEntitlement': 3300.00,
        'receivedSoFar': 1200.00,
        'remainingToReceive': 2100.00,
        'roiPercentage': 10.00,
        'roiAmount': 300.00,
        'paymentHistory': [
          {
            'distributionNumber': 1,
            'distributionDate': '2026-06-15',
            'leaderDistributionAmount': 2000.00,
            'myShare': 600.00,
          },
        ],
      };

      final entity = MyInvestmentReturnsResponseModel.fromJson(json).toEntity();
      final ui = investmentReturnsUiDataFromMyReturns(
        projectId: 'p1',
        projectName: 'Fund',
        entity: entity,
      );

      expect(entity.receivedSoFar, 1200);
      expect(ui.distributions.single.myShareUsd, 600);
    });
  });

  group('InvestmentDistributionPreviewResponseModel', () {
    test('parses preview breakdown', () {
      const json = {
        'distributionAmount': 2000.00,
        'remainingToDistribute': 3500.00,
        'memberCount': 1,
        'breakdown': [
          {
            'memberId': 'm1',
            'memberName': 'Jane D.',
            'contributionAmount': 3000.00,
            'contributionPercentage': 30.00,
            'willReceive': 600.00,
            'runningTotalAfter': 1200.00,
            'totalEntitlement': 3300.00,
          },
        ],
      };

      final entity =
          InvestmentDistributionPreviewResponseModel.fromJson(json).toEntity();
      final ui = investmentDistributionUiDataFromPreview(
        projectId: 'p1',
        projectName: 'Fund',
        entity: entity,
      );

      expect(ui.distributeAmountUsd, 2000);
      expect(ui.members.single.receivesUsd, 600);
    });
  });
}
