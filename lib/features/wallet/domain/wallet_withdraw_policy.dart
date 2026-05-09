import 'withdraw_delivery_method.dart';

/// Fee + ETA rules for withdrawal flows (matches product / Figma).
abstract final class WalletWithdrawPolicy {
  /// Instant rail fee — 1.5% of principal.
  static const double instantFeeRate = 0.015;

  static double feeAmount(double principal, WithdrawDeliveryMethod method) {
    if (method != WithdrawDeliveryMethod.instant) return 0;
    return double.parse(
      (principal * instantFeeRate).toStringAsFixed(2),
    );
  }

  static double netReceive(double principal, WithdrawDeliveryMethod method) {
    return double.parse(
      (principal - feeAmount(principal, method)).toStringAsFixed(2),
    );
  }
}
