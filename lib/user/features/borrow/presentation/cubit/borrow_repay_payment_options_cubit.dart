import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_borrow_repay_payment_options_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_borrow_repay_preview_use_case.dart';

class BorrowRepayPaymentOptionsState {
  final bool loading;
  final bool selecting;
  final BorrowRepayPaymentOptionsEntity? options;
  final String? errorMessage;

  const BorrowRepayPaymentOptionsState({
    this.loading = false,
    this.selecting = false,
    this.options,
    this.errorMessage,
  });

  bool get loadFailed =>
      errorMessage != null && !loading && options == null;

  BorrowRepayPaymentOptionsState copyWith({
    bool? loading,
    bool? selecting,
    BorrowRepayPaymentOptionsEntity? options,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BorrowRepayPaymentOptionsState(
      loading: loading ?? this.loading,
      selecting: selecting ?? this.selecting,
      options: options ?? this.options,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BorrowRepayPaymentOptionsCubit extends Cubit<BorrowRepayPaymentOptionsState> {
  final String projectId;
  final String borrowRequestId;
  final GetBorrowRepayPaymentOptionsUseCase _getPaymentOptionsUseCase;
  final GetBorrowRepayPreviewUseCase _getPreviewUseCase;
  BorrowRepayPaymentOptionsCubit({
    required this.projectId,
    required this.borrowRequestId,
    required GetBorrowRepayPaymentOptionsUseCase getPaymentOptionsUseCase,
    required GetBorrowRepayPreviewUseCase getPreviewUseCase,
    BorrowRepayPaymentOptionsEntity? preloadedOptions,
  }) : _getPaymentOptionsUseCase = getPaymentOptionsUseCase,
       _getPreviewUseCase = getPreviewUseCase,
       super(
         BorrowRepayPaymentOptionsState(
           loading: preloadedOptions == null,
           options: preloadedOptions,
         ),
       ) {
    if (preloadedOptions == null) {
      load();
    }
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));

    final result = await _getPaymentOptionsUseCase(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (options) => emit(
        BorrowRepayPaymentOptionsState(loading: false, options: options),
      ),
    );
  }

  Future<BorrowRepayPreviewEntity?> selectWallet() {
    return _loadPreview(paymentSourceType: 'Wallet');
  }

  Future<BorrowRepayPreviewEntity?> selectCard(String paymentMethodId) {
    return _loadPreview(
      paymentSourceType: 'Card',
      paymentMethodId: paymentMethodId,
    );
  }

  Future<BorrowRepayPreviewEntity?> _loadPreview({
    required String paymentSourceType,
    String? paymentMethodId,
  }) async {
    if (state.selecting) return null;
    emit(state.copyWith(selecting: true, clearError: true));

    final result = await _getPreviewUseCase(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      paymentSourceType: paymentSourceType,
      paymentMethodId: paymentMethodId,
    );

    if (isClosed) return null;

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            selecting: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
        return null;
      },
      (preview) {
        emit(state.copyWith(selecting: false));
        return preview;
      },
    );
  }
}
