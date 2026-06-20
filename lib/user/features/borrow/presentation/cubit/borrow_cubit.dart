import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/utils/idempotency_key.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_terms_entity.dart';
import 'package:vestie/user/features/borrow/domain/usecases/create_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_borrow_terms_use_case.dart';
import 'package:vestie/user/features/borrow/presentation/navigation/borrow_project_detail_sync.dart';

enum BorrowStep { amount, confirm, success }

class BorrowState {
  final ProjectWalletFlowArgs args;
  final BorrowStep step;
  final String amountDigits;
  final String note;
  final bool termsAccepted;
  final bool loading;
  final String? errorMessage;
  final BorrowTermsEntity? terms;
  final String? successMessage;
  final String? submitIdempotencyKey;

  const BorrowState({
    required this.args,
    this.step = BorrowStep.amount,
    this.amountDigits = '',
    this.note = '',
    this.termsAccepted = false,
    this.loading = false,
    this.errorMessage,
    this.terms,
    this.successMessage,
    this.submitIdempotencyKey,
  });

  BorrowState copyWith({
    BorrowStep? step,
    String? amountDigits,
    String? note,
    bool? termsAccepted,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    BorrowTermsEntity? terms,
    bool clearTerms = false,
    String? successMessage,
    String? submitIdempotencyKey,
    bool clearSubmitIdempotencyKey = false,
  }) {
    return BorrowState(
      args: args,
      step: step ?? this.step,
      amountDigits: amountDigits ?? this.amountDigits,
      note: note ?? this.note,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      terms: clearTerms ? null : (terms ?? this.terms),
      successMessage: successMessage ?? this.successMessage,
      submitIdempotencyKey: clearSubmitIdempotencyKey
          ? null
          : (submitIdempotencyKey ?? this.submitIdempotencyKey),
    );
  }

  double get amountValue {
    if (amountDigits.isEmpty) return 0;
    return int.parse(amountDigits) / 100.0;
  }

  String get amountFormatted {
    if (amountDigits.isEmpty) return '0.00';
    return amountValue.toStringAsFixed(2);
  }

  String get displayDollar => '\$$amountFormatted';
  String get borrowLimitFormatted => args.borrowLimit
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  String get dueByLabel => terms?.dueByDisplay ?? args.borrowDueByLabel;

  String get penaltyIfMissedLabel =>
      terms?.penaltyIfMissedDisplay ?? AppStrings.penaltyValuePercent;

  String get penaltyAppliesLabel =>
      terms?.penaltyAppliesDisplay ?? AppStrings.penaltyValueOneTime;

  String get agreementText =>
      terms?.agreementText ??
      AppStrings.borrowAgreementFallback(displayDollar, args.borrowDueByLabel);
}

class BorrowCubit extends Cubit<BorrowState> {
  final GetBorrowTermsUseCase _getBorrowTermsUseCase;
  final CreateBorrowRequestUseCase _createBorrowRequestUseCase;

  BorrowCubit(
    ProjectWalletFlowArgs args, {
    required GetBorrowTermsUseCase getBorrowTermsUseCase,
    required CreateBorrowRequestUseCase createBorrowRequestUseCase,
  }) : _getBorrowTermsUseCase = getBorrowTermsUseCase,
       _createBorrowRequestUseCase = createBorrowRequestUseCase,
       super(BorrowState(args: args));

  void setAmountDigits(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length > 8) d = d.substring(0, 8);
    while (d.length > 1 && d.startsWith('0')) {
      d = d.substring(1);
    }
    if (d.length == 1 && d == '0') d = '';
    emit(state.copyWith(amountDigits: d, clearTerms: true));
  }

  void setNote(String n) {
    emit(state.copyWith(note: n));
  }

  void setTermsAccepted(bool v) {
    emit(state.copyWith(termsAccepted: v));
  }

  Future<void> toConfirm() async {
    if (state.amountValue <= 0) return;

    emit(state.copyWith(loading: true, clearError: true));

    final result = await _getBorrowTermsUseCase(
      projectId: state.args.projectId,
      amount: state.amountValue,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (terms) {
        if (!terms.canBorrow) {
          emit(
            state.copyWith(
              loading: false,
              errorMessage: AppStrings.borrowCannotBorrowNow,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            loading: false,
            step: BorrowStep.confirm,
            terms: terms,
            termsAccepted: false,
            submitIdempotencyKey: newIdempotencyKey('borrow'),
            clearError: true,
          ),
        );
      },
    );
  }

  void backToAmount() {
    emit(
      state.copyWith(
        step: BorrowStep.amount,
        clearTerms: true,
        clearSubmitIdempotencyKey: true,
        clearError: true,
      ),
    );
  }

  void submit() {
    if (!state.termsAccepted || state.loading) return;
    _submitBorrowRequest();
  }

  Future<void> _submitBorrowRequest() async {
    if (state.loading) return;

    final idempotencyKey =
        state.submitIdempotencyKey ?? newIdempotencyKey('borrow');
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        submitIdempotencyKey: idempotencyKey,
      ),
    );

    final result = await _createBorrowRequestUseCase(
      projectId: state.args.projectId,
      amount: state.amountValue,
      reason: state.note.trim().isEmpty
          ? AppStrings.borrowDefaultReason
          : state.note.trim(),
      idempotencyKey: idempotencyKey,
    );

    if (isClosed) return;

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            loading: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
      },
      (_) async {
        await BorrowProjectDetailSync.reloadBeforeSuccess(state.args.projectId);
        if (isClosed) return;
        emit(state.copyWith(loading: false, step: BorrowStep.success));
      },
    );
  }
}
