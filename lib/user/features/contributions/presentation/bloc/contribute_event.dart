import 'package:equatable/equatable.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';

abstract class ContributeEvent extends Equatable {
  const ContributeEvent();

  @override
  List<Object?> get props => [];
}

class InitArgsEvent extends ContributeEvent {
  final ProjectWalletFlowArgs args;
  const InitArgsEvent({required this.args});
  @override
  List<Object?> get props => [args];
}

class DigitsChangedEvent extends ContributeEvent {
  final String digits;
  const DigitsChangedEvent({required this.digits});
  @override
  List<Object?> get props => [digits];
}

class SetNonRefundableEvent extends ContributeEvent {
  final bool accepted;
  const SetNonRefundableEvent({required this.accepted});
  @override
  List<Object?> get props => [accepted];
}

class BackToAmountEvent extends ContributeEvent {}

class GoToConfirmEvent extends ContributeEvent {}

class AmountChangedEvent extends ContributeEvent {
  final String projectId;
  final double amount;

  const AmountChangedEvent({required this.projectId, required this.amount});

  @override
  List<Object?> get props => [projectId, amount];
}

class ConfirmSubmitEvent extends ContributeEvent {
  final String projectId;
  final double amount;
  final String walletId;

  const ConfirmSubmitEvent({
    required this.projectId,
    required this.amount,
    required this.walletId,
  });

  @override
  List<Object?> get props => [projectId, amount, walletId];
}
