import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_card.dart';
import '../../domain/mock_profile_data.dart';

class PaymentMethodsState extends Equatable {
  final List<PaymentCard> cards;
  final bool loading;

  const PaymentMethodsState({this.cards = const [], this.loading = false});

  PaymentMethodsState copyWith({List<PaymentCard>? cards, bool? loading}) =>
      PaymentMethodsState(
          cards: cards ?? this.cards, loading: loading ?? this.loading);

  @override
  List<Object> get props => [cards, loading];
}

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit() : super(const PaymentMethodsState(loading: true)) {
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with PaymentRepository.getCards()
    emit(PaymentMethodsState(cards: List.from(MockProfileData.cards)));
  }

  void addCard(PaymentCard card) {
    emit(state.copyWith(cards: [...state.cards, card]));
  }

  void removeCard(String id) {
    emit(state.copyWith(
        cards: state.cards.where((c) => c.id != id).toList()));
  }

  void setPrimary(String id) {
    final updated = state.cards.map((c) => c.copyWith(isPrimary: c.id == id)).toList();
    emit(state.copyWith(cards: updated));
  }
}
