import 'package:equatable/equatable.dart';

class ContributionConfigEntity extends Equatable {
  final String projectId;
  final String projectCurrency;
  final double platformFeeRatePercent;
  final double minimumContributionAmount;
  final bool isNonRefundable;
  final double suggestedContributionAmount;
  final List<WalletSummaryEntity> wallets;

  const ContributionConfigEntity({
    required this.projectId,
    required this.projectCurrency,
    required this.platformFeeRatePercent,
    required this.minimumContributionAmount,
    required this.isNonRefundable,
    required this.suggestedContributionAmount,
    required this.wallets,
  });

  @override
  List<Object?> get props => [
        projectId,
        projectCurrency,
        platformFeeRatePercent,
        minimumContributionAmount,
        isNonRefundable,
        suggestedContributionAmount,
        wallets,
      ];
}

class WalletSummaryEntity extends Equatable {
  final String walletId;
  final String currency;
  final double availableBalance;

  const WalletSummaryEntity({
    required this.walletId,
    required this.currency,
    required this.availableBalance,
  });

  @override
  List<Object?> get props => [walletId, currency, availableBalance];
}
