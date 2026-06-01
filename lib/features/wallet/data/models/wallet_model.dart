import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';

class WalletRecentTransactionModel extends WalletRecentTransactionEntity {
  const WalletRecentTransactionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.amount,
    required super.direction,
    super.dateUtc,
  });

  factory WalletRecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletRecentTransactionModel(
      id: json.safeString('id'),
      type: json.safeString('type'),
      title: json.safeString('title'),
      amount: json.safeDouble('amount'),
      direction: json.safeString('direction', defaultValue: 'Debit'),
      dateUtc: _parseDate(json['date'] ?? json['createdAtUtc']),
    );
  }
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  return DateTime.tryParse(raw.toString());
}

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.walletId,
    required super.currency,
    required super.walletBalance,
    required super.availableBalance,
    required super.borrowedBalance,
    super.borrowed,
    super.lockedInProjects,
    super.pendingWithdrawal,
    super.recentTransactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final txs = (json['recentTransactions'] as List<dynamic>?)
            ?.whereType<Map>()
            .map(
              (e) => WalletRecentTransactionModel.fromJson(
                e.cast<String, dynamic>(),
              ),
            )
            .toList(growable: false) ??
        const <WalletRecentTransactionModel>[];

    return WalletModel(
      walletId: json.safeString('walletId'),
      currency: json.safeString('currency', defaultValue: 'USD'),
      walletBalance: json.safeDouble('walletBalance'),
      availableBalance: json.safeDouble('availableBalance'),
      borrowedBalance: json.safeDouble('borrowedBalance'),
      borrowed: json.safeDouble('borrowed'),
      lockedInProjects: json.safeDouble('lockedInProjects'),
      pendingWithdrawal: json.safeDouble('pendingWithdrawal'),
      recentTransactions: txs,
    );
  }

  WalletEntity toEntity() => WalletEntity(
        walletId: walletId,
        currency: currency,
        walletBalance: walletBalance,
        availableBalance: availableBalance,
        borrowedBalance: borrowedBalance,
        borrowed: borrowed,
        lockedInProjects: lockedInProjects,
        pendingWithdrawal: pendingWithdrawal,
        recentTransactions: recentTransactions,
      );
}
