import 'package:vestie/core/network/api_response_body.dart';
import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/wallet/domain/entities/withdrawal_entities.dart';

class WithdrawalPreviewModel extends WithdrawalPreviewEntity {
  const WithdrawalPreviewModel({
    required super.amount,
    required super.type,
    required super.feePercent,
    required super.feeAmount,
    required super.youWillReceive,
    required super.processingTime,
    required super.destinationDisplay,
    required super.currency,
  });

  factory WithdrawalPreviewModel.fromJson(Map<String, dynamic> json) {
    final body = unwrapApiResponseBody(json);
    return WithdrawalPreviewModel(
      amount: body.safeDouble('amount'),
      type: body.safeString('type'),
      feePercent: body.safeDouble('feePercent'),
      feeAmount: body.safeDouble('feeAmount'),
      youWillReceive: body.safeDouble('youWillReceive'),
      processingTime: body.safeString('processingTime'),
      destinationDisplay: body.safeString('destinationDisplay'),
      currency: body.safeString('currency', defaultValue: 'USD'),
    );
  }
}

class WithdrawalSubmitModel extends WithdrawalSubmitEntity {
  const WithdrawalSubmitModel({
    required super.withdrawalId,
    required super.status,
    required super.amount,
    required super.feeAmount,
    required super.youWillReceive,
    required super.processingTime,
  });

  factory WithdrawalSubmitModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalSubmitModel(
      withdrawalId: json.safeString('withdrawalId'),
      status: json.safeString('status'),
      amount: json.safeDouble('amount'),
      feeAmount: json.safeDouble('feeAmount'),
      youWillReceive: json.safeDouble('youWillReceive'),
      processingTime: json.safeString('processingTime'),
    );
  }
}

class WithdrawalStatusModel extends WithdrawalStatusEntity {
  const WithdrawalStatusModel({
    required super.withdrawalId,
    required super.status,
    required super.amount,
    required super.feeAmount,
    required super.youWillReceive,
    required super.type,
    super.failureReason,
  });

  factory WithdrawalStatusModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalStatusModel(
      withdrawalId: json.safeString('withdrawalId'),
      status: withdrawalStatusFromApi(json.safeString('status')),
      amount: json.safeDouble('amount'),
      feeAmount: json.safeDouble('feeAmount'),
      youWillReceive: json.safeDouble('youWillReceive'),
      type: json.safeString('type'),
      failureReason: json.safeStringNullable('failureReason'),
    );
  }
}
