import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_config_entity.dart';

class StripeConfigModel extends StripeConfigEntity {
  const StripeConfigModel({
    required super.publishableKey,
    super.connectAccountType,
  });

  factory StripeConfigModel.fromJson(Map<String, dynamic> json) {
    return StripeConfigModel(
      publishableKey: json.safeString(
        'publishableKey',
        defaultValue: json.safeString('PublishableKey'),
      ),
      connectAccountType: json.safeString(
        'connectAccountType',
        defaultValue: 'express',
      ),
    );
  }
}
