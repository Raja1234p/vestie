import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/formatters.dart';

import '../../../profile/domain/entities/payment_card.dart';
import '../../domain/wallet_transaction_type.dart';
import '../../domain/wallet_withdraw_policy.dart';
import 'package:vestie/core/utils/wallet_withdraw_validation.dart';
import '../../domain/withdraw_delivery_method.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_processing_fee_entity.dart';

class WalletTransactionState {
  final WalletTransactionType transactionType;
  final String amountDigits;
  final PaymentCard? selectedCard;
  final bool payFromWallet;
  final WithdrawDeliveryMethod? withdrawDeliveryMethod;
  final String? selectedBankAccountId;
  final String? selectedBankDisplayName;
  final double? withdrawYouWillReceive;
  final StripeProcessingFeeEntity? depositProcessingFee;

  const WalletTransactionState({
    required this.transactionType,
    this.amountDigits = '',
    this.selectedCard,
    this.payFromWallet = false,
    this.withdrawDeliveryMethod,
    this.selectedBankAccountId,
    this.selectedBankDisplayName,
    this.withdrawYouWillReceive,
    this.depositProcessingFee,
  });

  WalletTransactionState copyWith({
    WalletTransactionType? transactionType,
    String? amountDigits,
    PaymentCard? selectedCard,
    bool? payFromWallet,
    WithdrawDeliveryMethod? withdrawDeliveryMethod,
    String? selectedBankAccountId,
    String? selectedBankDisplayName,
    double? withdrawYouWillReceive,
    StripeProcessingFeeEntity? depositProcessingFee,
    bool clearSelectedCard = false,
    bool clearBankAccount = false,
    bool clearWithdrawYouWillReceive = false,
    bool clearDepositProcessingFee = false,
  }) {
    return WalletTransactionState(
      transactionType: transactionType ?? this.transactionType,
      amountDigits: amountDigits ?? this.amountDigits,
      selectedCard:
          clearSelectedCard ? null : (selectedCard ?? this.selectedCard),
      payFromWallet: payFromWallet ?? this.payFromWallet,
      withdrawDeliveryMethod:
          withdrawDeliveryMethod ?? this.withdrawDeliveryMethod,
      selectedBankAccountId: clearBankAccount
          ? null
          : (selectedBankAccountId ?? this.selectedBankAccountId),
      selectedBankDisplayName: clearBankAccount
          ? null
          : (selectedBankDisplayName ?? this.selectedBankDisplayName),
      withdrawYouWillReceive: clearWithdrawYouWillReceive
          ? null
          : (withdrawYouWillReceive ?? this.withdrawYouWillReceive),
      depositProcessingFee: clearDepositProcessingFee
          ? null
          : (depositProcessingFee ?? this.depositProcessingFee),
    );
  }

  double get amountParsed {
    if (amountDigits.isEmpty) return 0.0;
    return int.parse(amountDigits) / 100.0;
  }

  String get formattedAmount {
    return '\$${amountParsed.toStringAsFixed(2)}';
  }

  /// Net wallet credit from Stripe processing-fee API (not a client %).
  String get formattedDepositNetCredit {
    final net = depositProcessingFee?.netAmount ?? 0;
    return AppFormatters.formatCurrency(net);
  }

  /// Net bank payout — matches confirm "You will receive" row.
  String get formattedWithdrawYouWillReceive => AppFormatters.formatCurrency(
    withdrawYouWillReceive ??
        WalletWithdrawPolicy.netReceive(
          amountParsed,
          withdrawDeliveryMethod ?? WithdrawDeliveryMethod.standard,
        ),
  );

  bool get canConfirmDeposit {
    if (payFromWallet) return false;
    final cardId = selectedCard?.id.trim() ?? '';
    return cardId.isNotEmpty;
  }

  String? get depositValidationMessage {
    if (canConfirmDeposit) return null;
    return AppStrings.depositSelectCardRequired;
  }

  bool get canConfirmWithdraw {
    final bankId = selectedBankAccountId?.trim() ?? '';
    if (bankId.isEmpty) return false;
    return WalletWithdrawValidation.validateForWithdraw(amountParsed) == null;
  }

  String? get withdrawValidationMessage {
    if (canConfirmWithdraw) return null;
    final balanceErr =
        WalletWithdrawValidation.validateForWithdraw(amountParsed);
    if (balanceErr != null) return balanceErr;
    return AppStrings.withdrawSelectBankRequired;
  }
}

class WalletTransactionCubit extends Cubit<WalletTransactionState> {
  WalletTransactionCubit({
    WalletTransactionType initialType = WalletTransactionType.deposit,
  }) : super(WalletTransactionState(transactionType: initialType));

  void setTransactionType(WalletTransactionType type) {
    emit(state.copyWith(transactionType: type));
  }

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

  void appendAmountDigit(String digit) {
    if (state.amountDigits.length >= 8) return; // Prevent massive numbers
    // Prevent leading zero if it's the only character
    if (state.amountDigits.isEmpty && digit == '0') return;

    emit(state.copyWith(amountDigits: state.amountDigits + digit));
  }

  void removeAmountDigit() {
    if (state.amountDigits.isEmpty) return;
    emit(state.copyWith(
      amountDigits: state.amountDigits.substring(0, state.amountDigits.length - 1),
    ));
  }

  void selectCard(PaymentCard card) {
    emit(state.copyWith(selectedCard: card, payFromWallet: false));
  }

  void selectWallet() {
    emit(state.copyWith(clearSelectedCard: true, payFromWallet: true));
  }

  /// Default standard rail before the user opens the method picker.
  void prepareWithdrawMethodSelection() {
    emit(state.copyWith(
      withdrawDeliveryMethod: WithdrawDeliveryMethod.standard,
    ));
  }

  void setWithdrawDeliveryMethod(WithdrawDeliveryMethod method) {
    emit(state.copyWith(withdrawDeliveryMethod: method));
  }

  void selectBankAccount({
    required String bankAccountId,
    required String displayName,
  }) {
    emit(state.copyWith(
      selectedBankAccountId: bankAccountId,
      selectedBankDisplayName: displayName,
      clearSelectedCard: true,
      payFromWallet: false,
      clearWithdrawYouWillReceive: true,
    ));
  }

  /// Set from confirm fee preview / actual Stripe fee before success.
  void setDepositProcessingFee(StripeProcessingFeeEntity? fee) {
    emit(state.copyWith(
      depositProcessingFee: fee,
      clearDepositProcessingFee: fee == null,
    ));
  }

  /// Set from confirm preview before navigating to withdraw success.
  void setWithdrawYouWillReceive(double amount) {
    emit(state.copyWith(withdrawYouWillReceive: amount));
  }

  void reset() {
    emit(WalletTransactionState(transactionType: state.transactionType));
  }
}
