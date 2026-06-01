import 'package:vestie/core/utils/contribution_fee_policy.dart';
import 'entities/contribution_config_entity.dart';

ContributionConfigEntity defaultContributionConfig(
  String projectId, {
  List<WalletSummaryEntity> wallets = const [],
}) {
  return ContributionConfigEntity(
    projectId: projectId,
    projectCurrency: 'USD',
    platformFeeRatePercent: ContributionFeePolicy.platformFeeRate * 100,
    minimumContributionAmount: ContributionFeePolicy.minimumAmountUsd,
    isNonRefundable: true,
    suggestedContributionAmount: 50,
    wallets: wallets,
  );
}
