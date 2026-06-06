import 'package:flutter_bloc/flutter_bloc.dart';

/// Whole-dollar amount entry for modal sheets (create project, distribute funds).
class AmountEntryState {
  final String amountDigits;

  const AmountEntryState({this.amountDigits = ''});

  double get amountUsd =>
      amountDigits.isEmpty ? 0 : (int.tryParse(amountDigits) ?? 0).toDouble();

  String get formattedAmount {
    final intPart = amountUsd.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$intPart.00';
  }

  AmountEntryState copyWith({String? amountDigits}) =>
      AmountEntryState(amountDigits: amountDigits ?? this.amountDigits);
}

class AmountEntryCubit extends Cubit<AmountEntryState> {
  AmountEntryCubit() : super(const AmountEntryState());

  void appendAmountDigit(String d) {
    if (state.amountDigits.isEmpty && d == '0') return;
    if (state.amountDigits.length >= 7) return;
    emit(state.copyWith(amountDigits: state.amountDigits + d));
  }

  void removeAmountDigit() {
    if (state.amountDigits.isEmpty) return;
    emit(
      state.copyWith(
        amountDigits: state.amountDigits.substring(
          0,
          state.amountDigits.length - 1,
        ),
      ),
    );
  }

  void reset() => emit(const AmountEntryState());
}
