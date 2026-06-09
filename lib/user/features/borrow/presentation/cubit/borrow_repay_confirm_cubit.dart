import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/utils/idempotency_key.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';
import 'package:vestie/user/features/borrow/domain/usecases/submit_borrow_repayment_use_case.dart';
import 'package:vestie/user/features/borrow/presentation/navigation/borrow_project_detail_sync.dart';

class BorrowRepayConfirmState {
  final bool submitting;
  final String? errorMessage;

  const BorrowRepayConfirmState({
    this.submitting = false,
    this.errorMessage,
  });

  BorrowRepayConfirmState copyWith({
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BorrowRepayConfirmState(
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BorrowRepayConfirmCubit extends Cubit<BorrowRepayConfirmState> {
  final String projectId;
  final String borrowRequestId;
  final String paymentSourceType;
  final String? paymentMethodId;
  final SubmitBorrowRepaymentUseCase _submitUseCase;
  final String _idempotencyKey = newIdempotencyKey('repay');

  BorrowRepayConfirmCubit({
    required this.projectId,
    required this.borrowRequestId,
    required this.paymentSourceType,
    this.paymentMethodId,
    required SubmitBorrowRepaymentUseCase submitUseCase,
  }) : _submitUseCase = submitUseCase,
       super(const BorrowRepayConfirmState());

  Future<BorrowRepaymentResultEntity?> submit() async {
    if (state.submitting) return null;
    emit(state.copyWith(submitting: true, clearError: true));

    final result = await _submitUseCase(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      paymentSourceType: paymentSourceType,
      paymentMethodId: paymentMethodId,
      idempotencyKey: _idempotencyKey,
    );

    if (isClosed) return null;

    return result.fold<Future<BorrowRepaymentResultEntity?>>(
      (failure) async {
        emit(
          state.copyWith(
            submitting: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
        return null;
      },
      (success) async {
        WalletBalanceCache.clear();
        await BorrowProjectDetailSync.reloadBeforeSuccess(projectId);
        if (isClosed) return null;
        emit(state.copyWith(submitting: false));
        return success;
      },
    );
  }
}
