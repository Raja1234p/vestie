import 'package:equatable/equatable.dart';
import '../../domain/entities/contribution_preview_entity.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';

enum ContributeStep { amount, confirm, success }

class ContributeState extends Equatable {
  final ProjectWalletFlowArgs? args;
  final ContributeStep step;
  final String amountDigits;
  final bool nonRefundableAccepted;
  final bool isPreviewLoading;
  final bool isSubmitLoading;
  final bool isConfigLoading;
  final String selectedWalletId;
  final ContributionPreviewEntity? preview;
  final Failure? previewFailure;
  final Failure? submitFailure;
  final bool isSubmitSuccess;

  const ContributeState({
    this.args,
    this.step = ContributeStep.amount,
    this.amountDigits = '',
    this.nonRefundableAccepted = false,
    this.isPreviewLoading = false,
    this.isSubmitLoading = false,
    this.isConfigLoading = false,
    this.selectedWalletId = '',
    this.preview,
    this.previewFailure,
    this.submitFailure,
    this.isSubmitSuccess = false,
  });

  ContributeState copyWith({
    ProjectWalletFlowArgs? args,
    ContributeStep? step,
    String? amountDigits,
    bool? nonRefundableAccepted,
    bool? isPreviewLoading,
    bool? isSubmitLoading,
    bool? isConfigLoading,
    String? selectedWalletId,
    ContributionPreviewEntity? preview,
    Failure? previewFailure,
    Failure? submitFailure,
    bool? isSubmitSuccess,
    bool clearPreviewFailure = false,
    bool clearSubmitFailure = false,
    bool clearPreview = false,
  }) {
    return ContributeState(
      args: args ?? this.args,
      step: step ?? this.step,
      amountDigits: amountDigits ?? this.amountDigits,
      nonRefundableAccepted: nonRefundableAccepted ?? this.nonRefundableAccepted,
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
      isSubmitLoading: isSubmitLoading ?? this.isSubmitLoading,
      isConfigLoading: isConfigLoading ?? this.isConfigLoading,
      selectedWalletId: selectedWalletId ?? this.selectedWalletId,
      preview: clearPreview ? null : (preview ?? this.preview),
      previewFailure: clearPreviewFailure ? null : (previewFailure ?? this.previewFailure),
      submitFailure: clearSubmitFailure ? null : (submitFailure ?? this.submitFailure),
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
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

  double get vestieFee => preview?.platformFee ?? (amountValue * 0.03);
  String get vestieFeeFormatted => vestieFee.toStringAsFixed(2);
  String get totalDeductionFormatted =>
      (preview?.totalDeduction ?? (amountValue + vestieFee)).toStringAsFixed(2);

  bool get canSubmit => preview != null && !isPreviewLoading && previewFailure == null;

  @override
  List<Object?> get props => [
        args,
        step,
        amountDigits,
        nonRefundableAccepted,
        isPreviewLoading,
        isSubmitLoading,
        isConfigLoading,
        selectedWalletId,
        preview,
        previewFailure,
        submitFailure,
        isSubmitSuccess,
      ];
}
