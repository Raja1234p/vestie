/// Week 4 contribution fee rules (aligned with backend accounting).
class ContributionFeePolicy {
  ContributionFeePolicy._();

  static const double minimumAmountUsd = 5;
  static const double platformFeeRate = 0.07;

  static double platformFee(double amount) => amount * platformFeeRate;

  static double totalDebited(double amount) => amount + platformFee(amount);

  static String? validateAmount(double amount) {
    if (amount <= 0) return 'Enter an amount';
    if (amount < minimumAmountUsd) {
      return 'Minimum contribution is \$${minimumAmountUsd.toStringAsFixed(0)}';
    }
    return null;
  }
}
