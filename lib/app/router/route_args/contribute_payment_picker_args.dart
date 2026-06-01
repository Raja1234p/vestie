/// Args for contribute payment-method picker (wallet vs saved cards).
class ContributePaymentPickerArgs {
  final double walletBalance;
  final double requiredTotal;
  final String walletAmountFormatted;

  const ContributePaymentPickerArgs({
    required this.walletBalance,
    required this.requiredTotal,
    required this.walletAmountFormatted,
  });

  bool get walletCoversTotal => walletBalance >= requiredTotal;
}
