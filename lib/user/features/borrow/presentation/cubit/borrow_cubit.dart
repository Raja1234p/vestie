import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';

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
  BorrowCubit(ProjectWalletFlowArgs args) : super(BorrowState(args: args));

  /// Cent digits from the system numeric keyboard ([AppStackedCurrencyField]).
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

  /// UI-only submit — skips `POST /projects/{id}/borrow-requests` until API is wired.
  Future<void> _submitBorrowRequest() async {
    emit(state.copyWith(loading: true, clearError: true));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;
    emit(state.copyWith(loading: false, step: BorrowStep.success));
  }
}
