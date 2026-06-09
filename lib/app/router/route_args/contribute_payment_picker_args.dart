/// Args for contribute payment-method picker (wallet vs saved cards).
class ContributePaymentPickerArgs {
  final double walletBalance;
  final double requiredTotal;
  final String walletAmountFormatted;
  final bool initialPayFromWallet;
  final String? initialSelectedCardId;

  const ContributePaymentPickerArgs({
    required this.walletBalance,
    required this.requiredTotal,
    required this.walletAmountFormatted,
    this.initialPayFromWallet = true,
    this.initialSelectedCardId,
  });

  bool get walletCoversTotal => walletBalance >= requiredTotal;
}
