import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/wallet/domain/entities/withdrawal_entities.dart';
import 'package:vestie/features/wallet/domain/wallet_withdraw_policy.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';

void main() {
  group('WalletWithdrawPolicy.youWillReceiveAmount', () {
    test('uses preview youWillReceive when present', () {
      const preview = WithdrawalPreviewEntity(
        amount: 100,
        type: 'Instant',
        feePercent: 1.5,
        feeAmount: 1.5,
        youWillReceive: 98.5,
        processingTime: '30 Mins',
        destinationDisplay: 'Chase •••• 1234',
        currency: 'USD',
      );

      expect(
        WalletWithdrawPolicy.youWillReceiveAmount(
          principal: 100,
          method: WithdrawDeliveryMethod.instant,
          preview: preview,
        ),
        98.5,
      );
    });

    test('falls back to local net for instant when preview is null', () {
      expect(
        WalletWithdrawPolicy.youWillReceiveAmount(
          principal: 100,
          method: WithdrawDeliveryMethod.instant,
        ),
        98.5,
      );
    });

    test('falls back to full principal for standard when preview is null', () {
      expect(
        WalletWithdrawPolicy.youWillReceiveAmount(
          principal: 100,
          method: WithdrawDeliveryMethod.standard,
        ),
        100,
      );
    });
  });
}
