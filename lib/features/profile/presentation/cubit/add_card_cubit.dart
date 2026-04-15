import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../domain/entities/payment_card.dart';

class AddCardState extends Equatable {
  final String holderName;
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String? holderNameError;
  final String? cardNumberError;
  final String? expiryError;
  final String? cvvError;
  final bool saving;

  const AddCardState({
    this.holderName = '',
    this.cardNumber = '',
    this.expiry = '',
    this.cvv = '',
    this.holderNameError,
    this.cardNumberError,
    this.expiryError,
    this.cvvError,
    this.saving = false,
  });

  AddCardState copyWith({
    String? holderName,
    String? cardNumber,
    String? expiry,
    String? cvv,
    Object? holderNameError = _absent,
    Object? cardNumberError = _absent,
    Object? expiryError = _absent,
    Object? cvvError = _absent,
    bool? saving,
  }) {
    return AddCardState(
      holderName: holderName ?? this.holderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      holderNameError: holderNameError == _absent
          ? this.holderNameError
          : holderNameError as String?,
      cardNumberError: cardNumberError == _absent
          ? this.cardNumberError
          : cardNumberError as String?,
      expiryError:
          expiryError == _absent ? this.expiryError : expiryError as String?,
      cvvError: cvvError == _absent ? this.cvvError : cvvError as String?,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object> get props =>
      [
        holderName,
        cardNumber,
        expiry,
        cvv,
        holderNameError ?? '',
        cardNumberError ?? '',
        expiryError ?? '',
        cvvError ?? '',
        saving,
      ];
}

const Object _absent = Object();

class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit() : super(const AddCardState());

  void setHolderName(String value) {
    emit(state.copyWith(holderName: value, holderNameError: null));
  }

  void setCardNumber(String value) {
    emit(state.copyWith(cardNumber: value, cardNumberError: null));
  }

  void setExpiry(String value) {
    emit(state.copyWith(expiry: value, expiryError: null));
  }

  void setCvv(String value) {
    emit(state.copyWith(cvv: value, cvvError: null));
  }

  bool validate() {
    final holderNameError = ValidationUtils.validateCardHolderName(state.holderName);
    final cardNumberError = ValidationUtils.validateCardNumber(state.cardNumber);
    final expiryError = ValidationUtils.validateCardExpiry(state.expiry);
    final cvvError = ValidationUtils.validateCardCvv(state.cvv);

    emit(
      state.copyWith(
        holderNameError: holderNameError,
        cardNumberError: cardNumberError,
        expiryError: expiryError,
        cvvError: cvvError,
      ),
    );
    return holderNameError == null &&
        cardNumberError == null &&
        expiryError == null &&
        cvvError == null;
  }

  Future<PaymentCard?> save() async {
    if (!validate()) return null;
    emit(state.copyWith(saving: true));
    await Future.delayed(const Duration(milliseconds: 800));

    final digits = state.cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final brand = _detectBrand(digits);
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '0000';

    final card = PaymentCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      holderName: state.holderName.trim(),
      last4: last4,
      maskedNumber: '•••• $last4',
      expiry: state.expiry,
      brand: brand,
    );
    emit(state.copyWith(saving: false));
    return card;
  }

  CardBrand _detectBrand(String digits) {
    if (digits.startsWith('4')) return CardBrand.visa;
    if (digits.length >= 2) {
      final prefix = int.tryParse(digits.substring(0, 2));
      if (prefix != null && prefix >= 51 && prefix <= 55) {
        return CardBrand.mastercard;
      }
    }
    return CardBrand.other;
  }
}
