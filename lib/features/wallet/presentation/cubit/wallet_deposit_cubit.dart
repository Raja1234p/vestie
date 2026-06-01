import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_deposit_repository.dart';
import 'package:vestie/features/wallet/domain/usecases/run_wallet_deposit_use_case.dart';

class WalletDepositState extends Equatable {
  final bool isSubmitting;
  final bool isSuccess;
  final Failure? failure;
  final String? message;

  const WalletDepositState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.failure,
    this.message,
  });

  WalletDepositState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    Failure? failure,
    String? message,
    bool clearFailure = false,
  }) {
    return WalletDepositState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      failure: clearFailure ? null : (failure ?? this.failure),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, failure, message];
}

class WalletDepositCubit extends Cubit<WalletDepositState> {
  final RunWalletDepositUseCase runWalletDepositUseCase;

  WalletDepositCubit({required this.runWalletDepositUseCase})
      : super(const WalletDepositState());

  Future<void> submitDeposit(double amount) async {
    if (amount <= 0) return;
    emit(state.copyWith(isSubmitting: true, clearFailure: true, isSuccess: false));

    final result = await runWalletDepositUseCase(amount);

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        failure: failure,
      )),
      (outcome) {
        switch (outcome.result) {
          case DepositFlowResult.completed:
            emit(state.copyWith(isSubmitting: false, isSuccess: true));
          case DepositFlowResult.cancelled:
            emit(state.copyWith(
              isSubmitting: false,
              failure: ServerFailure(outcome.message ?? 'Deposit cancelled'),
            ));
          case DepositFlowResult.failed:
          case DepositFlowResult.timeout:
            emit(state.copyWith(
              isSubmitting: false,
              failure: ServerFailure(outcome.message ?? 'Deposit failed'),
              message: outcome.message,
            ));
        }
      },
    );
  }

  void reset() => emit(const WalletDepositState());
}
