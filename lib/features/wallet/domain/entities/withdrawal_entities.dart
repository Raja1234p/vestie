import 'package:equatable/equatable.dart';

enum WithdrawalApiType { standard, instant }

String withdrawalTypeToApi(WithdrawalApiType type) =>
    type == WithdrawalApiType.instant ? 'Instant' : 'Standard';

WithdrawalApiType withdrawalTypeFromDelivery(bool isInstant) =>
    isInstant ? WithdrawalApiType.instant : WithdrawalApiType.standard;

enum WithdrawalFlowStatus { processing, completed, failed }

WithdrawalFlowStatus withdrawalStatusFromApi(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
      return WithdrawalFlowStatus.completed;
    case 'failed':
      return WithdrawalFlowStatus.failed;
    default:
      return WithdrawalFlowStatus.processing;
  }
}

class WithdrawalPreviewEntity extends Equatable {
  final double amount;
  final String type;
  final double feePercent;
  final double feeAmount;
  final double youWillReceive;
  final String processingTime;
  final String destinationDisplay;
  final String currency;

  const WithdrawalPreviewEntity({
    required this.amount,
    required this.type,
    required this.feePercent,
    required this.feeAmount,
    required this.youWillReceive,
    required this.processingTime,
    required this.destinationDisplay,
    required this.currency,
  });

  @override
  List<Object?> get props => [
        amount,
        type,
        feePercent,
        feeAmount,
        youWillReceive,
        processingTime,
        destinationDisplay,
        currency,
      ];
}

class WithdrawalSubmitEntity extends Equatable {
  final String withdrawalId;
  final String status;
  final double amount;
  final double feeAmount;
  final double youWillReceive;
  final String processingTime;

  const WithdrawalSubmitEntity({
    required this.withdrawalId,
    required this.status,
    required this.amount,
    required this.feeAmount,
    required this.youWillReceive,
    required this.processingTime,
  });

  @override
  List<Object?> get props => [
        withdrawalId,
        status,
        amount,
        feeAmount,
        youWillReceive,
        processingTime,
      ];
}

class WithdrawalStatusEntity extends Equatable {
  final String withdrawalId;
  final WithdrawalFlowStatus status;
  final double amount;
  final double feeAmount;
  final double youWillReceive;
  final String type;
  final String? failureReason;

  const WithdrawalStatusEntity({
    required this.withdrawalId,
    required this.status,
    required this.amount,
    required this.feeAmount,
    required this.youWillReceive,
    required this.type,
    this.failureReason,
  });

  @override
  List<Object?> get props => [
        withdrawalId,
        status,
        amount,
        feeAmount,
        youWillReceive,
        type,
        failureReason,
      ];
}
