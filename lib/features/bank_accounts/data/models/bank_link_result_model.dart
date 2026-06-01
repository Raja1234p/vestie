import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_link_result_entity.dart';

import 'bank_account_model.dart';

class BankLinkResultModel extends BankLinkResultEntity {
  const BankLinkResultModel({
    super.bankAccount,
    super.onboardingUrl,
    super.onboardingExpiresAt,
  });

  factory BankLinkResultModel.fromJson(Map<String, dynamic> json) {
    BankAccountModel? account;
    if (json['bankAccount'] is Map) {
      account = BankAccountModel.fromJson(
        (json['bankAccount'] as Map).cast<String, dynamic>(),
      );
    }

    return BankLinkResultModel(
      bankAccount: account,
      onboardingUrl: json.safeStringNullable('onboardingUrl'),
      onboardingExpiresAt: _parseDate(json['onboardingExpiresAt']),
    );
  }
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw.toString());
}
