import 'package:vestie/core/utils/formatters.dart';

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
  final String? membershipId;

  static const double defaultWallet = 2400.0;
  static const double defaultBorrowLimit = 250.0;
  static const String defaultBorrowDueByLabel = 'May 1, 2025 (30 days)';

  const ProjectWalletFlowArgs({
    required this.projectId,
    required this.projectName,
    this.walletBalance = defaultWallet,
    this.borrowLimit = defaultBorrowLimit,
    this.borrowDueByLabel = defaultBorrowDueByLabel,
    this.membershipId,
  });

  String get walletAmountFormatted =>
      AppFormatters.formatMoneyAmount(walletBalance);

  ProjectWalletFlowArgs copyWithWalletBalance(double balance) {
    return ProjectWalletFlowArgs(
      projectId: projectId,
      projectName: projectName,
      walletBalance: balance,
      borrowLimit: borrowLimit,
      borrowDueByLabel: borrowDueByLabel,
      membershipId: membershipId,
    );
  }
}

