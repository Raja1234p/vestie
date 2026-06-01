/// Week 7 withdrawal amount rules (aligned with backend).
class WalletWithdrawValidation {
  WalletWithdrawValidation._();

  static const double minimumAmountUsd = 10;

  static String? validateAmount(double amount) {
    if (amount <= 0) return 'Enter an amount';
    if (amount < minimumAmountUsd) {
      return 'Minimum withdrawal is \$${minimumAmountUsd.toStringAsFixed(0)}';
    }
    return null;
  }
}
