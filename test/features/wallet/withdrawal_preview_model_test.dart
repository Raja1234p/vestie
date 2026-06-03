import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/wallet/data/models/withdrawal_models.dart';

void main() {
  test('WithdrawalPreviewModel parses preview API response', () {
    const json = {
      'amount': 10.0,
      'type': 'Instant',
      'feePercent': 1.5,
      'feeAmount': 0.15,
      'youWillReceive': 9.85,
      'processingTime': '30 Mins',
      'destinationDisplay': 'STRIPE TEST BANK - 2227',
      'currency': 'USD',
    };

    final model = WithdrawalPreviewModel.fromJson(json);

    expect(model.amount, 10.0);
    expect(model.type, 'Instant');
    expect(model.feePercent, 1.5);
    expect(model.feeAmount, 0.15);
    expect(model.youWillReceive, 9.85);
    expect(model.processingTime, '30 Mins');
    expect(model.destinationDisplay, 'STRIPE TEST BANK - 2227');
    expect(model.currency, 'USD');
  });

  test('WithdrawalPreviewModel unwraps nested data envelope', () {
    final model = WithdrawalPreviewModel.fromJson({
      'data': {
        'amount': 10.0,
        'type': 'Instant',
        'feePercent': 1.5,
        'feeAmount': 0.15,
        'youWillReceive': 9.85,
        'processingTime': '30 Mins',
        'destinationDisplay': 'STRIPE TEST BANK - 2227',
        'currency': 'USD',
      },
    });

    expect(model.feeAmount, 0.15);
    expect(model.youWillReceive, 9.85);
  });

  test('withdrawFeeInstantRow shows sub-dollar fee amount', () {
    expect(
      AppStrings.withdrawFeeInstantRow(feePercent: 1.5, feeAmount: 0.15),
      '1.5% (-\$0.15)',
    );
  });
}
