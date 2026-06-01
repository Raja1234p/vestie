import 'package:vestie/core/network/api_response_body.dart';
import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_config_entity.dart';

class StripeConfigModel extends StripeConfigEntity {
  const StripeConfigModel({
    required super.publishableKey,
    super.connectAccountType,
  });

  factory StripeConfigModel.fromJson(Map<String, dynamic> json) {
    final body = unwrapApiResponseBody(json);
    return StripeConfigModel(
      publishableKey: body.safeString(
        'publishableKey',
        defaultValue: body.safeString(
          'PublishableKey',
          defaultValue: body.safeString('publishable_key'),
        ),
      ),
      connectAccountType: body.safeString(
        'connectAccountType',
        defaultValue: 'express',
      ),
    );
  }
}
