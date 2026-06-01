import 'package:equatable/equatable.dart';

class WalletRecentTransactionEntity extends Equatable {
  final String id;
  final String type;
  final String title;
  final double amount;
  final String direction;
  final DateTime? dateUtc;

  const WalletRecentTransactionEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.direction,
    this.dateUtc,
  });

  bool get isDebit => direction.toLowerCase() == 'debit';

  @override
  List<Object?> get props => [id, type, title, amount, direction, dateUtc];
}

class WalletEntity extends Equatable {
  final String walletId;
  final String currency;
  final double walletBalance;
  final double availableBalance;
  final double borrowedBalance;
  final double borrowed;
  final double lockedInProjects;
  final double pendingWithdrawal;
  final List<WalletRecentTransactionEntity> recentTransactions;

  const WalletEntity({
    required this.walletId,
    required this.currency,
    required this.walletBalance,
    required this.availableBalance,
    required this.borrowedBalance,
    this.borrowed = 0,
    this.lockedInProjects = 0,
    this.pendingWithdrawal = 0,
    this.recentTransactions = const [],
  });

  @override
  List<Object?> get props => [
        walletId,
        currency,
        walletBalance,
        availableBalance,
        borrowedBalance,
        borrowed,
        lockedInProjects,
        pendingWithdrawal,
        recentTransactions,
      ];
}
