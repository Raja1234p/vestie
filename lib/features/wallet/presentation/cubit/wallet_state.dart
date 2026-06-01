import 'package:equatable/equatable.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';

class WalletState extends Equatable {
  final bool isLoading;
  final WalletEntity? wallet;
  final List<Transaction> recentActivity;
  final Failure? failure;
  final bool usedFallbackDisplay;

  const WalletState({
    this.isLoading = false,
    this.wallet,
    this.recentActivity = const [],
    this.failure,
    this.usedFallbackDisplay = false,
  });

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

  bool get hasPendingWithdrawal =>
      wallet != null && wallet!.pendingWithdrawal > 0;

  String get pendingWithdrawalFormatted {
    final pending = wallet?.pendingWithdrawal;
    if (pending == null) return r'$—';
    return _formatUsd(pending);
  }

  WalletState copyWith({
    bool? isLoading,
    WalletEntity? wallet,
    List<Transaction>? recentActivity,
    Failure? failure,
    bool? usedFallbackDisplay,
    bool clearFailure = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      wallet: wallet ?? this.wallet,
      recentActivity: recentActivity ?? this.recentActivity,
      failure: clearFailure ? null : (failure ?? this.failure),
      usedFallbackDisplay: usedFallbackDisplay ?? this.usedFallbackDisplay,
    );
  }

  static String _formatUsd(double amount) {
    final fixed = amount.toStringAsFixed(0);
    return '\$$fixed';
  }

  @override
  List<Object?> get props => [
        isLoading,
        wallet,
        recentActivity,
        failure,
        usedFallbackDisplay,
      ];
}
