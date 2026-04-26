import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_args/project_wallet_flow_args.dart';

enum ContributeStep { amount, confirm, success }

class ContributeState {
  final ProjectWalletFlowArgs args;
  final ContributeStep step;
  final String amountDigits;
  final bool nonRefundableAccepted;

  const ContributeState({
    required this.args,
    this.step = ContributeStep.amount,
    this.amountDigits = '',
    this.nonRefundableAccepted = false,
  });

  ContributeState copyWith({
    ContributeStep? step,
    String? amountDigits,
    bool? nonRefundableAccepted,
  }) {
    return ContributeState(
      args: args,
      step: step ?? this.step,
      amountDigits: amountDigits ?? this.amountDigits,
      nonRefundableAccepted:
          nonRefundableAccepted ?? this.nonRefundableAccepted,
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

  String get displayAmountDollar => '\$$amountFormatted';

  double get vestieFee => amountValue * 0.03;
  String get vestieFeeFormatted => vestieFee.toStringAsFixed(2);
  String get totalDeductionFormatted => (amountValue + vestieFee).toStringAsFixed(2);
}

class ContributeCubit extends Cubit<ContributeState> {
  ContributeCubit(ProjectWalletFlowArgs args)
      : super(ContributeState(args: args));

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

  void setAmountDigits(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length > 8) d = d.substring(0, 8);
    while (d.length > 1 && d.startsWith('0')) {
      d = d.substring(1);
    }
    if (d.length == 1 && d == '0') d = '';
    emit(state.copyWith(amountDigits: d));
  }

  void toConfirm() {
    if (state.amountValue <= 0) return;
    emit(state.copyWith(step: ContributeStep.confirm));
  }

  void backToAmount() {
    emit(state.copyWith(step: ContributeStep.amount));
  }

  void setNonRefundable(bool v) {
    emit(state.copyWith(nonRefundableAccepted: v));
  }

  void toSuccess() {
    if (!state.nonRefundableAccepted) return;
    emit(state.copyWith(step: ContributeStep.success));
  }
}
