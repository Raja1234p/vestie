import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';

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

  static String? validateSufficientBalance(double amount) {
    final available = WalletBalanceCache.value?.availableBalance;
    if (available == null) return null;
    if (amount > available) {
      return AppStrings.withdrawInsufficientBalance;
    }
    return null;
  }

  /// Min amount + available balance (when wallet cache is populated).
  static String? validateForWithdraw(double amount) {
    final minErr = validateAmount(amount);
    if (minErr != null) return minErr;
    return validateSufficientBalance(amount);
  }
}
