import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/domain/mock_profile_data.dart';

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
      (_) {
        emit(PaymentMethodsState(
          cards: List.from(MockProfileData.cards),
          loading: false,
          errorMessage: null,
        ));
      },
      (cards) => emit(PaymentMethodsState(cards: cards, loading: false)),
    );
  }

  void addCard(PaymentCard card) {
    emit(state.copyWith(cards: [...state.cards, card]));
  }

  Future<void> removeCard(String id) async {
    final result = await removePaymentMethodUseCase(id);
    result.fold(
      (_) => emit(state.copyWith(
        cards: state.cards.where((c) => c.id != id).toList(),
      )),
      (_) async {
        await load(forceRefresh: true);
      },
    );
  }

  Future<void> setPrimary(String id) async {
    final result = await setPrimaryPaymentMethodUseCase(id);
    result.fold(
      (_) {
        final updated = state.cards
            .map((c) => c.copyWith(isPrimary: c.id == id))
            .toList();
        emit(state.copyWith(cards: updated));
      },
      (_) async {
        await load(forceRefresh: true);
      },
    );
  }
}
