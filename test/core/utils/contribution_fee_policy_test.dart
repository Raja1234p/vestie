import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/contribution_fee_policy.dart';

void main() {
  group('ContributionFeePolicy', () {
    test('remainingToGoal clamps at zero', () {
      expect(
        ContributionFeePolicy.remainingToGoal(
          goalAmount: 5000,
          currentAmount: 4800,
        ),
        200,
      );
      expect(
        ContributionFeePolicy.remainingToGoal(
          goalAmount: 5000,
          currentAmount: 6000,
        ),
        0,
      );
    });

    test('validateAmount rejects amount above remaining goal', () {
      final message = ContributionFeePolicy.validateAmount(
        1000,
        maxContributionToGoal: 200,
      );

      expect(message, AppStrings.contributeOnlyAmountExceeded(r'$200.00'));
    });

    test('validateAmount rejects when goal already reached', () {
      final message = ContributionFeePolicy.validateAmount(
        10,
        maxContributionToGoal: 0,
      );

      expect(message, AppStrings.contributeProjectGoalReached);
    });

    test('validateAmount allows amount within remaining goal', () {
      expect(
        ContributionFeePolicy.validateAmount(
          150,
          maxContributionToGoal: 200,
        ),
        isNull,
      );
    });
  });
}
