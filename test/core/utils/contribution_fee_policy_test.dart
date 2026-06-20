import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/utils/contribution_fee_policy.dart';

void main() {
  group('ContributionFeePolicy', () {
    test('validateAmount rejects zero and below minimum', () {
      expect(ContributionFeePolicy.validateAmount(0), 'Enter an amount');
      expect(
        ContributionFeePolicy.validateAmount(4.99),
        'Minimum contribution is \$5',
      );
    });

    test('validateAmount allows any amount at or above minimum', () {
      expect(ContributionFeePolicy.validateAmount(5), isNull);
      expect(ContributionFeePolicy.validateAmount(10000), isNull);
    });

    test('platformFee is 7% of amount', () {
      expect(ContributionFeePolicy.platformFee(100), closeTo(7, 0.001));
      expect(ContributionFeePolicy.totalDebited(100), closeTo(107, 0.001));
    });
  });
}
