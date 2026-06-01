import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/wallet/domain/entities/withdrawal_entities.dart';
import 'package:vestie/features/wallet/domain/usecases/wallet_withdrawal_usecases.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';

class WalletWithdrawState extends Equatable {
  final bool isPreviewLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final WithdrawalPreviewEntity? preview;
  final Failure? failure;

  const WalletWithdrawState({
    this.isPreviewLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.preview,
    this.failure,
  });

  WalletWithdrawState copyWith({
    bool? isPreviewLoading,
    bool? isSubmitting,
    bool? isSuccess,
    WithdrawalPreviewEntity? preview,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return WalletWithdrawState(
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      preview: preview ?? this.preview,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props =>
      [isPreviewLoading, isSubmitting, isSuccess, preview, failure];
}

class WalletWithdrawCubit extends Cubit<WalletWithdrawState> {
  final PreviewWithdrawalUseCase previewWithdrawalUseCase;
  final RunWalletWithdrawUseCase runWalletWithdrawUseCase;

  WalletWithdrawCubit({
    required this.previewWithdrawalUseCase,
    required this.runWalletWithdrawUseCase,
  }) : super(const WalletWithdrawState());

  Future<void> loadPreview({
    required double amount,
    required WithdrawDeliveryMethod method,
  }) async {
    emit(state.copyWith(isPreviewLoading: true, clearFailure: true));
    final type = withdrawalTypeFromDelivery(
      method == WithdrawDeliveryMethod.instant,
    );
    final result = await previewWithdrawalUseCase(
      amount: amount,
      type: type,
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(isPreviewLoading: false, failure: f)),
      (preview) => emit(state.copyWith(
        isPreviewLoading: false,
        preview: preview,
        clearFailure: true,
      )),
    );
  }

  Future<void> submit({
    required double amount,
    required WithdrawDeliveryMethod method,
    required String bankAccountId,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearFailure: true, isSuccess: false));
    final type = withdrawalTypeFromDelivery(
      method == WithdrawDeliveryMethod.instant,
    );
    final result = await runWalletWithdrawUseCase(
      amount: amount,
      type: type,
      bankAccountId: bankAccountId,
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, failure: f)),
      (outcome) {
        if (outcome.status == WithdrawalFlowStatus.completed ||
            outcome.status == WithdrawalFlowStatus.processing) {
          emit(state.copyWith(isSubmitting: false, isSuccess: true));
        } else {
          emit(state.copyWith(
            isSubmitting: false,
            failure: ServerFailure(outcome.message ?? 'Withdrawal failed'),
          ));
        }
      },
    );
  }

  void reset() => emit(const WalletWithdrawState());
}
