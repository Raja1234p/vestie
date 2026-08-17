import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_processing_fee_entity.dart';
import 'package:vestie/features/stripe/domain/usecases/get_stripe_processing_fee_use_case.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_deposit_repository.dart';
import 'package:vestie/features/wallet/domain/usecases/run_wallet_deposit_use_case.dart';

class WalletDepositState extends Equatable {
  final bool isFeeLoading;
  final StripeProcessingFeeEntity? processingFee;
  final Failure? feeFailure;
  final bool isSubmitting;
  final bool isSuccess;
  final Failure? failure;
  final String? message;

  const WalletDepositState({
    this.isFeeLoading = false,
    this.processingFee,
    this.feeFailure,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.failure,
    this.message,
  });

  bool get canSubmit =>
      processingFee != null && !isFeeLoading && feeFailure == null;

  WalletDepositState copyWith({
    bool? isFeeLoading,
    StripeProcessingFeeEntity? processingFee,
    Failure? feeFailure,
    bool? isSubmitting,
    bool? isSuccess,
    Failure? failure,
    String? message,
    bool clearFailure = false,
    bool clearFeeFailure = false,
    bool clearProcessingFee = false,
  }) {
    return WalletDepositState(
      isFeeLoading: isFeeLoading ?? this.isFeeLoading,
      processingFee: clearProcessingFee
          ? null
          : (processingFee ?? this.processingFee),
      feeFailure: clearFeeFailure ? null : (feeFailure ?? this.feeFailure),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      failure: clearFailure ? null : (failure ?? this.failure),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        isFeeLoading,
        processingFee,
        feeFailure,
        isSubmitting,
        isSuccess,
        failure,
        message,
      ];
}

class WalletDepositCubit extends Cubit<WalletDepositState> {
  final RunWalletDepositUseCase runWalletDepositUseCase;
  final GetStripeProcessingFeeUseCase getStripeProcessingFeeUseCase;

  WalletDepositCubit({
    required this.runWalletDepositUseCase,
    required this.getStripeProcessingFeeUseCase,
  }) : super(const WalletDepositState());

  Future<void> loadProcessingFee({required double amount}) async {
    if (amount <= 0) return;
    emit(state.copyWith(
      isFeeLoading: true,
      clearFeeFailure: true,
      clearProcessingFee: true,
    ));

    final result = await getStripeProcessingFeeUseCase(amount: amount);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isFeeLoading: false,
        feeFailure: failure,
        clearProcessingFee: true,
      )),
      (fee) => emit(state.copyWith(
        isFeeLoading: false,
        processingFee: fee,
        clearFeeFailure: true,
      )),
    );
  }

  Future<void> submitDeposit({
    required double amount,
    required String paymentMethodId,
  }) async {
    if (amount <= 0 || !state.canSubmit) return;
    emit(state.copyWith(isSubmitting: true, clearFailure: true, isSuccess: false));

    final result = await runWalletDepositUseCase(
      amount: amount,
      paymentMethodId: paymentMethodId,
    );

    if (isClosed) return;

    await result.fold<Future<void>>(
      (failure) async {
        emit(state.copyWith(
          isSubmitting: false,
          failure: failure,
        ));
      },
      (outcome) async {
        switch (outcome.result) {
          case DepositFlowResult.completed:
            var fee = state.processingFee;
            final paymentIntentId = outcome.paymentIntentId?.trim() ?? '';
            if (paymentIntentId.isNotEmpty) {
              final actual = await getStripeProcessingFeeUseCase(
                paymentIntentId: paymentIntentId,
              );
              if (isClosed) return;
              actual.fold((_) {}, (resolved) => fee = resolved);
            }
            emit(state.copyWith(
              isSubmitting: false,
              isSuccess: true,
              processingFee: fee,
            ));
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

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  void reset() => emit(const WalletDepositState());
}
