import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_args/project_wallet_flow_args.dart';
import '../../../../core/di/service_locator.dart';
import '../../../borrow/domain/usecases/create_borrow_request_use_case.dart';

enum BorrowStep { amount, confirm, success }

class BorrowState {
  final ProjectWalletFlowArgs args;
  final BorrowStep step;
  final String amountDigits;
  final String note;
  final bool termsAccepted;
  final bool loading;
  final String? errorMessage;

  const BorrowState({
    required this.args,
    this.step = BorrowStep.amount,
    this.amountDigits = '',
    this.note = '',
    this.termsAccepted = false,
    this.loading = false,
    this.errorMessage,
  });

  BorrowState copyWith({
    BorrowStep? step,
    String? amountDigits,
    String? note,
    bool? termsAccepted,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BorrowState(
      args: args,
      step: step ?? this.step,
      amountDigits: amountDigits ?? this.amountDigits,
      note: note ?? this.note,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
}

class BorrowCubit extends Cubit<BorrowState> {
  final CreateBorrowRequestUseCase _createBorrowRequestUseCase;

  BorrowCubit(
    ProjectWalletFlowArgs args, {
    CreateBorrowRequestUseCase? createBorrowRequestUseCase,
  })  : _createBorrowRequestUseCase = createBorrowRequestUseCase ??
            ServiceLocator.instance.createBorrowRequestUseCase,
        super(BorrowState(args: args));

  void appendDigit(String d) {
    if (state.amountDigits.length >= 8) return;
    if (state.amountDigits.isEmpty && d == '0') return;
    emit(state.copyWith(amountDigits: state.amountDigits + d));
  }

  void removeDigit() {
    if (state.amountDigits.isEmpty) return;
    emit(state.copyWith(
      amountDigits:
          state.amountDigits.substring(0, state.amountDigits.length - 1),
    ));
  }

  /// Raw cent digits (same as [appendDigit] chain) — used for Android system keyboard.
  void setAmountDigits(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length > 8) d = d.substring(0, 8);
    while (d.length > 1 && d.startsWith('0')) {
      d = d.substring(1);
    }
    if (d.length == 1 && d == '0') d = '';
    emit(state.copyWith(amountDigits: d));
  }

  void setNote(String n) {
    emit(state.copyWith(note: n));
  }

  void setTermsAccepted(bool v) {
    emit(state.copyWith(termsAccepted: v));
  }

  void toConfirm() {
    if (state.amountValue <= 0) return;
    if (state.amountValue > state.args.borrowLimit) return;
    emit(state.copyWith(step: BorrowStep.confirm));
  }

  void backToAmount() {
    emit(state.copyWith(step: BorrowStep.amount));
  }

  void submit() {
    if (!state.termsAccepted) return;
    _submitBorrowRequest();
  }

  Future<void> _submitBorrowRequest() async {
    final membershipId = state.args.membershipId;
    if (membershipId == null || membershipId.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Missing membership id. Please reopen project.',
      ));
      return;
    }

    emit(state.copyWith(loading: true, clearError: true));
    final result = await _createBorrowRequestUseCase(
      projectId: state.args.projectId,
      amount: state.amountValue,
      reason: state.note.trim(),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        loading: false,
        step: BorrowStep.success,
      )),
    );
  }
}
