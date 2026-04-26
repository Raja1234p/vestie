/// Contribute / borrow wallet flow route args.
///
/// Kept under app router args to avoid coupling borrow/contribute features to
/// project_detail domain entities.
class ProjectWalletFlowArgs {
  final String projectId;
  final String projectName;
  final double walletBalance;
  final double borrowLimit;
  final String borrowDueByLabel;

  static const double defaultWallet = 2400.0;
  static const double defaultBorrowLimit = 250.0;

  const ProjectWalletFlowArgs({
    required this.projectId,
    required this.projectName,
    this.walletBalance = defaultWallet,
    this.borrowLimit = defaultBorrowLimit,
    this.borrowDueByLabel = 'May 1, 2025 (30 days)',
  });

  String get walletAmountFormatted {
    return walletBalance
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }
}

