import 'package:vestie/core/network/api_response_body.dart';
import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_processing_fee_entity.dart';

class StripeProcessingFeeModel extends StripeProcessingFeeEntity {
  const StripeProcessingFeeModel({
    required super.stripeFeeCents,
    required super.stripeFee,
    required super.isEstimated,
    required super.depositAmount,
    required super.netAmount,
    super.paymentIntentId,
    super.status,
  });

  factory StripeProcessingFeeModel.fromJson(Map<String, dynamic> json) {
    final body = unwrapApiResponseBody(json);
    return StripeProcessingFeeModel(
      stripeFeeCents: body.safeInt('stripeFeeCents'),
      stripeFee: body.safeDouble('stripeFee'),
      isEstimated: body.safeBool('isEstimated', defaultValue: true),
      depositAmount: body.safeDouble('depositAmount'),
      netAmount: body.safeDouble('netAmount'),
      paymentIntentId: body.safeStringNullable('paymentIntentId'),
      status: body.safeStringNullable('status'),
    );
  }
}
