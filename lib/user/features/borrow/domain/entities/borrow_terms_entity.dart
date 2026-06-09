class BorrowTermsEntity {
  final double amount;
  final String currency;
  final String dueByDisplay;
  final double penaltyPercentage;
  final String penaltyIfMissedDisplay;
  final String penaltyAppliesDisplay;
  final String agreementText;
  final bool canBorrow;

  const BorrowTermsEntity({
    required this.amount,
    required this.currency,
    required this.dueByDisplay,
    required this.penaltyPercentage,
    required this.penaltyIfMissedDisplay,
    required this.penaltyAppliesDisplay,
    required this.agreementText,
    required this.canBorrow,
  });
}
