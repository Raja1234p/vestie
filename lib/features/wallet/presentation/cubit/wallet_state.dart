import 'package:equatable/equatable.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';

class WalletState extends Equatable {
  final bool isLoading;
  final WalletEntity? wallet;
  final List<Transaction> recentActivity;
  final Failure? failure;

  const WalletState({
    this.isLoading = false,
    this.wallet,
    this.recentActivity = const [],
    this.failure,
  });

  bool get hasLoadError => failure != null && wallet == null && !isLoading;

  String get walletAmountFormatted {
    final balance = wallet?.availableBalance;
    if (balance == null) return r'$—';
    return _formatUsd(balance);
  }

  String get borrowedAmountFormatted {
    final borrowed = wallet?.borrowedBalance;
    if (borrowed == null) return r'$—';
    return _formatUsd(borrowed);
  }

  WalletState copyWith({
    bool? isLoading,
    WalletEntity? wallet,
    List<Transaction>? recentActivity,
    Failure? failure,
    bool clearFailure = false,
    bool clearWallet = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      wallet: clearWallet ? null : (wallet ?? this.wallet),
      recentActivity: recentActivity ?? this.recentActivity,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  static String _formatUsd(double amount) => AppFormatters.formatCurrency(amount);

  @override
  List<Object?> get props => [isLoading, wallet, recentActivity, failure];
}
