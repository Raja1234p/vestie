/// Deposit fee and balance preview for the confirm step (Figma, client-only).
abstract final class WalletDepositPolicy {
  static const double feePercent = 2.9;

  static String get feePercentLabel => '${feePercent.toStringAsFixed(1)}%';

  static double platformFee(double depositAmountUsd) =>
      depositAmountUsd * feePercent / 100;

  /// Net credited to wallet after UI fee (preview only — not from deposit API).
  static double netDepositCredit(double depositAmountUsd) =>
      depositAmountUsd - platformFee(depositAmountUsd);

  static double newBalanceAfter({
    required double currentBalanceUsd,
    required double depositAmountUsd,
  }) =>
      currentBalanceUsd + netDepositCredit(depositAmountUsd);
}
