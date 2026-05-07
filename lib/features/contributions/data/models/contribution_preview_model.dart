import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/contribution_preview_entity.dart';

class ContributionPreviewModel extends ContributionPreviewEntity {
  const ContributionPreviewModel({
    required super.amount,
    required super.platformFee,
    required super.totalDeduction,
    required super.currency,
  });

  factory ContributionPreviewModel.fromJson(Map<String, dynamic> json) {
    return ContributionPreviewModel(
      amount: json.safeDouble('amount'),
      platformFee: json.safeDouble('platformFee'),
      totalDeduction: json.safeDouble('totalDeduction'),
      currency: json.safeString('currency', defaultValue: 'USD'),
    );
  }
}
