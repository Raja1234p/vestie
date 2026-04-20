import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/wallet_transaction_type.dart';
import '../../../profile/domain/entities/payment_card.dart';

class WalletTransactionState {
  final WalletTransactionType transactionType;
  final String amountDigits;
  final PaymentCard? selectedCard;

  const WalletTransactionState({
    required this.transactionType,
    this.amountDigits = '',
    this.selectedCard,
  });

  WalletTransactionState copyWith({
    WalletTransactionType? transactionType,
    String? amountDigits,
    PaymentCard? selectedCard,
  }) {
    return WalletTransactionState(
      transactionType: transactionType ?? this.transactionType,
      amountDigits: amountDigits ?? this.amountDigits,
      selectedCard: selectedCard ?? this.selectedCard,
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
    emit(state.copyWith(selectedCard: card));
  }

  void reset() {
    emit(WalletTransactionState(transactionType: state.transactionType));
  }
}
