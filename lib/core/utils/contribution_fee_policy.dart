import 'package:vestie/core/constants/app_strings.dart';

/// Week 4 contribution fee rules (aligned with backend accounting).
class ContributionFeePolicy {
  ContributionFeePolicy._();

  static const double minimumAmountUsd = 5;
  static const double platformFeeRate = 0.15;

  static double platformFee(double amount) => amount * platformFeeRate;

  static double totalDebited(double amount) => amount + platformFee(amount);

  static double remainingToGoal({
    required double goalAmount,
    required double currentAmount,
  }) {
    if (goalAmount <= 0) return double.infinity;
    return (goalAmount - currentAmount).clamp(0.0, double.infinity);
  }

  static String? validateAmount(
    double amount, {
    double? maxContributionToGoal,
  }) {
    if (amount <= 0) return 'Enter an amount';
    if (amount < minimumAmountUsd) {
      return 'Minimum contribution is \$${minimumAmountUsd.toStringAsFixed(0)}';
    }
    if (maxContributionToGoal != null && maxContributionToGoal.isFinite) {
      if (maxContributionToGoal <= 0) {
        return AppStrings.contributeProjectGoalReached;
      }
      if (amount > maxContributionToGoal) {
        return AppStrings.contributeOnlyAmountExceeded(
          '\$${maxContributionToGoal.toStringAsFixed(2)}',
        );
      }
    }
    return null;
  }
}
