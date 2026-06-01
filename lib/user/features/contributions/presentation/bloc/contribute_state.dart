import 'package:equatable/equatable.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/contribution_fee_policy.dart';
import '../../domain/entities/contribution_preview_entity.dart';
import 'package:vestie/app/router/route_args/project_wallet_flow_args.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/user/features/contributions/data/models/contribution_submit_result_model.dart';

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
  final PaymentCard? selectedCard;
  final bool payFromWallet;
  final ContributionPreviewEntity? preview;
  final Failure? previewFailure;
  final Failure? submitFailure;
  final bool isSubmitSuccess;
  final ContributionSubmitResultModel? submitResult;

  const ContributeState({
    this.args,
    this.step = ContributeStep.amount,
    this.amountDigits = '',
    this.nonRefundableAccepted = false,
    this.isPreviewLoading = false,
    this.isSubmitLoading = false,
    this.isConfigLoading = false,
    this.selectedWalletId = '',
    this.selectedCard,
    this.payFromWallet = true,
    this.preview,
    this.previewFailure,
    this.submitFailure,
    this.isSubmitSuccess = false,
    this.submitResult,
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
    PaymentCard? selectedCard,
    bool? payFromWallet,
    bool clearSelectedCard = false,
    ContributionPreviewEntity? preview,
    Failure? previewFailure,
    Failure? submitFailure,
    bool? isSubmitSuccess,
    ContributionSubmitResultModel? submitResult,
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
      selectedCard:
          clearSelectedCard ? null : (selectedCard ?? this.selectedCard),
      payFromWallet: payFromWallet ?? this.payFromWallet,
      preview: clearPreview ? null : (preview ?? this.preview),
      previewFailure: clearPreviewFailure ? null : (previewFailure ?? this.previewFailure),
      submitFailure: clearSubmitFailure ? null : (submitFailure ?? this.submitFailure),
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
      submitResult: submitResult ?? this.submitResult,
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

  double get vestieFee =>
      preview?.platformFee ?? ContributionFeePolicy.platformFee(amountValue);
  String get vestieFeeFormatted => vestieFee.toStringAsFixed(2);
  String get totalDeductionFormatted =>
      (preview?.totalDeduction ?? (amountValue + vestieFee)).toStringAsFixed(2);

  bool get canSubmit => preview != null && !isPreviewLoading && previewFailure == null;

  double get walletBalance => args?.walletBalance ?? 0;

  double get totalDeductionValue =>
      preview?.totalDeduction ?? (amountValue + vestieFee);

  bool walletCovers(double amount) => walletBalance >= amount;

  bool get walletCoversTotal => walletCovers(totalDeductionValue);

  bool get walletCoversContribution => walletCovers(amountValue);

  /// User can pick a card when wallet cannot cover the confirm total.
  bool get canPickPaymentMethod => !walletCoversTotal;

  /// Confirm enabled when terms accepted and wallet covers total, or a card is selected.
  bool get canConfirmSubmit {
    if (preview == null || isPreviewLoading || previewFailure != null) {
      return false;
    }
    if (!nonRefundableAccepted) return false;
    if (payFromWallet) return walletCoversTotal;
    return selectedCard != null;
  }

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
        selectedCard,
        payFromWallet,
        preview,
        previewFailure,
        submitFailure,
        isSubmitSuccess,
        submitResult,
      ];
}
