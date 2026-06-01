import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

class PaymentMethodsState extends Equatable {
  final List<PaymentCard> cards;
  final bool loading;
  final String? errorMessage;

  const PaymentMethodsState({
    this.cards = const [],
    this.loading = false,
    this.errorMessage,
  });

  PaymentMethodsState copyWith({
    List<PaymentCard>? cards,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      PaymentMethodsState(
        cards: cards ?? this.cards,
        loading: loading ?? this.loading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [cards, loading, errorMessage];
}

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  final ListPaymentMethodsUseCase listPaymentMethodsUseCase;
  final SetPrimaryPaymentMethodUseCase setPrimaryPaymentMethodUseCase;
  final RemovePaymentMethodUseCase removePaymentMethodUseCase;

  PaymentMethodsCubit({
    required this.listPaymentMethodsUseCase,
    required this.setPrimaryPaymentMethodUseCase,
    required this.removePaymentMethodUseCase,
  }) : super(const PaymentMethodsState(loading: true)) {
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await listPaymentMethodsUseCase(forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(
        PaymentMethodsState(
          loading: false,
          errorMessage: failure.message,
        ),
      ),
      (cards) => emit(PaymentMethodsState(cards: cards, loading: false)),
    );
  }

  void addCard(PaymentCard card) {
    emit(state.copyWith(cards: [...state.cards, card], clearError: true));
  }

  Future<bool> removeCard(String id) async {
    emit(state.copyWith(clearError: true));
    final result = await removePaymentMethodUseCase(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            cards: state.cards.where((c) => c.id != id).toList(),
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> setPrimary(String id) async {
    emit(state.copyWith(clearError: true));
    final result = await setPrimaryPaymentMethodUseCase(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (_) async {
        await load(forceRefresh: true);
        return true;
      },
    );
  }
}
