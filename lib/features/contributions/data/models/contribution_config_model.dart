import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/contribution_config_entity.dart';

class ContributionConfigModel extends ContributionConfigEntity {
  const ContributionConfigModel({
    required super.projectId,
    required super.projectCurrency,
    required super.platformFeeRatePercent,
    required super.minimumContributionAmount,
    required super.isNonRefundable,
    required super.suggestedContributionAmount,
    required super.wallets,
  });

  factory ContributionConfigModel.fromJson(Map<String, dynamic> json) {
    return ContributionConfigModel(
      projectId: json.safeString('projectId'),
      projectCurrency: json.safeString('projectCurrency', defaultValue: 'USD'),
      platformFeeRatePercent: json.safeDouble('platformFeeRatePercent'),
      minimumContributionAmount: json.safeDouble('minimumContributionAmount'),
      isNonRefundable: json.safeBool('isNonRefundable'),
      suggestedContributionAmount: json.safeDouble('suggestedContributionAmount'),
      wallets: (json['wallets'] as List<dynamic>?)
              ?.map((e) => WalletSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WalletSummaryModel extends WalletSummaryEntity {
  const WalletSummaryModel({
    required super.walletId,
    required super.currency,
    required super.availableBalance,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      walletId: json.safeString('walletId'),
      currency: json.safeString('currency', defaultValue: 'USD'),
      availableBalance: json.safeDouble('availableBalance'),
    );
  }
}
