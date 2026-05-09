import 'package:vestie/core/utils/safe_parser.dart';
import '../../domain/entities/contribution_preview_entity.dart';

class ContributionPreviewModel extends ContributionPreviewEntity {
  const ContributionPreviewModel({
    required super.amount,
    required super.platformFee,
    required super.totalDeduction,
    required super.currency,
  });

  factory ContributionPreviewModel.fromJson(Map<String, dynamic> json) {
    final contributionAmount = json.safeDouble('contributionAmount');
    final platformFeeAmount = json.safeDouble('platformFeeAmount');
    final walletDeductionAmount = json.safeDouble('walletDeductionAmount');

    return ContributionPreviewModel(
      // Week4 keys with backward-safe fallbacks.
      amount: contributionAmount > 0 ? contributionAmount : json.safeDouble('amount'),
      platformFee: platformFeeAmount > 0 ? platformFeeAmount : json.safeDouble('platformFee'),
      totalDeduction:
          walletDeductionAmount > 0 ? walletDeductionAmount : json.safeDouble('totalDeduction'),
      currency: json.safeString('currency', defaultValue: 'USD'),
    );
  }
}
