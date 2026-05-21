/// Deposit fee and balance preview for the confirm step (Figma).
abstract final class WalletDepositPolicy {
  static const double feePercent = 2.5;

  static String get feePercentLabel => '${feePercent.toStringAsFixed(1)}%';

  static double newBalanceAfter({
    required double currentBalanceUsd,
    required double depositAmountUsd,
  }) =>
      currentBalanceUsd + depositAmountUsd;
}
