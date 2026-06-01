import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/utils/validation_utils.dart';
import 'package:vestie/features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

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
  final String? saveError;

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
    this.saveError,
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
    String? saveError,
    bool clearSaveError = false,
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
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }

  @override
  List<Object?> get props => [
        holderName,
        cardNumber,
        expiry,
        cvv,
        holderNameError ?? '',
        cardNumberError ?? '',
        expiryError ?? '',
        cvvError ?? '',
        saving,
        saveError ?? '',
      ];
}

const Object _absent = Object();

class AddCardCubit extends Cubit<AddCardState> {
  final SavePaymentCardUseCase savePaymentCardUseCase;
  final SavePaymentCardViaSetupUseCase savePaymentCardViaSetupUseCase;

  AddCardCubit({
    required this.savePaymentCardUseCase,
    required this.savePaymentCardViaSetupUseCase,
  }) : super(const AddCardState());

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
    final holderNameError =
        ValidationUtils.validateCardHolderName(state.holderName);
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
    if (kDebugMode) {
      if (!validate()) return null;
    }
    emit(state.copyWith(saving: true, clearSaveError: true));

    final result = kDebugMode
        ? await savePaymentCardUseCase(
            holderName: state.holderName,
            cardNumber: state.cardNumber,
            expiry: state.expiry,
            cvv: state.cvv,
          )
        : await savePaymentCardViaSetupUseCase();

    return result.fold(
      (failure) {
        emit(state.copyWith(saving: false, saveError: failure.message));
        return null;
      },
      (card) {
        emit(state.copyWith(saving: false));
        return card;
      },
    );
  }
}
