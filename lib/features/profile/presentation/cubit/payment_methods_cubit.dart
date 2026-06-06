import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

class PaymentMethodsState extends Equatable {
  final List<PaymentCard> cards;
  final bool loading;
  final bool addingCard;
  final String? settingPrimaryCardId;
  final String? removingCardId;
  final String? errorMessage;

  const PaymentMethodsState({
    this.cards = const [],
    this.loading = false,
    this.addingCard = false,
    this.settingPrimaryCardId,
    this.removingCardId,
    this.errorMessage,
  });

  PaymentMethodsState copyWith({
    List<PaymentCard>? cards,
    bool? loading,
    bool? addingCard,
    String? settingPrimaryCardId,
    bool clearSettingPrimary = false,
    String? removingCardId,
    bool clearRemovingCard = false,
    String? errorMessage,
    bool clearError = false,
  }) => PaymentMethodsState(
    cards: cards ?? this.cards,
    loading: loading ?? this.loading,
    addingCard: addingCard ?? this.addingCard,
    settingPrimaryCardId: clearSettingPrimary
        ? null
        : (settingPrimaryCardId ?? this.settingPrimaryCardId),
    removingCardId: clearRemovingCard
        ? null
        : (removingCardId ?? this.removingCardId),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    cards,
    loading,
    addingCard,
    settingPrimaryCardId,
    removingCardId,
    errorMessage,
  ];
}

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  final ListPaymentMethodsUseCase listPaymentMethodsUseCase;
  final SavePaymentCardViaSetupUseCase savePaymentCardViaSetupUseCase;
  final SetPrimaryPaymentMethodUseCase setPrimaryPaymentMethodUseCase;
  final RemovePaymentMethodUseCase removePaymentMethodUseCase;

  PaymentMethodsCubit({
    required this.listPaymentMethodsUseCase,
    required this.savePaymentCardViaSetupUseCase,
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
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (cards) => emit(PaymentMethodsState(cards: cards, loading: false)),
    );
  }

  void addCard(PaymentCard card) {
    emit(state.copyWith(cards: [...state.cards, card], clearError: true));
  }

  /// SetupIntent + PaymentSheet in place (no navigation).
  /// Returns `null` on success, or a user-facing error message on failure.
  Future<String?> addCardViaStripe({
    Future<void> Function()? onBeforePresentPaymentSheet,
  }) async {
    if (state.addingCard) return AppStrings.addCardStripeFailed;

    emit(state.copyWith(addingCard: true, clearError: true));

    final result = await savePaymentCardViaSetupUseCase(
      onBeforePresentPaymentSheet: onBeforePresentPaymentSheet,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(addingCard: false));
        return FailureMapper.userMessage(failure);
      },
      (card) {
        emit(
          state.copyWith(
            cards: [...state.cards, card],
            addingCard: false,
            clearError: true,
          ),
        );
        return null;
      },
    );
  }

  /// Returns `null` on success, or a user-facing error for toast.
  Future<String?> removeCard(String id) async {
    emit(state.copyWith(removingCardId: id, clearError: true));
    final result = await removePaymentMethodUseCase(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(clearRemovingCard: true));
        return FailureMapper.userMessage(failure);
      },
      (_) {
        emit(
          state.copyWith(
            cards: state.cards.where((c) => c.id != id).toList(),
            clearRemovingCard: true,
            clearError: true,
          ),
        );
        return null;
      },
    );
  }

  /// Returns `null` on success, or a user-facing error for toast.
  Future<String?> setPrimary(String id, {required bool isPrimary}) async {
    emit(state.copyWith(settingPrimaryCardId: id, clearError: true));
    final result = await setPrimaryPaymentMethodUseCase(
      id,
      isPrimary: isPrimary,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(clearSettingPrimary: true));
        return FailureMapper.userMessage(failure);
      },
      (_) {
        emit(
          state.copyWith(
            cards: [
              for (final card in state.cards)
                if (isPrimary)
                  card.copyWith(isPrimary: card.id == id)
                else if (card.id == id)
                  card.copyWith(isPrimary: false)
                else
                  card,
            ],
            clearSettingPrimary: true,
            clearError: true,
          ),
        );
        return null;
      },
    );
  }
}
