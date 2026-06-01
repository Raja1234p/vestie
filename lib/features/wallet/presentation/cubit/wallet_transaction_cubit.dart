import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/payment_card.dart';
import '../../domain/wallet_transaction_type.dart';
import '../../domain/withdraw_delivery_method.dart';

class WalletTransactionState {
  final WalletTransactionType transactionType;
  final String amountDigits;
  final PaymentCard? selectedCard;
  final bool payFromWallet;
  final WithdrawDeliveryMethod? withdrawDeliveryMethod;
  final String? selectedBankAccountId;
  final String? selectedBankDisplayName;

  const WalletTransactionState({
    required this.transactionType,
    this.amountDigits = '',
    this.selectedCard,
    this.payFromWallet = false,
    this.withdrawDeliveryMethod,
    this.selectedBankAccountId,
    this.selectedBankDisplayName,
  });

  WalletTransactionState copyWith({
    WalletTransactionType? transactionType,
    String? amountDigits,
    PaymentCard? selectedCard,
    bool? payFromWallet,
    WithdrawDeliveryMethod? withdrawDeliveryMethod,
    String? selectedBankAccountId,
    String? selectedBankDisplayName,
    bool clearSelectedCard = false,
    bool clearBankAccount = false,
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
    );
  }

  double get amountParsed {
    if (amountDigits.isEmpty) return 0.0;
    return int.parse(amountDigits) / 100.0;
  }

  String get formattedAmount {
    return '\$${amountParsed.toStringAsFixed(2)}';
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

  /// Default instant rail before the user opens the method picker.
  void prepareWithdrawMethodSelection() {
    emit(state.copyWith(
      withdrawDeliveryMethod: WithdrawDeliveryMethod.instant,
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
    ));
  }

  void reset() {
    emit(WalletTransactionState(transactionType: state.transactionType));
  }
}
