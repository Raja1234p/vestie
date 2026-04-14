import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_card.dart';

enum CardField { holderName, cardNumber, expiry, cvv }

class AddCardState extends Equatable {
  final String holderName;
  final String cardNumber; // raw digits max 16
  final String expiry;     // raw digits max 4 (MMYY)
  final String cvv;        // raw digits max 3
  final CardField activeField;
  final bool saving;
  final bool saved;

  const AddCardState({
    this.holderName = '',
    this.cardNumber = '',
    this.expiry = '',
    this.cvv = '',
    this.activeField = CardField.cardNumber,
    this.saving = false,
    this.saved = false,
  });

  AddCardState copyWith({
    String? holderName, String? cardNumber, String? expiry, String? cvv,
    CardField? activeField, bool? saving, bool? saved,
  }) {
    return AddCardState(
      holderName: holderName ?? this.holderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      activeField: activeField ?? this.activeField,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
    );
  }

  String get formattedCardNumber {
    final d = cardNumber.padRight(16, ' ');
    return '${d.substring(0,4)} ${d.substring(4,8)} ${d.substring(8,12)} ${d.substring(12,16)}'.trimRight();
  }

  String get formattedExpiry {
    if (expiry.length <= 2) return expiry;
    return '${expiry.substring(0, 2)}/${expiry.substring(2)}';
  }

  @override
  List<Object> get props =>
      [holderName, cardNumber, expiry, cvv, activeField, saving, saved];
}

class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit() : super(const AddCardState());

  void setActive(CardField field) => emit(state.copyWith(activeField: field));
  void setHolderName(String v)    => emit(state.copyWith(holderName: v));

  void appendDigit(String digit) {
    switch (state.activeField) {
      case CardField.cardNumber:
        if (state.cardNumber.length < 16) {
          emit(state.copyWith(cardNumber: state.cardNumber + digit));
        }
        break;
      case CardField.expiry:
        if (state.expiry.length < 4) {
          emit(state.copyWith(expiry: state.expiry + digit));
        }
        break;
      case CardField.cvv:
        if (state.cvv.length < 3) {
          emit(state.copyWith(cvv: state.cvv + digit));
        }
        break;
      case CardField.holderName: break;
    }
  }

  void backspace() {
    switch (state.activeField) {
      case CardField.cardNumber:
        if (state.cardNumber.isNotEmpty) {
          emit(state.copyWith(cardNumber: state.cardNumber.substring(0, state.cardNumber.length - 1)));
        }
        break;
      case CardField.expiry:
        if (state.expiry.isNotEmpty) {
          emit(state.copyWith(expiry: state.expiry.substring(0, state.expiry.length - 1)));
        }
        break;
      case CardField.cvv:
        if (state.cvv.isNotEmpty) {
          emit(state.copyWith(cvv: state.cvv.substring(0, state.cvv.length - 1)));
        }
        break;
      case CardField.holderName: break;
    }
  }

  Future<PaymentCard?> save() async {
    emit(state.copyWith(saving: true));
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: Replace with PaymentRepository.addCard(...)
    final card = PaymentCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      holderName: state.holderName,
      last4: state.cardNumber.length >= 4
          ? state.cardNumber.substring(state.cardNumber.length - 4)
          : '0000',
      maskedNumber: '•••• ${state.cardNumber.length >= 4 ? state.cardNumber.substring(state.cardNumber.length - 4) : '0000'}',
      expiry: state.formattedExpiry,
      brand: CardBrand.visa,
    );
    emit(state.copyWith(saving: false, saved: true));
    return card;
  }
}
