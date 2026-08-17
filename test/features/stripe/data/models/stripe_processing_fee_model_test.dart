import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/stripe/data/models/stripe_processing_fee_model.dart';

void main() {
  test('parses estimated processing fee from wrapped API body', () {
    final model = StripeProcessingFeeModel.fromJson({
      'value': {
        'stripeFeeCents': 320,
        'stripeFee': 3.20,
        'isEstimated': true,
        'depositAmount': 100,
        'netAmount': 96.80,
      },
    });

    expect(model.stripeFeeCents, 320);
    expect(model.stripeFee, 3.20);
    expect(model.isEstimated, isTrue);
    expect(model.depositAmount, 100);
    expect(model.netAmount, 96.80);
    expect(model.netCredit, 96.80);
  });

  test('parses actual processing fee after payment', () {
    final model = StripeProcessingFeeModel.fromJson({
      'stripeFeeCents': 321,
      'stripeFee': 3.21,
      'isEstimated': false,
      'depositAmount': 100,
      'netAmount': 96.79,
      'paymentIntentId': 'pi_123',
      'status': 'succeeded',
    });

    expect(model.isEstimated, isFalse);
    expect(model.paymentIntentId, 'pi_123');
    expect(model.status, 'succeeded');
  });
}
