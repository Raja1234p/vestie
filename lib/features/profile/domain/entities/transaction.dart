enum TransactionType { deposit, contribution, borrow, lend, withdrawal }

class Transaction {
  final String id;
  final String title;
  final String date;
  final double amount; // positive = incoming, negative = outgoing
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  bool get isPositive => amount >= 0;

  String get formattedAmount {
    final prefix = isPositive ? '+' : '';
    return '$prefix\$${amount.abs().toStringAsFixed(0)}';
  }

  /// Filter category mapping
  bool get isDeposit      => type == TransactionType.deposit || type == TransactionType.borrow;
  bool get isWithdrawal   => type == TransactionType.lend || type == TransactionType.withdrawal;
  bool get isContribution => type == TransactionType.contribution;
}
