import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../project_detail/domain/entities/project_detail_route_args.dart';

enum BorrowStep { amount, confirm, success }

class BorrowState {
  final ProjectWalletFlowArgs args;
  final BorrowStep step;
  final String amountDigits;
  final String note;
  final bool termsAccepted;

  const BorrowState({
    required this.args,
    this.step = BorrowStep.amount,
    this.amountDigits = '',
    this.note = '',
    this.termsAccepted = false,
  });

  BorrowState copyWith({
    BorrowStep? step,
    String? amountDigits,
    String? note,
    bool? termsAccepted,
  }) {
    return BorrowState(
      args: args,
      step: step ?? this.step,
      amountDigits: amountDigits ?? this.amountDigits,
      note: note ?? this.note,
      termsAccepted: termsAccepted ?? this.termsAccepted,
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
    emit(state.copyWith(step: BorrowStep.success));
  }
}
